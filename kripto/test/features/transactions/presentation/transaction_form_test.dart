import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronomind/features/prices/domain/price_info.dart';
import 'package:chronomind/features/prices/providers/prices_provider.dart';
import 'package:chronomind/features/transactions/domain/transaction.dart';
import 'package:chronomind/features/transactions/presentation/add_transaction_screen.dart';
import 'package:chronomind/features/transactions/providers/transactions_provider.dart';

void main() {
  testWidgets('TransactionForm renders all form inputs, currency toggles, and validates empty fields',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddTransactionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Kontroller
    expect(find.text('Yeni İşlem Ekle'), findsOneWidget);
    expect(find.text('ALIŞ'), findsOneWidget);
    expect(find.text('SATIŞ'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('TRY'), findsOneWidget);
    expect(find.text('Piyasa'), findsOneWidget);
    expect(find.text('ALIŞ İŞLEMİNİ KAYDET'), findsOneWidget);

    // Boş gönderim denemesi -> doğrulama hataları
    final submitButton = find.text('ALIŞ İŞLEMİNİ KAYDET');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Lütfen işlem miktarını girin.'), findsOneWidget);
    expect(find.text('Lütfen birim fiyatı girin.'), findsOneWidget);
  });

  testWidgets('TransactionForm switches between Buy and Sell, updating CTA text and preview',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddTransactionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // SATIŞ sekmesine tıkla
    await tester.tap(find.text('SATIŞ'));
    await tester.pumpAndSettle();

    expect(find.text('SATIŞ İŞLEMİNİ KAYDET'), findsOneWidget);
  });

  testWidgets('TransactionForm warns on overselling when selling more than held quantity',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Elde 0.1 BTC alış işlemi bulunan bir başlangıç durumu simüle edelim
    final initialTx = AppTransaction(
      id: 'tx-existing',
      userId: 'test-user',
      assetId: 'btc-asset',
      type: TransactionType.buy,
      quantity: Decimal.parse('0.1'),
      price: Decimal.parse('95000'),
      priceCurrency: 'USD',
      fee: Decimal.zero,
      executedAt: DateTime(2026, 1, 1),
      source: TransactionSource.manual,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionsProvider.overrideWith(() => MockTransactionsNotifier([initialTx])),
          pricesProvider.overrideWith(() => MockPricesNotifier()),
        ],
        child: const MaterialApp(
          home: AddTransactionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // SATIŞ moduna geç
    await tester.tap(find.text('SATIŞ'));
    await tester.pumpAndSettle();

    // 0.5 BTC satmaya çalış (elde 0.1 var)
    await tester.enterText(find.widgetWithText(TextFormField, 'İşlem Miktarı (BTC)'), '0.5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Birim Fiyat (USD)'), '96000');
    await tester.pumpAndSettle();

    final submitButton = find.text('SATIŞ İŞLEMİNİ KAYDET');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Yetersiz bakiye uyarısı görünmeli
    expect(find.textContaining('Yetersiz bakiye'), findsOneWidget);
  });
}

class MockTransactionsNotifier extends TransactionsNotifier {
  final List<AppTransaction> initial;
  MockTransactionsNotifier(this.initial);

  @override
  Future<List<AppTransaction>> build() async => initial;
}

class MockPricesNotifier extends PricesNotifier {
  @override
  Future<List<PriceInfo>> build() async => [
        PriceInfo(
          assetId: 'btc-asset',
          currency: 'USD',
          price: Decimal.parse('96000'),
          change24h: Decimal.parse('2.5'),
          fetchedAt: DateTime.now(),
        ),
      ];
}
