import '../entities/user_level_entity.dart';
import '../repositories/badges_repository.dart';

class GetUserLevelUseCase {
  const GetUserLevelUseCase(this._repository);

  final BadgesRepository _repository;

  Future<UserLevelEntity> call() => _repository.getLevel();
}
