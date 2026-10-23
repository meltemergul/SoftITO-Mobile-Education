import '../entities/calendar_day_detail_entity.dart';
import '../entities/calendar_month_entity.dart';

abstract class CalendarRepository {
  Future<CalendarMonthEntity> getMonthCalendar({String? month});
  Future<CalendarDayDetailEntity> getDayDetail(String date);
}
