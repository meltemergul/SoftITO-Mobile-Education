import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.dart';

class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured =>
      AppEnv.supabaseUrl.isNotEmpty &&
      !AppEnv.supabaseUrl.contains('placeholder') &&
      AppEnv.supabaseAnonKey.isNotEmpty &&
      !AppEnv.supabaseAnonKey.contains('placeholder');

  static Future<void> initialize() async {
    if (!isConfigured) {
      // Gerçek anahtarlar girilmeden önce uygulamanın çökmesini engeller
      return;
    }
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      publishableKey: AppEnv.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient? get client {
    if (!_initialized) return null;
    return Supabase.instance.client;
  }
}
