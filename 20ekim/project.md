# Girişim360 — PROJECT.md

Bu dosya, Girişim360 Flutter projesini geliştiren yapay zekâ ajanları ve yazılım geliştiriciler için bağlayıcı proje kılavuzudur.

Projede üretilen tüm kodlar bu kurallara uymalıdır. Kod yazılmadan önce mevcut proje yapısı incelenmeli, çalışan özellikler korunmalı, gereksiz bağımlılıklardan kaçınılmalı ve yapılan değişiklikler test edilmelidir.

## 1. Proje Özeti

- **Uygulama adı:** Girişim360
- **Amaç:** Girişimcilerin iş fikirlerini geliştirmelerini, mentor bulmalarını, hukuki süreçlerini takip etmelerini, iş planı hazırlamalarını, girişimci topluluğuna katılmalarını ve destek programlarına ulaşmalarını sağlayan dijital bir platform oluşturmak.
- **Hedef platformlar:** Öncelikle iOS ve Android, ardından Web ve masaüstü.
- **Framework:** Flutter 3.29.0
- **Dil:** Dart 3.x
- **Tasarım sistemi:** Material 3
- **Uygulama Icon:** Elektrik mavisi ve turkuaz geçişler,girişimcilik ve büyümeyi temsil eden sembol icon.
- **Arayüz dili:** Türkçe
- **Mimari:** Feature-first, modüler ve katmanlı yapı.
- **Backend:** İlk geliştirme aşamasında demo veriler kullanılabilir. Gerçek kullanıcılar, çevrim içi işlemler ve hassas belgeler için güvenli backend entegrasyonu gereklidir.

Belirtilen Flutter ve Dart sürümleri geliştirme ortamında doğrulanmalı, mevcut proje bağımlılıklarıyla uyumlu sürümler kullanılmalıdır.

## 2. Temel Özellikler

### 2.1. Girişim Yönetimi

Kullanıcılar girişimlerine ait bilgileri oluşturabilmeli ve güncelleyebilmelidir.

- Girişim adı, açıklaması, sektör, hedef kitle, ekip ve iş modeli.
- Girişimin mevcut aşamasını takip etme.
- Görev, son tarih ve kilometre taşı oluşturma.
- Tamamlanan görevlere göre ilerleme hesaplama.
- Girişim bilgilerini düzenleme ve arşivleme.

Girişim aşamaları:

1. Fikir
2. Doğrulama
3. İş planı
4. MVP / prototip
5. Şirketleşme
6. Pazara çıkış
7. Büyüme

Aşama geçişleri açık iş kurallarıyla yönetilmeli ve ilerleme hesaplamaları test edilmelidir.

### 2.2. Mentor–Menti Eşleşmesi

- Mentor ve girişimci profilleri oluşturulmalıdır.
- Sektör, uzmanlık, girişim aşaması, ihtiyaçlar ve uygunluk kriterleri değerlendirilmelidir.
- Eşleşmeler anlaşılır bir uyum puanıyla gösterilmelidir.
- Mentorluk talepleri gönderilebilmeli, kabul veya reddedilebilmelidir.
- Görüşmeler planlanabilmeli ve geçmiş görüşmeler takip edilebilmelidir.
- Görüşme sonrasında geri bildirim verilebilmelidir.

Eşleşme puanının hangi kriterlerden ve ağırlıklardan oluştuğu belgelenmeli; demo eşleşmeleri gerçek mentorlarla kurulmuş bağlantılar gibi gösterilmemelidir.

### 2.3. Hukuki Süreçler ve Avukat

- Şirket kuruluşu, sözleşmeler, marka, fikrî mülkiyet ve KVKK süreçleri takip edilebilmelidir.
- Faaliyet alanına göre gerekli olabilecek hukuki adımlar belirlenebilmelidir.
- Her girişim için ilgili hukuki süreçler etkinleştirilebilmelidir.
- Avukatın adı, uzmanlığı, doğrulanma durumu, iletişim bilgileri ve son görüşme tarihi gösterilebilmelidir.
- Belgelerin yüklenmesi, incelenmesi, eksik belgeler ve son tarihler takip edilebilmelidir.
- Kullanıcılar yalnızca erişim yetkileri bulunan belgeleri görüntüleyebilmelidir.

Genel sistem önerileri ile yetkili hukuk uzmanından alınan danışmanlık açıkça ayrılmalıdır. Hukuki içerikler kesin ve kişiye özel hukuki görüş olarak sunulmamalıdır.

### 2.4. İş Planı Oluşturma ve Analizi

İş planı şu bölümleri içermelidir:

- Problem ve çözüm
- Ürün veya hizmet
- Hedef kitle ve pazar
- Rakip analizi
- İş ve gelir modeli
- Pazarlama ve satış
- Ekip ve operasyon
- Finansal tahminler
- Riskler ve büyüme planı

Analiz sistemi eksik bölümleri, tutarsız varsayımları, finansal riskleri ve iyileştirme önerilerini göstermelidir.

Finansal hesaplamalar test edilebilir kurallarla yapılmalı; yapay zekâ tarafından üretilen analizler tahmin veya öneri olarak işaretlenmeli ve doğrulanmış veri gibi sunulmamalıdır.

### 2.5. Girişimci Topluluğu

- Paylaşım, yorum, beğeni ve kaydetme özellikleri bulunmalıdır.
- Kullanıcılar soru, deneyim, iş birliği ve ekip arkadaşı arayışı paylaşabilmelidir.
- Arama, konu etiketleri ve filtreleme desteklenmelidir.
- İçerik şikâyeti, kullanıcı engelleme ve moderasyon özellikleri bulunmalıdır.
- Özel hukuki belgeler ve gizli girişim bilgileri herkese açık paylaşılmamalıdır.

Topluluk özellikleri için gerekli kimlik doğrulama, erişim kontrolleri ve sunucu tarafı doğrulamalar uygulanmalıdır.

### 2.6. Destekler ve Programlar

- Hibe, teşvik, kuluçka, hızlandırma, yarışma, yatırım ve eğitim programları listelenmelidir.
- Programların uygunluk koşulları, destek türü, son başvuru tarihi ve resmî bağlantısı gösterilmelidir.
- Kullanıcılar programları kaydedebilmeli ve başvuru durumlarını takip edebilmelidir.
- Süresi geçmiş veya doğrulanmamış bilgiler açıkça işaretlenmelidir.
- Program bilgilerinin kaynağı ve son kontrol tarihi mümkün olduğunda saklanmalıdır.

Resmî kaynaklardan doğrulanmamış program bilgileri kesin ve güncel bilgi olarak sunulmamalıdır.

### 2.7. Dashboard ve Bildirimler

Ana sayfada aşağıdaki bilgiler gösterilmelidir:

- Girişimin mevcut aşaması ve ilerlemesi.
- Bekleyen görevler ve yaklaşan tarihler.
- Mentor eşleşmeleri ve görüşmeler.
- Hukuki süreçler ve belge durumları.
- İş planı analiz özeti.
- Önerilen destek programları.
- Topluluk paylaşımları.
- Bildirimler ve önemli hatırlatmalar.

Dashboard verileri ilgili servis veya repository katmanından alınmalı; yükleniyor, hata ve boş veri durumları ele alınmalıdır.

## 3. Tema ve Tasarım

Material 3 kullanılmalıdır.

**Karanlık tema:**
- Dark Navy / Obsidian arka plan.
- Elektrik mavisi ve turkuaz vurgu renkleri.
- Açık renkli, yüksek kontrastlı metinler.

**Aydınlık tema:**
- Beyaz ve açık gri arka plan.
- Kurumsal mavi ve turkuaz vurgu renkleri.
- Koyu lacivert metinler.

Tasarım kuralları:

- ThemeData, ColorScheme ve ThemeMode merkezi olarak yönetilmelidir.
- Açık, koyu ve sistem teması seçenekleri bulunmalıdır.
- Kullanıcı tema tercihi uygulama yeniden başlatıldığında korunmalıdır.
- Tema değişiklikleri bütün ekranlara yansımalıdır.
- Renkler ve metin stilleri ekranlarda sabit değerlerle tekrar edilmemelidir.
- Responsive tasarım ve erişilebilirlik gözetilmelidir.
- Dokunma alanları, metin ölçeklendirmesi ve renk kontrastı kontrol edilmelidir.

## 4. Mimari ve Klasör Yapısı

Kodlar tek bir dosyada toplanmamalıdır. Her özellik kendi modülünde geliştirilmelidir.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── navigation/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── errors/
│   ├── network/
│   ├── security/
│   ├── storage/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── startup/
│   ├── mentor_matching/
│   ├── legal_tracking/
│   ├── business_plan/
│   ├── community/
│   ├── programs/
│   ├── notifications/
│   └── profile/
└── shared/
    ├── models/
    └── widgets/

test/
├── core/
├── features/
└── widgets/

docs/
├── features.md
├── design.md
└── security.md
```

Gerekli klasörler geliştirme sırasında oluşturulmalıdır. Kullanılmayan boş dosyalar ve gereksiz soyutlamalar eklenmemelidir.

Her özellikte ihtiyaca göre models, services, repositories, controllers, views ve widgets katmanları kullanılabilir.

State yönetimi için mevcut projeye uygun, test edilebilir bir yaklaşım seçilmeli ve aynı iş için gereksiz yere birden fazla state yönetimi paketi kullanılmamalıdır.

## 5. Kod Kalitesi

1. Sayfa düzeyinde yoğun setState kullanımından kaçınılmalıdır. Yerel ve geçici arayüz durumlarında kullanılabilir.
2. State yönetimi test edilebilir olmalıdır.
3. Statik widget'larda mümkün olduğunda const kullanılmalıdır.
4. Renkler ve metin stilleri tema altyapısından alınmalıdır.
5. Uzun build metotları küçük, yeniden kullanılabilir widget'lara ayrılmalıdır.
6. İş kuralları UI kodundan ayrılmalıdır.
7. Veri erişimi servis veya repository katmanından yapılmalıdır.
8. Yükleme, hata, boş veri ve başarı durumları ele alınmalıdır.
9. İsimlendirmeler Dart standartlarına uymalıdır.
10. Gereksiz paketler onay ve gerekçe olmadan eklenmemelidir.
11. Asenkron işlemler, hata yönetimi ve ekran yaşam döngüsü doğru ele alınmalıdır.
12. Mevcut çalışan özellikler korunmalı ve değişiklikler küçük adımlarla yapılmalıdır.

## 6. Güvenlik ve Veri Yönetimi

- Kimlik doğrulama ve rol bazlı yetkilendirme uygulanmalıdır.
- Yetki kontrolleri yalnızca UI üzerinde bırakılmamalı, backend tarafında da doğrulanmalıdır.
- Kullanıcılar yalnızca yetkili oldukları girişimlere ve belgelere erişebilmelidir.
- Hassas belgeler güvenli biçimde saklanmalı ve paylaşılmalıdır.
- API anahtarları kaynak koduna gömülmemelidir.
- Kişisel veriler ve hukuki belgeler loglara yazılmamalıdır.
- KVKK, veri saklama, silme ve kullanıcı hakları gereksinimleri değerlendirilmelidir.
- Demo veriler gerçek kullanıcı verilerinden açıkça ayrılmalıdır.
- Dosya yüklemelerinde dosya türü, boyut, erişim yetkisi ve güvenlik kontrolleri uygulanmalıdır.
- Sunucu tarafı yetkilendirme ve veri doğrulama olmadan uygulama üretime hazır kabul edilmemelidir.
- Gerçek kimlik bilgileri ve gizli anahtarlar sürüm kontrolüne eklenmemelidir.

## 7. Geliştirme Sırası

1. Flutter projesini incele ve mevcut yapıyı doğrula.
2. Tema sistemi, ana navigasyon ve ortak bileşenleri oluştur.
3. Dashboard ve girişim aşamalarını geliştir.
4. Mentor–menti eşleşmesini ekle.
5. Hukuki süreçler ve avukat takibini geliştir.
6. İş planı oluşturma ve analizini ekle.
7. Topluluk özelliklerini geliştir.
8. Destek programları ve başvuru takibini ekle.
9. Profil, bildirimler ve ayarları tamamla.
10. Backend entegrasyonu, güvenlik kontrolleri ve platform testlerini gerçekleştir.

Her aşama doğrulanmadan bir sonraki aşamaya geçilmemelidir.

İlk aşamada çalışan bir temel oluşturulmalı; gerçek backend gerektiren özellikler, entegrasyon tamamlanana kadar demo veya geliştirme özelliği olarak açıkça belirtilmelidir.

## 8. Test ve Doğrulama

Her anlamlı kod değişikliğinden sonra uygun testler çalıştırılmalıdır.

Statik analiz:
```bash
flutter analyze
```

Testler:
```bash
flutter test
```

Uygulamayı çalıştırma:
```bash
flutter run
```

Gerekli olduğunda:
```bash
flutter build apk
flutter build web
```

Özellikle aşağıdaki alanlar test edilmelidir:

- Tema değişimi ve tercihin saklanması.
- Girişim aşamaları ve ilerleme hesaplaması.
- Mentor eşleşme kuralları.
- Hukuki belge erişim kontrolleri.
- Finansal hesaplamalar.
- Destek programı başvuru durumları.
- Hata, boş veri ve yükleme durumları.

Testler gerçekten çalıştırılmadan başarılı oldukları iddia edilmemelidir. Mevcut hatalar, çalıştırılamayan kontroller ve doğrulanmamış özellikler raporlanmalıdır.

## 9. Antigravity Çalışma ve Teslim Kuralları

- Kod yazmadan önce mevcut dosyaları ve bağımlılıkları incele.
- Değişiklik yapmadan önce mevcut mimariyi ve çalışan özellikleri değerlendir.
- Küçük ve mantıksal değişikliklerle ilerle.
- Çalışan özellikleri gereksiz yere yeniden yazma.
- Gerçek olmayan backend veya entegrasyonları tamamlanmış gibi gösterme.
- Demo verileri açıkça belirt.
- Her ekranı açık ve koyu temada kontrol et.
- Güvenlik ve yetkilendirme kurallarını dikkate al.
- Dosyaları yalnızca ihtiyaç duyulduğunda oluştur.
- Her görev sonunda değişiklikleri ve test sonuçlarını raporla.
- Dosya yollarını doğru belirt ve doğrulanmamış bağlantılar üretme.
- Büyük dosyaları tekrar basmak yerine kısa diff özeti sun.
- Kullanıcı onayı gerektiren yıkıcı işlemleri, veri silme işlemlerini ve önemli mimari değişiklikleri onaysız gerçekleştirme.

Her teslim şu başlıkları içermelidir:

1. Tamamlanan özellikler.
2. Oluşturulan ve değiştirilen dosyalar.
3. Mimari kararlar.
4. Çalıştırılan testler ve sonuçları.
5. Eksik entegrasyonlar veya bilinen sorunlar.
6. Önerilen sonraki adım.

## 10. Tamamlanma Kriterleri

Bir özellik ancak aşağıdaki koşullar karşılandığında tamamlanmış sayılmalıdır:

- İlgili arayüz ve iş mantığı uygulanmıştır.
- Yükleme, hata ve boş veri durumları ele alınmıştır.
- Tema ve responsive tasarım uyumludur.
- Gerekli erişim kontrolleri uygulanmıştır.
- İlgili testler çalıştırılmış ve sonuçları raporlanmıştır.
- Gerekli backend entegrasyonları doğrulanmıştır veya eksik olduğu açıkça belirtilmiştir.
- Belgelenmesi gereken kararlar ve sınırlamalar kaydedilmiştir.

**Temel ilke:** Önce çalışan, güvenli ve test edilebilir bir temel oluştur. Ardından özellikleri modüler biçimde geliştir. Görsel olarak hazır olan ancak gerçek iş mantığı veya gerekli güvenlik kontrolleri bulunmayan özellikleri üretime hazır olarak sunma.