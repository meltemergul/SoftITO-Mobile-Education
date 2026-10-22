import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code = 'UNKNOWN_ERROR',
    this.statusCode,
  });

  final String message;
  final String code;
  final int? statusCode;

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('error') && data['error'] is Map) {
        final err = data['error'] as Map;
        return ApiException(
          code: (err['code'] as String?) ?? 'API_ERROR',
          message: (err['message'] as String?) ?? 'Bir hata oluştu.',
          statusCode: response.statusCode,
        );
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          code: 'TIMEOUT',
          message: 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          code: 'NETWORK_ERROR',
          message: 'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı ve sunucuyu kontrol edin.',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          code: 'CANCELLED',
          message: 'İşlem iptal edildi.',
        );
      default:
        return ApiException(
          code: 'UNEXPECTED_ERROR',
          message: e.message ?? 'Beklenmeyen bir ağ hatası meydana geldi.',
          statusCode: response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
