import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  });

  Future<UserEntity> guest();

  Future<UserEntity> upgradeGuest({
    required String email,
    required String password,
    required String displayName,
  });

  Future<String> forgotPassword({required String email});

  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> logout();

  Future<bool> isAuthenticated();
}
