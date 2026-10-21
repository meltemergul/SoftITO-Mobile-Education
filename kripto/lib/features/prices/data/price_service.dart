import 'dart:convert';
import 'dart:io';
import 'package:decimal/decimal.dart';
import '../../../core/errors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/asset.dart';
import '../domain/price_info.dart';

class PriceService {
  final HttpClient _httpClient;

  PriceService({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient() {
    _httpClient.connectionTimeout = const Duration(seconds: 10);
  }

  /// Tüm desteklenen kriptoların güncel canlı piyasa verilerini CoinGecko'dan çeker.
  Future<List<PriceInfo>> fetchPrices({List<Asset>? customAssets}) async {
    List<Asset> targetAssets = customAssets ?? Asset.defaultAssets;

    // Supabase bağlıysa veritabanındaki aktif varlıkları da listeye dahil et
    final client = SupabaseService.client;
    if (client != null && customAssets == null) {
      try {
        final response = await client
            .from('assets')
            .select('id, symbol, name, coingecko_id, market_cap_rank')
            .order('market_cap_rank', ascending: true);

        if (response.isNotEmpty) {
          final dbAssets = response
              .map((e) => Asset.fromJson(e))
              .toList();

          // Birleştir (defaultAssets + dbAssets)
          final Map<String, Asset> merged = {};
          for (final a in Asset.defaultAssets) {
            merged[a.coingeckoId.toLowerCase()] = a;
          }
          for (final a in dbAssets) {
            merged[a.coingeckoId.toLowerCase()] = a;
          }
          targetAssets = merged.values.toList();
        }
      } catch (_) {
        // Tablo henüz yoksa defaultAssets ile devam et
      }
    }

    // 1. Varsa Supabase Edge Function dene
    if (client != null) {
      try {
        final response = await client.functions.invoke('get-prices');
        if (response.status == 200 && response.data is List) {
          final data = response.data as List;
          if (data.isNotEmpty) {
            return _expandPriceKeys(
              data.map((item) => PriceInfo.fromJson(item as Map<String, dynamic>)).toList(),
              targetAssets,
            );
          }
        }
      } catch (_) {
        // Edge function yoksa doğrudan CoinGecko Free API'ye geç
      }
    }

    // 2. Doğrudan CoinGecko v3 Simple Price API (Anlık)
    return await _fetchDirectFromCoinGecko(targetAssets);
  }

  /// CoinGecko v3 Simple Price Free Plan API
  Future<List<PriceInfo>> _fetchDirectFromCoinGecko(List<Asset> assets) async {
    final ids = assets.map((a) => a.coingeckoId).toSet().join(',');
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price'
      '?ids=$ids&vs_currencies=usd,try&include_24hr_change=true',
    );

    try {
      final request = await _httpClient.getUrl(url);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'ChronomindPortfolio/1.0 (Flutter)');

      final response = await request.close();

      if (response.statusCode == 429) {
        throw const RateLimitError('CoinGecko istek limiti aşıldı (ücretsiz plan). Lütfen biraz bekleyin.');
      }

      if (response.statusCode != 200) {
        throw NetworkError('CoinGecko API yanıt vermedi (${response.statusCode})');
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final now = DateTime.now().toUtc();
      final results = <PriceInfo>[];
      final upsertRows = <Map<String, dynamic>>[];

      for (final asset in assets) {
        final coinData = data[asset.coingeckoId] as Map<String, dynamic>?;
        if (coinData == null) continue;

        // USD Fiyatı
        if (coinData['usd'] != null) {
          final p = Decimal.parse(coinData['usd'].toString());
          final c = coinData['usd_24h_change'] != null
              ? Decimal.parse(coinData['usd_24h_change'].toString())
              : null;

          _addPriceWithAliases(results, asset, 'USD', p, c, now);

          upsertRows.add({
            'asset_id': asset.id,
            'currency': 'USD',
            'price': p.toDouble(),
            'change_24h': c?.toDouble() ?? 0.0,
            'fetched_at': now.toIso8601String(),
          });
        }

        // TRY Fiyatı
        if (coinData['try'] != null) {
          final p = Decimal.parse(coinData['try'].toString());
          final c = coinData['try_24h_change'] != null
              ? Decimal.parse(coinData['try_24h_change'].toString())
              : null;

          _addPriceWithAliases(results, asset, 'TRY', p, c, now);

          upsertRows.add({
            'asset_id': asset.id,
            'currency': 'TRY',
            'price': p.toDouble(),
            'change_24h': c?.toDouble() ?? 0.0,
            'fetched_at': now.toIso8601String(),
          });
        }
      }

      // Supabase bağlıysa önbellek tablosuna da asenkron kaydet
      _cacheToSupabase(upsertRows);

      if (results.isNotEmpty) {
        return results;
      }

      return _getDemoPrices();
    } on SocketException catch (e) {
      throw NetworkError('İnternet bağlantısı kurulamadı.', e);
    } catch (e) {
      if (e is AppException) rethrow;
      return _getDemoPrices();
    }
  }

  /// Tüm eşleşmelerin (UUID, coingeckoId, symbol, symbol-asset) bulunabilmesi için
  /// fiyat nesnesini tüm geçerli anahtarlarla listeye ekler.
  void _addPriceWithAliases(
    List<PriceInfo> list,
    Asset asset,
    String currency,
    Decimal price,
    Decimal? change24h,
    DateTime fetchedAt,
  ) {
    final keys = {
      asset.id,
      asset.coingeckoId,
      asset.symbol.toLowerCase(),
      '${asset.symbol.toLowerCase()}-asset',
    };

    for (final key in keys) {
      list.add(PriceInfo(
        assetId: key,
        currency: currency,
        price: price,
        change24h: change24h,
        fetchedAt: fetchedAt,
      ));
    }
  }

  List<PriceInfo> _expandPriceKeys(List<PriceInfo> source, List<Asset> assets) {
    final Map<String, Asset> byCg = {for (final a in assets) a.coingeckoId.toLowerCase(): a};
    final Map<String, Asset> byId = {for (final a in assets) a.id.toLowerCase(): a};
    final results = <PriceInfo>[...source];

    for (final item in source) {
      final a = byId[item.assetId.toLowerCase()] ?? byCg[item.assetId.toLowerCase()];
      if (a != null) {
        results.add(PriceInfo(
          assetId: a.coingeckoId,
          currency: item.currency,
          price: item.price,
          change24h: item.change24h,
          fetchedAt: item.fetchedAt,
        ));
        results.add(PriceInfo(
          assetId: '${a.symbol.toLowerCase()}-asset',
          currency: item.currency,
          price: item.price,
          change24h: item.change24h,
          fetchedAt: item.fetchedAt,
        ));
      }
    }
    return results;
  }

  void _cacheToSupabase(List<Map<String, dynamic>> rows) async {
    final client = SupabaseService.client;
    if (client == null || rows.isEmpty) return;
    try {
      await client.from('price_cache').upsert(rows, onConflict: 'asset_id,currency');
    } catch (_) {
      // Tablo henüz açılmamışsa veya RLS kısıtlaması varsa sessizce geç
    }
  }

  List<PriceInfo> _getDemoPrices() {
    final now = DateTime.now().toUtc();
    final demoList = <PriceInfo>[];
    for (final a in Asset.defaultAssets) {
      final (pUsd, pTry, change) = switch (a.symbol) {
        'BTC' => (Decimal.parse('84476.00'), Decimal.parse('4189950.00'), Decimal.parse('2.15')),
        'ETH' => (Decimal.parse('2509.86'), Decimal.parse('124488.00'), Decimal.parse('2.50')),
        'SOL' => (Decimal.parse('108.28'), Decimal.parse('5370.55'), Decimal.parse('1.75')),
        'BNB' => (Decimal.parse('749.68'), Decimal.parse('37184.00'), Decimal.parse('1.80')),
        'XRP' => (Decimal.parse('1.38'), Decimal.parse('68.47'), Decimal.parse('3.98')),
        'DOGE' => (Decimal.parse('0.14'), Decimal.parse('6.95'), Decimal.parse('1.20')),
        'ADA' => (Decimal.parse('0.228'), Decimal.parse('11.31'), Decimal.parse('2.30')),
        'AVAX' => (Decimal.parse('9.89'), Decimal.parse('490.53'), Decimal.parse('2.48')),
        _ => (Decimal.parse('1.00'), Decimal.parse('50.00'), Decimal.zero),
      };

      _addPriceWithAliases(demoList, a, 'USD', pUsd, change, now);
      _addPriceWithAliases(demoList, a, 'TRY', pTry, change, now);
    }
    return demoList;
  }
}
