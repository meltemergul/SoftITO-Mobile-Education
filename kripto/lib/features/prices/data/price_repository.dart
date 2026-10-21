import '../../../core/constants.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/price_info.dart';
import 'price_service.dart';

class PriceRepository {
  final PriceService _priceService;
  List<PriceInfo> _lastKnownPrices = [];

  PriceRepository(this._priceService);

  List<PriceInfo> get lastKnownPrices => List.unmodifiable(_lastKnownPrices);

  Future<List<PriceInfo>> getCachedPrices() async {
    final client = SupabaseService.client;
    if (client == null) {
      if (_lastKnownPrices.isEmpty) {
        _lastKnownPrices = await _priceService.fetchPricesFromEdgeFunction();
      }
      return _lastKnownPrices;
    }

    try {
      final response = await client
          .from('price_cache')
          .select('asset_id, currency, price, change_24h, fetched_at');

      final prices = (response as List<dynamic>)
          .map((e) => PriceInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      if (prices.isNotEmpty) {
        // Önbellek tazeliğini kontrol et
        final now = DateTime.now().toUtc();
        final ttlSeconds = AppConstants.defaultPriceTtlSeconds;
        final isFresh = prices.every((p) =>
            now.difference(p.fetchedAt.toUtc()).inSeconds < ttlSeconds);

        if (isFresh) {
          _lastKnownPrices = prices;
          return prices;
        }
      }

      // Önbellek boş veya eskiyse Edge Function'dan yenile
      final refreshed = await _priceService.fetchPricesFromEdgeFunction();
      if (refreshed.isNotEmpty) {
        _lastKnownPrices = refreshed;
        return refreshed;
      }
    } catch (_) {
      // Ağ hatası veya istisna durumunda son bilinen fiyatları koru
      if (_lastKnownPrices.isNotEmpty) {
        return _lastKnownPrices;
      }
    }

    return _lastKnownPrices;
  }

  Future<List<PriceInfo>> refreshPrices() async {
    try {
      final refreshed = await _priceService.fetchPricesFromEdgeFunction();
      if (refreshed.isNotEmpty) {
        _lastKnownPrices = refreshed;
        return refreshed;
      }
    } catch (_) {
      // Ağ hatasında son bilinen fiyatları döndür (ekran boş kalmaz)
      if (_lastKnownPrices.isNotEmpty) {
        return _lastKnownPrices;
      }
      rethrow;
    }
    return _lastKnownPrices;
  }
}
