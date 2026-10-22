import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  CreateHabitUseCase(this.repository);

  final HabitRepository repository;

  Future<HabitEntity> call({
    required String name,
    required String icon,
    required String category,
    String? unit,
    required double dailyGoal,
    required double step,
    required List<int> repeatDays,
    String? reminderTime,
  }) {
    return repository.createHabit(
      name: name,
      icon: icon,
      category: category,
      unit: unit,
      dailyGoal: dailyGoal,
      step: step,
      repeatDays: repeatDays,
      reminderTime: reminderTime,
    );
  }
}
