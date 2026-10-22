import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Future<List<HabitEntity>> getHabits({bool includeArchived = false});
  Future<HabitEntity> getHabitById(String id);
  Future<HabitEntity> createHabit({
    required String name,
    required String icon,
    required String category,
    String? unit,
    required double dailyGoal,
    required double step,
    required List<int> repeatDays,
    String? reminderTime,
  });
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
  });
  Future<void> archiveHabit(String id);
  Future<List<HabitTemplateEntity>> getTemplates();
}
