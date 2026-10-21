import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

class CurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'USD';

  void setCurrency(String currency) {
    state = currency;
    ref.read(settingsRepositoryProvider).setDefaultCurrency(currency);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(() {
  return CurrencyNotifier();
});

/// Gizlilik modu: true iken tutarlar "••••" ile maskelenir.
class PrivacyModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final privacyModeProvider = NotifierProvider<PrivacyModeNotifier, bool>(
  PrivacyModeNotifier.new,
);

/// Arayüz Teması Yönetimi (Karanlık / Aydınlık / Sistem)
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSavedTheme();
    return ThemeMode.dark;
  }

  Future<void> _loadSavedTheme() async {
    final saved = await ref.read(settingsRepositoryProvider).getTheme();
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.system ? 'system' : 'dark');
    await ref.read(settingsRepositoryProvider).setTheme(str);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});
