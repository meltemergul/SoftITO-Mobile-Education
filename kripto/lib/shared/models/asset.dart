import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';

class Asset {
  final String id;
  final String symbol;
  final String name;
  final String coingeckoId;
  final String? imageUrl;
  final int? marketCapRank;

  const Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.coingeckoId,
    this.imageUrl,
    this.marketCapRank,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      coingeckoId: json['coingecko_id'] as String,
      imageUrl: json['image_url'] as String?,
      marketCapRank: json['market_cap_rank'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'coingecko_id': coingeckoId,
      'image_url': imageUrl,
      'market_cap_rank': marketCapRank,
    };
  }

  static const List<Asset> defaultAssets = [
    Asset(id: 'btc-asset', symbol: 'BTC', name: 'Bitcoin', coingeckoId: 'bitcoin', marketCapRank: 1),
    Asset(id: 'eth-asset', symbol: 'ETH', name: 'Ethereum', coingeckoId: 'ethereum', marketCapRank: 2),
    Asset(id: 'sol-asset', symbol: 'SOL', name: 'Solana', coingeckoId: 'solana', marketCapRank: 3),
    Asset(id: 'bnb-asset', symbol: 'BNB', name: 'BNB', coingeckoId: 'binancecoin', marketCapRank: 4),
    Asset(id: 'xrp-asset', symbol: 'XRP', name: 'XRP', coingeckoId: 'ripple', marketCapRank: 5),
    Asset(id: 'doge-asset', symbol: 'DOGE', name: 'Dogecoin', coingeckoId: 'dogecoin', marketCapRank: 6),
    Asset(id: 'ada-asset', symbol: 'ADA', name: 'Cardano', coingeckoId: 'cardano', marketCapRank: 7),
    Asset(id: 'avax-asset', symbol: 'AVAX', name: 'Avalanche', coingeckoId: 'avalanche-2', marketCapRank: 8),
  ];
}

final assetsProvider = FutureProvider<List<Asset>>((ref) async {
  final client = SupabaseService.client;
  if (client == null) {
    return Asset.defaultAssets;
  }

  try {
    final response = await client
        .from('assets')
        .select('id, symbol, name, coingecko_id, image_url, market_cap_rank')
        .order('market_cap_rank', ascending: true);

    final list = (response as List<dynamic>)
        .map((e) => Asset.fromJson(e as Map<String, dynamic>))
        .toList();

    return list.isNotEmpty ? list : Asset.defaultAssets;
  } catch (_) {
    return Asset.defaultAssets;
  }
});
