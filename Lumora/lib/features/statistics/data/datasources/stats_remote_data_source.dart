import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/stats_model.dart';

abstract class StatsRemoteDataSource {
  Future<StatsModel> getStats({String range = 'weekly'});
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  StatsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<StatsModel> getStats({String range = 'weekly'}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.statsWithRange(range),
      );
      return StatsModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
