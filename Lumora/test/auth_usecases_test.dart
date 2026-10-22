import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/features/auth/domain/entities/user_entity.dart';
import 'package:lumora/features/auth/domain/repositories/auth_repository.dart';
import 'package:lumora/features/auth/domain/usecases/login_usecase.dart';
import 'package:lumora/features/auth/domain/usecases/register_usecase.dart';
import 'package:lumora/features/auth/domain/usecases/guest_usecase.dart';
import 'package:lumora/features/auth/domain/usecases/upgrade_guest_usecase.dart';
import 'package:lumora/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:lumora/features/auth/domain/usecases/reset_password_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  final UserEntity dummyUser = const UserEntity(
    id: 'usr_test_1',
    email: 'selin@example.com',
    displayName: 'Selin Yılmaz',
    username: 'selin',
    avatarUrl: null,
    isGuest: false,
    createdAt: '2026-10-22T20:00:00.000Z',
  );

  bool authenticated = false;
  bool shouldThrow = false;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (shouldThrow) throw Exception('Geçersiz e-posta veya şifre.');
    authenticated = true;
    return dummyUser;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  }) async {
    if (shouldThrow) throw Exception('Bu e-posta adresi zaten kullanımda.');
    authenticated = true;
    return dummyUser;
  }

  @override
  Future<UserEntity> guest() async {
    authenticated = true;
    return const UserEntity(
      id: 'usr_guest_1',
      displayName: 'Misafir Kullanıcı',
      isGuest: true,
      createdAt: '2026-10-22T20:00:00.000Z',
    );
  }

  @override
  Future<UserEntity> upgradeGuest({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (shouldThrow) throw Exception('Yükseltme başarısız.');
    return dummyUser;
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    if (shouldThrow) throw Exception('Hata');
    return 'Şifre sıfırlama talimatları gönderildi.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (shouldThrow) throw Exception('Geçersiz kod.');
    return 'Şifreniz başarıyla güncellendi.';
  }

  @override
  Future<void> logout() async {
    authenticated = false;
  }

  @override
  Future<bool> isAuthenticated() async {
    return authenticated;
  }
}

void main() {
  late FakeAuthRepository repository;

  setUp(() {
    repository = FakeAuthRepository();
  });

  group('Auth UseCases Unit Testleri', () {
    test('LoginUseCase başarılı giriş yapar ve UserEntity döner', () async {
      final useCase = LoginUseCase(repository);
      final user = await useCase(
        email: 'selin@example.com',
        password: 'Password123!',
        rememberMe: true,
      );

      expect(user.id, 'usr_test_1');
      expect(user.email, 'selin@example.com');
      expect(repository.authenticated, isTrue);
    });

    test('RegisterUseCase yeni kullanıcı kaydeder', () async {
      final useCase = RegisterUseCase(repository);
      final user = await useCase(
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz',
        rememberMe: true,
      );

      expect(user.id, 'usr_test_1');
      expect(user.displayName, 'Selin Yılmaz');
    });

    test('GuestUseCase misafir kullanıcı oluşturur', () async {
      final useCase = GuestUseCase(repository);
      final user = await useCase();

      expect(user.isGuest, isTrue);
      expect(user.email, isNull);
    });

    test('UpgradeGuestUseCase misafir hesabı tam hesaba dönüştürür', () async {
      final useCase = UpgradeGuestUseCase(repository);
      final user = await useCase(
        email: 'selin@example.com',
        password: 'Password123!',
        displayName: 'Selin Yılmaz',
      );

      expect(user.isGuest, isFalse);
    });

    test('ForgotPasswordUseCase sıfırlama talimatı mesajı döner', () async {
      final useCase = ForgotPasswordUseCase(repository);
      final message = await useCase(email: 'selin@example.com');

      expect(message, 'Şifre sıfırlama talimatları gönderildi.');
    });

    test('ResetPasswordUseCase yeni şifre onay mesajı döner', () async {
      final useCase = ResetPasswordUseCase(repository);
      final message = await useCase(
        email: 'selin@example.com',
        code: '123456',
        newPassword: 'BrandNewPassword123!',
      );

      expect(message, 'Şifreniz başarıyla güncellendi.');
    });
  });
}
