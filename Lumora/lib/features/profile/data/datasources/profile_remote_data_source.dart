import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/user_profile_model.dart';
import '../models/user_settings_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  });
  Future<UserSettingsModel> getSettings();
  Future<UserSettingsModel> updateSettings(UserSettingsModel settings);
  Future<String> exportData(String format);
  Future<void> deleteAccount();
  Future<void> updateHabitGoal({
    required String habitId,
    required double dailyGoal,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.profile,
      );
      return UserProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? displayName,
    String? username,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        if (displayName != null) 'displayName': displayName,
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      };

      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.profile,
        data: body,
      );
      return UserProfileModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserSettingsModel> getSettings() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.settings,
      );
      return UserSettingsModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserSettingsModel> updateSettings(UserSettingsModel settings) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        ApiEndpoints.settings,
        data: settings.toJson(),
      );
      return UserSettingsModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<String> exportData(String format) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        ApiEndpoints.exportData(format),
        options: Options(responseType: ResponseType.plain),
      );
      return response.data.toString();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _apiClient.dio.delete<dynamic>(ApiEndpoints.account);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> updateHabitGoal({
    required String habitId,
    required double dailyGoal,
  }) async {
    try {
      await _apiClient.dio.patch<dynamic>(
        '${ApiEndpoints.habits}/$habitId',
        data: {'dailyGoal': dailyGoal},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
