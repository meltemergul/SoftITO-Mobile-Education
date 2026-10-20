import 'package:flutter/material.dart';

/// Dark Obsidian & Neon Gece Spor Salonu Renk Paleti
abstract final class AppColors {
  // Arka plan ve yüzey renkleri (Dark Obsidian)
  static const Color background = Color(0xFF090D14);
  static const Color surface = Color(0xFF131924);
  static const Color surfaceElevated = Color(0xFF1C2536);
  static const Color surfaceBorder = Color(0xFF263248);

  // Neon Vurgu Renkleri
  static const Color neonWater = Color(0xFF00E5FF);       // Canlı Neon Su Mavisi
  static const Color neonWaterLight = Color(0xFF67F6FF);  // Açık Su Parıltısı
  static const Color neonEnergy = Color(0xFF00FF88);      // Neon Egzersiz Yeşili
  static const Color neonCalorie = Color(0xFFFF5E36);     // Neon Kalori Turuncusu
  static const Color neonPurple = Color(0xFFB55FE6);      // Neon Spor Vurgusu

  // Metin Renkleri
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Durum Renkleri
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF3366);
}
