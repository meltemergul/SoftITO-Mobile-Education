import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/habit_model.dart';
import '../models/habit_template_model.dart';

abstract class HabitRemoteDataSource {
  Future<List<HabitModel>> getHabits({bool includeArchived = false});
  Future<HabitModel> getHabitById(String id);
  Future<HabitModel> createHabit(Map<String, dynamic> body);
  Future<HabitModel> updateHabit(String id, Map<String, dynamic> body);
  Future<void> archiveHabit(String id);
  Future<List<HabitTemplateModel>> getTemplates();
}

class HabitRemoteDataSourceImpl implements HabitRemoteDataSource {
  HabitRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<HabitModel>> getHabits({bool includeArchived = false}) async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        ApiEndpoints.habits,
        queryParameters: includeArchived ? {'includeArchived': 'true'} : null,
      );
      final data = response.data ?? [];
      return data
          .map((item) => HabitModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<HabitModel> getHabitById(String id) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.habits}/$id',
      );
      return HabitModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<HabitModel> createHabit(Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.habits,
        data: body,
      );
      return HabitModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<HabitModel> updateHabit(String id, Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.habits}/$id',
        data: body,
      );
      return HabitModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> archiveHabit(String id) async {
    try {
      await _apiClient.dio.delete<dynamic>(
        '${ApiEndpoints.habits}/$id',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<HabitTemplateModel>> getTemplates() async {
    try {
      final response = await _apiClient.dio.get<List<dynamic>>(
        ApiEndpoints.habitTemplates,
      );
      final data = response.data ?? [];
      return data
          .map((item) => HabitTemplateModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
