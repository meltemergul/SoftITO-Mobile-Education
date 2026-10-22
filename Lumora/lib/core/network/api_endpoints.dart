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
}
