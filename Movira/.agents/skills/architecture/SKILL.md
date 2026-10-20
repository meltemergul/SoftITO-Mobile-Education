# Architecture Skill --- Flutter Feature-First

## Amaç

Araç kiralama uygulamasının iş kurallarını UI, durum yönetimi ve veri
sağlayıcılarından ayırarak test edilebilir bir mimari kur. Önce mevcut
projeyi incele; bu belgeyi mevcut kodun üzerine düşünmeden dayatma.

Detaylı durum yaşam döngüsü, Dart 3 sealed class modelleri ve exception-failure
eşlemeleri için [.agents/skills/references/state_flow.md](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/references/state_flow.md)
belgesini ve modül üretimleri için [.agents/skills/scripts/generate_feautre.sh](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/scripts/generate_feautre.sh)
betiğini kullan.

## Karar ilkeleri

1.  Var olan mimariyi ve paketleri incele; çalışan yapıyı gerekçesiz
    değiştirme.
2.  Feature-first organizasyonu tercih et; her özellik kendi
    presentation, domain ve data sorumluluklarını taşısın.
3.  UI katmanı doğrudan HTTP, SQL veya backend SDK çağırmasın.
4.  Domain katmanı Flutter widget'larına ve belirli backend
    sağlayıcısına bağımlı olmasın.
5.  Basit ihtiyaçlar için gereksiz soyutlama, aşırı use case veya katman
    üretme.
6.  Backend ve kimlik doğrulama sağlayıcısı kararlaştırılmadıysa
    seçenekleri belgele; varsayılan olarak sağlayıcıya özgü kod ekleme.

## Önerilen yapı

Mevcut depoya göre uyarlanmak üzere:

``` text
lib/
  app/
    app.dart
    router/
    theme/
    l10n/
  core/
    errors/
    result/
    network/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    listings/
      data/
      domain/
      presentation/
    vehicles/
      data/
      domain/
      presentation/
    offers/
      data/
      domain/
      presentation/
    rentals/
      data/
      domain/
      presentation/
    messaging/
      data/
      domain/
      presentation/
    reviews/
      data/
      domain/
      presentation/
    galleries/
      data/
      domain/
      presentation/
```

## Katman sorumlulukları

### Presentation

-   Ekranlar, widget'lar, form state'i ve kullanıcı etkileşimi.
-   Durum yönetimi üzerinden domain/repository arayüzlerine erişir.
-   API DTO'larını doğrudan UI modeli olarak kullanmaktan kaçınır.
-   Yükleniyor, başarı, boş ve hata durumlarını açık modellerle temsil
    eder.

### Domain

-   İş varlıkları, iş kuralları ve gerektiğinde use case'ler.
-   Teklif/kiralama durum geçişleri, tarih çakışması ilkeleri ve yorum
    uygunluğu gibi kuralları ifade eder.
-   Flutter UI ve backend SDK'larından bağımsız tutulur.
-   Basit CRUD işlemlerinde gereksiz katman ekleme; karmaşık iş
    kurallarında use case kullan.

### Data

-   Repository uygulamaları, uzak/yerel veri kaynakları, DTO ve
    mapper'lar.
-   Ağ/SDK hatalarını uygulamanın tanımlı hata modeline dönüştürür.
-   Backend yanıtlarını doğrulamadan domain modeline güvenilir veri
    olarak kabul etmez.
-   Sayfalama, zaman aşımı, tekrar deneme ve iptal davranışlarını
    ihtiyaca göre ele alır.

## Durum yönetimi ve yönlendirme

-   Projede mevcut bir yaklaşım varsa onu takip et.
-   Yeni projede Riverpod ve `go_router` değerlendirilebilir; seçimi
    bağımlılık eklemeden önce açıkla.
-   Oturum durumuna bağlı yönlendirme merkezi olmalı.
-   Giriş gerektiren sayfalara yönlendirmede dönüş hedefi güvenli
    biçimde korunabilir.
-   Navigasyon koruması, backend yetkilendirmesinin yerine geçmez.
-   Asenkron işlemlerde ekran kapanmışsa state güncellemesi ve kaynak
    temizliği güvenli olmalı.

## Temel domain kuralları

### İlan ve araç

-   Araç varlığı ile kiralama ilanı kavramsal olarak ayrılmalı; bir
    aracın ilan geçmişi ve ilan durumu gerekebilir.
-   İlan düzenleme yetkisi sunucu tarafında sahiplik kontrolüyle
    doğrulanmalı.
-   Fotoğraf metaverisi ve sıralaması ilanla ilişkilendirilmeli.

### Teklif ve kiralama

-   `Offer` ile `Rental` ayrı varlıklar olmalı; teklif kabulü otomatik
    olarak ödeme tamamlandı anlamına gelmemeli.
-   Teklif durumu için geçerli durum geçişleri tanımlanmalı.
-   Aynı araç ve çakışan tarih aralıklarında eşzamanlı kabul işlemleri
    backend/veritabanı düzeyinde atomik olarak kontrol edilmeli.
-   İstemci tarafındaki kontrol yalnızca kullanıcı deneyimi sağlar;
    bütünlük garantisi vermez.
-   Zaman damgaları, saat dilimi ve başlangıç/bitiş sınırları açıkça
    tanımlanmalı.
-   Para tutarı kayan noktalı sayı ile gelişigüzel temsil edilmemeli;
    para birimiyle birlikte kesin bir format kullanılmalı.

### Mesajlaşma

-   Konuşma, ilan ve katılımcılar arasında açık ilişki olmalı.
-   Erişim denetimi her okuma/yazma işleminde uygulanmalı.
-   Gerçek zamanlı iletişim veya polling kararı backend yeteneklerine
    göre verilmeli.

### Puan ve yorum

-   Yorum yazma hakkı tamamlanmış ve doğrulanabilir kiralama koşuluna
    bağlanmalı.
-   Tekrar yorum, moderasyon ve güncelleme kuralları tanımlanmalı.
-   Araç, araç sahibi ve galeri puanlarının kapsamı ayrı modellenmeli.
-   Ortalama puan hesaplaması tutarlı olmalı; mümkünse sunucu tarafında
    güvenilir biçimde yönetilmeli.

### Galeri

-   Galeri/işletme profili ile tekil araç ilanı farklı varlıklar olarak
    ele alınmalı.
-   Galeri yorumları ve araç yorumları veri modelinde karıştırılmamalı.
-   Galeri sahipliği/doğrulaması gerekip gerekmediği ürün kararıdır.

## Hata modeli

-   Hataları kullanıcıya gösterilebilir kategoriye dönüştür: ağ,
    yetkisiz erişim, doğrulama, bulunamadı, çakışma ve beklenmeyen hata.
-   Teknik detayları kullanıcıya ham biçimde gösterme.
-   İstemci retry davranışını idempotent olmayan işlemlerde dikkatle
    tasarla.
-   Teklif gönderimi veya kabulü gibi işlemlerde çift gönderim ve tekrar
    istek riskini ele al.

## Güvenlik

-   Yetkilendirme, sahiplik, teklif katılımcılığı ve mesaj erişimi
    backend'de kontrol edilmeli.
-   Hassas alanlar loglanmamalı; sırlar depoya eklenmemeli.
-   Dosya yüklemeleri tür, boyut ve erişim politikalarıyla korunmalı.
-   Oturum belirteçleri platformun güvenli depolama mekanizmasına uygun
    saklanmalı.
-   KVKK ve veri saklama/silme kararları ürün ve hukuk incelemesi
    gerektirir.

## Test edilebilirlik

-   Domain kuralları unit testlerle sınanmalı.
-   Repository arayüzleri fake/mock uygulamalarla test edilebilmeli.
-   UI testleri başarı, boş, yükleniyor, hata ve tekrar dene durumlarını
    kapsamalı.
-   Kritik akışlar: oturum, ilan oluşturma, fotoğraf ekleme, teklif
    gönderme, teklif kabul/ret, mesajlaşma, kiralama durum değişimi ve
    yorum gönderme.
-   Yetkisiz işlemler ve çakışan tarihli teklif kabulü için backend
    testleri planlanmalı.

## Bağımlılık yönetimi

-   Paket eklemeden önce ihtiyacı, mevcut alternatifleri ve bakım
    durumunu değerlendir.
-   Sürüm uyumluluğunu mevcut Flutter/Dart SDK ile doğrula.
-   Paket sürümlerini ve lockfile değişikliklerini kontrol et.
-   Sağlayıcı seçilmeden Firebase/Supabase/özel API kodunu varsayılan
    kabul etme.

## Mimari karar kaydı

Önemli kararlar için kısa bir kayıt tut: - Bağlam / ihtiyaç -
Değerlendirilen seçenekler - Karar ve gerekçe - Etkiler / ödünleşimler -
Yeniden değerlendirme koşulu

## Mimari teslim kontrol listesi

-   [ ] Mevcut proje ve bağımlılıklar incelendi.
-   [ ] UI, domain ve data sorumlulukları ayrıldı.
-   [ ] İş kuralları widget içine gömülmedi.
-   [ ] Teklif ve kiralama yaşam döngüleri ayrıştırıldı.
-   [ ] Yetki ve eşzamanlılık kuralları sunucu tarafı gereksinimi olarak
    belgelendi.
-   [ ] Hata, boş ve yükleniyor durumları tanımlandı.
-   [ ] Testler ve analiz komutları çalıştırıldı veya neden
    çalıştırılamadığı belirtildi.
-   [ ] Belirsiz ürün/backend kararları açıkça listelendi.
