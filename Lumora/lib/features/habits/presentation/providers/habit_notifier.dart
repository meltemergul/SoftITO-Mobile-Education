import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../data/datasources/habit_remote_data_source.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/usecases/create_habit_usecase.dart';
import '../../domain/usecases/delete_habit_usecase.dart';
import '../../domain/usecases/get_habit_templates_usecase.dart';
import '../../domain/usecases/get_habits_usecase.dart';
import '../../domain/usecases/update_habit_usecase.dart';

// Repository Provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final dataSource = HabitRemoteDataSourceImpl(apiClient);
  return HabitRepositoryImpl(dataSource);
});

// Use Case Providers
final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>((ref) {
  return GetHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final getHabitTemplatesUseCaseProvider = Provider<GetHabitTemplatesUseCase>((ref) {
  return GetHabitTemplatesUseCase(ref.watch(habitRepositoryProvider));
});

final createHabitUseCaseProvider = Provider<CreateHabitUseCase>((ref) {
  return CreateHabitUseCase(ref.watch(habitRepositoryProvider));
});

final updateHabitUseCaseProvider = Provider<UpdateHabitUseCase>((ref) {
  return UpdateHabitUseCase(ref.watch(habitRepositoryProvider));
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  return DeleteHabitUseCase(ref.watch(habitRepositoryProvider));
});

// Templates FutureProvider
final habitTemplatesProvider = FutureProvider<List<HabitTemplateEntity>>((ref) async {
  final useCase = ref.watch(getHabitTemplatesUseCaseProvider);
  return useCase();
});

// State for Habit List
@immutable
sealed class HabitListState {
  const HabitListState();
}

class HabitListInitial extends HabitListState {
  const HabitListInitial();
}

class HabitListLoading extends HabitListState {
  const HabitListLoading();
}

class HabitListData extends HabitListState {
  const HabitListData(this.habits);
  final List<HabitEntity> habits;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitListData && listEquals(habits, other.habits);

  @override
  int get hashCode => habits.hashCode;
}

class HabitListError extends HabitListState {
  const HabitListError(this.message);
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitListError && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

// Habit Notifier
class HabitNotifier extends Notifier<HabitListState> {
  @override
  HabitListState build() {
    // Sayfa açıldığında otomatik yükleme yapılabilir
    return const HabitListInitial();
  }

  Future<void> loadHabits({bool includeArchived = false}) async {
    state = const HabitListLoading();
    try {
      final getHabits = ref.read(getHabitsUseCaseProvider);
      final habits = await getHabits(includeArchived: includeArchived);
      state = HabitListData(habits);

      // Mevcut hatırlatıcıları yeniden planla
      final notificationService = ref.read(notificationServiceProvider);
      for (final habit in habits) {
        if (!habit.archived && habit.reminderTime != null && habit.reminderTime!.isNotEmpty) {
          await notificationService.scheduleHabitReminder(
            habitId: habit.id,
            habitName: habit.name,
            reminderTime: habit.reminderTime!,
            repeatDays: habit.repeatDays,
          );
        }
      }
    } on ApiException catch (e) {
      state = HabitListError(e.message);
    } catch (e) {
      state = HabitListError(e.toString());
    }
  }

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
    try {
      final createHabitUseCase = ref.read(createHabitUseCaseProvider);
      final created = await createHabitUseCase(
        name: name,
        icon: icon,
        category: category,
        unit: unit,
        dailyGoal: dailyGoal,
        step: step,
        repeatDays: repeatDays,
        reminderTime: reminderTime,
      );

      // Bildirim planla
      if (created.reminderTime != null && created.reminderTime!.isNotEmpty) {
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.scheduleHabitReminder(
          habitId: created.id,
          habitName: created.name,
          reminderTime: created.reminderTime!,
          repeatDays: created.repeatDays,
        );
      }

      // Listeyi güncelle
      final currentList = state is HabitListData
          ? (state as HabitListData).habits
          : <HabitEntity>[];
      state = HabitListData([...currentList, created]);

      return created;
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw e.toString();
    }
  }

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
    try {
      final updateHabitUseCase = ref.read(updateHabitUseCaseProvider);
      final updated = await updateHabitUseCase(
        id,
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

      final notificationService = ref.read(notificationServiceProvider);
      if (updated.archived || updated.reminderTime == null || updated.reminderTime!.isEmpty) {
        await notificationService.cancelHabitReminder(id);
      } else {
        await notificationService.scheduleHabitReminder(
          habitId: updated.id,
          habitName: updated.name,
          reminderTime: updated.reminderTime!,
          repeatDays: updated.repeatDays,
        );
      }

      // Listeyi güncelle
      if (state is HabitListData) {
        final currentList = (state as HabitListData).habits;
        final index = currentList.indexWhere((h) => h.id == id);
        if (index != -1) {
          final newList = [...currentList];
          if (updated.archived) {
            newList.removeAt(index);
          } else {
            newList[index] = updated;
          }
          state = HabitListData(newList);
        }
      }

      return updated;
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      final deleteHabitUseCase = ref.read(deleteHabitUseCaseProvider);
      await deleteHabitUseCase(id);

      // Bildirimi iptal et
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelHabitReminder(id);

      // Listeden çıkar
      if (state is HabitListData) {
        final currentList = (state as HabitListData).habits;
        state = HabitListData(currentList.where((h) => h.id != id).toList());
      }
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw e.toString();
    }
  }
}

final habitNotifierProvider =
    NotifierProvider<HabitNotifier, HabitListState>(HabitNotifier.new);
