import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Güvenli token saklama servisi.
/// "Beni hatırla" kapalıysa token yalnızca bellek üzerinde tutulur;
/// açıksa flutter_secure_storage (Keychain / Keystore) ile kalıcı saklanır.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const String _keyToken = 'lumora_jwt_token';

  String? _inMemoryToken;

  /// Token kaydetme
  /// [persist]: true ise FlutterSecureStorage'a yazar, false ise yalnızca bellekte tutar.
  Future<void> saveToken(String token, {bool persist = true}) async {
    _inMemoryToken = token;
    if (persist) {
      await _storage.write(key: _keyToken, value: token);
    } else {
      await _storage.delete(key: _keyToken);
    }
  }

  /// Token okuma
  Future<String?> getToken() async {
    if (_inMemoryToken != null) {
      return _inMemoryToken;
    }
    final persisted = await _storage.read(key: _keyToken);
    _inMemoryToken = persisted;
    return persisted;
  }

  /// Token silme (çıkış yapıldığında)
  Future<void> clearToken() async {
    _inMemoryToken = null;
    await _storage.delete(key: _keyToken);
  }

  /// Token var mı kontrolü
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
