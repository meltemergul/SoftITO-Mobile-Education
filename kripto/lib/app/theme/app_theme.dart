import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Chronomind Tasarım Sistemi: Tema Tanımları (Dark Obsidian & Light Solar Platinum)
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF051424),
      canvasColor: const Color(0xFF051424),
      cardColor: const Color(0xFF0D1C2D),
      dividerColor: const Color(0x991F344D),
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF06B6D4),
        secondary: Color(0xFF3B82F6),
        surface: Color(0xFF0D1C2D),
        error: Color(0xFFEF4444),
        onPrimary: Color(0xFF051424),
        onSecondary: Color(0xFFF8FAFC),
        onSurface: Color(0xFFF8FAFC),
        onError: Color(0xFFF8FAFC),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: AppTextStyles.headlineXl,
        headlineMedium: AppTextStyles.headlineLg,
        headlineSmall: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelSmall: AppTextStyles.labelSm,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0D1C2D),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedCard,
          side: BorderSide(color: Color(0xFF1F344D), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF051424),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06B6D4),
          foregroundColor: const Color(0xFF051424),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedButton,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF8FAFC),
          backgroundColor: const Color(0xFF13263B),
          side: const BorderSide(color: Color(0xFF2A4462), width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedButton,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0A1929),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: const Color(0xFF64748B)),
        labelStyle: AppTextStyles.labelSm,
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFF1F344D), width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFF1F344D), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFF06B6D4), width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      canvasColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE2E8F0),
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0891B2),
        secondary: Color(0xFF3B82F6),
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF0F172A),
        onSurface: Color(0xFF0F172A),
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        headlineLarge: AppTextStyles.headlineXl,
        headlineMedium: AppTextStyles.headlineLg,
        headlineSmall: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelSmall: AppTextStyles.labelSm,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedCard,
          side: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0891B2),
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedButton,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          backgroundColor: const Color(0xFFF1F5F9),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedButton,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: const Color(0xFF94A3B8)),
        labelStyle: AppTextStyles.labelSm,
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFF0891B2), width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
      ),
    );
  }
}
