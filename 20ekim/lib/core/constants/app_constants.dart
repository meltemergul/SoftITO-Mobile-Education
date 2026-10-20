// Girişim360 — Uygulama Sabitleri
// PROJECT.md kuralları ile uyumlu genel konfigürasyon ve metin sabitleri

class AppConstants {
  AppConstants._();

  static const String appName = 'Girişim360';
  static const String appTagline = 'Girişimcilik ve Büyüme Platformu';
  static const String appVersion = '1.0.0';

  // Girişim Aşamaları (PROJECT.md Bölüm 2.1)
  static const List<String> startupStages = [
    'Fikir',
    'Doğrulama',
    'İş Planı',
    'MVP / Prototip',
    'Şirketleşme',
    'Pazara Çıkış',
    'Büyüme',
  ];

  // Arayüz Metinleri
  static const String demoBadgeText = 'Demo Veri / Geliştirme Modu';
  static const String legalDisclaimer =
      'Platformdaki hukuki süreç bilgileri genel rehberlik niteliğindedir; bağlayıcı hukuki danışmanlık yerine geçmez.';
  static const String aiDisclaimer =
      'Yapay zekâ analizleri tahmin ve iyileştirme önerisidir; kesinleşmiş finansal veya hukuki taahhüt içermez.';
}
