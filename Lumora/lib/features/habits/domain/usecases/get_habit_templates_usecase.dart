import '../entities/habit_entity.dart';
import '../repositories/habit_repository.dart';

class GetHabitTemplatesUseCase {
  GetHabitTemplatesUseCase(this.repository);

  final HabitRepository repository;

  Future<List<HabitTemplateEntity>> call() {
    return repository.getTemplates();
  }
}
