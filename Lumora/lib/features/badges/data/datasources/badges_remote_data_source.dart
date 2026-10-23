import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/badge_model.dart';
import '../models/user_level_model.dart';

abstract class BadgesRemoteDataSource {
  Future<List<BadgeModel>> getBadges();
  Future<UserLevelModel> getLevel();
}

class BadgesRemoteDataSourceImpl implements BadgesRemoteDataSource {
  BadgesRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<BadgeModel>> getBadges() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.badges,
      );
      final rawList = response.data?['badges'] as List<dynamic>? ?? [];
      return rawList
          .map((item) => BadgeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserLevelModel> getLevel() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.level,
      );
      return UserLevelModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
