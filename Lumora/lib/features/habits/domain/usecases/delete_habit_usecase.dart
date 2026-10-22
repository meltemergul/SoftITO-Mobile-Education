import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  DeleteHabitUseCase(this.repository);

  final HabitRepository repository;

  Future<void> call(String id) {
    return repository.archiveHabit(id);
  }
}
