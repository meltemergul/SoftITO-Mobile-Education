import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/price_info.dart';

class PriceService {
  Future<List<PriceInfo>> fetchPricesFromEdgeFunction() async {
    final client = SupabaseService.client;
    if (client == null) {
      // Demo / Yerel geliştirme durumunda örnek canlı fiyatlar döner
      return _getDemoPrices();
    }

    try {
      final response = await client.functions.invoke('get-prices');

      if (response.status == 429) {
        throw const RateLimitError('Fiyat istek limiti aşıldı.');
      }

      if (response.status != 200) {
        throw NetworkError('Fiyat servisi yanıt vermedi (${response.status})');
      }

      final data = response.data;
      if (data is List) {
        return data
            .map((item) => PriceInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on SocketException catch (e) {
      throw NetworkError('İnternet bağlantısı kurulamadı.', e);
    } on FunctionException catch (e) {
      if (e.status == 429) {
        throw RateLimitError(e.details?.toString() ?? 'Limit aşıldı.', e);
      }
      throw NetworkError(e.details?.toString() ?? 'Fiyat fonksiyonu çağrılamadı.', e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownError('Fiyatlar güncellenirken bir hata oluştu.', e);
    }
  }

  List<PriceInfo> _getDemoPrices() {
    final now = DateTime.now().toUtc();
    return [
      PriceInfo(
        assetId: 'btc-asset',
        currency: 'USD',
        price: Decimal.parse('96450.00'),
        change24h: Decimal.parse('2.34'),
        fetchedAt: now,
      ),
      PriceInfo(
        assetId: 'btc-asset',
        currency: 'TRY',
        price: Decimal.parse('3320000.00'),
        change24h: Decimal.parse('2.41'),
        fetchedAt: now,
      ),
      PriceInfo(
        assetId: 'eth-asset',
        currency: 'USD',
        price: Decimal.parse('3420.50'),
        change24h: Decimal.parse('-1.12'),
        fetchedAt: now,
      ),
      PriceInfo(
        assetId: 'eth-asset',
        currency: 'TRY',
        price: Decimal.parse('117800.00'),
        change24h: Decimal.parse('-1.05'),
        fetchedAt: now,
      ),
      PriceInfo(
        assetId: 'sol-asset',
        currency: 'USD',
        price: Decimal.parse('194.20'),
        change24h: Decimal.parse('5.67'),
        fetchedAt: now,
      ),
      PriceInfo(
        assetId: 'sol-asset',
        currency: 'TRY',
        price: Decimal.parse('6690.00'),
        change24h: Decimal.parse('5.80'),
        fetchedAt: now,
      ),
    ];
  }
}
