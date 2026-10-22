import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _tokenStorage.saveToken(response.token, persist: rememberMe);
    return response.user;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  }) async {
    final response = await _remoteDataSource.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _tokenStorage.saveToken(response.token, persist: rememberMe);
    return response.user;
  }

  @override
  Future<UserEntity> guest() async {
    final response = await _remoteDataSource.guest();
    // Misafir oturumu oturum süresince veya kalıcı saklanabilir
    await _tokenStorage.saveToken(response.token, persist: true);
    return response.user;
  }

  @override
  Future<UserEntity> upgradeGuest({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _remoteDataSource.upgradeGuest(
      email: email,
      password: password,
      displayName: displayName,
    );
    await _tokenStorage.saveToken(response.token, persist: true);
    return response.user;
  }

  @override
  Future<String> forgotPassword({required String email}) {
    return _remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  @override
  Future<bool> isAuthenticated() {
    return _tokenStorage.hasToken();
  }
}
