import 'package:flutter/material.dart';

/// Vital Momentum Tasarım Sistemi Anlamsal Renk Tokenları
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.primary,
    required this.primaryStrong,
    required this.streak,
    required this.streakStrong,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.border,
    required this.inactive,
    required this.water,
    required this.book,
    required this.sport,
    required this.mind,
    required this.customCategory,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.accessibleGreenText,
  });

  final Color primary;
  final Color primaryStrong;
  final Color streak;
  final Color streakStrong;
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color border;
  final Color inactive;

  // Kategori Renkleri
  final Color water;
  final Color book;
  final Color sport;
  final Color mind;
  final Color customCategory;

  // Tipografi Renkleri
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color accessibleGreenText;

  /// Açık Tema Paleti (Vital Momentum spesifikasyonu)
  factory AppColorsExtension.light() {
    return const AppColorsExtension(
      primary: Color(0xFF10B981),
      primaryStrong: Color(0xFF059669),
      streak: Color(0xFFF97316),
      streakStrong: Color(0xFFEA580C),
      background: Color(0xFFFAF8FF),
      backgroundAlt: Color(0xFFF8FAFC),
      surface: Color(0xFFFFFFFF),
      border: Color(0xFFE2E8F0),
      inactive: Color(0xFFF1F5F9),
      water: Color(0xFF0284C7),
      book: Color(0xFFD97706),
      sport: Color(0xFFEA580C),
      mind: Color(0xFF7C3AED), // Tasarımda tanımsızdı, önerilen mor
      customCategory: Color(0xFF10B981),
      textPrimary: Color(0xFF0F172A),
      textSecondary: Color(0xFF64748B),
      textTertiary: Color(0xFF94A3B8),
      textOnPrimary: Color(0xFFFFFFFF),
      accessibleGreenText: Color(0xFF047857), // WCAG AA erişilebilir yeşil
    );
  }

  /// TODO: Koyu tema renk paleti henüz tasarım ekibi tarafından tanımlanmamıştır.
  /// Mimari ve sistem yapı olarak hazır tutulmuş olup, şimdilik geçici koyu tonlar kullanılmıştır.
  factory AppColorsExtension.dark() {
    return const AppColorsExtension(
      primary: Color(0xFF10B981),
      primaryStrong: Color(0xFF059669),
      streak: Color(0xFFF97316),
      streakStrong: Color(0xFFEA580C),
      background: Color(0xFF0F172A),
      backgroundAlt: Color(0xFF1E293B),
      surface: Color(0xFF1E293B),
      border: Color(0xFF334155),
      inactive: Color(0xFF334155),
      water: Color(0xFF38BDF8),
      book: Color(0xFFFBBF24),
      sport: Color(0xFFFB923C),
      mind: Color(0xFFA78BFA),
      customCategory: Color(0xFF34D399),
      textPrimary: Color(0xFFF8FAFC),
      textSecondary: Color(0xFF94A3B8),
      textTertiary: Color(0xFF64748B),
      textOnPrimary: Color(0xFFFFFFFF),
      accessibleGreenText: Color(0xFF34D399),
    );
  }

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primary,
    Color? primaryStrong,
    Color? streak,
    Color? streakStrong,
    Color? background,
    Color? backgroundAlt,
    Color? surface,
    Color? border,
    Color? inactive,
    Color? water,
    Color? book,
    Color? sport,
    Color? mind,
    Color? customCategory,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnPrimary,
    Color? accessibleGreenText,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryStrong: primaryStrong ?? this.primaryStrong,
      streak: streak ?? this.streak,
      streakStrong: streakStrong ?? this.streakStrong,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      inactive: inactive ?? this.inactive,
      water: water ?? this.water,
      book: book ?? this.book,
      sport: sport ?? this.sport,
      mind: mind ?? this.mind,
      customCategory: customCategory ?? this.customCategory,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      accessibleGreenText: accessibleGreenText ?? this.accessibleGreenText,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryStrong: Color.lerp(primaryStrong, other.primaryStrong, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
      streakStrong: Color.lerp(streakStrong, other.streakStrong, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      water: Color.lerp(water, other.water, t)!,
      book: Color.lerp(book, other.book, t)!,
      sport: Color.lerp(sport, other.sport, t)!,
      mind: Color.lerp(mind, other.mind, t)!,
      customCategory: Color.lerp(customCategory, other.customCategory, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      accessibleGreenText: Color.lerp(accessibleGreenText, other.accessibleGreenText, t)!,
    );
  }
}

extension AppColorsBuildContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light();
}
