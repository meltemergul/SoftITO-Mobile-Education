import 'package:flutter/material.dart';

/// Chronomind Tasarım Sistemi: Saf Karanlık Mod (Dark Obsidian Precision)
/// Kaynak: .agents/skills/design/SKILL.md §3.1
class AppColors {
  AppColors._();

  // Yüzeyler (Surfaces)
  static const Color canvas = Color(0xFF051424);
  static const Color surfaceDim = Color(0xFF010F1F);
  static const Color surface1 = Color(0xFF0D1C2D);
  static const Color surface2 = Color(0xFF13263B);
  static const Color surface3 = Color(0xFF1F344D);
  static const Color inputInset = Color(0xFF0A1929);

  // Marka ve Etkileşim (Brand & Interaction)
  static const Color primary = Color(0xFF06B6D4); // Cyan
  static const Color primaryBright = Color(0xFF22D3EE);
  static const Color secondary = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);

  // Kâr / Zarar (Profit / Loss)
  static const Color profit = Color(0xFF10B981);
  static const Color profitText = Color(0xFF34D399);
  static const Color profitMuted = Color(0xFF059669);
  static const Color loss = Color(0xFFEF4444);
  static const Color lossText = Color(0xFFF87171);
  static const Color lossMuted = Color(0xFFDC2626);

  // Metin (Typography)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Sınırlar (Borders)
  static const Color borderCard = Color(0xFF1F344D);
  static const Color borderSheet = Color(0xFF2A4462);
  static const Color borderDivider = Color(0x991F344D);
  static const Color borderCyanFocus = Color(0x4D06B6D4);

  // Rozet Arka Plan ve Kenarlıkları
  static const Color profitBg = Color(0x1A10B981);
  static const Color profitBorder = Color(0x3310B981);
  static const Color lossBg = Color(0x1AEF4444);
  static const Color lossBorder = Color(0x33EF4444);

  // Varlık dağılımı / grafik paleti
  static const List<Color> chartPalette = [
    primary,
    profit,
    secondary,
    Color(0xFFA78BFA),
    Color(0xFFF59E0B),
    Color(0xFFF472B6),
  ];
  static const Color chartOther = textMuted;
}

