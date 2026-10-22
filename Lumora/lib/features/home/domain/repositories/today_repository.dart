import '../entities/today_entity.dart';

abstract class TodayRepository {
  Future<TodayEntity> getToday({bool forceRefresh = false});
  Future<void> updateLog(String habitId, String date, {double? amount, double? delta});
  Future<void> syncPendingOps();
}
