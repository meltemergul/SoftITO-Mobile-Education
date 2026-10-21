import 'package:flutter/material.dart';

/// Chronomind Tasarım Sistemi: Boşluk ve Köşe Jetonları (SKILL.md §3.3)
class AppSpacing {
  AppSpacing._();

  // 4px / 8px Izgara Jetonları
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xlg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // Sayfa Kenar Boşlukları
  static const double screenMarginMobile = 16.0;
  static const double screenMarginTablet = 24.0;
  static const double screenMarginDesktop = 32.0;

  // Kartlar arası ve içi boşluklar
  static const double cardGap = 12.0;
  static const double cardPadding = 16.0;
  static const double cardPaddingCompact = 12.0;
  static const double sectionGap = 24.0;

  // Köşe Yuvarlaklığı (Border Radius)
  static const double radiusCheckbox = 4.0;
  static const double radiusCard = 16.0; // rounded-2xl
  static const double radiusInput = 12.0; // rounded-xl
  static const double radiusButton = 12.0; // rounded-xl
  static const double radiusSheet = 24.0;
  static const double radiusPill = 999.0;
  static const double tokenIconSize = 32.0;

  // BorderRadius Nesneleri
  static const BorderRadius roundedCheckbox = BorderRadius.all(Radius.circular(radiusCheckbox));
  static const BorderRadius roundedCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius roundedInput = BorderRadius.all(Radius.circular(radiusInput));
  static const BorderRadius roundedButton = BorderRadius.all(Radius.circular(radiusButton));
  static const BorderRadius roundedSheet = BorderRadius.all(Radius.circular(radiusSheet));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(radiusPill));

  // Minimum Dokunma Hedefi
  static const double minTouchTarget = 44.0;
}
