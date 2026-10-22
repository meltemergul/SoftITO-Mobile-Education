import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class UpdateHabitUseCase {
  UpdateHabitUseCase(this.repository);

  final HabitRepository repository;

  Future<HabitEntity> call(
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
  }) {
    return repository.updateHabit(
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
  }
}
