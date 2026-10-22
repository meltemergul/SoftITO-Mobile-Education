import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_data_source.dart';

class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._remoteDataSource);

  final HabitRemoteDataSource _remoteDataSource;

  @override
  Future<List<HabitEntity>> getHabits({bool includeArchived = false}) async {
    final models = await _remoteDataSource.getHabits(includeArchived: includeArchived);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<HabitEntity> getHabitById(String id) async {
    final model = await _remoteDataSource.getHabitById(id);
    return model.toEntity();
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
    final body = {
      'name': name,
      'icon': icon,
      'category': category,
      if (unit != null && unit.isNotEmpty) 'unit': unit,
      'dailyGoal': dailyGoal,
      'step': step,
      'repeatDays': repeatDays,
      if (reminderTime != null && reminderTime.isNotEmpty)
        'reminderTime': reminderTime,
    };

    final model = await _remoteDataSource.createHabit(body);
    return model.toEntity();
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
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (dailyGoal != null) 'dailyGoal': dailyGoal,
      if (step != null) 'step': step,
      if (repeatDays != null) 'repeatDays': repeatDays,
      if (reminderTime != null) 'reminderTime': reminderTime,
      if (archived != null) 'archived': archived,
    };

    final model = await _remoteDataSource.updateHabit(id, body);
    return model.toEntity();
  }

  @override
  Future<void> archiveHabit(String id) async {
    await _remoteDataSource.archiveHabit(id);
  }

  @override
  Future<List<HabitTemplateEntity>> getTemplates() async {
    final models = await _remoteDataSource.getTemplates();
    return models.map((m) => m.toEntity()).toList();
  }
}
