import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class GetHabitsUseCase {
  GetHabitsUseCase(this.repository);

  final HabitRepository repository;

  Future<List<HabitEntity>> call({bool includeArchived = false}) {
    return repository.getHabits(includeArchived: includeArchived);
  }
}
