import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Güvenli token saklama servisi.
/// "Beni hatırla" kapalıysa token yalnızca bellek üzerinde tutulur;
/// açıksa flutter_secure_storage (Keychain / Keystore) ile kalıcı saklanır.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ??
            const FlutterSecureStorage(
              mOptions: MacOsOptions(
                usesDataProtectionKeychain: false,
              ),
            );

  final FlutterSecureStorage _storage;
  static const String _keyToken = 'lumora_jwt_token';

  String? _inMemoryToken;

  /// Token kaydetme
  /// [persist]: true ise FlutterSecureStorage'a yazar, false ise yalnızca bellekte tutar.
  Future<void> saveToken(String token, {bool persist = true}) async {
    _inMemoryToken = token;
    if (persist) {
      try {
        await _storage.write(key: _keyToken, value: token);
      } catch (_) {
        // macOS Keychain entitlement veya developer team hatası durumunda in-memory çalışmaya devam eder
      }
    } else {
      try {
        await _storage.delete(key: _keyToken);
      } catch (_) {}
    }
  }

  /// Token okuma
  Future<String?> getToken() async {
    if (_inMemoryToken != null) {
      return _inMemoryToken;
    }
    try {
      final persisted = await _storage.read(key: _keyToken);
      _inMemoryToken = persisted;
      return persisted;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  /// Token silme (çıkış yapıldığında)
  Future<void> clearToken() async {
    _inMemoryToken = null;
    try {
      await _storage.delete(key: _keyToken);
    } catch (_) {}
  }

  /// Token var mı kontrolü
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
