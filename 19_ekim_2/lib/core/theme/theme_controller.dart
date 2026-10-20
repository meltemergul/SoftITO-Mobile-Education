import 'package:flutter/material.dart';

/// Tema modunu (Karanlık / Aydınlık) ValueNotifier ile yöneten kontrolcü sınıfı.
class ThemeController {
  final ValueNotifier<ThemeMode> themeMode;

  ThemeController({ThemeMode initialMode = ThemeMode.dark})
      : themeMode = ValueNotifier<ThemeMode>(initialMode);

  /// Aktif modun karanlık olup olmadığını döner
  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  /// Karanlık ve aydınlık mod arasında geçiş yapar
  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.dark;
    }
  }

  /// Belirli bir tema modunu ayarlar
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void dispose() {
    themeMode.dispose();
  }
}
