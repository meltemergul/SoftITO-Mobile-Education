import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Obsidian Precision Financial: Tema Tanımı
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvas,
      canvasColor: AppColors.canvas,
      cardColor: AppColors.surface1,
      dividerColor: AppColors.borderDivider,
      splashFactory: InkRipple.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface1,
        error: AppColors.loss,
        onPrimary: AppColors.canvas,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: AppTextStyles.headlineXl,
        headlineMedium: AppTextStyles.headlineLg,
        headlineSmall: AppTextStyles.headlineSm,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelSmall: AppTextStyles.labelSm,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface1,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.roundedCard,
          side: BorderSide(color: AppColors.borderCard, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.canvas,
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
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface2,
          side: const BorderSide(color: AppColors.borderSheet, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.roundedButton,
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputInset,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.labelSm,
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: AppColors.borderCard, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: AppColors.borderCard, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: AppColors.lossText, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.roundedInput,
          borderSide: BorderSide(color: AppColors.loss, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface2,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
