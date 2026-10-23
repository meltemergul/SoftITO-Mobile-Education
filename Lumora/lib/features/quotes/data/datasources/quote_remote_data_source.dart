import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_error.dart';
import '../models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<QuoteModel> getDailyQuote({String? date});
  Future<bool> addFavorite(String quoteId);
  Future<bool> removeFavorite(String quoteId);
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  QuoteRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QuoteModel> getDailyQuote({String? date}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        ApiEndpoints.dailyQuote,
        queryParameters: date != null ? {'date': date} : null,
      );
      final data = response.data!;
      final quoteMap = (data['quote'] ?? data) as Map<String, dynamic>;
      return QuoteModel.fromJson(quoteMap);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<bool> addFavorite(String quoteId) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        ApiEndpoints.favoriteQuote(quoteId),
      );
      return (response.data?['isFavorite'] as bool?) ?? true;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<bool> removeFavorite(String quoteId) async {
    try {
      final response = await _apiClient.dio.delete<Map<String, dynamic>>(
        ApiEndpoints.favoriteQuote(quoteId),
      );
      return (response.data?['isFavorite'] as bool?) ?? false;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
