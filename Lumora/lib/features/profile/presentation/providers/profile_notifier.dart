import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../habits/domain/entities/habit_entity.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../../habits/presentation/providers/habit_notifier.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRemoteDataSourceImpl(apiClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remote = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remote);
});

@immutable
class ProfileState {
  const ProfileState({
    this.profile,
    this.settings,
    this.waterHabit,
    this.bookHabit,
    this.allHabits = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.infoMessage,
    this.exportedFormat,
    this.exportedData,
  });

  final UserProfileEntity? profile;
  final UserSettingsEntity? settings;
  final HabitEntity? waterHabit;
  final HabitEntity? bookHabit;
  final List<HabitEntity> allHabits;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? infoMessage;
  final String? exportedFormat;
  final String? exportedData;

  ProfileState copyWith({
    UserProfileEntity? profile,
    UserSettingsEntity? settings,
    HabitEntity? waterHabit,
    HabitEntity? bookHabit,
    List<HabitEntity>? allHabits,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? infoMessage,
    String? exportedFormat,
    String? exportedData,
    bool clearInfo = false,
    bool clearExport = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
      waterHabit: waterHabit ?? this.waterHabit,
      bookHabit: bookHabit ?? this.bookHabit,
      allHabits: allHabits ?? this.allHabits,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      exportedFormat: clearExport ? null : (exportedFormat ?? this.exportedFormat),
      exportedData: clearExport ? null : (exportedData ?? this.exportedData),
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _profileRepo;
  late final HabitRepository _habitRepo;
  late final NotificationService _notificationService;

  @override
  ProfileState build() {
    _profileRepo = ref.watch(profileRepositoryProvider);
    _habitRepo = ref.watch(habitRepositoryProvider);
    _notificationService = ref.watch(notificationServiceProvider);
    return const ProfileState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _profileRepo.getProfile(),
        _profileRepo.getSettings(),
        _habitRepo.getHabits(),
      ]);

      final profile = results[0] as UserProfileEntity;
      final settings = results[1] as UserSettingsEntity;
      final habits = results[2] as List<HabitEntity>;

      HabitEntity? water;
      HabitEntity? book;

      for (final h in habits) {
        if (!h.archived) {
          if (water == null && (h.category == 'water' || h.name.toLowerCase().contains('su'))) {
            water = h;
          }
          if (book == null && (h.category == 'book' || h.name.toLowerCase().contains('kitap'))) {
            book = h;
          }
        }
      }

      // Tema modunu güncelle
      ref.read(themeModeProvider.notifier).setThemeMode(parseThemeMode(settings.theme));

      state = state.copyWith(
        profile: profile,
        settings: settings,
        waterHabit: water,
        bookHabit: book,
        allHabits: habits,
        isLoading: false,
        errorMessage: null,
      );

      // Bildirimleri planla
      await rescheduleNotifications(settings, habits);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Profil bilgileri yüklenemedi.',
      );
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null, clearInfo: true);

    try {
      final updated = await _profileRepo.updateProfile(
        displayName: displayName,
        username: username,
        avatarUrl: avatarUrl,
      );

      state = state.copyWith(
        profile: updated,
        isSaving: false,
        infoMessage: 'Profil bilgileri güncellendi.',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Profil güncellenirken bir hata oluştu.',
      );
    }
  }

  Future<void> updateTheme(String newTheme) async {
    if (state.settings == null || state.settings!.theme == newTheme) return;

    final updatedSettings = state.settings!.copyWith(theme: newTheme);
    // UI temasını anında yansıt
    ref.read(themeModeProvider.notifier).setThemeMode(parseThemeMode(newTheme));

    state = state.copyWith(settings: updatedSettings);

    try {
      await _profileRepo.updateSettings(updatedSettings);
    } catch (e) {
      debugPrint('[ProfileNotifier] Tema kaydedilemedi: $e');
    }
  }

  Future<void> updateWeekStartsOn(int day) async {
    if (state.settings == null || state.settings!.weekStartsOn == day) return;

    final updatedSettings = state.settings!.copyWith(weekStartsOn: day);
    state = state.copyWith(settings: updatedSettings);

    try {
      await _profileRepo.updateSettings(updatedSettings);
    } catch (e) {
      debugPrint('[ProfileNotifier] Hafta başlangıcı kaydedilemedi: $e');
    }
  }

  Future<void> updateNotificationSettings({
    bool? smart,
    bool? morningEnabled,
    String? morningTime,
    bool? eveningEnabled,
    String? eveningTime,
    bool? soundAndHaptics,
  }) async {
    if (state.settings == null) return;

    final current = state.settings!;
    final updatedNotifications = current.notifications.copyWith(
      smart: smart,
      morningMotivation: current.notifications.morningMotivation.copyWith(
        enabled: morningEnabled,
        time: morningTime,
      ),
      eveningChainCheck: current.notifications.eveningChainCheck.copyWith(
        enabled: eveningEnabled,
        time: eveningTime,
      ),
      soundAndHaptics: soundAndHaptics,
    );

    final updatedSettings = current.copyWith(notifications: updatedNotifications);
    state = state.copyWith(settings: updatedSettings);

    try {
      await _profileRepo.updateSettings(updatedSettings);
      await rescheduleNotifications(updatedSettings, state.allHabits);
    } catch (e) {
      debugPrint('[ProfileNotifier] Bildirim ayarları kaydedilemedi: $e');
    }
  }

  Future<void> updateGoal({
    required String category,
    required double newGoal,
  }) async {
    final habit = category == 'water' ? state.waterHabit : state.bookHabit;
    if (habit == null) return;

    state = state.copyWith(isSaving: true, errorMessage: null, clearInfo: true);

    try {
      await _profileRepo.updateHabitGoal(
        habitId: habit.id,
        dailyGoal: newGoal,
      );

      final updatedHabit = habit.copyWith(dailyGoal: newGoal);
      if (category == 'water') {
        state = state.copyWith(waterHabit: updatedHabit, isSaving: false);
      } else {
        state = state.copyWith(bookHabit: updatedHabit, isSaving: false);
      }

      state = state.copyWith(
        infoMessage: '${habit.name} hedefi güncellendi.',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Hedef güncellenirken bir hata oluştu.',
      );
    }
  }

  Future<void> exportData(String format) async {
    state = state.copyWith(isSaving: true, errorMessage: null, clearInfo: true);

    try {
      final content = await _profileRepo.exportData(format);
      state = state.copyWith(
        isSaving: false,
        exportedFormat: format,
        exportedData: content,
        infoMessage: '${format.toUpperCase()} formatında dışa aktarım hazırlandı.',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Veri dışa aktarılırken bir hata oluştu.',
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _profileRepo.deleteAccount();
      await _notificationService.cancelAll();

      // Oturumu kapat
      ref.read(authStateProvider.notifier).setAuthenticated(false);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Hesap silinirken bir hata oluştu.',
      );
      rethrow;
    }
  }

  Future<void> rescheduleNotifications(
    UserSettingsEntity settings,
    List<HabitEntity> habits,
  ) async {
    // architecture-skill.md Bölüm 10:
    // "Bildirimler: Hatırlatma saatleri cihazda yerel bildirim olarak planlanır.
    // Alışkanlık veya ayar değişince bildirimler yeniden planlanır.
    // 21:30 zincir kontrolü, o gün tamamlanmamış planlı alışkanlık varsa gösterilir."
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1: Pazartesi ... 7: Pazar

    // O gün planlı alışkanlıkların varlığını kontrol et
    final todayPlannedHabits = habits.where((h) => !h.archived && h.repeatDays.contains(todayWeekday)).toList();
    final hasUncompletedPlanned = todayPlannedHabits.isNotEmpty;

    // Sabah motivasyonu
    await _notificationService.scheduleMorningMotivation(
      enabled: settings.notifications.morningMotivation.enabled,
      time: settings.notifications.morningMotivation.time,
    );

    // Akşam zincir kontrolü
    await _notificationService.scheduleEveningChainCheck(
      enabled: settings.notifications.eveningChainCheck.enabled,
      time: settings.notifications.eveningChainCheck.time,
      hasUncompletedPlannedHabits: hasUncompletedPlanned,
    );

    // Alışkanlık hatırlatıcıları
    for (final h in habits) {
      if (!h.archived && h.reminderTime != null) {
        await _notificationService.scheduleHabitReminder(
          habitId: h.id,
          habitName: h.name,
          reminderTime: h.reminderTime!,
          repeatDays: h.repeatDays,
        );
      }
    }
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
