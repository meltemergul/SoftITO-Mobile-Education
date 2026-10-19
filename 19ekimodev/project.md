# Kan Bağışı ve İhtiyaç Takip Uygulaması
Bu doküman Flutter projesinde geliştirme yapacak olan Ajan (AntiGravity) yapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı buradaki kurallara UYMAK ZORUNDADIR.

## 1. Proje Özeti ve Teknolojiler
- **Uygulama Adı:** CanBağım (Grafik Destekli Akıllı Kan Bağışı ve Acil İhtiyaç Takip Platformu)
- **Hedef Platformlar:** iOS ve Android öncelikli; ardından Web ve Masaüstü platformları.
- **Flutter SDK:** 3.15.1
- **Dart SDK:** 3.6.0
- **Tasarım Dili:** Material 3, Dinamik Çift Tema Desteği:
  - **Karanlık Tema (Dark Mode):** Derin gece medikal paleti; koyu zemin (`#0B0E14`), yüzey kartları (`#151A23`), medikal bordo/kırmızı vurgu (`#E63946`), yumuşak kritik uyarı ve durum tonları (`#FF4D6D`, `#48CAE4`).
  - **Aydınlık Tema (Light Mode):** Klinik hijyenik palet; nötr açık zemin (`#F8F9FA`), saf beyaz kartlar (`#FFFFFF`), yüksek kontrastlı koyu metinler (`#1A1A1A`), canlı bağış kırmızısı (`#D90429`) ve güven verici medikal mavi detaylar.
- **Tema Durum Yönetimi:** `ValueNotifier<ThemeMode>` ile sayfa düzeyinde ağır `setState` olmaksızın anlık tema geçişi.

---

## 2. Mimari Yapı: Özellik Bazlı (Feature-First)
Kodlar kesinlikle tek bir yerde toplanmayacaktır. Her modül kendi bağımsız `features` alt dizininde geliştirilecektir.

```text
lib/
├── core/
│   ├── extensions/
│   │   ├── context_extension.dart
│   │   └── date_extension.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── blood_value_ranges.dart
│   └── theme/
│       ├── app_theme.dart
│       └── theme_controller.dart
├── features/
│   ├── blood_values/          # Bağış için gerekli kan değerleri (Hemoglobin, Demir, Nabız vb.)
│   │   ├── controller/
│   │   ├── models/
│   │   ├── view/
│   │   └── widget/
│   ├── donation_centers/      # Harita/liste tabanlı kan bağışı noktaları ve istasyonlar
│   │   ├── controller/
│   │   ├── models/
│   │   ├── view/
│   │   └── widget/
│   ├── urgent_requests/       # Acil kan bağışına ihtiyacı olan kişiler ve talepler
│   │   ├── controller/
│   │   ├── models/
│   │   ├── view/
│   │   └── widget/
│   └── donation_statistics/   # Aylık kan bağışı sayıları ve dağılım grafikleri
│       ├── controller/
│       ├── models/
│       ├── view/
│       └── widget/
└── main.dart                  # Yalnızca uygulama başlatma, servis/tema sağlayıcı tanımları
```

---

## 3. Modül Fonksiyonel Detayları

1. **Kan Değerleri Modülü (`blood_values`):**
   - Bağışçının girdiği veya sistemden çektiği değerlerin referans aralıklarına uygunluğunu analiz eder (Hemoglobin: Kadın $\ge 12.5\text{ g/dL}$, Erkek $\ge 13.5\text{ g/dL}$; Tansiyon; Ağırlık $\ge 50\text{ kg}$; Nabız vb.).
   - Değerlerin bağışa uygun olup olmadığını dinamik renk indikatörleriyle (yeşil/kırmızı/sarı) gösterir.

2. **Bağış Noktaları Modülü (`donation_centers`):**
   - En yakın Kızılay/hastane kan bağış merkezleri, seyyar kan alma otobüsleri, çalışma saatleri ve doluluk durumları.

3. **Acil İhtiyaç Modülü (`urgent_requests`):**
   - Kan grubu ($A^+$, $0^-$, $AB^+$, vb.), lokasyon, ünite miktarı ve aciliyet derecesine göre filtrelenebilir hasta/talep listesi.

4. **Aylık Bağış Grafikleri Modülü (`donation_statistics`):**
   - Aylık bağış sayıları, yıllık karşılaştırmalar ve kan grubu dağılımlarını görselleştiren hafif ve performanslı çubuk (bar) ve çizgi (line) grafikleri.

---

## 4. Kırmızı Çizgiler ve Kod Kalite Standartları
1. **State Yönetim Standartları:**
   - Sayfa düzeyinde ağır `setState` kullanımından kesinlikle kaçınılacaktır.
   - Durum takibinde yerel `ValueNotifier`, `ChangeNotifier` veya `InheritedNotifier` gibi Flutter çekirdek sınıfları kullanılacaktır. Yalnızca buton animasyonu gibi yerel mikro durumlar için `StatefulWidget` kabul edilir.
2. **UI ve Performans Kuralları:**
   - Statik tüm widget'larda `const` kurucular zorunludur.
   - Renkler ve metin stilleri kesinlikle `AppColors` veya `Theme.of(context)` üzerinden okunacak; kod içerisinde inline sabit hex kodları yazılmayacaktır.
   - 40 satırı geçen `build` metotları yasaktır; modüler özel widget'lara (`widget/` klasörü altına) bölünmelidir.
3. **Harici Paket Sınırlaması:**
   - Projeye onay alınmadan harici ağır state paketleri (Bloc, Riverpod, MobX vb.) EKLENMEYECEKTİR.
   - Grafik kütüphaneleri dâhil olmak üzere yalnızca onaylanmış, hafif ve platform uyumlu paketler tercih edilebilir.

---

## 5. Geliştirme Analiz ve Test Komutları
Ajan, yaptığı herhangi bir kod değişikliğinden sonra aşağıdaki kontrollerin hatasız geçtiğini doğrulamalıdır:

- **Statik Kod Analizi (0 uyarı ve 0 hata şart):**
```bash
flutter analyze
```

- **Birim ve Widget Testleri:**
```bash
flutter test
```

- **Projeyi Çalıştırma:**
```bash
flutter run
```

---

## 6. Ajanın Çıktı ve Yanıt Verme Standartları
- **Açıklamalar:** Türkçe teknik terimlerin özünü bozmadan net ve doğrudan olacaktır.
- **Değişiklik Sunumları:** Var olan uzun bir dosyada küçük bir değişiklik yapıldığında tüm dosya baştan yazılmayacak; ilgili sınıf veya fonksiyon blokları diff/odaklı kod blokları şeklinde gösterilecektir.
- **Dosya Yolları:** Bahsedilen ve üretilen her dosya için proje dizinine göre tıklanabilir yol (ör. `lib/features/blood_values/models/blood_metric.dart`) verilecektir.
- **Doğrulama:** Her kod üretiminden sonra kullanıcıya: *"Şimdi `flutter analyze` ile kontrol edebilirsin."* yönergesi verilecektir.