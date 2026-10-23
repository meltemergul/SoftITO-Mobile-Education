import '../entities/badge_entity.dart';
import '../entities/user_level_entity.dart';

abstract class BadgesRepository {
  Future<List<BadgeEntity>> getBadges();
  Future<UserLevelEntity> getLevel();
}
