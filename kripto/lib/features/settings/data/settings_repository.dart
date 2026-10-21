import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _keyCurrency = 'default_currency';
  static const _keyTheme = 'theme';
  static const _keyRefreshSeconds = 'refresh_seconds';

  Future<String> getDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? 'USD';
  }

  Future<void> setDefaultCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrency, currency);
  }

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? 'dark';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, theme);
  }

  Future<int> getRefreshSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRefreshSeconds) ?? 60;
  }

  Future<void> setRefreshSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRefreshSeconds, seconds);
  }
}
