import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/features/home/domain/entities/today_entity.dart';
import 'package:lumora/features/home/domain/repositories/today_repository.dart';
import 'package:lumora/features/home/presentation/providers/today_notifier.dart';
import 'package:lumora/features/home/presentation/screens/home_screen.dart';

class MockTodayRepository implements TodayRepository {
  bool shouldFail = false;
  final List<String> updatedLogs = [];

  TodayEntity testTodayData = const TodayEntity(
    date: '2026-10-22',
    timezone: 'Europe/Istanbul',
    progress: DailyProgressEntity(
      completed: 1,
      total: 2,
      percentage: 50,
      isAllCompleted: false,
    ),
    xp: UserXpEntity(
      totalXp: 15,
      level: 1,
      title: 'Çırak',
      currentLevelXp: 15,
      nextLevelXp: 100,
      progressPercent: 15,
    ),
    overallStreak: 3,
    streakFreezeCount: 2,
    habits: [
      TodayHabitItemEntity(
        id: 'hbt_1',
        name: 'Sabah Koşusu',
        icon: 'directions_run',
        category: 'sport',
        unit: 'km',
        dailyGoal: 5,
        step: 1,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        isPlannedToday: true,
        isCompletedToday: true,
        currentAmount: 5,
        currentStreak: 3,
      ),
      TodayHabitItemEntity(
        id: 'hbt_2',
        name: 'Su İçme',
        icon: 'water_drop',
        category: 'water',
        unit: 'ml',
        dailyGoal: 2000,
        step: 250,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        isPlannedToday: true,
        isCompletedToday: false,
        currentAmount: 1000,
        currentStreak: 2,
      ),
    ],
  );

  @override
  Future<TodayEntity> getToday({bool forceRefresh = false}) async {
    if (shouldFail) {
      throw Exception('Ağ hatası meydana geldi.');
    }
    return testTodayData;
  }

  @override
  Future<void> updateLog(String habitId, String date, {double? amount, double? delta}) async {
    if (shouldFail) {
      throw Exception('Sunucuya ulaşılamadı.');
    }
    updatedLogs.add('$habitId:$date:$amount:$delta');
  }

  @override
  Future<void> syncPendingOps() async {}
}

void main() {
  group('Today Notifier Unit Testleri', () {
    late MockTodayRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockTodayRepository();
      container = ProviderContainer(
        overrides: [
          todayRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. loadToday veriyi başarıyla yükler ve durumu günceller', () async {
      final notifier = container.read(todayNotifierProvider.notifier);
      await notifier.loadToday();

      final state = container.read(todayNotifierProvider);
      expect(state.isLoading, false);
      expect(state.todayData, isNotNull);
      expect(state.todayData!.habits.length, 2);
      expect(state.todayData!.progress.percentage, 50);
      expect(state.todayData!.xp.totalXp, 15);
    });

    test('2. toggleHabit optimistic olarak tamamlanmayı, ilerlemeyi ve XPyi günceller', () async {
      final notifier = container.read(todayNotifierProvider.notifier);
      await notifier.loadToday();

      // Su İçme (tamamlanmamış olan) alışkanlığını toggle et
      final waterHabit = container.read(todayNotifierProvider).todayData!.habits[1];
      await notifier.toggleHabit(waterHabit);

      final state = container.read(todayNotifierProvider);
      final updatedWater = state.todayData!.habits.firstWhere((h) => h.id == 'hbt_2');
      expect(updatedWater.isCompletedToday, true);

      // 2'de 2 tamamlandığı için progress %100 ve isAllCompleted olmalı
      expect(state.todayData!.progress.completed, 2);
      expect(state.todayData!.progress.percentage, 100);
      expect(state.todayData!.progress.isAllCompleted, true);

      // XP 15 + 15 = 30 olmalı
      expect(state.todayData!.xp.totalXp, 30);

      // Kutlama tetiklenmiş olmalı
      expect(state.showCelebration, true);
    });

    test('3. adjustCounter sayaç türü alışkanlığı optimistic günceller', () async {
      final notifier = container.read(todayNotifierProvider.notifier);
      await notifier.loadToday();

      final waterHabit = container.read(todayNotifierProvider).todayData!.habits[1];
      // +250 ml ekle: 1000 -> 1250 ml
      await notifier.adjustCounter(waterHabit, 250);

      final state = container.read(todayNotifierProvider);
      final updated = state.todayData!.habits.firstWhere((h) => h.id == 'hbt_2');
      expect(updated.currentAmount, 1250);
      expect(updated.isCompletedToday, false); // 1250 < 2000
    });

    test('4. Hata durumunda optimistic güncelleme geri alınır', () async {
      final notifier = container.read(todayNotifierProvider.notifier);
      await notifier.loadToday();

      mockRepo.shouldFail = true;

      final waterHabit = container.read(todayNotifierProvider).todayData!.habits[1];
      await notifier.toggleHabit(waterHabit);

      final state = container.read(todayNotifierProvider);
      // Hata mesajı ayarlanmış olmalı
      expect(state.errorMessage, isNotNull);
      // Su içme eski haline (completed: false) dönmüş olmalı
      final reverted = state.todayData!.habits.firstWhere((h) => h.id == 'hbt_2');
      expect(reverted.isCompletedToday, false);
    });
  });

  group('HomeScreen UI & Widget Testleri', () {
    late MockTodayRepository mockRepo;

    setUp(() {
      mockRepo = MockTodayRepository();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          todayRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      );
    }

    testWidgets('1. Günün İlhamı, Günün İlerlemesi ve Alışkanlık kartları render edilir', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Günün İlhamı'), findsOneWidget);
      expect(find.text('Günün İlerlemesi'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Bugünün Alışkanlıkları'), findsOneWidget);
      expect(find.text('Sabah Koşusu'), findsOneWidget);
      expect(find.text('Su İçme'), findsOneWidget);

      // FAB kontrolü
      expect(find.text('Yeni Alışkanlık'), findsOneWidget);
    });

    testWidgets('2. Sayaç türü alışkanlıkta hızlı + ve - butonları çalışır', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Su içme sayaç kartındaki +250ml butonu
      final plusButton = find.text('+250ml');
      expect(plusButton, findsOneWidget);

      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      // 1000 + 250 = 1250 ml güncellenmiş olmalı
      expect(find.text('1250 / 2000 ml'), findsOneWidget);
    });

    testWidgets('3. Hiç alışkanlık olmadığında boş durum mesajı gösterilir', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      mockRepo.testTodayData = mockRepo.testTodayData.copyWith(habits: []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Henüz bir alışkanlık eklemediniz'), findsOneWidget);
    });
  });
}
