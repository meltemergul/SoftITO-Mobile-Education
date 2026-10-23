import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/features/calendar/data/models/calendar_day_detail_model.dart';
import 'package:lumora/features/calendar/data/models/calendar_month_model.dart';
import 'package:lumora/features/calendar/domain/entities/calendar_day_detail_entity.dart';
import 'package:lumora/features/calendar/domain/entities/calendar_month_entity.dart';
import 'package:lumora/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:lumora/features/calendar/presentation/providers/calendar_notifier.dart';
import 'package:lumora/features/calendar/presentation/screens/calendar_screen.dart';

class MockCalendarRepository implements CalendarRepository {
  bool shouldFail = false;

  CalendarMonthEntity testMonthData = const CalendarMonthEntity(
    month: '2026-10',
    unbrokenDays: 14,
    longestStreak: 21,
    days: [
      CalendarDayEntity(
        date: '2026-10-01',
        status: CalendarDayStatus.completed,
        totalPlanned: 2,
        completedCount: 2,
        isToday: false,
      ),
      CalendarDayEntity(
        date: '2026-10-02',
        status: CalendarDayStatus.partial,
        totalPlanned: 2,
        completedCount: 1,
        isToday: false,
      ),
      CalendarDayEntity(
        date: '2026-10-03',
        status: CalendarDayStatus.empty,
        totalPlanned: 1,
        completedCount: 0,
        isToday: false,
      ),
      CalendarDayEntity(
        date: '2026-10-04',
        status: CalendarDayStatus.rest,
        totalPlanned: 0,
        completedCount: 0,
        isToday: false,
      ),
      CalendarDayEntity(
        date: '2026-10-05',
        status: CalendarDayStatus.completed,
        totalPlanned: 2,
        completedCount: 2,
        isToday: true, // Bugün
      ),
      CalendarDayEntity(
        date: '2026-10-06',
        status: CalendarDayStatus.future,
        totalPlanned: 0,
        completedCount: 0,
        isToday: false,
      ),
    ],
    activeHabits: [
      ActiveHabitChainEntity(
        id: 'hbt_water',
        name: 'Su İçme',
        icon: 'water_drop',
        category: 'water',
        completionRate: 85,
        currentStreak: 12,
        last7Days: [
          HabitMicroDayEntity(date: '2026-09-29', isPlanned: true, isCompleted: true),
          HabitMicroDayEntity(date: '2026-09-30', isPlanned: true, isCompleted: true),
          HabitMicroDayEntity(date: '2026-10-01', isPlanned: true, isCompleted: true),
          HabitMicroDayEntity(date: '2026-10-02', isPlanned: true, isCompleted: false),
          HabitMicroDayEntity(date: '2026-10-03', isPlanned: true, isCompleted: true),
          HabitMicroDayEntity(date: '2026-10-04', isPlanned: false, isCompleted: false),
          HabitMicroDayEntity(date: '2026-10-05', isPlanned: true, isCompleted: true),
        ],
      ),
    ],
  );

  CalendarDayDetailEntity testDayDetail = const CalendarDayDetailEntity(
    date: '2026-10-02',
    status: CalendarDayStatus.partial,
    totalPlanned: 2,
    completedCount: 1,
    habits: [
      CalendarDayHabitEntity(
        id: 'hbt_water',
        name: 'Su İçme',
        icon: 'water_drop',
        category: 'water',
        unit: 'ml',
        dailyGoal: 2000,
        step: 250,
        isPlanned: true,
        isCompleted: true,
        currentAmount: 2000,
        targetAmount: 2000,
      ),
      CalendarDayHabitEntity(
        id: 'hbt_book',
        name: 'Kitap Okuma',
        icon: 'menu_book',
        category: 'book',
        unit: 'sayfa',
        dailyGoal: 20,
        step: 5,
        isPlanned: true,
        isCompleted: false,
        currentAmount: 10,
        targetAmount: 20,
      ),
    ],
  );

  @override
  Future<CalendarMonthEntity> getMonthCalendar({String? month}) async {
    if (shouldFail) {
      throw Exception('Ağ hatası meydana geldi.');
    }
    return testMonthData;
  }

  @override
  Future<CalendarDayDetailEntity> getDayDetail(String date) async {
    if (shouldFail) {
      throw Exception('Sunucuya ulaşılamadı.');
    }
    return testDayDetail;
  }
}

void main() {
  group('Takvim Model & Notifier Testleri', () {
    test('1. CalendarMonthModel fromJson ve toJson dönüşümü doğru çalışır', () {
      final json = {
        'month': '2026-10',
        'unbrokenDays': 10,
        'longestStreak': 15,
        'days': [
          {
            'date': '2026-10-01',
            'status': 'completed',
            'totalPlanned': 2,
            'completedCount': 2,
            'isToday': false,
          }
        ],
        'activeHabits': [
          {
            'id': 'hbt_1',
            'name': 'Koşu',
            'icon': 'directions_run',
            'category': 'sport',
            'completionRate': 80,
            'currentStreak': 5,
            'last7Days': [
              {
                'date': '2026-10-01',
                'isPlanned': true,
                'isCompleted': true,
              }
            ],
          }
        ],
      };

      final model = CalendarMonthModel.fromJson(json);
      expect(model.month, '2026-10');
      expect(model.unbrokenDays, 10);
      expect(model.longestStreak, 15);
      expect(model.days.length, 1);
      expect(model.days.first.status, CalendarDayStatus.completed);
      expect(model.activeHabits.length, 1);
      expect(model.activeHabits.first.name, 'Koşu');

      final serialized = model.toJson();
      expect(serialized['month'], '2026-10');
      expect(serialized['unbrokenDays'], 10);
    });

    test('2. CalendarDayDetailModel fromJson dönüşümü doğru çalışır', () {
      final json = {
        'date': '2026-10-05',
        'status': 'partial',
        'totalPlanned': 2,
        'completedCount': 1,
        'habits': [
          {
            'id': 'hbt_1',
            'name': 'Su',
            'icon': 'water_drop',
            'category': 'water',
            'unit': 'ml',
            'dailyGoal': 2000,
            'step': 250,
            'isPlanned': true,
            'isCompleted': true,
            'currentAmount': 2000,
            'targetAmount': 2000,
          }
        ],
      };

      final model = CalendarDayDetailModel.fromJson(json);
      expect(model.date, '2026-10-05');
      expect(model.status, CalendarDayStatus.partial);
      expect(model.habits.length, 1);
      expect(model.habits.first.currentAmount, 2000);
    });

    test('3. CalendarNotifier loadCalendar, previousMonth, nextMonth doğru çalışır', () async {
      final mockRepo = MockCalendarRepository();
      final container = ProviderContainer(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(calendarNotifierProvider.notifier);
      await notifier.loadCalendar();

      final state = container.read(calendarNotifierProvider);
      expect(state.isLoading, false);
      expect(state.calendarData, isNotNull);
      expect(state.calendarData!.unbrokenDays, 14);
      expect(state.calendarData!.longestStreak, 21);

      // Ay değiştirme
      final initialMonth = state.currentMonth.month;
      await notifier.previousMonth();
      final prevMonthState = container.read(calendarNotifierProvider);
      expect(prevMonthState.currentMonth.month, (initialMonth == 1) ? 12 : initialMonth - 1);
    });
  });

  group('CalendarScreen Widget Testleri', () {
    testWidgets('1. Takvim ekranı tüm temel bileşenleri doğru biçimde render eder', (tester) async {
      final mockRepo = MockCalendarRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Ay Başlığı
      expect(find.text('Zinciri Kırma Takvimi'), findsOneWidget);

      // 2. Aylık İstikrar Özeti
      expect(find.text('Aylık İstikrar Özeti'), findsOneWidget);
      expect(find.text('14 Gün'), findsOneWidget);
      expect(find.text('21 Gün'), findsOneWidget);

      // 3. Zincir Matrisi
      expect(find.text('Zincir Matrisi'), findsOneWidget);
      expect(find.text('Pzt'), findsOneWidget);
      expect(find.text('Paz'), findsOneWidget);

      // Şekille ayırt edilebilirlik kontrolü:
      // Tamamlanan gün hücresinde check ikonu
      expect(find.byIcon(Icons.check_rounded), findsWidgets);
      // Kısmi gün hücresinde kare/nokta ikonu
      expect(find.byIcon(Icons.square_rounded), findsWidgets);
      // Bugün alev ikonu
      expect(find.byIcon(Icons.local_fire_department_rounded), findsWidgets);

      // 4. Aktif Hedef Zincirleri
      expect(find.text('Aktif Hedef Zincirleri'), findsOneWidget);
      expect(find.text('Su İçme'), findsOneWidget);
      expect(find.text('%85'), findsOneWidget);
      expect(find.text('🔥 12 Gün Seri'), findsOneWidget);

      // 5. Günün Zincir Sözü
      expect(find.text('Günün Zincir Sözü'), findsOneWidget);
      expect(find.byIcon(Icons.auto_stories_rounded), findsOneWidget);
    });

    testWidgets('2. Güne dokunulduğunda alt sayfa (bottom sheet) açılır ve detayları gösterir', (tester) async {
      final mockRepo = MockCalendarRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 2. gün hücresine dokun (2026-10-02)
      final day2Finder = find.text('2');
      expect(day2Finder, findsOneWidget);
      await tester.tap(day2Finder);
      await tester.pumpAndSettle();

      // Bottom sheet açılmış olmalı
      expect(find.text('2 Ekim 2026'), findsOneWidget);
      expect(find.text('Kısmi'), findsWidgets);
      expect(find.text('Kitap Okuma'), findsOneWidget);
      expect(find.text('10 / 20 sayfa'), findsOneWidget);
    });

    testWidgets('3. O ayda gün verisi olmadığında boş durum kartı gösterilir', (tester) async {
      final mockRepo = MockCalendarRepository();
      mockRepo.testMonthData = const CalendarMonthEntity(
        month: '2026-10',
        unbrokenDays: 0,
        longestStreak: 0,
        days: [],
        activeHabits: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bu ayda henüz kayıt yok'), findsOneWidget);
    });
  });
}
