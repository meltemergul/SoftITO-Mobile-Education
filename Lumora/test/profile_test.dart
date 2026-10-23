import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/core/notifications/notification_service.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/core/theme/theme_mode_provider.dart';
import 'package:lumora/features/habits/domain/entities/habit_entity.dart';
import 'package:lumora/features/habits/domain/repositories/habit_repository.dart';
import 'package:lumora/features/habits/presentation/providers/habit_notifier.dart';
import 'package:lumora/features/profile/data/models/user_profile_model.dart';
import 'package:lumora/features/profile/data/models/user_settings_model.dart';
import 'package:lumora/features/profile/domain/entities/user_profile_entity.dart';
import 'package:lumora/features/profile/domain/entities/user_settings_entity.dart';
import 'package:lumora/features/profile/domain/repositories/profile_repository.dart';
import 'package:lumora/features/profile/presentation/providers/profile_notifier.dart';
import 'package:lumora/features/profile/presentation/screens/profile_screen.dart';
import 'package:lumora/features/profile/presentation/widgets/account_system_section.dart';
import 'package:lumora/features/profile/presentation/widgets/goal_management_section.dart';
import 'package:lumora/features/profile/presentation/widgets/invite_friend_card.dart';
import 'package:lumora/features/profile/presentation/widgets/preferences_section.dart';
import 'package:lumora/features/profile/presentation/widgets/profile_header.dart';
import 'package:lumora/features/profile/presentation/widgets/quick_metrics_card.dart';

class MockNotificationService implements NotificationService {
  bool morningScheduled = false;
  bool eveningScheduled = false;
  bool cancelled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> scheduleHabitReminder({
    required String habitId,
    required String habitName,
    required String reminderTime,
    required List<int> repeatDays,
  }) async {}

  @override
  Future<void> cancelHabitReminder(String habitId) async {}

  @override
  Future<void> cancelAll() async {
    cancelled = true;
  }

  @override
  Future<void> scheduleMorningMotivation({
    required bool enabled,
    required String time,
  }) async {
    morningScheduled = enabled;
  }

  @override
  Future<void> scheduleEveningChainCheck({
    required bool enabled,
    required String time,
    required bool hasUncompletedPlannedHabits,
  }) async {
    eveningScheduled = enabled && hasUncompletedPlannedHabits;
  }
}

class MockHabitRepository implements HabitRepository {
  List<HabitEntity> habits = [
    const HabitEntity(
      id: 'h-water',
      userId: 'user-123',
      name: 'Su İç',
      category: 'water',
      icon: 'water_drop',
      step: 250,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      dailyGoal: 2000,
      unit: 'ml',
      archived: false,
      createdAt: '2026-01-01T00:00:00.000Z',
    ),
    const HabitEntity(
      id: 'h-book',
      userId: 'user-123',
      name: 'Kitap Oku',
      category: 'book',
      icon: 'menu_book',
      step: 5,
      repeatDays: [1, 2, 3, 4, 5, 6, 7],
      dailyGoal: 20,
      unit: 'sayfa',
      archived: false,
      createdAt: '2026-01-01T00:00:00.000Z',
    ),
  ];

  @override
  Future<List<HabitEntity>> getHabits({bool includeArchived = false}) async {
    return habits.where((h) => includeArchived ? true : !h.archived).toList();
  }

  @override
  Future<HabitEntity> getHabitById(String id) async {
    return habits.firstWhere((h) => h.id == id);
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
      id: 'h-${habits.length + 1}',
      userId: 'user-123',
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
    final idx = habits.indexWhere((h) => h.id == id);
    final cur = habits[idx];
    final updated = cur.copyWith(
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
    habits[idx] = updated;
    return updated;
  }

  @override
  Future<void> archiveHabit(String id) async {
    final idx = habits.indexWhere((h) => h.id == id);
    if (idx != -1) {
      habits[idx] = habits[idx].copyWith(archived: true);
    }
  }

  @override
  Future<List<HabitTemplateEntity>> getTemplates() async {
    return const [];
  }
}

class MockProfileRepository implements ProfileRepository {
  bool shouldFail = false;
  bool deleteAccountCalled = false;
  String? lastExportFormat;
  String? lastUpdatedHabitId;
  double? lastUpdatedGoal;

  UserProfileEntity mockProfile = const UserProfileEntity(
    id: 'user-123',
    email: 'test@lumora.app',
    displayName: 'Test Kullanıcı',
    username: 'test_kullanici',
    avatarUrl: null,
    isGuest: false,
    createdAt: '2026-01-15T10:00:00.000Z',
    bestStreak: 21,
    totalGoals: 6,
    level: 4,
  );

  UserSettingsEntity mockSettings = const UserSettingsEntity(
    userId: 'user-123',
    theme: 'dark',
    weekStartsOn: 1,
    timezone: 'Europe/Istanbul',
    notifications: NotificationPreferences(
      smart: true,
      morningMotivation: NotificationScheduleItem(enabled: true, time: '08:00'),
      eveningChainCheck: NotificationScheduleItem(enabled: true, time: '21:30'),
      soundAndHaptics: true,
    ),
    streakFreezeCount: 1,
  );

  @override
  Future<UserProfileEntity> getProfile() async {
    if (shouldFail) throw Exception('Profil yüklenemedi');
    return mockProfile;
  }

  @override
  Future<UserProfileEntity> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) async {
    if (shouldFail) throw Exception('Profil güncellenemedi');
    mockProfile = mockProfile.copyWith(
      displayName: displayName ?? mockProfile.displayName,
      username: username ?? mockProfile.username,
      avatarUrl: avatarUrl ?? mockProfile.avatarUrl,
    );
    return mockProfile;
  }

  @override
  Future<UserSettingsEntity> getSettings() async {
    if (shouldFail) throw Exception('Ayarlar yüklenemedi');
    return mockSettings;
  }

  @override
  Future<UserSettingsEntity> updateSettings(UserSettingsEntity settings) async {
    if (shouldFail) throw Exception('Ayarlar güncellenemedi');
    mockSettings = settings;
    return mockSettings;
  }

  @override
  Future<String> exportData(String format) async {
    if (shouldFail) throw Exception('Dışa aktarma başarısız');
    lastExportFormat = format;
    return 'exported $format data';
  }

  @override
  Future<void> deleteAccount() async {
    if (shouldFail) throw Exception('Hesap silinemedi');
    deleteAccountCalled = true;
  }

  @override
  Future<void> updateHabitGoal({
    required String habitId,
    required double dailyGoal,
  }) async {
    if (shouldFail) throw Exception('Hedef güncellenemedi');
    lastUpdatedHabitId = habitId;
    lastUpdatedGoal = dailyGoal;
  }
}

void main() {
  group('Profile & Settings Models', () {
    test('UserProfileModel serialization and deserialization', () {
      final json = {
        'user': {
          'id': 'u1',
          'email': 'lumora@test.com',
          'displayName': 'Lumora User',
          'username': 'lumora_user',
          'avatarUrl': 'https://lumora.app/avatar.png',
          'isGuest': false,
          'createdAt': '2026-03-01T00:00:00.000Z',
        },
        'quickMetrics': {
          'bestStreak': 14,
          'totalGoals': 5,
          'level': 3,
        },
      };

      final model = UserProfileModel.fromJson(json);
      expect(model.id, 'u1');
      expect(model.displayName, 'Lumora User');
      expect(model.bestStreak, 14);
      expect(model.level, 3);

      final outputJson = model.toJson();
      expect(outputJson['email'], 'lumora@test.com');
      expect(outputJson['quickMetrics']['bestStreak'], 14);
    });

    test('UserSettingsModel serialization and copyWith', () {
      final json = {
        'userId': 'u1',
        'theme': 'light',
        'weekStartsOn': 1,
        'timezone': 'Europe/Istanbul',
        'notifications': {
          'smart': true,
          'morningMotivation': {'enabled': true, 'time': '08:00'},
          'eveningChainCheck': {'enabled': true, 'time': '21:30'},
          'soundAndHaptics': false,
        },
        'streakFreezeCount': 2,
      };

      final model = UserSettingsModel.fromJson(json);
      expect(model.theme, 'light');
      expect(model.notifications.soundAndHaptics, false);
      expect(model.notifications.morningMotivation.time, '08:00');

      final entity = model.toEntity();
      final updated = entity.copyWith(theme: 'dark');
      expect(updated.theme, 'dark');
      expect(updated.notifications.smart, true);
    });
  });

  group('ProfileNotifier', () {
    late MockProfileRepository mockProfileRepo;
    late MockHabitRepository mockHabitRepo;
    late MockNotificationService mockNotificationService;
    late ProviderContainer container;

    setUp(() {
      mockProfileRepo = MockProfileRepository();
      mockHabitRepo = MockHabitRepository();
      mockNotificationService = MockNotificationService();

      container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockProfileRepo),
          habitRepositoryProvider.overrideWithValue(mockHabitRepo),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Loads profile, settings, and habits on loadData', () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      final state = container.read(profileNotifierProvider);
      expect(state.isLoading, false);
      expect(state.profile?.displayName, 'Test Kullanıcı');
      expect(state.settings?.theme, 'dark');
      expect(state.waterHabit?.dailyGoal, 2000);
      expect(state.bookHabit?.dailyGoal, 20);
      expect(state.settings?.notifications.morningMotivation.time, '08:00');
      expect(state.settings?.notifications.eveningChainCheck.time, '21:30');
    });

    test('Updates profile display name and username', () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      await notifier.updateProfile(
        displayName: 'Yeni İsim',
        username: 'yeni_kullanici',
      );

      final state = container.read(profileNotifierProvider);
      expect(state.profile?.displayName, 'Yeni İsim');
      expect(state.profile?.username, 'yeni_kullanici');
    });

    test('Updates notification settings', () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      await notifier.updateNotificationSettings(
        smart: false,
        soundAndHaptics: false,
      );

      final state = container.read(profileNotifierProvider);
      expect(state.settings?.notifications.smart, false);
      expect(state.settings?.notifications.soundAndHaptics, false);
    });

    test('Updates theme setting', () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      await notifier.updateTheme('light');

      final state = container.read(profileNotifierProvider);
      expect(state.settings?.theme, 'light');
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('Updates water and book goal targets', () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      await notifier.updateGoal(
        category: 'water',
        newGoal: 2500,
      );

      final state = container.read(profileNotifierProvider);
      expect(state.waterHabit?.dailyGoal, 2500);
      expect(mockProfileRepo.lastUpdatedGoal, 2500);
    });

    test('Export data invokes repository for csv and json', () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      await notifier.exportData('csv');
      var state = container.read(profileNotifierProvider);
      expect(state.exportedFormat, 'csv');
      expect(state.exportedData, 'exported csv data');
      expect(mockProfileRepo.lastExportFormat, 'csv');

      await notifier.exportData('json');
      state = container.read(profileNotifierProvider);
      expect(state.exportedFormat, 'json');
      expect(state.exportedData, 'exported json data');
      expect(mockProfileRepo.lastExportFormat, 'json');
    });

    test('Delete account calls repository deleteAccount and cancels notifications',
        () async {
      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadData();

      await notifier.deleteAccount();
      expect(mockProfileRepo.deleteAccountCalled, true);
      expect(mockNotificationService.cancelled, true);
    });
  });

  group('ProfileScreen Widget Tests', () {
    late MockProfileRepository mockProfileRepo;
    late MockHabitRepository mockHabitRepo;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockProfileRepo = MockProfileRepository();
      mockHabitRepo = MockHabitRepository();
      mockNotificationService = MockNotificationService();
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockProfileRepo),
          habitRepositoryProvider.overrideWithValue(mockHabitRepo),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: ProfileScreen(),
          ),
        ),
      );
    }

    testWidgets('Renders all profile sections properly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Profile Header
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.text('Test Kullanıcı'), findsOneWidget);
      expect(find.text('@test_kullanici'), findsOneWidget);

      // Quick Metrics
      expect(find.byType(QuickMetricsCard), findsOneWidget);
      expect(find.text('21 Gün'), findsOneWidget);
      expect(find.text('En İyi Seri'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Toplam Hedef'), findsOneWidget);
      expect(find.text('Seviye 4'), findsOneWidget);
      expect(find.text('Mevcut Seviye'), findsOneWidget);

      // Preferences Section
      expect(find.byType(PreferencesSection), findsOneWidget);
      expect(find.text('Tercihler & Hatırlatıcılar'), findsOneWidget);
      expect(find.text('Akıllı Bildirimler'), findsOneWidget);
      expect(find.text('Sabah Motivasyonu'), findsOneWidget);
      expect(find.text('Akşam Zincir Kontrolü'), findsOneWidget);
      expect(find.text('Titreşim & Ses Efektleri'), findsOneWidget);
      expect(find.text('Haftanın İlk Günü'), findsOneWidget);

      // Goal Management Section
      expect(find.byType(GoalManagementSection), findsOneWidget);
      expect(find.text('Hedef Yönetimi'), findsOneWidget);
      expect(find.text('Günlük Su Hedefi'), findsOneWidget);
      expect(find.text('Günlük Kitap Hedefi'), findsOneWidget);

      // Invite Friend Card (Placeholder)
      expect(find.byType(InviteFriendCard), findsOneWidget);
      expect(find.text('Birlikte Güçlüyüz'), findsOneWidget);
      expect(find.text('Yakında'), findsWidgets);

      // Account & System Section
      expect(find.byType(AccountSystemSection), findsOneWidget);
      expect(find.text('Hesap & Sistem'), findsOneWidget);
      expect(find.text('Uygulama Teması'), findsOneWidget);
      expect(find.text('Bulut Senkronizasyonu'), findsOneWidget);
      expect(find.text('Veri Dışa Aktarma'), findsOneWidget);
      expect(find.text('CSV İndir'), findsOneWidget);
      expect(find.text('JSON İndir'), findsOneWidget);
      expect(find.text('Çıkış Yap'), findsOneWidget);
      expect(find.text('Hesabı ve Tüm Verileri Sil'), findsOneWidget);
    });

    testWidgets('Opens edit profile dialog and updates name', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on edit button in ProfileHeader
      final editButton = find.byIcon(Icons.edit_outlined);
      expect(editButton, findsWidgets);
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Profili Düzenle'), findsOneWidget);
      final nameField = find.widgetWithText(TextField, 'Görünen Ad');
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Geliştirici İsim');
      await tester.pumpAndSettle();

      // Tap Kaydet
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      // Expect updated profile name
      expect(find.text('Geliştirici İsim'), findsOneWidget);
    });

    testWidgets('Toggles theme mode buttons (Sistem, Açık, Koyu)',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Sistem'), findsOneWidget);
      expect(find.text('Açık'), findsOneWidget);
      expect(find.text('Koyu'), findsOneWidget);

      // Tap 'Açık'
      await tester.tap(find.text('Açık'));
      await tester.pumpAndSettle();
      expect(mockProfileRepo.mockSettings.theme, 'light');

      // Tap 'Koyu'
      await tester.tap(find.text('Koyu'));
      await tester.pumpAndSettle();
      expect(mockProfileRepo.mockSettings.theme, 'dark');
    });

    testWidgets('Exports data in CSV and JSON formats', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap CSV İndir
      await tester.tap(find.text('CSV İndir'));
      await tester.pumpAndSettle();
      expect(mockProfileRepo.lastExportFormat, 'csv');
      expect(find.text('CSV Dışa Aktarıldı'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();

      // Tap JSON İndir
      await tester.tap(find.text('JSON İndir'));
      await tester.pumpAndSettle();
      expect(mockProfileRepo.lastExportFormat, 'json');
      expect(find.text('JSON Dışa Aktarıldı'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
    });

    testWidgets('Opens confirmation dialog before deleting account',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Hesabı ve Tüm Verileri Sil
      await tester.tap(find.text('Hesabı ve Tüm Verileri Sil'));
      await tester.pumpAndSettle();

      // Alert dialog opens
      expect(find.text('Hesabı Sil'), findsOneWidget);
      expect(
        find.text(
            'Hesabınızı ve tüm alışkanlık verilerinizi, tamamlama kayıtlarınızı ve ayarlarınızı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        findsOneWidget,
      );
      expect(find.text('Vazgeç'), findsOneWidget);
      expect(find.text('Kalıcı Olarak Sil'), findsOneWidget);

      // Tap Kalıcı Olarak Sil
      await tester.tap(find.text('Kalıcı Olarak Sil'));
      await tester.pumpAndSettle();

      expect(mockProfileRepo.deleteAccountCalled, true);
    });

    testWidgets('Opens goal editor dialog for water', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find the water edit button
      final editButtons = find.widgetWithText(OutlinedButton, 'Düzenle');
      expect(editButtons, findsWidgets);

      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Günlük Su Hedefi'), findsWidgets);
      expect(find.text('Günlük hedef miktarını belirleyin (ml):'), findsOneWidget);

      // Enter new values
      final targetField = find.byType(TextField);
      await tester.enterText(targetField.last, '2500');
      await tester.pumpAndSettle();

      // Tap Kaydet
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(mockProfileRepo.lastUpdatedGoal, 2500);
    });
  });
}
