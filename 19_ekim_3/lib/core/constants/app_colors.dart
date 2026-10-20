import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk paletleri (Material 3 uyumlu)
abstract class AppColors {
  // --- Koyu Tema (Dark Mode): Gece Spor Salonu Paleti ---
  // Dark Obsidian & Neon Cyan / Blue
  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF1A1A1E);
  static const Color darkSurfaceVariant = Color(0xFF26262B);
  static const Color darkPrimary = Color(0xFF00E5FF); // Neon Cyan
  static const Color darkOnPrimary = Color(0xFF00363D);
  static const Color darkSecondary = Color(0xFF0070F3); // Electric Blue
  static const Color darkOnSecondary = Colors.white;
  static const Color darkAccent = Color(0xFF00FFA3); // Neon Green / Mint
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // --- Aydınlık Tema (Light Mode): Canlı & Ferah Sporcu Paleti ---
  // Clean White, Sky Blue & Dynamic Slate
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);
  static const Color lightPrimary = Color(0xFF0284C7); // Sky Blue
  static const Color lightOnPrimary = Colors.white;
  static const Color lightSecondary = Color(0xFF334155); // Dynamic Slate
  static const Color lightOnSecondary = Colors.white;
  static const Color lightAccent = Color(0xFF0EA5E9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Ortak Bildirim ve Durum Renkleri
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}
