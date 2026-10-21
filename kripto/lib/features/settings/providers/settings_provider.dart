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
