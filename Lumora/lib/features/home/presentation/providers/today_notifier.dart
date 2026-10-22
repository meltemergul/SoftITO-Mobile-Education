import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/storage/today_cache_storage.dart';
import '../../data/datasources/today_remote_data_source.dart';
import '../../data/repositories/today_repository_impl.dart';
import '../../domain/entities/today_entity.dart';
import '../../domain/repositories/today_repository.dart';
import '../../domain/usecases/get_today_usecase.dart';
import '../../domain/usecases/update_habit_log_usecase.dart';

// Storage Provider
final todayCacheStorageProvider = Provider<TodayCacheStorage>((ref) {
  return TodayCacheStorage();
});

// DataSource & Repository Providers
final todayRemoteDataSourceProvider = Provider<TodayRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TodayRemoteDataSourceImpl(apiClient);
});

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  final remote = ref.watch(todayRemoteDataSourceProvider);
  final cache = ref.watch(todayCacheStorageProvider);
  return TodayRepositoryImpl(
    remoteDataSource: remote,
    cacheStorage: cache,
  );
});

// Use Cases
final getTodayUseCaseProvider = Provider<GetTodayUseCase>((ref) {
  return GetTodayUseCase(ref.watch(todayRepositoryProvider));
});

final updateHabitLogUseCaseProvider = Provider<UpdateHabitLogUseCase>((ref) {
  return UpdateHabitLogUseCase(ref.watch(todayRepositoryProvider));
});

// Today State
@immutable
class TodayState {
  const TodayState({
    this.isLoading = false,
    this.isOffline = false,
    this.todayData,
    this.errorMessage,
    this.showCelebration = false,
  });

  final bool isLoading;
  final bool isOffline;
  final TodayEntity? todayData;
  final String? errorMessage;
  final bool showCelebration;

  TodayState copyWith({
    bool? isLoading,
    bool? isOffline,
    TodayEntity? todayData,
    String? errorMessage,
    bool? showCelebration,
  }) {
    return TodayState(
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      todayData: todayData ?? this.todayData,
      errorMessage: errorMessage,
      showCelebration: showCelebration ?? this.showCelebration,
    );
  }
}

// Today Notifier
class TodayNotifier extends Notifier<TodayState> {
  late final GetTodayUseCase _getTodayUseCase;
  late final UpdateHabitLogUseCase _updateHabitLogUseCase;

  @override
  TodayState build() {
    _getTodayUseCase = ref.watch(getTodayUseCaseProvider);
    _updateHabitLogUseCase = ref.watch(updateHabitLogUseCaseProvider);

    return const TodayState(isLoading: false);
  }

  Future<void> loadToday({bool force = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final data = await _getTodayUseCase(forceRefresh: force);
      state = state.copyWith(
        isLoading: false,
        isOffline: false,
        todayData: data,
        errorMessage: null,
      );
    } on ApiException catch (e) {
      final isNetwork = e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT';
      state = state.copyWith(
        isLoading: false,
        isOffline: isNetwork,
        errorMessage: isNetwork ? null : e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// İşaretleme türü alışkanlık dokunulduğunda (Optimistic UI)
  Future<void> toggleHabit(TodayHabitItemEntity habit) async {
    final currentData = state.todayData;
    if (currentData == null) return;

    final willComplete = !habit.isCompletedToday;
    final targetAmount = willComplete ? habit.dailyGoal : 0.0;

    // Önceki durumu sakla (hata olursa geri alma için)
    final previousState = state;

    // Optimistic güncelleme hesaplaması
    final updatedHabits = currentData.habits.map((h) {
      if (h.id == habit.id) {
        return h.copyWith(
          isCompletedToday: willComplete,
          currentAmount: targetAmount,
          currentStreak: willComplete
              ? habit.currentStreak + 1
              : (habit.currentStreak > 0 ? habit.currentStreak - 1 : 0),
        );
      }
      return h;
    }).toList();

    // İlerleme hesaplama
    final plannedHabits = updatedHabits.where((h) => h.isPlannedToday).toList();
    final completedCount = plannedHabits.where((h) => h.isCompletedToday).length;
    final totalPlanned = plannedHabits.length;
    final percent = totalPlanned > 0
        ? ((completedCount / totalPlanned) * 100).round()
        : 100;
    final isAllCompleted = completedCount == totalPlanned && totalPlanned > 0;

    // XP güncelleme
    final xpDelta = willComplete ? 15 : -15;
    final newTotalXp = (currentData.xp.totalXp + xpDelta).clamp(0, 999999);
    final updatedXp = currentData.xp.copyWith(totalXp: newTotalXp);

    final updatedData = currentData.copyWith(
      habits: updatedHabits,
      progress: currentData.progress.copyWith(
        completed: completedCount,
        total: totalPlanned,
        percentage: percent,
        isAllCompleted: isAllCompleted,
      ),
      xp: updatedXp,
    );

    // State'i anında güncelle (Optimistic UI)
    state = state.copyWith(
      todayData: updatedData,
      showCelebration: isAllCompleted && !currentData.progress.isAllCompleted,
    );

    // Arka planda sunucuya gönder
    try {
      await _updateHabitLogUseCase(
        habitId: habit.id,
        date: currentData.date,
        amount: targetAmount,
      );
    } catch (e) {
      // Hata oluştu -> Optimistic state'i geri al
      state = previousState.copyWith(
        errorMessage: 'İşlem sunucuya iletilemedi. Değişiklik geri alındı.',
      );
    }
  }

  /// Sayaç türü alışkanlık için hızlı miktar artırma / azaltma (Optimistic UI)
  Future<void> adjustCounter(TodayHabitItemEntity habit, double delta) async {
    final currentData = state.todayData;
    if (currentData == null) return;

    final previousState = state;
    final newAmount = (habit.currentAmount + delta).clamp(0.0, 999999.0);
    final wasCompleted = habit.isCompletedToday;
    final isNowCompleted = newAmount >= habit.dailyGoal;

    final updatedHabits = currentData.habits.map((h) {
      if (h.id == habit.id) {
        return h.copyWith(
          currentAmount: newAmount,
          isCompletedToday: isNowCompleted,
          currentStreak: !wasCompleted && isNowCompleted
              ? habit.currentStreak + 1
              : (wasCompleted && !isNowCompleted
                  ? (habit.currentStreak > 0 ? habit.currentStreak - 1 : 0)
                  : habit.currentStreak),
        );
      }
      return h;
    }).toList();

    final plannedHabits = updatedHabits.where((h) => h.isPlannedToday).toList();
    final completedCount = plannedHabits.where((h) => h.isCompletedToday).length;
    final totalPlanned = plannedHabits.length;
    final percent = totalPlanned > 0
        ? ((completedCount / totalPlanned) * 100).round()
        : 100;
    final isAllCompleted = completedCount == totalPlanned && totalPlanned > 0;

    // XP değişimi (yalnızca tamamlanma durumu değişirse)
    int xpDelta = 0;
    if (!wasCompleted && isNowCompleted) {
      xpDelta = 15;
    } else if (wasCompleted && !isNowCompleted) {
      xpDelta = -15;
    }

    final newTotalXp = (currentData.xp.totalXp + xpDelta).clamp(0, 999999);
    final updatedXp = currentData.xp.copyWith(totalXp: newTotalXp);

    final updatedData = currentData.copyWith(
      habits: updatedHabits,
      progress: currentData.progress.copyWith(
        completed: completedCount,
        total: totalPlanned,
        percentage: percent,
        isAllCompleted: isAllCompleted,
      ),
      xp: updatedXp,
    );

    // Optimistic UI
    state = state.copyWith(
      todayData: updatedData,
      showCelebration: isAllCompleted && !currentData.progress.isAllCompleted,
    );

    try {
      await _updateHabitLogUseCase(
        habitId: habit.id,
        date: currentData.date,
        delta: delta,
      );
    } catch (e) {
      state = previousState.copyWith(
        errorMessage: 'İşlem sunucuya iletilemedi. Değişiklik geri alındı.',
      );
    }
  }

  void dismissCelebration() {
    state = state.copyWith(showCelebration: false);
  }
}

final todayNotifierProvider =
    NotifierProvider<TodayNotifier, TodayState>(TodayNotifier.new);
