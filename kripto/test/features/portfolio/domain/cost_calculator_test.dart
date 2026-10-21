import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronomind/core/errors.dart';
import 'package:chronomind/features/portfolio/domain/cost_calculator.dart';
import 'package:chronomind/features/transactions/domain/transaction.dart';

void main() {
  AppTransaction createTx({
    required String id,
    required TransactionType type,
    required String quantity,
    required String price,
    String fee = '0',
    required DateTime executedAt,
    DateTime? deletedAt,
  }) {
    return AppTransaction(
      id: id,
      userId: 'user-1',
      assetId: 'btc-asset',
      type: type,
      quantity: Decimal.parse(quantity),
      price: Decimal.parse(price),
      priceCurrency: 'USD',
      fee: Decimal.parse(fee),
      executedAt: executedAt,
      source: TransactionSource.manual,
      createdAt: executedAt,
      deletedAt: deletedAt,
    );
  }

  group('CostCalculator (DCA ve Gerçekleşmiş K/Z Testleri)', () {
    // Senaryo 1: Tek alış - ortalama = alış fiyatı
    test('1. Tek alış: ortalama fiyat alış fiyatına eşit olmalıdır', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '0.5',
          price: '80000',
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
      ];

      final result = CostCalculator.calculatePosition(transactions: txs);

      expect(result.heldQuantity, Decimal.parse('0.5'));
      expect(result.averageBuyPrice, Decimal.parse('80000'));
      expect(result.totalCost, Decimal.parse('40000'));
      expect(result.realizedSales, isEmpty);
      expect(result.totalRealizedPnl, Decimal.zero);
    });

    // Senaryo 2: İki alış (farklı fiyat) - ağırlıklı ortalama
    test('2. İki alış: ağırlıklı ortalama doğru hesaplanmalıdır', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '1',
          price: '10000',
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
        createTx(
          id: 'tx-2',
          type: TransactionType.buy,
          quantity: '1',
          price: '20000',
          executedAt: DateTime(2026, 1, 2, 10, 0),
        ),
      ];

      final result = CostCalculator.calculatePosition(transactions: txs);

      // Toplam maliyet: 10,000 + 20,000 = 30,000. Eldeki: 2 BTC. Ortalama: 15,000
      expect(result.heldQuantity, Decimal.parse('2'));
      expect(result.totalCost, Decimal.parse('30000'));
      expect(result.averageBuyPrice, Decimal.parse('15000'));
    });

    // Senaryo 3: Kısmi satış - ortalama değişmez, gerçekleşmiş K/Z doğru
    test('3. Kısmi satış: ortalama maliyet değişmemeli, gerçekleşmiş K/Z hesaplanmalıdır', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '2',
          price: '15000',
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
        createTx(
          id: 'tx-2',
          type: TransactionType.sell,
          quantity: '0.5',
          price: '25000',
          executedAt: DateTime(2026, 1, 2, 10, 0),
        ),
      ];

      final result = CostCalculator.calculatePosition(transactions: txs);

      // Kalan miktar: 2 - 0.5 = 1.5 BTC
      expect(result.heldQuantity, Decimal.parse('1.5'));
      // Ortalama maliyet satıştan etkilenmez: 15,000
      expect(result.averageBuyPrice, Decimal.parse('15000'));
      // Kalan maliyet: 1.5 * 15,000 = 22,500
      expect(result.totalCost, Decimal.parse('22500'));

      // Gerçekleşmiş K/Z: (25,000 - 15,000) * 0.5 = 5,000
      expect(result.realizedSales.length, 1);
      expect(result.realizedSales.first.netPnl, Decimal.parse('5000'));
      expect(result.totalRealizedPnl, Decimal.parse('5000'));
    });

    // Senaryo 4: Tam satış sonrası yeniden alış - eski ortalama taşınmaz
    test('4. Tam satış sonrası yeniden alış: maliyet sıfırlanmalı ve eski ortalama taşınmamalıdır', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '1',
          price: '10000',
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
        createTx(
          id: 'tx-2',
          type: TransactionType.sell,
          quantity: '1',
          price: '12000',
          executedAt: DateTime(2026, 1, 2, 10, 0),
        ),
        // Miktar 0'a indi. Şimdi yeni fiyattan alış:
        createTx(
          id: 'tx-3',
          type: TransactionType.buy,
          quantity: '1',
          price: '50000',
          executedAt: DateTime(2026, 1, 3, 10, 0),
        ),
      ];

      final result = CostCalculator.calculatePosition(transactions: txs);

      // Yeni pozisyon tamamen 50,000 seviyesinden başlamalıdır
      expect(result.heldQuantity, Decimal.parse('1'));
      expect(result.averageBuyPrice, Decimal.parse('50000'));
      expect(result.totalCost, Decimal.parse('50000'));
      expect(result.totalRealizedPnl, Decimal.parse('2000')); // İlk satıştan 2000 kâr
    });

    // Senaryo 5: Farklı sırada gelen kayıtlar - executed_at sırasına göre sonuç aynı
    test('5. Farklı sırada gelen kayıtlar: kronolojik sıraya göre aynı sonucu vermelidir', () {
      final txEarlyBuy = createTx(
        id: 'tx-1',
        type: TransactionType.buy,
        quantity: '1',
        price: '20000',
        executedAt: DateTime(2026, 1, 1, 10, 0),
      );
      final txMidSell = createTx(
        id: 'tx-2',
        type: TransactionType.sell,
        quantity: '0.5',
        price: '30000',
        executedAt: DateTime(2026, 1, 2, 10, 0),
      );
      final txLateBuy = createTx(
        id: 'tx-3',
        type: TransactionType.buy,
        quantity: '1',
        price: '40000',
        executedAt: DateTime(2026, 1, 3, 10, 0),
      );

      // Karışık sıralı liste veriliyor:
      final result1 = CostCalculator.calculatePosition(transactions: [txLateBuy, txEarlyBuy, txMidSell]);
      final result2 = CostCalculator.calculatePosition(transactions: [txEarlyBuy, txMidSell, txLateBuy]);

      expect(result1.heldQuantity, result2.heldQuantity);
      expect(result1.averageBuyPrice, result2.averageBuyPrice);
      expect(result1.totalCost, result2.totalCost);
      expect(result1.totalRealizedPnl, result2.totalRealizedPnl);
    });

    // Senaryo 6: Komisyonlu işlem
    test('6. Komisyonlu işlem: komisyon alışta maliyete eklenmeli, satışta kârdan düşmelidir', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '1',
          price: '10000',
          fee: '50', // 10,000 + 50 = 10,050
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
        createTx(
          id: 'tx-2',
          type: TransactionType.sell,
          quantity: '0.5',
          price: '15000',
          fee: '20',
          executedAt: DateTime(2026, 1, 2, 10, 0),
        ),
      ];

      final result = CostCalculator.calculatePosition(transactions: txs);

      // Alış ortalaması komisyon dahil: 10,050
      expect(result.realizedSales.first.averageBuyPrice, Decimal.parse('10050'));

      // Gerçekleşmiş K/Z = (15,000 - 10,050) * 0.5 - 20
      // 4,950 * 0.5 = 2,475. 2,475 - 20 = 2,455
      expect(result.realizedSales.first.netPnl, Decimal.parse('2455'));
      expect(result.totalRealizedPnl, Decimal.parse('2455'));

      // Kalan 0.5 BTC maliyeti: 5,025
      expect(result.heldQuantity, Decimal.parse('0.5'));
      expect(result.averageBuyPrice, Decimal.parse('10050'));
      expect(result.totalCost, Decimal.parse('5025'));
    });

    // Senaryo 7: Çok küçük miktarlar ve yuvarlama (Decimal ile kayıpsız)
    test('7. Çok küçük miktarlar (Satoshi): Decimal ile kayıpsız hesaplanmalıdır', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '0.00000001', // 1 Satoshi
          price: '95432.12345678',
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
        createTx(
          id: 'tx-2',
          type: TransactionType.buy,
          quantity: '0.00000002', // 2 Satoshi
          price: '96000.00000000',
          executedAt: DateTime(2026, 1, 2, 10, 0),
        ),
      ];

      final result = CostCalculator.calculatePosition(transactions: txs);

      expect(result.heldQuantity, Decimal.parse('0.00000003'));
      expect(result.totalCost, (Decimal.parse('0.00000001') * Decimal.parse('95432.12345678')) +
          (Decimal.parse('0.00000002') * Decimal.parse('96000.00000000')));
    });

    // Senaryo 8: Fazla satış - hata veya doğrulama sonucu
    test('8. Fazla satış: yetersiz bakiye durumunda ValidationError fırlatılmalıdır', () {
      final txs = [
        createTx(
          id: 'tx-1',
          type: TransactionType.buy,
          quantity: '0.1',
          price: '90000',
          executedAt: DateTime(2026, 1, 1, 10, 0),
        ),
        createTx(
          id: 'tx-2',
          type: TransactionType.sell,
          quantity: '0.5', // Elde 0.1 varken 0.5 satmaya çalışıyor
          price: '95000',
          executedAt: DateTime(2026, 1, 2, 10, 0),
        ),
      ];

      expect(
        () => CostCalculator.calculatePosition(transactions: txs),
        throwsA(isA<ValidationError>()),
      );
    });
  });
}
