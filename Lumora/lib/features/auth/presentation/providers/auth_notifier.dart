import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/guest_usecase.dart';
import '../../domain/usecases/upgrade_guest_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_state.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remote,
    tokenStorage: tokenStorage,
  );
});

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final GuestUseCase _guestUseCase;
  late final UpgradeGuestUseCase _upgradeGuestUseCase;
  late final ForgotPasswordUseCase _forgotPasswordUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _guestUseCase = GuestUseCase(_repository);
    _upgradeGuestUseCase = UpgradeGuestUseCase(_repository);
    _forgotPasswordUseCase = ForgotPasswordUseCase(_repository);
    _resetPasswordUseCase = ResetPasswordUseCase(_repository);

    // Uygulama başlangıcında token kontrolü
    Future.microtask(() => checkAuthStatus());

    return const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final hasToken = await _repository.isAuthenticated();
    if (hasToken) {
      state = state.copyWith(status: AuthStatus.authenticated);
      ref.read(authStateProvider.notifier).setAuthenticated(true);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      ref.read(authStateProvider.notifier).setAuthenticated(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _loginUseCase(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      ref.read(authStateProvider.notifier).setAuthenticated(true);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _registerUseCase(
        email: email,
        password: password,
        displayName: displayName,
        rememberMe: rememberMe,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      ref.read(authStateProvider.notifier).setAuthenticated(true);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> guest() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _guestUseCase();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      ref.read(authStateProvider.notifier).setAuthenticated(true);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> upgradeGuest({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await _upgradeGuestUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true, clearInfo: true);
    try {
      final message = await _forgotPasswordUseCase(email: email);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        infoMessage: message,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true, clearInfo: true);
    try {
      final message = await _resetPasswordUseCase(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        infoMessage: message,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
    ref.read(authStateProvider.notifier).setAuthenticated(false);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
