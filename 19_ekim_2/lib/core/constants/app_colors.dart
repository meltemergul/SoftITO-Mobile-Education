import 'package:flutter/material.dart';

/// Gece spor salonu (Dark Obsidian & Neon) renk paleti.
class AppColors {
  const AppColors._();

  // Karanlık Mod (Dark Obsidian & Neon)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF131823);
  static const Color darkSurfaceLight = Color(0xFF1B2232);
  static const Color darkSurfaceBorder = Color(0xFF263045);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextMuted = Color(0xFF555F70);

  // Geriye dönük uyumluluk sabitleri (Koyu Tema)
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceLight = darkSurfaceLight;
  static const Color surfaceBorder = darkSurfaceBorder;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;

  // Aydınlık Mod (Clean Pure White & Sky Cyan)
  static const Color lightBackground = Color(0xFFF4F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFEAEFF7);
  static const Color lightSurfaceBorder = Color(0xFFD6E0EA);
  static const Color lightPrimary = Color(0xFF0284C7);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Ortak Vurgu ve Fonksiyonel Renkler
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonBlue = Color(0xFF0077FE);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF9100);
  static const Color neonPurple = Color(0xFFD500F9);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);
  static const Color waterBlue = Color(0xFF00B4D8);
}
