# Fitness Su Takip Uygulaması
Bu döküman Flutter projesinde geliştirme yapacak olan Ajan(antigravity) yaapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur.Projede üretilen her kod satırı buradaki kurallara UYMAK ZORUNDADUR.

## 1.Proje Özeti ve Teknolojiler
-**Uygulama Adı:** susadım(akıllı su egzersiz ve kalori takibi uygulaması)

-**Hedef Platform:** ios ve android öncelikli ardından web ve masaüstü platformları

-**Flutter SDK:** 3.29.0

-**Dart SDK:** 3.0.0

-**Tasarım Dili:** Material 3,Koyu Tema(gece spor salonu paleti,dark obsidian&neon);

-**Özellikler:** 
* **Egzersiz Takibi** Egzersiz yaptıkça ihtiyaç duyulan su miktarı otomatik olarak hesaplanır ve kullanıcıya bildirilir.
* **Akıllı Su Takibi** Günlük su tüketimi hedeflenen miktara ulaşma durumu ve geçmiş kayıtlarını tutar. 

## Mimarı Yapı : Özellik bazlı
kodlar kesinlikle tek bir yerde toplanmayacaktır.her modül kendi feature klasöründe kodlanacaktır.

## AppIcon: 
Su içen bir adamın silüetini mavi-siyah yap,sağ üst köşede spor aleti olsun


```text
lib/
core/
extension'lar
      constans/app_colors.dart
      theme/app_theme.dart

  feautres/
       water_traker/
          controller/
          models/
          view/
          widget/
    workout/
        contoller/
        models/
        wiew/
        widget/

      main.dart
```

#### sadece uygulama başlatma ve tema bölümleri

## 3 Kırmızı çizgiler kod kalite standartları
1-  **State yönetim standartları**
sayfa düzeyinde ağır `setState` KULLANILMAYACAKTIR.
sadece yerel arayüz durumunu yöneten (örneğin buton animasyonları vb.) StatefulWidget kabul edilir.


2- **UI ve Performans Kuralları:**
Statik tüm widget'lerda `const` zorunludur.
Renk ve metin stilleri keasinlikle yasaktır 40 satırı geçen build metodları özel widgetlere yazılacaktır.

3- **Yasaklı Paketler:**
Projeye onay almadan harici ağır state paketleri EKLENMEYECEKTİR.
Dart'ın Flutter'ın yerel çekirdel apilerini kullanmak esastır.

## 4 Geliştirme analiz ve test komutları
Ajan yaptığı herhangi bir kod değişikliklerden sonra mutlaka alttaki komutların çalıştığını doğrulamalıdır.

* **Statik Kod Analizi(0 uyarı ve 0 hata şart):**
```bash
flutter analyze
````

* **Birim ve widget testleri:**
```bash
flutter test
```
* **Prpojeyi çalıştırma:**
```bash
fluttter run
```

## 5 ajanın çıktı ve yanıt verme standartları

**Açıklamalar** Türkçe teknik terimlerin özünü bozmadan net ve doğrudan olacaktır.
**Değişiklik Sunumları:** Örnek 500 satırlık bir dosyada 3 satır değiştiyse tüm dosyayı baştan sonra basma;hedef satırları ve diff yapısını göster
**Dosya Yolları**Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklanabilir link ver.
**Doğrulama:** Kod yazdıktan sonra kullanıcıyı "şimdi flutter analiz ile kontrol edebilirsin" şeklinde doğrulama yönergeleri ver.



      

