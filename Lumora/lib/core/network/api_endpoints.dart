import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

abstract class ApiEndpoints {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://127.0.0.1:3000';
  }

  // Auth uç noktaları
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String guest = '/auth/guest';
  static const String upgrade = '/auth/upgrade';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Alışkanlık ve Log uç noktaları
  static const String habits = '/habits';
  static const String habitTemplates = '/habit-templates';
  static const String logs = '/logs';
  static const String today = '/today';

  // Quotes uç noktaları
  static const String dailyQuote = '/quotes/daily';
  static String favoriteQuote(String id) => '/quotes/$id/favorite';

  // Calendar uç noktaları
  static const String calendar = '/calendar';
  static String calendarDay(String date) => '/calendar/day/$date';

  // Stats uç noktaları
  static const String stats = '/stats';
  static String statsWithRange(String range) => '/stats?range=$range';

  // Badges ve Level uç noktaları
  static const String badges = '/badges';
  static const String level = '/level';

  // Profile, Settings, Export & Account uç noktaları
  static const String profile = '/profile';
  static const String settings = '/settings';
  static String exportData(String format) => '/export?format=$format';
  static const String account = '/account';
}
