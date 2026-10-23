import '../entities/badge_entity.dart';
import '../repositories/badges_repository.dart';

class GetBadgesUseCase {
  const GetBadgesUseCase(this._repository);

  final BadgesRepository _repository;

  Future<List<BadgeEntity>> call() => _repository.getBadges();
}
