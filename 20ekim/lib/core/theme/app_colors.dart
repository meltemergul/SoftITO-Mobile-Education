// Girişim360 — Renk Paleti (PROJECT.md Bölüm 3)
// Dark Navy / Obsidian, Elektrik Mavisi ve Turkuaz vurgu renkleri

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ortak Vurgu Renkleri
  static const Color electricBlue = Color(0xFF0066FF);
  static const Color electricBlueLight = Color(0xFF2979FF);
  static const Color turquoise = Color(0xFF00F5D4);
  static const Color turquoiseDark = Color(0xFF00B4D8);

  // Karanlık Tema Renkleri (Dark Navy / Obsidian)
  static const Color darkBackground = Color(0xFF0B132B); // Dark Navy
  static const Color darkSurface = Color(0xFF1C2541);    // Obsidian
  static const Color darkSurfaceContainer = Color(0xFF232F55);
  static const Color darkSurfaceContainerHigh = Color(0xFF2D3C6A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkOutline = Color(0xFF3E4F7A);

  // Aydınlık Tema Renkleri (Beyaz / Açık Gri / Kurumsal Mavi)
  static const Color lightBackground = Color(0xFFF8F9FA); // Açık gri
  static const Color lightSurface = Color(0xFFFFFFFF);    // Beyaz
  static const Color lightSurfaceContainer = Color(0xFFEDF2F7);
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color corporateBlue = Color(0xFF0D47A1);  // Kurumsal mavi
  static const Color lightTurquoise = Color(0xFF00838F);  // Turkuaz vurgu
  static const Color lightTextPrimary = Color(0xFF0A192F);// Koyu lacivert
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightOutline = Color(0xFFCBD5E1);

  // Durum Renkleri
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
