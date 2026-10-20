# Araç Kiralama Platformu --- Proje Rehberi

Bu doküman Flutter projesinde geliştirme yapacak olan Ajan (AntiGravity) yapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı buradaki kurallara UYMAK ZORUNDADIR.

## 1. Proje amacı ve özellikler

Uygulama Adı: Movira
Hedef Platformlar: iOS ve Android öncelikli; ardından Web ve Masaüstü platformları.
Flutter SDK: 3.15.1
Dart SDK: 3.6.0
Tasarım Dili: Material 3
Tema Durum Yönetimi: ValueNotifier<ThemeMode> ile sayfa düzeyinde ağır setState olmaksızın anlık tema geçişi.


## 2. Çalışma kuralları

1.  Kod yazmadan önce mevcut depo yapısını, `pubspec.yaml`, Flutter/Dart
    sürümlerini, mevcut yönlendirmeyi, durum yönetimini ve testleri
    incele.
2.  Mevcut kodu veya bağımlılıkları incelemeden toplu değişiklik yapma.
    Çalışan yapıyı koru; gerekçesiz yeniden yazım yapma.
3.  Backend, kimlik doğrulama sağlayıcısı, ödeme altyapısı veya harita
    servisi seçilmiş gibi davranma. Önce seçenekleri ve etkilerini
    açıkla; onaylanmadan sağlayıcıya özel entegrasyon ekleme.
4.  Bir iş tamamlandığında değişen dosyaları, önemli kararları,
    çalıştırılan kontrolleri ve kalan işleri özetle.
5.  Gerçek olmayan API, veri veya test başarısı iddia etme.
    Çalıştırılamayan kontrolleri açıkça belirt.
6.  Gizli anahtarları, erişim belirteçlerini veya kişisel verileri
    kaynak koda ve loglara yazma.
7.  Arayüz metinlerini mümkün olduğunca merkezi ve yerelleştirmeye uygun
    tut.

## 3. Ana kullanıcı rolleri

-   **Ziyaretçi:** ilanları ve herkese açık araç/galeri
    değerlendirmelerini görüntüler; teklif vermek, mesaj göndermek veya
    ilan yayımlamak için oturum açmaya yönlendirilir.
-   **Üye / kiracı:** araç arar, filtreler, kiralama bilgilerini
    inceler, araç sahibine soru sorar, teklif verir ve izin verilen
    aşamalarda yorum yapar.
-   **Araç sahibi / ilan veren:** araç ilanı oluşturur ve düzenler,
    fotoğraf ekler, teklifleri inceler, teklif kabul/ret işlemi yapar ve
    kiralama sürecini takip eder.
-   **Yönetici (gelecek kapsam):** ilanları, raporları, kullanıcıları ve
    moderasyonu yönetir. Yönetici ekranları MVP kapsamına otomatik
    olarak dahil değildir.

Bir kullanıcı hem kiracı hem ilan veren olabilir; rolü tek ve değişmez
bir hesap tipine kilitleme.

## 4. Temel özellikler

### 4.1 Üyelik ve oturum

-   Kayıt olma, giriş, çıkış ve oturum durumunu koruma.
-   Form doğrulama, yükleniyor/hata/başarı durumları.
-   Parola sıfırlama, e-posta/telefon doğrulama gibi işlevler backend
    seçimine göre planlanır.Şimdilik user-12345 ile  girilecek
-   Kimlik doğrulama ve yetkilendirme farklı kavramlardır. İlan
    düzenleme ve teklif onayı gibi izinler sunucu tarafında da
    doğrulanmalıdır.
-   Misafir gezinmesi desteklenebilir; korumalı işlemlerde anlaşılır
    giriş yönlendirmesi gösterilir.

### 4.2 Araç ilanlarını keşfetme

-   İlan listesi ve ilan detay ekranı.
-   Arama ve filtreler: konum/bölge (altyapı seçimine bağlı), kiralama
    tarih aralığı ve süresi, günlük/ toplam fiyat aralığı, araç sınıfı,
    marka/model, vites, yakıt türü, koltuk sayısı ve uygunluk.
-   Sıralama: önerilen, fiyat artan/azalan, puan ve yenilik gibi
    seçenekler.
-   Boş sonuç, yükleniyor, hata, yeniden dene ve sayfalama durumları.
-   Filtre seçimi ve aktif filtrelerin temizlenmesi anlaşılır olmalı.

### 4.3 Araç ilanı oluşturma ve yönetme

İlan alanları en az şu bilgileri kapsamalıdır: - Başlık ve açıklama -
Marka, model, model yılı ve araç sınıfı - Yakıt, vites, koltuk sayısı ve
gerekli görülen diğer özellikler - Günlük fiyat, para birimi, varsa
depozito/ek ücretler ve fiyat kuralları - Minimum/maksimum kiralama
süresi - Uygunluk takvimi veya tarih aralığı - Teslim alma bölgesi ve
teslim koşulları - Araç fotoğrafları - İlan durumu: taslak, yayın
incelemesinde (gerekiyorsa), yayında, pasif veya arşivlenmiş

Fiyat, depozito, iptal, kilometre sınırı, sigorta ve yaş/ehliyet
koşulları ürün kararıdır; belirlenmediyse varsayım olarak kesinleştirme.
Gerekli alanları form doğrulamasında belirt.

### 4.4 Fotoğraf galerisi

-   Birden fazla fotoğraf seçme, önizleme, kaldırma ve kapak fotoğrafı
    seçme.
-   Yükleme ilerlemesi ve yükleme hatası gösterme.
-   Dosya türü/boyutu sınırları ve güvenli depolama politikası
    yapılandırılabilir olmalı.
-   Görsel yükleme başarısızsa kullanıcı ilanı kaydetme durumunu
    anlayabilmeli.
-   Fotoğraflar erişilebilir açıklamalarla sunulmalı; gerçek dosya
    depolama sağlayıcısı seçilmeden sağlayıcıya özel kod yazılmamalı.

### 4.5 Teklif ve onay akışı

-   Kiracı, araç ve tarih aralığını seçerek kiralama teklifi oluşturur.
-   Teklif; araç, kiracı, ilan sahibi, başlangıç/bitiş zamanı, teklif
    tutarı, para birimi, mesaj ve zaman damgalarını ilişkilendirir.
-   Durumlar en az: beklemede, kabul edildi, reddedildi, kiracı
    tarafından geri çekildi ve süresi doldu. İptal ve tamamlandı
    durumları kiralama yaşam döngüsüyle ayrıca modellenir.
-   İlan sahibi yalnızca kendi ilanlarına gelen tekliflerde işlem
    yapabilir.
-   Aynı aracın çakışan tarihler için birden fazla teklifinin kabul
    edilmesi yarış koşullarına karşı sunucu tarafında engellenmelidir.
-   Teklifin kabul edilmesi tek başına ödeme alındığı veya rezervasyonun
    kesinleştiği anlamına gelmez. Kesin akış ürün ve backend
    kararlarıyla tanımlanır.
-   Durum geçişleri açık kurallarla ve denetlenebilir olaylarla
    uygulanır.

### 4.6 Araç sahibine soru sorma

-   İlan detayından soru başlatma ve yanıtları görüntüleme.
-   Mesajlar ilgili ilan, gönderen ve alıcıyla ilişkilendirilir.
-   Yalnızca yetkili katılımcılar konuşmayı görebilir.
-   Yükleniyor, boş konuşma, gönderim hatası ve yeniden dene durumları
    bulunur.
-   Spam/engelleme/şikâyet mekanizmaları ürün kapsamına göre
    eklenebilir. Mesajlaşmanın gerçek zamanlı olup olmayacağı backend
    seçimine bağlıdır.

### 4.7 Kiralama ve durum takibi

Kiralama yaşam döngüsü, teklif durumundan ayrı modellenmelidir. Örnek
durumlar: - Teklif kabul edildi / rezervasyon bekliyor - Onaylandı -
Başlangıç zamanı yaklaşıyor - Devam ediyor - Tamamlandı - İptal edildi -
Uyuşmazlık veya inceleme (gerekiyorsa)

Kullanıcılar kendi kiralamalarının güncel durumunu, tarihlerini ve
sonraki adımları görür. Durum değiştirme yetkileri ve geçişleri tanımlı
olmalıdır; istemcideki bir düğmeye güvenerek yetkilendirme
yapılmamalıdır.

### 4.8 Puanlar ve yorumlar

-   Kullanıcılar yalnızca doğrulanabilir ve tamamlanmış bir kiralama
    sonrasında ilgili taraf/araç için değerlendirme yapabilir.
-   Araç puanı ve ilan sahibi/galeri puanı ayrı kavramlar olarak
    tasarlanabilir; iş kuralı netleştirilmeden tek puana
    indirgenmemelidir.
-   Galeriler ayrı bir listeleme türü olarak sunulur; galeri profili,
    ilanları, ortalama puanı ve yorumları bulunabilir.
-   Puanlar 1--5 yıldız olarak gösterilebilir. Ortalama ve değerlendirme
    sayısı birlikte gösterilir.
-   Bir değerlendirme için izin verilen düzenleme/silme kuralları
    tanımlanmalıdır.
-   Tekrarlı yorum, sahte puan ve uygunsuz içerik riskleri ele
    alınmalıdır.
-   Yorum moderasyonu, raporlama ve itiraz akışı ürün kararına göre
    planlanır.
-   Ortalama puan istemcide tek kaynak kabul edilmemeli; güvenilir
    biçimde hesaplanmalı veya sunucu tarafında güncellenmelidir.

### 4.9 Galeri listeleme ve keşfetme

-   Galeri listesi ve detay sayfası.
-   Filtreleme/sıralama; ortalama yıldız, yorum sayısı, konum ve mevcut
    araç sayısı gibi alanlar ürün kapsamına göre eklenebilir.
-   Galeriye ait yorumlar ve puanlar, araç ilanı puanlarından ayırt
    edilmelidir.
-   Galeri sahibi doğrulaması gerekiyorsa süreç ayrıca tanımlanmalıdır.

## 5. Önerilen bilgi mimarisi

Başlangıç navigasyonu için şu bölümler değerlendirilebilir: - Keşfet -
Favoriler (MVP kararına bağlı) - İlan ver - Teklifler / Kiralamalar -
Mesajlar - Profil

Galeri keşfi, Keşfet içinde bir sekme veya ayrı bir ekran olabilir.
Navigasyon nihai hale getirilmeden önce kullanıcı akışları ve kapsam
doğrulanmalıdır.

## 6. Tasarım sistemi

-   Material 3 bileşenleri ve tema altyapısı kullan.
-   Açık/koyu tema desteğini merkezi `ThemeData` üzerinden yönet; sistem
    temasını izleme seçeneği sun.
-   Renk, tipografi, boşluk, köşe yarıçapı ve ikon kurallarını tasarım
    tokenlarıyla merkezileştir.
-   Tutarlı buton, metin alanı, form alanı, yıldız puanı, ilan kartı,
    filtre çipi, durum rozeti, boş durum ve hata bileşenleri oluştur.
-   Formlarda klavye türü, odak sırası, hata metni ve erişilebilir
    etiketleri düşün.
-   Diyaloglar yalnızca gerekli onaylar ve kısa kararlar için
    kullanılsın; uzun formları diyaloga sıkıştırma.
-   Dokunma hedefleri, ekran okuyucu etiketleri, kontrast ve metin
    ölçekleme desteklenmeli.
-   Marka renkleri kararlaştırılana kadar renkleri doğrudan ekranlara
    sabitleme.

## 7. Mimari ve kod düzeni

Mevcut depo incelenerek uyarlanmak şartıyla önerilen feature-first yapı:

``` text
lib/
  app/
    app.dart
    router/
    theme/
    l10n/
  core/
    errors/
    network/
    result/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    vehicles/
      data/
      domain/
      presentation/
    listings/
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

-   Presentation: ekranlar, widget'lar, form durumları ve kullanıcı
    etkileşimleri.
-   Domain: iş kuralları, modeller/entitiler ve gerekiyorsa use
    case'ler.
-   Data: DTO'lar, veri kaynakları, repository uygulamaları ve eşleme.
-   Katmanlar arası bağımlılık yönü kontrollü olmalı; UI doğrudan HTTP
    istemcisine veya veritabanına bağlanmamalı.
-   Durum yönetimi ve yönlendirme paketleri mevcut projeye göre seçilir.
    Yeni projede Riverpod ve `go_router` değerlendirilebilir;
    onaylanmadan mevcut teknoloji yığını değiştirilmemeli.
-   Backend sağlayıcısı henüz belirlenmemiştir. Repository arayüzleri
    sağlayıcı bağımlılığını sınırlar.

## 8. Önemli veri varlıkları

İlk modelleme için: - User - Vehicle - VehicleListing - VehiclePhoto -
Offer - Rental - Conversation - Message - Review - Gallery / Dealer -
AvailabilityPeriod (gerekliyse) - Report / ModerationAction (kapsama
bağlı)

İlişkiler, alanlar, silme politikaları ve veri sahipliği backend seçimi
ve kullanım senaryolarıyla doğrulanmalıdır. Para değerleri kayan nokta
hassasiyetine bırakılmamalı; para birimiyle birlikte güvenli bir temsil
kullanılmalıdır. Tarihler saat dilimi ve çakışma kurallarıyla ele
alınmalıdır.

## 9. Güvenlik ve gizlilik

-   Yetki kontrolleri sunucu tarafında uygulanmalı.
-   Kullanıcı yalnızca kendi ilanını düzenleyebilmeli; teklif üzerinde
    yalnızca yetkili taraflar işlem yapabilmeli.
-   Mesajlar, kişisel bilgiler ve kiralama ayrıntıları yalnızca yetkili
    kullanıcılara açılmalı.
-   İstemci doğrulaması kullanıcı deneyimi içindir; sunucu
    doğrulamasının yerine geçmez.
-   Hassas verileri loglama; sırları `.env` benzeri dosyalarda bile
    repoya ekleme.
-   Fotoğraf ve metin girdileri doğrulanmalı; yüklemelerde dosya türü ve
    boyutu sınırlandırılmalı.
-   KVKK, saklama/silme, kullanıcı rızası ve yasal kiralama koşulları
    ürünün hedef pazarıyla birlikte değerlendirilmelidir. Bu doküman
    hukuki danışmanlık değildir.

## 10. Test stratejisi

-   Unit test: validatörler, fiyat/tarih kuralları, teklif ve kiralama
    durum geçişleri, puan hesaplama.
-   Widget test: form hataları, filtreler, boş/yükleniyor/hata
    durumları, diyaloglar ve tema.
-   Repository test: başarılı yanıt, hata, boş sonuç ve eşleme.
-   Integration test: kayıt/giriş, ilan oluşturma, teklif verme ve
    onaylama, mesajlaşma ve tamamlanmış kiralama sonrası yorum.
-   Eşzamanlı teklif kabulü ve yetkisiz erişim gibi kritik kurallar
    backend testleriyle de doğrulanmalı.
-   Testlerde gerçek kullanıcı verisi veya gerçek üretim anahtarları
    kullanılmamalı.

## 11. MVP önerisi

Öncelik sırası: 1. Proje iskeleti, tema, navigasyon, ortak UI
bileşenleri. 2. Üyelik ve oturum durumu. 3. Araç ilanı listesi,
filtreler ve detay. 4. İlan oluşturma ve fotoğraf yükleme arayüzü. 5.
Teklif oluşturma, ilan sahibinin kabul/ret akışı. 6. Kiralama durum
ekranı. 7. İlan içi soru/mesaj akışı. 8. Tamamlanmış kiralama sonrası
yorum ve puanlar. 9. Galeri profili, listeleme ve puanlama. 10.
Erişilebilirlik, güvenlik, test ve hata durumlarını güçlendirme.

Bu sıra ürün önceliklerine göre değişebilir. Ödeme, kimlik doğrulama
belgeleri, canlı konum, harita, bildirim, sözleşme ve yönetici paneli
kapsamda kesinleşmedikçe otomatik olarak eklenmemelidir.

## 12. Tamamlanma ölçütleri

Bir özellik tamamlandı sayılmadan önce: - Kullanıcı akışının başarı,
boş, yükleniyor ve hata durumları düşünülmüş olmalı. - Form doğrulaması
ve erişilebilir etiketler eklenmiş olmalı. - Yetki ve veri sahipliği
etkileri değerlendirilmiş olmalı. - İlgili testler yazılmış ve mümkünse
çalıştırılmış olmalı. - `flutter analyze` ve ilgili test sonuçları
raporlanmalı. - Tasarım tokenları ve ortak bileşenler kullanılmalı;
yinelenen kod gerekçesiz çoğaltılmamalı. - Belirsiz ürün kararları
açıkça listelenmeli, sessizce varsayılmamalı.
 **Değişiklik Sunumları:** Var olan uzun bir dosyada küçük bir değişiklik yapıldığında tüm dosya baştan yazılmayacak; ilgili sınıf veya fonksiyon blokları diff/odaklı kod blokları şeklinde gösterilecektir.
- **Dosya Yolları:** Bahsedilen ve üretilen her dosya için proje dizinine göre tıklanabilir yol (ör. `lib/features/vehicles/domain/entities/vehicle_entity.dart`) verilecektir.
