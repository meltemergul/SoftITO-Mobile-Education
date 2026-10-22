import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/app/router.dart';
import 'package:lumora/features/auth/domain/entities/user_entity.dart';
import 'package:lumora/features/auth/domain/repositories/auth_repository.dart';
import 'package:lumora/features/auth/presentation/providers/auth_notifier.dart';
import 'package:lumora/features/auth/presentation/providers/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  bool authenticated = false;
  bool shouldFail = false;

  final testUser = const UserEntity(
    id: 'usr_test_1',
    email: 'selin@example.com',
    displayName: 'Selin Yılmaz',
    isGuest: false,
    createdAt: '2026-10-22T20:00:00.000Z',
  );

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (shouldFail) throw Exception('Geçersiz e-posta veya şifre.');
    authenticated = true;
    return testUser;
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  }) async {
    if (shouldFail) throw Exception('Bu e-posta adresi zaten kullanımda.');
    authenticated = true;
    return testUser;
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
    return testUser;
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    if (shouldFail) throw Exception('Sıfırlama başarısız.');
    return 'Şifre sıfırlama talimatları gönderildi.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (shouldFail) throw Exception('Kod geçersiz.');
    return 'Şifreniz başarıyla sıfırlandı.';
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
  late MockAuthRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier Unit Testleri', () {
    test('Başlangıç durumu kontrolü ve checkAuthStatus', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.checkAuthStatus();

      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(container.read(authStateProvider), isFalse);
    });

    test('Başarılı login auth durumunu authenticated yapar ve authStateProvider güncellenir',
        () async {
      final notifier = container.read(authNotifierProvider.notifier);

      final success = await notifier.login(
        email: 'selin@example.com',
        password: 'Password123!',
        rememberMe: true,
      );

      expect(success, isTrue);
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.email, 'selin@example.com');
      expect(container.read(authStateProvider), isTrue);
    });

    test('Hatalı login durumunda AuthStatus.error ve errorMessage oluşur', () async {
      mockRepository.shouldFail = true;
      final notifier = container.read(authNotifierProvider.notifier);

      final success = await notifier.login(
        email: 'selin@example.com',
        password: 'WrongPassword!',
        rememberMe: true,
      );

      expect(success, isFalse);
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, contains('Geçersiz e-posta veya şifre'));
      expect(container.read(authStateProvider), isFalse);
    });

    test('Guest girişi misafir kullanıcısı oluşturur ve sisteme dahil eder', () async {
      final notifier = container.read(authNotifierProvider.notifier);

      final success = await notifier.guest();

      expect(success, isTrue);
      final state = container.read(authNotifierProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.isGuest, isTrue);
      expect(container.read(authStateProvider), isTrue);
    });

    test('ForgotPassword ve ResetPassword akışı infoMessage üretir', () async {
      final notifier = container.read(authNotifierProvider.notifier);

      final forgotSuccess = await notifier.forgotPassword(email: 'selin@example.com');
      expect(forgotSuccess, isTrue);
      expect(container.read(authNotifierProvider).infoMessage,
          'Şifre sıfırlama talimatları gönderildi.');

      final resetSuccess = await notifier.resetPassword(
        email: 'selin@example.com',
        code: '123456',
        newPassword: 'NewPassword123!',
      );
      expect(resetSuccess, isTrue);
      expect(container.read(authNotifierProvider).infoMessage,
          'Şifreniz başarıyla sıfırlandı.');
    });

    test('Logout oturumu kapatır ve authStateProvider false olur', () async {
      final notifier = container.read(authNotifierProvider.notifier);
      await notifier.login(
        email: 'selin@example.com',
        password: 'Password123!',
        rememberMe: true,
      );
      expect(container.read(authStateProvider), isTrue);

      await notifier.logout();
      expect(container.read(authNotifierProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authStateProvider), isFalse);
    });
  });
}
