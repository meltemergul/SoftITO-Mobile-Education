import '../entities/today_entity.dart';
import '../repositories/today_repository.dart';

class GetTodayUseCase {
  GetTodayUseCase(this._repository);

  final TodayRepository _repository;

  Future<TodayEntity> call({bool forceRefresh = false}) {
    return _repository.getToday(forceRefresh: forceRefresh);
  }
}
