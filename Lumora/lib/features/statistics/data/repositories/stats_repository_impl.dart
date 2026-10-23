import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_remote_data_source.dart';

class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._remoteDataSource);

  final StatsRemoteDataSource _remoteDataSource;

  @override
  Future<StatsEntity> getStats({String range = 'weekly'}) {
    return _remoteDataSource.getStats(range: range);
  }
}
