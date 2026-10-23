import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_level_entity.dart';
import '../../domain/repositories/badges_repository.dart';
import '../datasources/badges_remote_data_source.dart';

class BadgesRepositoryImpl implements BadgesRepository {
  BadgesRepositoryImpl(this._remoteDataSource);

  final BadgesRemoteDataSource _remoteDataSource;

  @override
  Future<List<BadgeEntity>> getBadges() async {
    final models = await _remoteDataSource.getBadges();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<UserLevelEntity> getLevel() async {
    final model = await _remoteDataSource.getLevel();
    return model.toEntity();
  }
}
