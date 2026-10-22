import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumora/app/app.dart';
import 'package:lumora/features/auth/domain/entities/user_entity.dart';
import 'package:lumora/features/auth/domain/repositories/auth_repository.dart';
import 'package:lumora/features/auth/presentation/providers/auth_notifier.dart';

class WidgetTestFakeAuthRepository implements AuthRepository {
  bool _authenticated = false;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _authenticated = true;
    return const UserEntity(
      id: 'usr_1',
      email: 'selin@example.com',
      displayName: 'Selin Yılmaz',
      isGuest: false,
      createdAt: '2026-10-22T20:00:00.000Z',
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  }) async {
    _authenticated = true;
    return const UserEntity(
      id: 'usr_1',
      email: 'selin@example.com',
      displayName: 'Selin Yılmaz',
      isGuest: false,
      createdAt: '2026-10-22T20:00:00.000Z',
    );
  }

  @override
  Future<UserEntity> guest() async {
    _authenticated = true;
    return const UserEntity(
      id: 'usr_guest',
      displayName: 'Misafir',
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
    return const UserEntity(
      id: 'usr_guest',
      email: 'selin@example.com',
      displayName: 'Selin Yılmaz',
      isGuest: false,
      createdAt: '2026-10-22T20:00:00.000Z',
    );
  }

  @override
  Future<String> forgotPassword({required String email}) async {
    return 'Kod gönderildi.';
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return 'Şifre güncellendi.';
  }

  @override
  Future<void> logout() async {
    _authenticated = false;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _authenticated;
  }
}

void main() {
  testWidgets('LumoraApp auth guard redirects to LoginScreen and allows login',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeRepo = WidgetTestFakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const LumoraApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Giriş ekranında marka öğelerinin ve butonların görünürlüğünü doğrula
    expect(find.text('Lumora'), findsOneWidget);
    expect(find.text('Pozitif Rutinler'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsWidgets);
    expect(find.text('Kayıt Ol'), findsOneWidget);
    expect(find.text('Misafir Olarak Devam Et'), findsOneWidget);

    // Misafir olarak giriş yap butonuna bas
    await tester.tap(find.text('Misafir Olarak Devam Et'));
    await tester.pumpAndSettle();

    // Ana sekme çubuğuna ve Bugün sayfasına yönlendirildiğini doğrula
    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Takvim'), findsOneWidget);
    expect(find.text('İstatistik'), findsOneWidget);
    expect(find.text('Rozetler'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
