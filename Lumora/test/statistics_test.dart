import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/features/statistics/data/models/stats_model.dart';
import 'package:lumora/features/statistics/domain/entities/stats_entity.dart';
import 'package:lumora/features/statistics/domain/repositories/stats_repository.dart';
import 'package:lumora/features/statistics/presentation/providers/stats_notifier.dart';
import 'package:lumora/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:lumora/features/statistics/presentation/widgets/category_distribution_widget.dart';
import 'package:lumora/features/statistics/presentation/widgets/habit_details_list_widget.dart';
import 'package:lumora/features/statistics/presentation/widgets/overall_score_card.dart';
import 'package:lumora/features/statistics/presentation/widgets/productive_hours_widget.dart';
import 'package:lumora/features/statistics/presentation/widgets/range_filter_selector.dart';
import 'package:lumora/features/statistics/presentation/widgets/routine_bar_chart.dart';
import 'package:lumora/features/statistics/presentation/widgets/weekly_momentum_card.dart';

class MockStatsRepository implements StatsRepository {
  bool shouldFail = false;
  String? lastRequestedRange;

  StatsEntity mockStats = const StatsEntity(
    range: 'weekly',
    hasEnoughData: true,
    overallScore: 88,
    trend: 6,
    dailyChart: [
      DailyChartEntity(
        date: '2026-10-17',
        dayLabel: 'Cmt',
        rate: 100,
        completed: 2,
        total: 2,
        isPeak: true,
      ),
      DailyChartEntity(
        date: '2026-10-18',
        dayLabel: 'Paz',
        rate: 50,
        completed: 1,
        total: 2,
        isPeak: false,
      ),
    ],
    categoryDistribution: [
      CategoryDistributionEntity(
        category: 'water',
        name: 'Su',
        rate: 95,
        completedCount: 6,
        totalPlanned: 7,
      ),
      CategoryDistributionEntity(
        category: 'book',
        name: 'Kitap',
        rate: 80,
        completedCount: 4,
        totalPlanned: 5,
      ),
    ],
    productiveHours: [
      ProductiveHourEntity(
        period: 'morning',
        label: 'Sabah (06:00-12:00)',
        percentage: 60,
        count: 6,
      ),
      ProductiveHourEntity(
        period: 'evening',
        label: 'Akşam (18:00-24:00)',
        percentage: 40,
        count: 4,
      ),
    ],
    bestHabit: BestHabitEntity(
      id: 'h1',
      name: 'Su İçme',
      icon: 'water_drop',
      category: 'water',
      rate: 95,
      currentStreak: 12,
    ),
    overallStreak: 5,
    longestStreak: 14,
    totalCompletedDays: 18,
    habitProgress: [
      HabitProgressDetailEntity(
        id: 'h1',
        name: 'Su İçme',
        icon: 'water_drop',
        category: 'water',
        rate: 95,
        completedDays: 6,
        totalPlannedDays: 7,
        currentStreak: 12,
        longestStreak: 14,
      ),
      HabitProgressDetailEntity(
        id: 'h2',
        name: 'Kitap Okuma',
        icon: 'menu_book',
        category: 'book',
        rate: 80,
        completedDays: 4,
        totalPlannedDays: 5,
        currentStreak: 4,
        longestStreak: 8,
      ),
    ],
  );

  @override
  Future<StatsEntity> getStats({String range = 'weekly'}) async {
    lastRequestedRange = range;
    if (shouldFail) {
      throw Exception('Network error');
    }
    return mockStats;
  }
}

void main() {
  group('Stats Models Tests', () {
    test('StatsModel.fromJson correctly parses full JSON payload', () {
      final json = {
        'range': 'monthly',
        'hasEnoughData': true,
        'overallScore': 92,
        'trend': 8,
        'dailyChart': [
          {
            'date': '2026-10-20',
            'dayLabel': 'Sal',
            'rate': 100,
            'completed': 3,
            'total': 3,
            'isPeak': true,
          }
        ],
        'categoryDistribution': [
          {
            'category': 'sport',
            'name': 'Spor',
            'rate': 85,
            'completedCount': 5,
            'totalPlanned': 6,
          }
        ],
        'productiveHours': [
          {
            'period': 'morning',
            'label': 'Sabah (06:00-12:00)',
            'percentage': 70,
            'count': 7,
          }
        ],
        'bestHabit': {
          'id': 'habit_123',
          'name': 'Sabah Koşusu',
          'icon': 'directions_run',
          'category': 'sport',
          'rate': 90,
          'currentStreak': 15,
        },
        'overallStreak': 7,
        'longestStreak': 20,
        'totalCompletedDays': 25,
        'habitProgress': [
          {
            'id': 'habit_123',
            'name': 'Sabah Koşusu',
            'icon': 'directions_run',
            'category': 'sport',
            'rate': 90,
            'completedDays': 18,
            'totalPlannedDays': 20,
            'currentStreak': 15,
            'longestStreak': 20,
          }
        ]
      };

      final model = StatsModel.fromJson(json);

      expect(model.range, 'monthly');
      expect(model.hasEnoughData, true);
      expect(model.overallScore, 92);
      expect(model.trend, 8);
      expect(model.dailyChart.length, 1);
      expect(model.dailyChart.first.isPeak, true);
      expect(model.categoryDistribution.first.name, 'Spor');
      expect(model.productiveHours.first.percentage, 70);
      expect(model.bestHabit?.name, 'Sabah Koşusu');
      expect(model.bestHabit?.currentStreak, 15);
      expect(model.overallStreak, 7);
      expect(model.longestStreak, 20);
      expect(model.totalCompletedDays, 25);
      expect(model.habitProgress.first.completedDays, 18);
    });

    test('StatsModel.fromJson handles null bestHabit and empty arrays', () {
      final json = {
        'range': 'all',
        'hasEnoughData': false,
        'overallScore': 0,
        'trend': null,
        'dailyChart': [],
        'categoryDistribution': [],
        'productiveHours': [],
        'bestHabit': null,
        'overallStreak': 0,
        'longestStreak': 0,
        'totalCompletedDays': 0,
        'habitProgress': [],
      };

      final model = StatsModel.fromJson(json);

      expect(model.hasEnoughData, false);
      expect(model.trend, isNull);
      expect(model.bestHabit, isNull);
      expect(model.dailyChart, isEmpty);
      expect(model.categoryDistribution, isEmpty);
    });
  });

  group('StatsNotifier Tests', () {
    late MockStatsRepository mockRepo;

    setUp(() {
      mockRepo = MockStatsRepository();
    });

    test('Initial state is weekly range and not loading', () {
      final container = ProviderContainer(
        overrides: [
          statsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(statsNotifierProvider);
      expect(state.range, 'weekly');
      expect(state.isLoading, false);
      expect(state.stats, isNull);
      expect(state.errorMessage, isNull);
    });

    test('loadStats successfully populates stats', () async {
      final container = ProviderContainer(
        overrides: [
          statsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(statsNotifierProvider.notifier).loadStats();

      final state = container.read(statsNotifierProvider);
      expect(state.isLoading, false);
      expect(state.stats, isNotNull);
      expect(state.stats?.overallScore, 88);
      expect(state.errorMessage, isNull);
      expect(mockRepo.lastRequestedRange, 'weekly');
    });

    test('changeRange updates range and reloads stats', () async {
      final container = ProviderContainer(
        overrides: [
          statsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(statsNotifierProvider.notifier).changeRange('monthly');

      final state = container.read(statsNotifierProvider);
      expect(state.range, 'monthly');
      expect(mockRepo.lastRequestedRange, 'monthly');
    });

    test('loadStats sets errorMessage on failure', () async {
      mockRepo.shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          statsRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(statsNotifierProvider.notifier).loadStats();

      final state = container.read(statsNotifierProvider);
      expect(state.isLoading, false);
      expect(state.stats, isNull);
      expect(state.errorMessage, 'İstatistikler yüklenemedi.');
    });
  });

  group('Statistics Widgets & Screen UI Tests', () {
    late MockStatsRepository mockRepo;

    setUp(() {
      mockRepo = MockStatsRepository();
    });

    Widget createTestApp({StatsEntity? customStats}) {
      if (customStats != null) {
        mockRepo.mockStats = customStats;
      }
      return ProviderScope(
        overrides: [
          statsRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const StatisticsScreen(),
        ),
      );
    }

    testWidgets('Renders all primary sections when data is available', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Ekran Başlığı & Filtre
      expect(find.text('İstatistik'), findsOneWidget);
      expect(find.byType(RangeFilterSelector), findsOneWidget);
      expect(find.text('Haftalık'), findsOneWidget);
      expect(find.text('Aylık'), findsOneWidget);
      expect(find.text('Tüm Zamanlar'), findsOneWidget);

      // Genel Başarı Skoru
      expect(find.byType(OverallScoreCard), findsOneWidget);
      expect(find.text('%88'), findsOneWidget);
      expect(find.text('+6%'), findsOneWidget);
      expect(find.text('18 Gün'), findsOneWidget); // Tamamlanan Gün
      expect(find.text('14 Gün'), findsOneWidget); // En Uzun Seri

      // Rutin Performansı Çubuk Grafiği
      expect(find.byType(RoutineBarChart), findsOneWidget);
      expect(find.text('Rutin Performansı'), findsOneWidget);
      expect(find.text('Cmt'), findsOneWidget);
      expect(find.text('Paz'), findsOneWidget);

      // Kategori Dağılımı
      expect(find.byType(CategoryDistributionWidget), findsOneWidget);
      expect(find.text('Kategori Dağılımı'), findsOneWidget);
      expect(find.text('Su'), findsOneWidget);
      expect(find.text('%95'), findsAtLeastNWidgets(1));

      // Alışkanlık Detayı (Tasarımda olmayan önerilen bölüm - Bölüm 6.4)
      expect(find.byType(HabitDetailsListWidget), findsOneWidget);
      expect(find.text('Alışkanlık Detayı'), findsOneWidget);
      expect(find.text('Mevcut Seri: 12 Gün'), findsOneWidget);
      expect(find.text('En Uzun: 14 Gün'), findsOneWidget);

      // En Verimli Saatler
      expect(find.byType(ProductiveHoursWidget), findsOneWidget);
      expect(find.text('En Verimli Saatler'), findsOneWidget);
      expect(find.text('Sabah (06:00-12:00)'), findsOneWidget);

      // Haftalık Özet & Momentum Kartı
      expect(find.byType(WeeklyMomentumCard), findsOneWidget);
      expect(find.text('Yüksek Momentum!'), findsOneWidget);
      expect(find.text('En Düzenli Alışkanlık'), findsOneWidget);
    });

    testWidgets('Shows guidance message when hasEnoughData is false', (tester) async {
      const emptyStats = StatsEntity(
        range: 'weekly',
        hasEnoughData: false,
        overallScore: 0,
        trend: null,
        dailyChart: [],
        categoryDistribution: [],
        productiveHours: [],
        bestHabit: null,
        overallStreak: 0,
        longestStreak: 0,
        totalCompletedDays: 0,
        habitProgress: [],
      );

      await tester.pumpWidget(createTestApp(customStats: emptyStats));
      await tester.pumpAndSettle();

      // Yetersiz veri bilgilendirme mesajı (design-skill.md Bölüm 6.4)
      expect(find.text('İstatistikler birkaç günlük veriyle oluşur'), findsOneWidget);
      expect(
        find.textContaining('Grafik ve odak saatlerinin detaylı analiz edilebilmesi'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping on a different range updates selected range', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Aylık filtresine tıkla
      await tester.tap(find.text('Aylık'));
      await tester.pumpAndSettle();

      expect(mockRepo.lastRequestedRange, 'monthly');
    });
  });
}
