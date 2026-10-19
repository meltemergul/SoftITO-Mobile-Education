import 'package:flutter/material.dart';

abstract final class AppColors {
  // Karanlık tema (derin gece medikal paleti)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF151A23);
  static const Color darkPrimary = Color(0xFFE63946);
  static const Color darkText = Color(0xFFE8EAED);

  // Aydınlık tema (klinik hijyenik palet)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightPrimary = Color(0xFFD90429);
  static const Color medicalBlue = Color(0xFF0077B6);

  // Tıbbi durum ve aciliyet tonları
  static const Color eligible = Color(0xFF2EC4B6);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color ineligible = Color(0xFFE63946);
  static const Color critical = Color(0xFFFF4D6D);
  static const Color info = Color(0xFF48CAE4);
}
