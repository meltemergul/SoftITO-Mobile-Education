import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/calendar_day_detail_model.dart';
import '../models/calendar_month_model.dart';

abstract class CalendarRemoteDataSource {
  Future<CalendarMonthModel> getMonthCalendar({String? month});
  Future<CalendarDayDetailModel> getDayDetail(String date);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  CalendarRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CalendarMonthModel> getMonthCalendar({String? month}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.calendar,
        queryParameters: month != null ? {'month': month} : null,
      );
      return CalendarMonthModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CalendarDayDetailModel> getDayDetail(String date) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.calendarDay(date),
      );
      return CalendarDayDetailModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
