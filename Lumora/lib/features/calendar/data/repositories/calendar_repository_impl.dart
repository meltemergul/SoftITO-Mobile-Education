import '../../domain/entities/calendar_day_detail_entity.dart';
import '../../domain/entities/calendar_month_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_data_source.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._remoteDataSource);

  final CalendarRemoteDataSource _remoteDataSource;

  @override
  Future<CalendarMonthEntity> getMonthCalendar({String? month}) {
    return _remoteDataSource.getMonthCalendar(month: month);
  }

  @override
  Future<CalendarDayDetailEntity> getDayDetail(String date) {
    return _remoteDataSource.getDayDetail(date);
  }
}
