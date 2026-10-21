sealed class AppException implements Exception {
  final String message;
  final dynamic originalError;

  const AppException(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class NetworkError extends AppException {
  const NetworkError([super.message = 'İnternet bağlantısı kurulamadı.', super.originalError]);
}

class AuthError extends AppException {
  const AuthError([super.message = 'Kimlik doğrulama hatası oluştu.', super.originalError]);
}

class ValidationError extends AppException {
  const ValidationError(super.message, [super.originalError]);
}

class RateLimitError extends AppException {
  const RateLimitError([super.message = 'İstek limiti aşıldı. Lütfen biraz bekleyin.', super.originalError]);
}

class UnknownError extends AppException {
  const UnknownError([super.message = 'Beklenmeyen bir hata oluştu.', super.originalError]);
}
