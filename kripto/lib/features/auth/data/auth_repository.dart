import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  SupabaseClient? get _client => SupabaseService.client;

  Stream<AuthState>? get authStateChanges => _client?.auth.onAuthStateChange;

  User? get currentUser => _client?.auth.currentUser;

  Session? get currentSession => _client?.auth.currentSession;

  bool get isAuthenticated => currentUser != null;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthError('Veritabanı bağlantısı yapılandırılmadı. Lütfen .env ayarlarını kontrol edin.');
    }

    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthError(_mapAuthErrorMessage(e), e);
    } on SocketException catch (e) {
      throw NetworkError('İnternet bağlantısı kurulamadı.', e);
    } catch (e) {
      throw UnknownError('Giriş yapılırken beklenmeyen bir hata oluştu.', e);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const AuthError('Veritabanı bağlantısı yapılandırılmadı. Lütfen .env ayarlarını kontrol edin.');
    }

    try {
      await client.auth.signUp(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthError(_mapAuthErrorMessage(e), e);
    } on SocketException catch (e) {
      throw NetworkError('İnternet bağlantısı kurulamadı.', e);
    } catch (e) {
      throw UnknownError('Kayıt oluşturulurken beklenmeyen bir hata oluştu.', e);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final client = _client;
    if (client == null) {
      throw const AuthError('Veritabanı bağlantısı yapılandırılmadı.');
    }

    try {
      await client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthError(_mapAuthErrorMessage(e), e);
    } on SocketException catch (e) {
      throw NetworkError('İnternet bağlantısı kurulamadı.', e);
    } catch (e) {
      throw UnknownError('Şifre sıfırlama e-postası gönderilemedi.', e);
    }
  }

  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (_) {
      // Hata durumunda bile yerel oturumu düşür
    }
  }

  String _mapAuthErrorMessage(AuthException error) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (msg.contains('user already registered') || msg.contains('already exists')) {
      return 'Bu e-posta adresiyle kayıtlı bir hesap zaten var.';
    }
    if (msg.contains('password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    if (msg.contains('valid email')) {
      return 'Lütfen geçerli bir e-posta adresi girin.';
    }
    if (msg.contains('rate limit')) {
      return 'Çok fazla deneme yaptınız. Lütfen birkaç dakika sonra tekrar deneyin.';
    }
    return error.message;
  }
}
