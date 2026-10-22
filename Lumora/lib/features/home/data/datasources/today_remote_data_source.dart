import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/today_model.dart';

abstract class TodayRemoteDataSource {
  Future<TodayModel> getToday();
  Future<void> updateLog(String habitId, String date, {double? amount, double? delta});
}

class TodayRemoteDataSourceImpl implements TodayRemoteDataSource {
  TodayRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<TodayModel> getToday() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.today,
      );
      return TodayModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> updateLog(
    String habitId,
    String date, {
    double? amount,
    double? delta,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (amount != null) body['amount'] = amount;
      if (delta != null) body['delta'] = delta;

      await _apiClient.dio.put<dynamic>(
        '${ApiEndpoints.habits}/$habitId/logs/$date',
        data: body,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
