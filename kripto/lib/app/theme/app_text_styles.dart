import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Obsidian Precision Financial: Tipografi
class AppTextStyles {
  AppTextStyles._();

  // Başlıklar (Plus Jakarta Sans)
  static final TextStyle headlineXl = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.96, // -0.03em
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineXlMobile = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7, // -0.025em
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineLg = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48, // -0.02em
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3, // -0.015em
    color: AppColors.textPrimary,
  );

  static final TextStyle headlineSm = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.16, // -0.01em
    color: AppColors.textPrimary,
  );

  // Gövde Metinleri (Inter)
  static final TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // Finansal Rakamlar (Tabular Figures - Rakamlar Titremez)
  static final TextStyle labelNumericLg = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.48,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static final TextStyle labelNumericMd = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.16,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle numeric({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // Mikro Etiketler ve Rozetler
  static final TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.44, // +0.04em
    color: AppColors.textSecondary,
  );

  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5, // +0.05em
    color: AppColors.textMuted,
  );
}
