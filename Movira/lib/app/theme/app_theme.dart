import 'package:flutter/material.dart';

/// Movira Global Tema Yöneticisi (PROJECT.md Madde 1 & 6)
/// `ValueNotifier<ThemeMode>` ile sayfa düzeyinde ağır setState olmaksızın anlık tema geçişi sağlar.
final ValueNotifier<ThemeMode> globalThemeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

/// Movira Material 3 Tasarım Sistemi ve Renk Tokenları
class AppTheme {
  AppTheme._();

  // Tasarım Renk Tokenları (PROJECT.md & design/SKILL.md)
  static const Color primaryRed = Color(0xFFDC2626); // Modern Crimson Kırmızı
  static const Color darkRed = Color(0xFF991B1B);
  static const Color darkBordeauxBg = Color(0xFF140707); // Koyu Bordo / Antrasit Arka Plan
  static const Color darkSurface = Color(0xFF1F0B0B);
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;

  /// Açık Tema (Material 3)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.light,
        primary: primaryRed,
        surface: lightSurface,
      ),
      scaffoldBackgroundColor: lightBg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          side: const BorderSide(color: primaryRed),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Koyu Tema (Koyu Bordo / Antrasit Material 3)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        brightness: Brightness.dark,
        primary: const Color(0xFFEF4444),
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBordeauxBg,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF1C0A0A),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
