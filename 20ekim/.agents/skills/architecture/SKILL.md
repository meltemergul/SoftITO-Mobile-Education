---
name: girisim360-architecture
description: Girişim360 Flutter uygulamasında mimari kararlar, feature-first modüller, katmanlar, state yönetimi, veri akışı, backend sınırları, güvenlik ve testler üzerinde çalışırken kullanılır.
---

# Girişim360 Architecture Skill

## Amaç

Girişim360'ı sürdürülebilir, test edilebilir ve güvenli bir Flutter uygulaması olarak geliştir. Bu beceri yeni özellik ekleme, mevcut kodu düzenleme, klasör yapısını belirleme, veri modelleri oluşturma, state yönetimi seçme ve backend entegrasyonu planlama sırasında uygulanır.

`PROJECT.md` projenin bağlayıcı genel kurallarını tanımlar. Bu skill mimari kararların nasıl alınacağını açıklar. Mevcut proje incelenmeden büyük çaplı yeniden yapılandırma yapma.

## Çalışmaya başlamadan önce

1. `PROJECT.md`, `pubspec.yaml`, `lib/`, `test/` ve mevcut dokümantasyonu incele.
2. Flutter ve Dart sürümlerini doğrula; mevcut paketlerin sürüm ve kullanımını kontrol et.
3. Uygulamanın başlangıç noktası, yönlendirme, state yönetimi, tema ve veri erişim yollarını belirle.
4. Çalışan özellikleri, mevcut testleri ve bilinen hataları not et.
5. En küçük güvenli değişiklik planını çıkar; kullanıcı istemedikçe tüm mimariyi baştan yazma.
6. Paket eklemeden önce mevcut bağımlılıkların ihtiyacı karşılayıp karşılamadığını değerlendir.

## Mimari ilkeler

- **Feature-first:** Kodları teknik katmana göre tüm uygulamada toplamak yerine öncelikle iş özelliklerine göre grupla.
- **Katman ayrımı:** UI, iş kuralları ve veri erişimi birbirinden ayrılmalı.
- **Bağımlılık yönü:** Presentation, domain sözleşmelerini kullanır; data katmanı domain sözleşmelerini uygular. Domain, Flutter UI veya somut veri kaynağına bağımlı olmamalı.
- **Yüksek uyum, düşük bağlılık:** Bir özellikteki değişiklik diğer özellikleri gereksiz yere etkilememeli.
- **Test edilebilirlik:** İş kuralları UI'dan bağımsız olarak test edilebilmeli.
- **Yalınlık:** Gerçek gereksinim olmadan soyutlama, katman, paket veya boş dosya oluşturma.
- **Aşamalı evrim:** İlk sürümde modüler monolit yaklaşımını tercih et; mikroservisleri ancak kanıtlanmış ölçek veya ekip ihtiyacı varsa değerlendir.
- **Mevcut yapıya saygı:** İşleyen kodu sırf tercih edilen mimariye uymuyor diye topluca yeniden yazma.

## Önerilen dizin yapısı

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── bootstrap.dart
│   ├── router/
│   └── di/
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── security/
│   ├── storage/
│   ├── theme/
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
```

Bir özellik için yalnızca gereken katmanları oluştur:

```text
features/startup/
├── data/
│   ├── datasources/
│   ├── dto/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── controllers/
    ├── pages/
    └── widgets/
```

Bu örnek zorunlu bir klasör şablonu değildir. Basit bir özellikte ayrı use case veya DTO katmanı gerekmiyorsa gereksiz dosyalar üretme. Bir katman ancak gerçek sorumluluğu varsa eklenmeli.

## Katmanların sorumlulukları

### App

- Uygulama başlangıcı, tema, yönlendirme ve bağımlılık kurulumunu koordine eder.
- İş kurallarını ve veri erişim mantığını burada toplama.
- Başlangıçta gerekli konfigürasyonu doğrula; gizli anahtarları kaynak koduna koyma.

### Core

- Tema, ağ istemcisi, ortak hata tipleri, güvenli depolama adaptörleri ve genel yardımcıları içerir.
- `core` içine belirli bir iş özelliğine ait kuralları koyma.
- Ortak kodu yalnızca birden fazla modül gerçekten paylaşıyorsa buraya taşı.

### Presentation

- Sayfalar, widget'lar ve UI state'ini yöneten controller/notifier bileşenlerini içerir.
- Kullanıcı etkileşimlerini use case veya repository üzerinden işleme aktarır.
- HTTP isteklerini, SQL sorgularını veya karmaşık iş kurallarını widget içine yazma.
- Yükleniyor, başarı, boş ve hata durumlarını açıkça modelle.

### Domain

- İş kuralları, entity'ler, repository sözleşmeleri ve gerektiğinde use case'leri içerir.
- Flutter widget'larına, belirli bir HTTP istemcisine veya veritabanı paketine bağlanmamalı.
- İş mantığı için anlaşılır girdiler, çıktılar ve hata sonuçları tanımla.

### Data

- Repository uygulamaları, uzak/yerel veri kaynakları ve gerekliyse DTO dönüşümlerini içerir.
- API yanıtlarını doğrudan UI modeline kontrolsüz biçimde taşımak yerine doğrula ve dönüştür.
- Ağ hatası, zaman aşımı, yetkisiz erişim ve beklenmeyen yanıtları ele al.
- Demo ve gerçek veri kaynaklarını açık biçimde ayır.

## State yönetimi

- Mevcut projede çalışan bir state yönetimi çözümü varsa önce onu değerlendir.
- Yeni projede Riverpod değerlendirilebilir; ancak eklemeden önce sürüm ve mevcut bağımlılıklarla uyumu doğrula.
- Aynı iş için birden fazla state yönetimi yaklaşımını gelişigüzel karıştırma.
- Widget içinde yalnızca yerel ve geçici UI state'i için `setState` kullanılabilir.
- İş kuralları controller/notifier veya domain katmanında tutulmalı.
- Asenkron state; loading, data/success, empty ve error durumlarını kapsamalı.
- Bir işlemden sonra ekranın güncellenmesi açık ve test edilebilir olmalı.
- Controller'ların yaşam döngüsünü ve aboneliklerin temizlenmesini dikkate al.

## Repository ve veri akışı

Önerilen akış:

`Page/Widget → Controller/Notifier → Use case (gerekiyorsa) → Repository sözleşmesi → Repository uygulaması → Data source`

- Her küçük işlem için zorunlu olarak use case oluşturma; iş kuralı karmaşıklaştığında veya tekrar kullanıldığında ekle.
- Repository sözleşmesi domain katmanında, uygulaması data katmanında bulunabilir.
- Yerel demo verisini doğrudan UI dosyasına gömme.
- Veri kaynağı değiştiğinde ekranların etkilenmemesi için repository sınırını koru.
- Hata sonuçlarını kullanıcıya gösterilecek mesajlardan ayır; teknik ayrıntıları hassas veri içermeden kaydet.
- Cache ve çevrimdışı davranışlarını yalnızca gereksinim varsa ekle ve veri tutarlılığını tanımla.

## Girişim360 alan modeli ve iş kuralları

- Girişim aşamalarını sabit ve doğrulanabilir bir modelde tanımla: Fikir, Doğrulama, İş planı, MVP/prototip, Şirketleşme, Pazara çıkış, Büyüme.
- İlerleme yüzdesini açıkça belgelenmiş bir kuralla hesapla; rastgele veya yalnızca görsel amaçlı değer üretme.
- Mentor uyum puanında kriterleri ve ağırlıkları belirle; puanı gerçek bir başarı garantisi gibi sunma.
- Hukuki adımlar girişimin türü ve faaliyet alanına göre değişebilir; tüm kullanıcılara aynı zorunlu listeyi koşulsuz uygulama.
- Finansal hesaplamaları UI dışına çıkar ve sınır durumlarıyla test et.
- Programların kaynak, son kontrol tarihi ve son başvuru tarihi gibi alanlarını modelle.
- Yapay zekâ çıktılarıyla doğrulanmış kaynak verilerini ayrı tut; varsayımları ve belirsizliği sakla.
- Durum alanları için tutarlı enum veya benzeri tipli model kullan; serbest metin durumlarına gereksiz yere dayanma.

## Backend ve güvenlik sınırları

- Demo veri kaynağını gerçek backend olarak tanıtma.
- Backend sağlayıcısı ve API sözleşmeleri seçilmeden hayali endpoint veya tamamlanmış entegrasyon üretme.
- Kimlik doğrulama ile yetkilendirmeyi ayrı değerlendir.
- UI'da gizlenen bir kontrol güvenlik sınırı değildir; tüm yetki kontrolleri sunucu tarafında uygulanmalı.
- Her girişim kaynağında kullanıcı üyeliği/rolü doğrulanmalı.
- Hukuki belgeler için güvenli dosya depolama, erişim politikaları, indirme yetkileri ve gerektiğinde süreli bağlantılar planlanmalı.
- Gizli anahtar, token, kişisel veri veya belge içeriğini loglama.
- API anahtarlarını mobil istemciye gömerek gizli tutmaya çalışma; sunucuya ait sırları backend'de sakla.
- Veri saklama, silme, dışa aktarma ve KVKK gereksinimlerini tasarım aşamasında değerlendir.
- Güvenlik kontrolleri uygulanmadan özelliği üretime hazır olarak işaretleme.

## Hata yönetimi

- Beklenen iş hataları ile ağ/altyapı hatalarını ayır.
- Kullanıcıya eyleme dönük, Türkçe ve anlaşılır mesajlar göster.
- Hassas teknik ayrıntıları veya stack trace'i kullanıcı arayüzüne gösterme.
- Ağ isteklerinde uygun timeout ve hata davranışı tanımla.
- Yeniden deneme yalnızca güvenli işlemlerde ve uygun koşullarda yapılmalı; kayıt oluşturma gibi işlemlerde çift kayıt riskini değerlendir.
- Başarısız işlemde kullanıcı girdisini mümkün olduğunca koru.

## Test stratejisi

Her anlamlı değişiklikten sonra uygun kontrolleri çalıştır:

```bash
flutter analyze
flutter test
```

Gerekli olduğunda platform build'lerini de doğrula. Çalıştırılmamış testleri başarılı diye raporlama.

Test katmanları:

- Unit test: iş kuralları, ilerleme hesapları, eşleşme puanı ve finansal hesaplamalar.
- Repository test: veri dönüşümleri, hata eşlemesi ve veri kaynağı davranışı.
- Controller/provider test: loading, success, empty ve error durumları.
- Widget test: temel etkileşim, doğrulama ve erişilebilir UI davranışı.
- Entegrasyon testi: kritik kullanıcı akışları ve gerçek backend bağlandığında yetki senaryoları.

## Bağımlılık ve kod kalitesi

- Yeni paket eklemeden önce Flutter/Dart uyumluluğunu, bakım durumunu ve mevcut çözümü incele.
- Gereksiz bağımlılık, duplicate paket ve kullanılmayan kod ekleme.
- Uygun olduğunda `const` kullan.
- İsimlendirmelerde Dart standartlarına uy.
- Uzun metotları ve widget ağaçlarını anlamlı parçalara ayır.
- Her soyutlamanın somut bir sorumluluğu olmalı.
- API ve domain modellerinin birbirine dönüşümü açık ve test edilebilir olmalı.
- Sırf mimari örneğine uymak için çalışan kodu gereksiz yere taşıma.

## Değişiklik yapma prosedürü

1. İlgili dosyaları ve çağrı zincirini incele.
2. Mevcut davranışı ve olası yan etkileri belirle.
3. En küçük yeterli değişiklik planını oluştur.
4. Kod değişikliğini uygula.
5. Formatlama ve statik analizi çalıştır.
6. İlgili testleri çalıştır; mümkünse yeni davranış için test ekle.
7. Değiştirilen dosyaları ve doğrulanamayan noktaları raporla.

## Teslim raporu

Her görev sonunda şu başlıkları kullan:

1. Tamamlanan özellikler
2. Oluşturulan/değiştirilen dosyalar
3. Mimari kararlar ve gerekçeleri
4. Çalıştırılan komutlar ve gerçek sonuçları
5. Eksik entegrasyonlar, bilinen riskler ve takip işleri
6. Önerilen sonraki adım

Testler çalıştırılamadıysa nedenini açıkla. Backend veya harici servis kurulmadıysa entegrasyonun tamamlandığını söyleme.

## Tamamlanma kontrol listesi

- [ ] Değişiklik mevcut mimariyle uyumlu.
- [ ] UI, iş kuralları ve veri erişimi doğru ayrılmış.
- [ ] Yükleniyor, hata, boş ve başarı durumları ele alınmış.
- [ ] Yetki kontrolleri yalnızca UI'a bırakılmamış.
- [ ] Hassas veri loglanmıyor.
- [ ] İlgili testler eklenmiş veya mevcut testler çalıştırılmış.
- [ ] `flutter analyze` sonucu raporlanmış.
- [ ] Demo ve gerçek entegrasyonlar açıkça ayrılmış.
- [ ] Değiştirilen dosyalar ve bilinen sınırlamalar teslim raporunda listelenmiş.

**Temel kural:** Önce mevcut sistemi anla, sonra en küçük güvenli değişikliği yap. Mimariyi amaç değil, sürdürülebilir ve test edilebilir ürün geliştirmek için araç olarak kullan.
