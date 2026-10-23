import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/features/quotes/data/models/quote_model.dart';
import 'package:lumora/features/quotes/domain/entities/quote.dart';
import 'package:lumora/features/quotes/domain/repositories/quote_repository.dart';
import 'package:lumora/features/quotes/presentation/providers/daily_quote_provider.dart';
import 'package:lumora/features/quotes/presentation/widgets/inspiration_quote_card.dart';

class MockQuoteRepository implements QuoteRepository {
  Quote testQuote = const Quote(
    id: 'q_test_1',
    text: 'Zor olduğu için cesaret edemiyor değiliz; biz cesaret edemediğimiz için zordur.',
    author: 'Seneca',
    source: 'fallback',
    isFavorite: false,
  );

  bool shouldFail = false;
  int addFavoriteCallCount = 0;
  int removeFavoriteCallCount = 0;

  @override
  Future<Quote> getDailyQuote({String? date}) async {
    if (shouldFail) {
      throw Exception('Ağ hatası meydana geldi.');
    }
    return testQuote;
  }

  @override
  Future<bool> addFavorite(String quoteId) async {
    if (shouldFail) {
      throw Exception('Sunucu hatası');
    }
    addFavoriteCallCount++;
    testQuote = testQuote.copyWith(isFavorite: true);
    return true;
  }

  @override
  Future<bool> removeFavorite(String quoteId) async {
    if (shouldFail) {
      throw Exception('Sunucu hatası');
    }
    removeFavoriteCallCount++;
    testQuote = testQuote.copyWith(isFavorite: false);
    return false;
  }
}

void main() {
  group('Quotes Model & Unit Testleri', () {
    test('1. QuoteModel fromJson ve toJson dönüşümü doğru çalışır', () {
      final jsonWithAuthor = {
        'id': 'q_1',
        'text': 'Küçük adımlar büyük hedeflere götürür.',
        'author': 'Marcus Aurelius',
        'source': 'fallback',
        'isFavorite': true,
      };

      final model = QuoteModel.fromJson(jsonWithAuthor);
      expect(model.id, 'q_1');
      expect(model.text, 'Küçük adımlar büyük hedeflere götürür.');
      expect(model.author, 'Marcus Aurelius');
      expect(model.source, 'fallback');
      expect(model.isFavorite, true);

      final backToJson = model.toJson();
      expect(backToJson['author'], 'Marcus Aurelius');
      expect(backToJson['isFavorite'], true);

      // Atıfsız (author: null) durum
      final jsonNullAuthor = {
        'id': 'q_2',
        'text': 'Her gün yeni bir başlangıçtır.',
        'author': null,
        'source': 'fallback',
        'isFavorite': false,
      };

      final modelNull = QuoteModel.fromJson(jsonNullAuthor);
      expect(modelNull.author, isNull);
      expect(modelNull.isFavorite, false);
    });

    test('2. DailyQuoteNotifier loadDailyQuote veriyi başarıyla yükler', () async {
      final mockRepo = MockQuoteRepository();
      final container = ProviderContainer(
        overrides: [
          quoteRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(dailyQuoteNotifierProvider.notifier);
      await notifier.loadDailyQuote();

      final state = container.read(dailyQuoteNotifierProvider);
      expect(state.isLoading, false);
      expect(state.quote, isNotNull);
      expect(state.quote!.author, 'Seneca');
      expect(state.quote!.isFavorite, false);
    });

    test('3. DailyQuoteNotifier toggleFavorite optimistic günceller ve hata durumunda geri alır', () async {
      final mockRepo = MockQuoteRepository();
      final container = ProviderContainer(
        overrides: [
          quoteRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(dailyQuoteNotifierProvider.notifier);
      await notifier.loadDailyQuote();

      // Favorile
      await notifier.toggleFavorite();
      expect(container.read(dailyQuoteNotifierProvider).quote!.isFavorite, true);
      expect(mockRepo.addFavoriteCallCount, 1);

      // Favoriden çıkar
      await notifier.toggleFavorite();
      expect(container.read(dailyQuoteNotifierProvider).quote!.isFavorite, false);
      expect(mockRepo.removeFavoriteCallCount, 1);

      // Hata simülasyonu
      mockRepo.shouldFail = true;
      await notifier.toggleFavorite(); // favorilemeye çalışır ama fail olur
      expect(container.read(dailyQuoteNotifierProvider).quote!.isFavorite, false);
      expect(container.read(dailyQuoteNotifierProvider).errorMessage, 'Favori durumu güncellenemedi.');
    });
  });

  group('InspirationQuoteCard Widget Testleri', () {
    testWidgets('1. Atıflı söz olduğunda yazar satırı gösterilir', (tester) async {
      final mockRepo = MockQuoteRepository();
      mockRepo.testQuote = const Quote(
        id: 'q_10',
        text: 'En büyük zafer düşmemek değil, her düştüğünde ayağa kalkabilmektir.',
        author: 'Konfüçyüs',
        source: 'fallback',
        isFavorite: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: InspirationQuoteCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Günün İlhamı'), findsOneWidget);
      expect(
        find.text('"En büyük zafer düşmemek değil, her düştüğünde ayağa kalkabilmektir."'),
        findsOneWidget,
      );
      // Yazar satırı gösterilmeli
      expect(find.text('— Konfüçyüs'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);

      // Kalp butonuna dokunulduğunda favorileme tetiklenir
      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(mockRepo.addFavoriteCallCount, 1);
    });

    testWidgets('2. Atıfsız söz olduğunda (author == null) yazar satırı ASLA gösterilmez', (tester) async {
      final mockRepo = MockQuoteRepository();
      mockRepo.testQuote = const Quote(
        id: 'q_20',
        text: 'İrade, her gün yeniden inşa edilen bir kas gibidir.',
        author: null,
        source: 'fallback',
        isFavorite: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quoteRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: InspirationQuoteCard(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Günün İlhamı'), findsOneWidget);
      expect(
        find.text('"İrade, her gün yeniden inşa edilen bir kas gibidir."'),
        findsOneWidget,
      );
      // Yazar tire işareti veya yazar satırı ASLA bulunmamalıdır
      expect(find.textContaining('—'), findsNothing);
    });
  });
}
