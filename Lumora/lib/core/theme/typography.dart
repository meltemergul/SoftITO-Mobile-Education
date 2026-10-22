import 'package:flutter/material.dart';

/// Vital Momentum Tipografi Sistemi
abstract class AppTypography {
  static const String fontFamily = 'Plus Jakarta Sans';

  /// Büyük yüzde, seviye sayısı (32 / 40, weight 800)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32.0,
    height: 40.0 / 32.0,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  /// Ekran başlıkları (22 / 28, weight 700)
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    height: 28.0 / 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  /// Kart başlıkları (18 / 24, weight 700)
  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    height: 24.0 / 18.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
  );

  /// Ana metin, giriş alanları (16 / 24, weight 500)
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w500,
  );

  /// İkincil metin (14 / 20, weight 500)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w500,
  );

  /// Etiketler, rozet metni, XP çipi (12 / 16, weight 600)
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
