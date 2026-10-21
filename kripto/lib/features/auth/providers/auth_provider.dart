import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AuthState?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges ?? const Stream.empty();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user ?? ref.watch(authRepositoryProvider).currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
    });
    return !state.hasError;
  }

  Future<bool> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
          );
    });
    return !state.hasError;
  }

  Future<bool> resetPassword(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(
            email: email,
          );
    });
    return !state.hasError;
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
  }
}
