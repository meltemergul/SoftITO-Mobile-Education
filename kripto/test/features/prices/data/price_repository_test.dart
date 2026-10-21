import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronomind/features/prices/data/price_repository.dart';
import 'package:chronomind/features/prices/data/price_service.dart';
import 'package:chronomind/features/prices/domain/price_info.dart';

class MockPriceService extends PriceService {
  int fetchCallCount = 0;
  List<PriceInfo> stubbedPrices = [];
  bool shouldThrow = false;

  @override
  Future<List<PriceInfo>> fetchPricesFromEdgeFunction() async {
    fetchCallCount++;
    if (shouldThrow) {
      throw Exception('Ağ hatası: Sunucuya ulaşılamıyor');
    }
    return stubbedPrices;
  }
}

void main() {
  group('PriceRepository Testleri', () {
    late MockPriceService mockService;
    late PriceRepository repository;

    setUp(() {
      mockService = MockPriceService();
      repository = PriceRepository(mockService);
    });

    test('1. İlk çağrıda fiyatları çeker ve önbelleğe alır', () async {
      final now = DateTime.now().toUtc();
      mockService.stubbedPrices = [
        PriceInfo(
          assetId: 'btc-1',
          currency: 'USD',
          price: Decimal.parse('95000'),
          change24h: Decimal.parse('1.5'),
          fetchedAt: now,
        ),
      ];

      final prices = await repository.getCachedPrices();

      expect(prices.length, 1);
      expect(prices.first.price, Decimal.parse('95000'));
      expect(mockService.fetchCallCount, 1);
      expect(repository.lastKnownPrices.length, 1);
    });

    test('2. Ağ hatasında son bilinen fiyatları korur (ekran boş kalmaz)', () async {
      final now = DateTime.now().toUtc();
      mockService.stubbedPrices = [
        PriceInfo(
          assetId: 'btc-1',
          currency: 'USD',
          price: Decimal.parse('95000'),
          change24h: Decimal.parse('1.5'),
          fetchedAt: now,
        ),
      ];

      // İlk başarılı çekim
      await repository.getCachedPrices();
      expect(repository.lastKnownPrices.length, 1);

      // İkinci çağrıda ağ kopuyor
      mockService.shouldThrow = true;
      final cachedFallback = await repository.getCachedPrices();

      // Son bilinen fiyat korunmalı
      expect(cachedFallback.length, 1);
      expect(cachedFallback.first.price, Decimal.parse('95000'));
    });

    test('3. refreshPrices çağrısı hata verse dahi son bilinen fiyatları döndürür', () async {
      final now = DateTime.now().toUtc();
      mockService.stubbedPrices = [
        PriceInfo(
          assetId: 'eth-1',
          currency: 'USD',
          price: Decimal.parse('3500'),
          change24h: Decimal.parse('-0.5'),
          fetchedAt: now,
        ),
      ];

      await repository.getCachedPrices();

      mockService.shouldThrow = true;
      final fallback = await repository.refreshPrices();

      expect(fallback.length, 1);
      expect(fallback.first.price, Decimal.parse('3500'));
    });
  });
}
