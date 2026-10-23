import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/core/notifications/notification_service.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/features/habits/domain/entities/habit_entity.dart';
import 'package:lumora/features/habits/domain/repositories/habit_repository.dart';
import 'package:lumora/features/habits/presentation/providers/habit_notifier.dart';
import 'package:lumora/features/habits/presentation/screens/habit_form_screen.dart';

class MockHabitRepository implements HabitRepository {
  List<HabitEntity> habits = [
    const HabitEntity(
      id: 'hbt_mock_1',
      userId: 'usr_mock',
      name: 'Su İçme',
      icon: 'water_drop',
      category: 'water',
      unit: 'ml',
      dailyGoal: 2000,
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '10:00',
      archived: false,
      createdAt: '2026-10-22T10:00:00.000Z',
    ),
  ];

  final List<HabitTemplateEntity> templates = const [
    HabitTemplateEntity(
      id: 'tmpl_water',
      name: 'Su İçme',
      icon: 'water_drop',
      category: 'water',
      unit: 'ml',
      dailyGoal: 2500,
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '10:00',
      description: 'Günlük hidrasyon hedefini koru.',
    ),
    HabitTemplateEntity(
      id: 'tmpl_book',
      name: 'Kitap Okuma',
      icon: 'menu_book',
      category: 'book',
      unit: 'sayfa',
      dailyGoal: 20,
      step: 5,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      reminderTime: '21:00',
      description: 'Her gün 20 sayfa kitap oku.',
    ),
  ];

  @override
  Future<List<HabitEntity>> getHabits({bool includeArchived = false}) async {
    return habits.where((h) => includeArchived ? true : !h.archived).toList();
  }

  @override
  Future<HabitEntity> getHabitById(String id) async {
    final found = habits.firstWhere((h) => h.id == id);
    return found;
  }

  @override
  Future<HabitEntity> createHabit({
    required String name,
    required String icon,
    required String category,
    String? unit,
    required double dailyGoal,
    required double step,
    required List<int> repeatDays,
    String? reminderTime,
  }) async {
    final created = HabitEntity(
      id: 'hbt_${habits.length + 1}',
      userId: 'usr_mock',
      name: name,
      icon: icon,
      category: category,
      unit: unit,
      dailyGoal: dailyGoal,
      step: step,
      repeatDays: repeatDays,
      reminderTime: reminderTime,
      archived: false,
      createdAt: DateTime.now().toIso8601String(),
    );
    habits.add(created);
    return created;
  }

  @override
  Future<HabitEntity> updateHabit(
    String id, {
    String? name,
    String? icon,
    String? category,
    String? unit,
    double? dailyGoal,
    double? step,
    List<int>? repeatDays,
    String? reminderTime,
    bool? archived,
  }) async {
    final index = habits.indexWhere((h) => h.id == id);
    final current = habits[index];
    final updated = current.copyWith(
      name: name,
      icon: icon,
      category: category,
      unit: unit,
      dailyGoal: dailyGoal,
      step: step,
      repeatDays: repeatDays,
      reminderTime: reminderTime,
      archived: archived,
    );
    habits[index] = updated;
    return updated;
  }

  @override
  Future<void> archiveHabit(String id) async {
    final index = habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      habits[index] = habits[index].copyWith(archived: true);
    }
  }

  @override
  Future<List<HabitTemplateEntity>> getTemplates() async {
    return templates;
  }
}

class MockNotificationService implements NotificationService {
  final List<String> scheduledReminders = [];
  final List<String> cancelledReminders = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String reminderTime,
    required List<int> repeatDays,
  }) async {
    scheduledReminders.add('$habitId:$reminderTime');
  }

  @override
  Future<void> cancelHabitReminder(String habitId) async {
    cancelledReminders.add(habitId);
  }

  @override
  Future<void> scheduleMorningMotivation({
    required bool enabled,
    required String time,
  }) async {}

  @override
  Future<void> scheduleEveningChainCheck({
    required bool enabled,
    required String time,
    required bool hasUncompletedPlannedHabits,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  group('Habits Notifier Unit Testleri', () {
    late MockHabitRepository mockRepo;
    late MockNotificationService mockNotifications;
    late ProviderContainer container;

    setUp(() {
      mockRepo = MockHabitRepository();
      mockNotifications = MockNotificationService();

      container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider.overrideWithValue(mockNotifications),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('1. Başlangıç durumu HabitListInitial olmalı', () {
      final state = container.read(habitNotifierProvider);
      expect(state, isA<HabitListInitial>());
    });

    test('2. loadHabits alışkanlıkları yükler ve bildirimleri yeniden planlar', () async {
      final notifier = container.read(habitNotifierProvider.notifier);
      await notifier.loadHabits();

      final state = container.read(habitNotifierProvider);
      expect(state, isA<HabitListData>());
      final habits = (state as HabitListData).habits;
      expect(habits.length, 1);
      expect(habits.first.name, 'Su İçme');

      // Bildirim planlanmış olmalı (Su İçme reminderTime='10:00' var)
      expect(mockNotifications.scheduledReminders, contains('hbt_mock_1:10:00'));
    });

    test('3. createHabit yeni alışkanlık ekler ve hatırlatıcıyı planlar', () async {
      final notifier = container.read(habitNotifierProvider.notifier);
      await notifier.loadHabits();

      final created = await notifier.createHabit(
        name: 'Kitap Okuma',
        icon: 'menu_book',
        category: 'book',
        unit: 'sayfa',
        dailyGoal: 20,
        step: 5,
        repeatDays: [1, 2, 3, 4, 5],
        reminderTime: '21:30',
      );

      expect(created.id, 'hbt_2');
      expect(created.name, 'Kitap Okuma');

      final state = container.read(habitNotifierProvider) as HabitListData;
      expect(state.habits.length, 2);

      // Yeni alışkanlık için bildirim planlanmış olmalı
      expect(mockNotifications.scheduledReminders, contains('hbt_2:21:30'));
    });

    test('4. updateHabit alışkanlığı günceller ve hatırlatıcıyı yeniler', () async {
      final notifier = container.read(habitNotifierProvider.notifier);
      await notifier.loadHabits();

      final updated = await notifier.updateHabit(
        'hbt_mock_1',
        name: 'Bol Su İçme',
        dailyGoal: 3000,
        reminderTime: '11:00',
      );

      expect(updated.name, 'Bol Su İçme');
      expect(updated.dailyGoal, 3000);

      final state = container.read(habitNotifierProvider) as HabitListData;
      expect(state.habits.first.name, 'Bol Su İçme');
      expect(mockNotifications.scheduledReminders, contains('hbt_mock_1:11:00'));
    });

    test('5. deleteHabit alışkanlığı arşivler ve bildirimi iptal eder', () async {
      final notifier = container.read(habitNotifierProvider.notifier);
      await notifier.loadHabits();

      await notifier.deleteHabit('hbt_mock_1');

      final state = container.read(habitNotifierProvider) as HabitListData;
      expect(state.habits.isEmpty, true);
      expect(mockNotifications.cancelledReminders, contains('hbt_mock_1'));
    });
  });

  group('HabitFormScreen Form & Widget Testleri', () {
    late MockHabitRepository mockRepo;
    late MockNotificationService mockNotifications;

    setUp(() {
      mockRepo = MockHabitRepository();
      mockNotifications = MockNotificationService();
    });

    Widget createTestWidget({HabitEntity? initialHabit}) {
      return ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider.overrideWithValue(mockNotifications),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: HabitFormScreen(initialHabit: initialHabit),
        ),
      );
    }

    testWidgets('1. Yeni alışkanlık formunda tüm temel bileşenler render edilir', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Yeni Alışkanlık'), findsOneWidget);
      expect(find.text('Hazır Şablonlar'), findsOneWidget);
      expect(find.text('Alışkanlık Adı'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('İkon Seç'), findsOneWidget);
      expect(find.text('Hedef ve Miktar'), findsOneWidget);
      expect(find.text('Tekrar Günleri'), findsOneWidget);
      expect(find.text('Günlük Hatırlatıcı'), findsOneWidget);
      expect(find.text('Alışkanlığı Kaydet'), findsOneWidget);
    });

    testWidgets('2. Hazır şablona dokununca form otomatik doldurulur', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // "Kitap Okuma" şablon çipine dokun
      final bookChip = find.text('Kitap Okuma');
      expect(bookChip, findsOneWidget);
      await tester.tap(bookChip);
      await tester.pumpAndSettle();

      // Formda ad alanına Kitap Okuma yazılmış olmalı
      expect(find.text('Kitap Okuma'), findsWidgets);
      expect(find.text('sayfa'), findsOneWidget);
    });

    testWidgets('3. Ad alanı boş bırakıldığında doğrulama hatası verir', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Kaydet butonunu görünür yap ve dokun
      final saveBtn = find.text('Alışkanlığı Kaydet');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Alışkanlık adı boş bırakılamaz.'), findsOneWidget);
    });

    testWidgets('4. Düzenleme modunda Sil butonu ve onay diyaloğu doğru çalışır', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final existingHabit = mockRepo.habits.first;
      await tester.pumpWidget(createTestWidget(initialHabit: existingHabit));
      await tester.pumpAndSettle();

      expect(find.text('Alışkanlığı Düzenle'), findsOneWidget);
      expect(find.text('Değişiklikleri Kaydet'), findsOneWidget);
      expect(find.text('Alışkanlığı Sil'), findsOneWidget);

      // Sil butonunu görünür yap ve bas
      final deleteBtn = find.text('Alışkanlığı Sil');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Onay penceresi ve "geçmiş korunur" uyarısı görünmeli
      expect(find.text('Bu alışkanlığı silmek istediğinize emin misiniz?'), findsOneWidget);
      expect(
        find.text('Alışkanlık arşivlenir; geçmiş loglarınız ve başarılarınız korunur.'),
        findsOneWidget,
      );
      expect(find.text('Evet, Sil'), findsOneWidget);
    });
  });
}
