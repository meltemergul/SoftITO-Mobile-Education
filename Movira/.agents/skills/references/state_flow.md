# Movira — Durum Yönetimi ve Veri Akışı Kılavuzu (State Flow & Data Lifecycle Reference)

Bu doküman, Movira Flutter Araç Kiralama Platformu uygulamasındaki durum yönetimi (state management), tek yönlü veri akışı (unidirectional data flow), katman sorumlulukları, yaşam döngüsü durumları, hata yönetimi, güvenlik, tema entegrasyonu ve oturum kurallarını belirleyen bağlayıcı referans kılavuzdur.

Bu kılavuz; `PROJECT.md`, `.agents/SKILL.md`, `.agents/skills/architecture/SKILL.md` ve `.agents/skills/design/SKILL.md` belgelerinde tanımlanan ilkelerle %100 uyumlu olarak hazırlanmıştır.

---

## 1. Mimari Prensipler ve Veri Akışı Genel Bakışı

Movira, **Feature-First (Özellik Öncelikli)**, **Modüler** ve **Katmanlı (Clean Architecture / Domain-Driven)** mimari yaklaşımını benimser.

### 1.1. Tek Yönlü Veri Akışı (Unidirectional Data Flow)

Uygulamada veri akışı kesin kurallara bağlıdır ve ters yönde kontrolsüz veri transferine izin verilmez:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION KATMANI                          │
│                                                                        │
│   [ Page / View ] ──(Kullanıcı Etkileşimi)──► [ Controller / Notifier ] │
│          ▲                                             │               │
│          │                                             │ (İş Mantığı)  │
│          └───(Immutable State / Reaktif Dinleme)───────┘               │
└────────────────────────────────────────────┬───────────────────────────┘
                                             │
                                             ▼
┌────────────────────────────────────────────────────────────────────────┐
│                             DOMAIN KATMANI                             │
│                                                                        │
│   [ Use Case / Interactor ] (Orkestrasyon, Tarih & Fiyat Kuralları)    │
│                          │                                             │
│                          ▼                                             │
│   [ Repository Sözleşmesi (Abstract Interface) ]                       │
│   [ Entities & Value Objects (Saf Dart Nesneleri) ]                    │
└────────────────────────────────────────────┬───────────────────────────┘
                                             │
                                             ▼
┌────────────────────────────────────────────────────────────────────────┐
│                              DATA KATMANI                              │
│                                                                        │
│   [ Repository Implementation ]                                        │
│          │                                                             │
│          ├──► [ Remote Data Source (REST API / Demo Remote Source) ]   │
│          ├──► [ Local Data Source (Secure Storage / SharedPreferences) ]│
│          └──► [ DTO & Mapper (JSON / Harici Veri -> Domain Entity) ]   │
└────────────────────────────────────────────────────────────────────────┘
```

1. **Görünüm (View):** Yalnızca state'i render eder ve kullanıcı etkileşimlerini (tıklama, form doldurma, filtre seçimi) Controller'a iletir. Doğrudan API çağırmaz, iş mantığı barındırmaz.
2. **Denetleyici (Controller / ValueNotifier):** Sayfa durumunu yönetir, use case veya repository çağrısını başlatır, dönen `Result<T, Failure>` sonucuna göre UI durumunu immutable nesnelerle günceller.
3. **İş Mantığı (Domain):** Uygulamanın çekirdek kurallarını (çakışan kiralama tarihleri, teklif durum geçişleri, kiralama tamamlanmadan yorum yapılamaması vb.) uygular. UI ve harici kütüphanelerden tamamen bağımsızdır.
4. **Veri (Data):** Harici kaynaklardan (ağ veya yerel disk) veriyi çeker, DTO modellerini domain varlıklarına (Entity) dönüştürür, hata durumlarını uygulamanın standart `Failure` nesnelerine çevirir.

---

### 1.2. Katman Sorumluluk Matrisi

| Katman | Sorumluluklar | İçerdikleri | Asla Yapılmaması Gerekenler |
| :--- | :--- | :--- | :--- |
| **Presentation** | Ekran çizimi, animasyonlar, kullanıcı girdisi toplama, erişilebilirlik, tema takibi | `Pages`, `Widgets`, `Controllers / ValueNotifiers`, `UI State Modelleri` | HTTP isteği atmak, doğrudan veritabanı sorgulamak, ham iş kuralı çalıştırmak, `BuildContext`'i asenkron boşluklardan sonra kontrolsüz kullanmak |
| **Domain** | Çekirdek iş mantığı, varlıklar, durum geçiş doğrulamaları, kontratlar | `Entities`, `Value Objects`, `Repository Interfaces`, `Use Cases`, `Failures` | `flutter/material.dart` import etmek, harici backend SDK'sına (Firebase, Supabase vb.) doğrudan bağımlı olmak |
| **Data** | Veri sağlama, önbellekleme, serileştirme/haritalama, hata dönüştürme | `Repository Impl`, `Remote Data Sources`, `Local Data Sources`, `DTOs / Mappers` | UI nesnelerini bilmek, domain varlıklarını doğrudan JSON alanlarıyla kirletmek, yetki doğrulaması yapmadan veriyi güvenilir saymak |

---

## 2. Durum Yaşam Döngüsü ve Modelleme (State Lifecycle)

Movira ekranları, asenkron işlemler boyunca aşağıdaki standart yaşam döngüsünü takip eder:

### 2.1. Standart UI Durumları

```text
                ┌──────────────┐
                │   Initial    │
                └──────┬───────┘
                       │ (Ekran Açılışı / Veri Yükleme Başlangıcı)
                       ▼
                ┌──────────────┐
       ┌───────►│   Loading    │◄──────────────┐
       │        └──────┬───────┘               │
       │               │                       │
       │     (Başarılı │ Yanıt)                │ (Yeniden Dene / Retry)
       │               ▼                       │
       │        ┌──────────────┐               │
       │        │   Success    ├────┐          │
       │        └──────────────┘    │          │
(Tekrar│               │ (Veri      │ (İşlem   │
Yükle) │               │  Boşsa)    │  Hatası) │
       │               ▼            │          │
       │        ┌──────────────┐    │          │
       │        │    Empty     │    │          │
       │        └──────────────┘    ▼          │
       │                     ┌──────────────┐  │
       └─────────────────────┤    Error     ├──┘
                             └──────────────┘
```

1. **Initial (Başlangıç):** Ekran ilk kez belleğe yüklendiğinde ve henüz hiçbir veri isteği tetiklenmediğinde geçerlidir.
2. **Loading (Yükleniyor):** Veri kaynağından yanıt beklenirken gösterilen durumdur. İskelet yükleyiciler (shimmer) veya dairesel ilerleme çubukları sunulur.
3. **Success (Başarılı):** Veri başarıyla alınmış ve en az bir geçerli veri öğesi bulunmuştur.
4. **Empty (Boş Durum):** Sorgulanan kriterlere uygun hiçbir araç, teklif veya mesaj bulunamadığında gösterilir. Kullanıcıya net eylem önerisi (filtreleri temizle, yeni teklif ver vb.) sunar.
5. **Error (Hatalı Durum):** Ağ kesintisi, sunucu hatası veya izin uyuşmazlığı durumunda gösterilir. Ekranda kullanıcı dostu Türkçe hata mesajı ve **Yeniden Dene** butonu yer alır.

### 2.2. Eylem Durumları (Action & Mutation States)

Mevcut ekran açıkken gerçekleştirilen mutasyon işlemlerinde (ör. teklif verme, teklif onaylama, ilan silme):

- **ActionInProgress (İşlem Sürüyor):** Buton üzerinde minyatür yükleniyor ikonu gösterilir ve çift tıklamayı önlemek için buton kilitlenir.
- **ActionSuccess (İşlem Başarılı):** SnackBar veya onay diyaloğu ile bildirim yapılır, ardından ilgili liste reaktif olarak güncellenir.
- **ActionFailure (İşlem Başarısız):** Kullanıcı bağlamından koparılmadan formun yanında veya SnackBar'da anlaşılır hata bildirilir.

### 2.3. Dart 3 Sealed Class ile Güvenli Durum Modellemesi

Sayfa durumları Dart 3'ün `sealed class` özelliği ile modellenir; böylece `switch-case` yapılarında tüm durumların ele alınması derleme zamanında güvenceye alınır:

```dart
/// Araç Listeleme Ekran Durumu
sealed class VehicleListingsState {
  const VehicleListingsState();
}

final class VehicleListingsInitial extends VehicleListingsState {
  const VehicleListingsInitial();
}

final class VehicleListingsLoading extends VehicleListingsState {
  const VehicleListingsLoading();
}

final class VehicleListingsSuccess extends VehicleListingsState {
  final List<VehicleListingEntity> listings;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const VehicleListingsSuccess({
    required this.listings,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  VehicleListingsSuccess copyWith({
    List<VehicleListingEntity>? listings,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return VehicleListingsSuccess(
      listings: listings ?? this.listings,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class VehicleListingsEmpty extends VehicleListingsState {
  final String message;
  final bool hasActiveFilters;

  const VehicleListingsEmpty({
    required this.message,
    this.hasActiveFilters = false,
  });
}

final class VehicleListingsError extends VehicleListingsState {
  final String userFriendlyMessage;
  final bool canRetry;

  const VehicleListingsError({
    required this.userFriendlyMessage,
    this.canRetry = true,
  });
}
```

---

## 3. Movira Modüllerine Özgü Durum Akış Senaryoları

### 3.1. Senaryo A — Üyelik, Oturum ve Misafir Gezinmesi (Auth & Session Flow)

`PROJECT.md` Madde 4.1 gereğince:
1. **Mevcut Oturum Kuralı:** Backend seçimi kesinleşene kadar MVP aşamasında oturum doğrulama mock/test kullanıcısı **`user-12345`** kimliği üzerinden simüle edilir.
2. **Misafir Gezinmesi:** Oturum açmamış kullanıcılar (Ziyaretçi) ilanları ve galerileri serbestçe inceler.
3. **Korumalı İşlemler:**
   - Teklif verme, ilan oluşturma veya mesaj gönderme butonuna tıklandığında kullanıcı `user-12345` oturumuna veya giriş ekranına yönlendirilir.
   - Giriş tamamlandıktan sonra kullanıcı başladığı bağlama (ör. teklif verme formuna) otomatik geri döndürülür.
4. **Çoklu Rol Desteği:** Bir kullanıcı hem kiracı hem ilan veren olabilir; hesap tipi tek bir role kilitlenemez.

---

### 3.2. Senaryo B — Araç İlanlarını Keşfetme, Filtreleme ve Sayfalama

1. **Açılış:** Controller `loadListings()` fonksiyonunu çağırır -> State `VehicleListingsLoading` olur.
2. **Filtreleme:** Kullanıcı marka, model, vites, yakıt türü, tarih aralığı veya günlük fiyat aralığı seçtiğinde:
   - Aktif filtre parametreleri güncellenir.
   - Sayfalama indeksi 1'e sıfırlanır.
   - Filtre çipleri anında UI'da seçili durumu yansıtır.
3. **Sonuç Değerlendirme:**
   - Liste boşsa: `VehicleListingsEmpty(message: 'Arama kriterlerinize uygun araç bulunamadı.', hasActiveFilters: true)` üretilir. UI'da "Filtreleri Temizle" butonu sunulur.
   - Liste doluysa: `VehicleListingsSuccess` üretilir.
4. **Sonsuz Kaydırma (Pagination):** Liste sonuna yaklaşıldığında:
   - Mevcut state `VehicleListingsSuccess` korunarak `isLoadingMore: true` yapılır.
   - Yeni sayfa başarıyla geldiğinde mevcut listeye eklenir (`[...oldList, ...newList]`).
   - Yeni veri yoksa `hasReachedMax: true` olarak işaretlenir ve gereksiz istek engellenir.

---

### 3.3. Senaryo C — Teklif Verme ve Onay Akışı (Offer Lifecycle)

Teklif yaşam döngüsü kesin kurallara ve durum geçişlerine tabidir:

```text
                  ┌──────────────┐
                  │   pending    │ (Teklif Oluşturuldu)
                  └──────┬───────┘
         ┌───────────────┼───────────────┐
         │               │               │
         ▼               ▼               ▼
  ┌──────────────┐┌──────────────┐┌──────────────┐
  │   accepted   ││   rejected   ││  withdrawn   │
  └──────┬───────┘└──────────────┘└──────────────┘
         │
         ▼
  (Kiralama Sürecine Geçiş)
```

#### Durum Geçiş Kuralları:
- **`pending` (Beklemede):** Kiracı teklifi gönderdi; araç sahibi inceliyor. Kiracı bu aşamada teklifi geri çekebilir (`withdrawn`).
- **`accepted` (Kabul Edildi):** Yalnızca ilan sahibi tarafından onaylanabilir.
  - **Kritik İş Kuralı:** İlan sahibinin bir teklifi kabul etmesi durumunda, aynı araç için **çakışan tarih aralığına sahip diğer tüm bekleyen teklifler** sunucu tarafında atomik olarak reddedilmeli veya geçersiz kılınmalıdır.
  - İstemci tarafı doğrulama sadece kullanıcı deneyimi sağlar; eşzamanlı yarış koşulları (race conditions) sunucu tarafında kilitlenmelidir.
- **`rejected` (Reddedildi):** İlan sahibi teklifi reddettiğinde bu durum terminal durumdur; yeniden açılamaz.
- **`withdrawn` (Geri Çekildi):** Kiracı, teklif onaylanmadan önce kendi isteğiyle teklifi iptal ettiğinde oluşur.
- **`expired` (Süresi Doldu):** Belirlenen yanıt süresi (örn. 24 saat) dolduğunda sistem tarafından otomatik atanır.

---

### 3.4. Senaryo D — Kiralama Yaşam Döngüsü ve Durum Takibi (Rental Lifecycle)

Teklif kabul edildikten sonra kiralama nesnesi (`RentalEntity`) devreye girer. Teklif ile kiralama ayrı varlıklardır:

```text
┌───────────────────────┐
│ reserved / confirmed  │ ──► Teklif kabul edildi, rezervasyon kesinleşti
└──────────┬────────────┘
           │
           ▼
┌───────────────────────┐
│      approaching      │ ──► Teslim alma tarihi yaklaşıyor (Örn: son 24 saat)
└──────────┬────────────┘
           │
           ▼
┌───────────────────────┐
│      in_progress      │ ──► Araç teslim alındı, kiralama aktif devam ediyor
└──────────┬────────────┘
           │
           ▼
┌───────────────────────┐
│       completed       │ ──► Araç teslim edildi, kiralama başarıyla bitti
└──────────┬────────────┘
           │
           ▼ (Yalnızca bu aşamadan sonra Yorum & Puanlama açılır!)
┌───────────────────────┐
│     review_ready      │
└───────────────────────┘
```

#### Kiralama Kuralları:
1. `cancelled` (İptal): Koşullara bağlı olarak başlangıçtan önce gerçekleşebilir.
2. `disputed` (İnceleme / Uyuşmazlık): Hasar, geç teslim veya kural ihlallerinde devreye girer.
3. Yetki Sınırı: Kiralama durumunu yalnızca yetkili taraflar ve sistem değiştirebilir; UI butonunun varlığına güvenilmez.

---

### 3.5. Senaryo E — Araç Sahibine Soru Sorma ve Mesajlaşma (Messaging Flow)

1. **Konuşma Başlatma:** İlan detay ekranından "Araç Sahibine Soru Sor" tıklandığında:
   - Kullanıcı oturum açmamışsa -> Giriş sayfasına yönlendirilir (`user-12345` akışı).
   - Kullanıcı kendi ilanına soru sormaya çalışıyorsa -> Hata uyarısı verilir.
2. **Mesaj Gönderimi:**
   - Mesaj metni doğrulandıktan sonra yerel listeye `isSending: true` olarak eklenir.
   - Sunucudan başarılı yanıt gelince `isSending: false` olur ve `messageId` atanır.
   - Hata alınırsa mesajın yanında "Gönderilemedi - Tekrar Dene" ikonu gösterilir.
3. **Erişim Güvenliği:** Bir konuşmadaki mesajları yalnızca kiracı ve araç sahibi görüntüleyebilir.

---

### 3.6. Senaryo F — Değerlendirme ve Puanlama Akışı (Reviews & Ratings)

1. **Uygunluk Kontrolü:** Kullanıcı bir araç veya araç sahibi hakkında yorum yazabilmek için:
   - `rental.status == RentalStatus.completed` şartını sağlamalıdır.
   - İlgili kiralamaya ait daha önce yorum yapılmamış olmalıdır (tekrarlı yorum engeli).
2. **Puanlama Ayrımı:**
   - **Araç Puanı:** Aracın temizliği, mekanik durumu, fotoğraflarla uyumu.
   - **İlan Sahibi / Galeri Puanı:** İletişim, zamanında teslim, güvenilirlik.
   - Bu iki metrik bağımsız olarak toplanır ve ortalaması sunucu tarafında hesaplanır.
3. **Puan Gösterimi:** Arayüzde hem 1-5 yıldız simgeleri hem de sayısal ortalama ve toplam değerlendirme sayısı (örn. `★ 4.8 (34 değerlendirme)`) birlikte sunulur.

---

### 3.7. Senaryo G — İlan Oluşturma ve Fotoğraf Yükleme (Host Flow)

1. **Adımlı Form:** Araç bilgileri (Marka, Model, Yıl), Özellikler (Vites, Yakıt, Koltuk), Fiyatlandırma ve Koşullar (Günlük ücret, depozito, km sınırı), Fotoğraf Galerisi.
2. **Fotoğraf Seçimi ve Doğrulama:**
   - Minimum 1, tercihen en az 3 fotoğraf seçilmelidir.
   - Dosya boyutları ve formatları (.jpg, .png, .webp) yerel olarak kontrol edilir.
   - Kullanıcı kapak fotoğrafını serbestçe belirleyebilmelidir.
3. **Yükleme Süreci:**
   - Yükleme ilerleme yüzdesi (Progress Bar) gösterilir.
   - Fotoğraf yükleme başarısız olursa kullanıcı tüm formu kaybetmemeli, yalnızca başarısız görseller için "Tekrar Yükle" eylemi sunulmalıdır.
4. **İlan Durumu:** Form tamamlandığında ilan `draft` (taslak) veya `published` (yayında) olarak kaydedilir.

---

### 3.8. Senaryo H — Dinamik Tema Yönetimi (Theme Mode Flow)

Movira, Material 3 standartlarında açık (Light) ve koyu (Dark) tema desteği sunar.

1. **Merkezi Durum:** Tema modu `ValueNotifier<ThemeMode>` ile yönetilir:
   - `ThemeMode.system`: Cihazın sistem temasını takip eder.
   - `ThemeMode.light`: Açık tema.
   - `ThemeMode.dark`: Koyu bordo / derin antrasit arka planlı koyu tema.
2. **Ağır setState Olmaksızın Anlık Geçiş:** `MaterialApp` widget'ı bir `ValueListenableBuilder<ThemeMode>` ile sarılır. Tema değiştiğinde tüm uygulama ağacı yeniden çizilmek zorunda kalmadan sadece tema bildirimine abone widget'lar güncellenir.
3. **Tasarım Dili:** Ana renk Kırmızı (`#DC2626` / M3 Crimson) tonlarıdır. Bileşenlerde doğrudan sabit Hex renkler yerine `Theme.of(context).colorScheme` tokenları kullanılır.

---

## 4. Hata Yönetimi ve Exception-Failure Eşleme Tablosu

Uygulamada tüm asenkron operasyonlar `Result<T, Failure>` nesnesi döndürür. Hiçbir raw exception UI katmanına sızdırılmaz.

### Eşleme Matrisi

| Ham Exception (Data Katmanı) | Failure Tipi (Domain) | Kullanıcıya Gösterilen Türkçe Mesaj (Presentation) | Önerilen UI Aksiyonu |
| :--- | :--- | :--- | :--- |
| `SocketException`, `TimeoutException` | `NetworkFailure` | "İnternet bağlantınız kontrol edilemedi. Lütfen bağlantınızı kontrol edip tekrar deneyin." | Yeniden Dene Butonu |
| `UnauthorizedException (HTTP 401)` | `AuthFailure` | "Oturum süreniz doldu veya giriş yapmanız gerekiyor." | Giriş Yap Ekranına Yönlendirme (`user-12345`) |
| `ForbiddenException (HTTP 403)` | `PermissionFailure` | "Bu işlem için gerekli yetkiye sahip değilsiniz." | Uyarı Diyaloğu / Geri Dönüş |
| `ConflictException (HTTP 409)` | `DateConflictFailure` | "Seçtiğiniz tarihler için araç artık uygun değil veya başka bir teklif onaylandı." | Tarih Seçimini Güncelle Butonu |
| `NotFoundException (HTTP 404)` | `NotFoundFailure` | "Aradığınız ilan, teklif veya kullanıcı bulunamadı." | Boş Ekran / Listeye Dönüş |
| `ValidationException (HTTP 422)` | `ValidationFailure` | "Lütfen formdaki eksik veya geçersiz alanları kontrol edin." | İlgili Form Alanının Altında Hata Metni |
| `ServerException (HTTP 500/503)` | `ServerFailure` | "Sunucularımızda geçici bir sorun oluştu. Kısa süre sonra tekrar deneyiniz." | Hata Paneli ve Destek Bildirimi |
| `UnknownException` | `UnexpectedFailure` | "Beklenmeyen bir durum oluştu. Lütfen uygulamayı yeniden başlatmayı deneyin." | Tekrar Dene Butonu |

---

## 5. Güvenlik, Gizlilik, Yetkilendirme ve KVKK İlkeleri

1. **Sunucu Taraflı Otorite:**
   - İlan düzenleme, fiyat güncelleme, teklif kabulü ve mesajlaşma izinleri istemcide değil, sunucu tarafında token ve yetki doğrulamasıyla korunmalıdır.
   - İstemcide gizlenen veya devre dışı bırakılan butonlar yalnızca arayüz kolaylığıdır; güvenlik bariyeri sayılamaz.
2. **Hassas Veri ve Sırların Korunması:**
   - Kaynak kodda, Git reposunda ve loglarda API anahtarları, şifreler, kullanıcı kimlik numaraları, ehliyet fotokopileri veya kart bilgileri asla yer almaz.
   - Loglamalarda hassas alanlar maskelenir.
3. **Sahte Veri (Demo Mode) Sınırı:**
   - Mock/Demo veri kaynakları `demo/` veya `mock/` isimleriyle açıkça ayrıştırılır.
   - Gerçek backend entegrasyonu tamamlanmadıkça sahte servisler gerçekmiş gibi raporlanmaz.
4. **Veri Tipleri ve Parasal Güvenlik:**
   - Kiralama ve depozito tutarları `double` kayan noktalı sayı ile serbest hesaplanmaz. Para birimiyle birlikte kuruş/cent bazlı tamsayı veya `RentalPrice` nesnesiyle modellenir.

---

## 6. Geliştirici ve Ajan Kontrol Listesi (State Flow Checklist)

Bir özellik veya ekran geliştirildiğinde şu kontrol listesi eksiksiz doğrulanmalıdır:

- [ ] **Mevcut Proje İncelendi mi:** Depo yapısı, sürümler ve standartlar kontrol edildi mi?
- [ ] **Tek Yönlü Akış Korundu mu:** UI doğrudan veri katmanına erişiyor mu? (Erişmemeli!)
- [ ] **Tüm Yaşam Döngüsü Durumları Ele Alındı mı:** Loading, Success, Empty ve Error durumları tasarlandı mı?
- [ ] **Dart 3 Sealed Class Kullanıldı mı:** Durumlar tüketilirken `switch-case` derleme güvencesi sağlandı mı?
- [ ] **Hata Mesajları Kullanıcı Odaklı mı:** Teknik terimler gizlenip anlaşılır Türkçe rehberlik sunuldu mu?
- [ ] **Oturum ve Misafir Akışı Gözetildi mi:** `user-12345` test oturumu ve korumalı işlemlerde geri dönüş kurgulandı mı?
- [ ] **Teklif ve Kiralama Ayrımı Yapıldı mı:** `Offer` kabulünün otomatik ödeme/kiralama olmadığı kuralına uyuldu mu?
- [ ] **Çakışan Tarih Kuralı Gözetildi mi:** Aynı araca aynı tarihte çakışan teklif kabulü engellendi mi?
- [ ] **Yorum Uygunluğu Kontrol Edildi mi:** Yalnızca tamamlanmış kiralama sahiplerine yorum izni verildi mi?
- [ ] **Tema Entegrasyonu Tam mı:** `ValueNotifier<ThemeMode>` ve `Theme.of(context)` kullanılarak kırmızı M3 temasına uyuldu mu?
- [ ] **Erişilebilirlik ve Dokunma Alanları:** Dokunma hedefleri en az 48x48 dp ve metin ölçeklemesine uygun mu?
- [ ] **Güvenlik ve Gizlilik:** Hassas veriler veya backend sırları koda gömülmedi mi?
