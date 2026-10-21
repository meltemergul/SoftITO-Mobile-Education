import 'package:flutter/material.dart';

/// Obsidian Precision Financial: Renk Jetonları
class AppColors {
  AppColors._();

  // Yüzeyler
  static const Color canvas = Color(0xFF0B0F19);
  static const Color surface1 = Color(0xFF111827);
  static const Color surface2 = Color(0xFF1E293B);
  static const Color surface3 = Color(0xFF334155);
  static const Color inputInset = Color(0xFF0E1422);

  // Marka ve Etkileşim
  static const Color primary = Color(0xFF06B6D4);
  static const Color secondary = Color(0xFF3B82F6);

  // Kâr / Zarar
  static const Color profit = Color(0xFF10B981);
  static const Color profitText = Color(0xFF34D399);
  static const Color profitMuted = Color(0xFF059669);
  static const Color loss = Color(0xFFEF4444);
  static const Color lossText = Color(0xFFF87171);
  static const Color lossMuted = Color(0xFFDC2626);

  // Metin
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Yarı Saydam Sınırlar ve Vurgular
  static const Color borderCard = Color(0x0FFFFFFF); // Beyaz %6
  static const Color borderSheet = Color(0x1FFFFFFF); // Beyaz %12
  static const Color borderDivider = Color(0x08FFFFFF); // Beyaz %3
  static const Color borderCyanFocus = Color(0x4D06B6D4); // Cyan %30

  // Rozet Arka Plan ve Kenarlıkları
  static const Color profitBg = Color(0x1F10B981); // #10B981 %12
  static const Color profitBorder = Color(0x4010B981); // #10B981 %25
  static const Color lossBg = Color(0x1FEF4444); // #EF4444 %12
  static const Color lossBorder = Color(0x40EF4444); // #EF4444 %25
}
