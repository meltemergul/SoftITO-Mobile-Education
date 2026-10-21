class AppConstants {
  AppConstants._();

  static const String appName = 'Chronomind';

  // Fiyat Önbelleği (TTL)
  static const int defaultPriceTtlSeconds = 60;
  static const int minPriceTtlSeconds = 30;

  // Desteklenen Para Birimleri
  static const String currencyUsd = 'USD';
  static const String currencyTry = 'TRY';
  static const String defaultCurrency = currencyUsd;

  // Zaman Aralıkları
  static const List<String> periods = ['1G', '1H', '1A'];
}
