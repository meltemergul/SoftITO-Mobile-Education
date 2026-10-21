import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Chronomind Tasarım Sistemi: Tipografi (SKILL.md §3.2)
class AppTextStyles {
  AppTextStyles._();

  // Display / Total Balance: 32-36px, 700-800, tabular
  static TextStyle get displayBalance => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        height: 40 / 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Başlıklar (Plus Jakarta Sans)
  static TextStyle get headlineXl => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.96,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineXlMobile => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.48,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.16,
        color: AppColors.textPrimary,
      );

  // Gövde Metinleri (Inter)
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.textSecondary,
      );

  // Finansal Rakamlar (Tabular Figures)
  static TextStyle get labelNumericLg => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 28 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.48,
        color: AppColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle get labelNumericMd => GoogleFonts.plusJakartaSans(
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
    Color? color,
    double? height,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // Mikro Etiketler ve Rozetler
  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.44,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 10,
        height: 12 / 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      );
}
