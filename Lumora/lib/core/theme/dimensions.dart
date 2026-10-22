import 'package:flutter/material.dart';

/// Vital Momentum Boşluk Tokenları
abstract class AppSpacing {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;

  /// Ekran yatay kenar boşluğu
  static const double screenHorizontal = 16.0;

  /// Minimum erişilebilir dokunma hedefi boyutu (WCAG)
  static const double minTouchTarget = 48.0;
}

/// Vital Momentum Köşe Yuvarlama Tokenları
abstract class AppRadius {
  /// Kartlar ve metin girişleri: rounded-2xl (16 px)
  static const double card = 16.0;
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16.0));

  /// Butonlar, çipler, rozetler ve toggle'lar: rounded-full (hap)
  static const double pill = 999.0;
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(999.0));
}
