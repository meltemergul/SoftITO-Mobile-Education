# Kripto Kâr / Zarar ve Portföy Takibi--- Proje Rehberi
Bu doküman Flutter projesinde geliştirme yapacak olan Ajan (AntiGravity) yapay zeka ve yazılım geliştiriciler için bağlayıcı bir kılavuzdur. Projede üretilen her kod satırı buradaki kurallara UYMAK ZORUNDADIR.
# Uygulama Adı: Chronomind  

## 1. Proje Özeti
Kripto varlık alım-satım işlemlerinin maliyet ortalamasını, anlık kâr/zarar oranını ve toplam portföy dağılımını takip eden finansal gösterge paneli. Uygulama mobil (Flutter) olarak geliştirilir, veriler bulutta saklanır ve fiyatlar anlık olarak güncellenir.

## 2. Proje Amacı
Karmaşık borsalardaki alım noktalarını tek merkezde toplayarak ortalama maliyet (DCA) ve kâr/zarar durumunu anlık ve net görebilmek. Profil oluşturularak farklı cihazlardan erişim ve veri senkronizasyonu sağlanabilmelidir.

## 3. Tahmini Ekran ve Sayfa Sayısı
6 Ekran:
1. Giriş Yap / Kayıt Ol
2. Dashboard (Portföy Genel Bakış)
3. Alış / Satış İşlem Formu
4. Varlık Dağılım Grafiği
5. Kâr / Zarar Geçmiş Tablosu
6. Ayarlar

## 4. Temel Özellikler
- Varlık bazında ortalama alış fiyatı (DCA) otomatik hesaplama
- Anlık kâr/zarar tutarı ve yüzde (yeşil/kırmızı) göstergeleri
- Portföy varlık dağılımı halka (donut) grafiği
- İşlem geçmişi ve gerçekleşmiş kâr dökümü
- USD / TL cinsinden değer görüntüleme (tek dokunuşla geçiş)
- Günlük, haftalık ve aylık fiyat grafikleri
- Piyasa fiyatının otomatik gelmesi ile alış/satış formu
- CSV ile toplu işlem yükleme veya manuel giriş
- Kayıt/giriş ile farklı cihazlardan erişim ve senkronizasyon

## 5. Hedef Kitle
Genel kullanıcılar, öğrenciler veya ilgili alan profesyonelleri.

---

## 6. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler & Kütüphaneler

| Katman | Teknoloji | Kullanım amacı |
|---|---|---|
| Frontend | **Flutter** (Dart) | Tek kod tabanıyla Android/iOS arayüzü |
| Backend / Veritabanı | **Supabase (PostgreSQL)** | Kimlik doğrulama, veri saklama, anlık veri akışı (Realtime) |
| Fiyat verisi | **CoinGecko Demo API + önbellek** | Güncel fiyat ve geçmiş fiyat grafikleri |

**Ek kütüphaneler (Flutter):**
- `supabase_flutter`: giriş, veritabanı ve Realtime bağlantısı
- `fl_chart`: fiyat çizgi grafiği ve donut grafik
- `dio` veya `http`: CoinGecko isteklerini yapmak için
- `riverpod` veya `provider`: durum yönetimi (ekranlar arası güncel veri paylaşımı)
- `csv` ve `file_picker`: CSV içe aktarma
- `intl`: para ve tarih formatı (TL, USD, binlik ayırıcı)
- `shared_preferences`: tema ve para birimi tercihleri

**Anlık veri görüntüleme yaklaşımı:**
- Fiyatlar uygulama açıkken **her 60 saniyede bir** yenilenir (CoinGecko ücretsiz katmanı yaklaşık bu sıklıkta güncelleniyor).
- Ekran yukarı çekilince elle yenileme (pull-to-refresh) desteklenir.
- Fiyat isteği tek bir toplu çağrıyla yapılır (tüm coinler tek istekte), böylece günlük limit aşılmaz.
- Fiyatlar Supabase'teki `price_cache` tablosunda saklanır. Önbellek 60 saniyeden tazeyse API'ye tekrar gidilmez. Bu sayede ücretsiz limit korunur ve ekranlar hızlı açılır.
- İşlem eklendiğinde veya silindiğinde **Supabase Realtime** sayesinde Dashboard, dağılım ve geçmiş ekranları otomatik güncellenir.

### 6.2. Sayfa Hiyerarşisi ve Akış Planı

**Genel akış:** Giriş/Kayıt → Dashboard → (İşlem Ekle / Varlık Dağılımı / Kâr-Zarar Geçmişi / Ayarlar)

Alt gezinme çubuğu: **Dashboard · Varlıklar · İşlem Ekle (+) · Geçmiş · Ayarlar**

---

#### Sayfa 1: Giriş Yap / Kayıt Ol
- [ ] E-posta ve şifre ile kayıt olma / giriş yapma (Supabase Auth)
- [ ] "Şifremi unuttum" bağlantısı
- [ ] Kayıt sonrası ilk açılışta veri ekleme seçimi: **Manuel giriş** veya **CSV yükle**
- [ ] Giriş yapılmış oturum hatırlanır, tekrar giriş istenmez
- [ ] Hatalı giriş ve boş alan uyarıları

**Akış:** Kayıt ol → veri ekleme yöntemi seç → Dashboard

---

#### Sayfa 2: Dashboard (Portföy Genel Bakış)
- [ ] Üstte **toplam portföy değeri**, toplam K/Z (tutar ve %), bugünkü değişim
- [ ] **USD / TL anahtarı:** seçilen para birimine göre tüm değerler yeniden listelenir
- [ ] **Zaman aralığı seçici:** Günlük / Haftalık / Aylık, seçime göre fiyat/portföy grafiği değişir
- [ ] Varlık listesi: coin adı, miktar, güncel fiyat, K/Z (yeşil/kırmızı + ok simgesi)
- [ ] **Tavsiye edilen kriptolar** bölümü: piyasa hacmi veya 24 saatlik değişime göre öne çıkan coinler (CoinGecko verisinden, yatırım tavsiyesi değildir uyarısıyla)
- [ ] Verilerin son güncellenme saati ("Son güncelleme: 14:35")
- [ ] Aşağı çekerek yenileme, 60 sn otomatik yenileme
- [ ] Boş durum: "Henüz işlem yok, ilk alımını ekle" butonu

---

#### Sayfa 3: Alış / Satış İşlem Formu
- [ ] **Alış / Satış** anahtarı
- [ ] Coin seçimi (arama kutusu ile)
- [ ] Miktar, birim fiyat, tarih ve saat, komisyon (opsiyonel), not (opsiyonel)
- [ ] **Para birimi seçimi: USD veya TL**
- [ ] **"Piyasa fiyatını kullan" butonu:** güncel fiyatı CoinGecko'dan otomatik doldurur
- [ ] Canlı önizleme: "Yeni ortalama maliyetin: $X" ve toplam tutar
- [ ] Doğrulama: negatif/sıfır miktar yok, **eldeki miktardan fazla satış yapılamaz**, aşırı sapmalı fiyatta uyarı
- [ ] Kaydet sonrası Dashboard'a dönüş ve başarı mesajı
- [ ] Mevcut işlemi **düzenleme ve silme** (geçmiş ekranından açılır)

---

#### Sayfa 4: Varlık Dağılım Grafiği Ekranı
- [ ] **Donut grafik:** coin ağırlıkları, ortada toplam değer
- [ ] Dilime dokununca o coinin detayı açılır
- [ ] Varlık tablosu, her coin için:
  - Adet
  - Ortalama alım fiyatı
  - Anlık değer
  - Kâr/zarar tutarı
  - Kâr/zarar yüzdesi
- [ ] **Toplam varlıklar** satırı (alt toplam)
- [ ] Yoğunlaşma uyarısı: tek coin portföyün %50'sinden fazlaysa bilgi mesajı
- [ ] Sıralama: değere göre, K/Z'ye göre, ada göre

---

#### Sayfa 5: Kâr / Zarar Geçmiş Tablosu Ekranı
- [ ] İki sekme: **İşlem Geçmişi** ve **Gerçekleşmiş Kâr Dökümü**
- [ ] İşlem Geçmişi: tarih, coin, alış/satış, miktar, fiyat, tutar
- [ ] Gerçekleşmiş Kâr Dökümü: satış tarihi, coin, ortalama alış, satış fiyatı, **net kâr/zarar**
- [ ] Filtre: tarih aralığı, coin, kârlı/zararlı
- [ ] Altta toplam gerçekleşmiş kâr/zarar özeti
- [ ] CSV olarak dışa aktarma
- [ ] Satıra dokununca düzenle / sil

---

#### Sayfa 6: Ayarlar Ekranı
- [ ] Profil bilgileri ve çıkış yapma
- [ ] Varsayılan para birimi (USD / TL)
- [ ] Tema (açık / koyu)
- [ ] **CSV içe aktarma** (örnek dosya şablonunu indirme bağlantısıyla)
- [ ] Verileri dışa aktarma
- [ ] Veri yenileme sıklığı (30 sn / 60 sn / 5 dk)
- [ ] Hesabı ve tüm verileri silme
- [ ] Uygulama hakkında ve yatırım tavsiyesi değildir uyarısı

### 6.3. Veri Modeli ve Bileşen Tasarımı

**Temel ilke:** İşlemler tek gerçek kaynaktır. Ortalama maliyet, K/Z ve bakiye **kaydedilmez, işlemlerden hesaplanır.** Böylece bir işlem düzeltildiğinde tüm değerler tutarlı kalır.

**Veritabanı tabloları (Supabase / PostgreSQL):**

```sql
-- Kullanıcı profili (kimlik doğrulama Supabase Auth'ta tutulur)
profiles(
  id uuid PRIMARY KEY,          -- auth.users.id ile aynı
  display_name text,
  default_currency text,        -- 'USD' | 'TRY'
  created_at timestamptz
)

-- Varlık kataloğu
assets(
  id uuid PRIMARY KEY,
  symbol text,                  -- BTC
  name text,                    -- Bitcoin
  coingecko_id text UNIQUE      -- bitcoin
)

-- ASIL TABLO: tüm alış/satış işlemleri
transactions(
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES profiles(id),
  asset_id uuid REFERENCES assets(id),
  type text,                    -- 'BUY' | 'SELL'
  quantity numeric(38,18),
  price numeric(38,18),         -- birim fiyat
  price_currency text,          -- 'USD' | 'TRY'
  fee numeric(38,18) DEFAULT 0,
  executed_at timestamptz,
  source text,                  -- 'MANUAL' | 'CSV'
  note text,
  created_at timestamptz DEFAULT now(),
  deleted_at timestamptz        -- yumuşak silme
)

-- Fiyat önbelleği (CoinGecko çağrılarını azaltır)
price_cache(
  asset_id uuid REFERENCES assets(id),
  currency text,                -- 'USD' | 'TRY'
  price numeric(38,18),
  change_24h numeric,
  fetched_at timestamptz,
  PRIMARY KEY (asset_id, currency)
)
```

**Güvenlik:** `profiles` ve `transactions` tablolarında **Row Level Security (RLS)** açılır; her kullanıcı yalnızca `user_id = auth.uid()` olan satırları görür ve değiştirir.

**İndeksler:** `transactions(user_id, asset_id, executed_at)`

**Hesaplama kuralları (Dart tarafında):**

- **Ortalama alış fiyatı:** `Σ(alış miktarı × alış fiyatı) / Σ(alış miktarı)`. Satış yapıldığında ortalama maliyet değişmez, yalnızca eldeki miktar azalır.
- **Eldeki miktar:** `Σ alış miktarı − Σ satış miktarı`
- **Gerçekleşmemiş K/Z:** `(güncel fiyat − ortalama alış) × eldeki miktar`
- **K/Z yüzdesi:** `(güncel fiyat − ortalama alış) / ortalama alış × 100`
- **Gerçekleşmiş K/Z (satış başına):** `(satış fiyatı − o andaki ortalama alış) × satılan miktar − komisyon`
- **Para birimi dönüşümü:** CoinGecko'dan hem USD hem TRY fiyatı alınır, dönüşüm için ayrı kur tablosu gerekmez.

**Para ve miktarlar:** `float` kullanılmaz. Veritabanında `numeric`, Dart tarafında `decimal` paketi kullanılır (yuvarlama hatası olmasın).

**CSV şablonu:**
```
tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon
2026-01-15 10:30,BTC,BUY,0.05,95000,USD,2.5
```

**Flutter klasör yapısı (öneri):**
```text
lib/
  main.dart

  app/
    app.dart                         (MaterialApp, tema bağlama)
    router/
      app_router.dart                (rotalar, oturuma göre yönlendirme)
    theme/
      app_colors.dart
      app_text_styles.dart
      app_spacing.dart
      app_theme.dart

  core/                              (hiçbir özelliğe ait olmayan altyapı)
    constants.dart                   (fiyat TTL, varsayılanlar)
    errors.dart                      (AppException türleri)
    formatters.dart                  (para, yüzde, tarih, tr_TR)
    env.dart                         (Supabase URL ve anon anahtar)
    services/
      supabase_service.dart          (istemci tek yerde)

  shared/                            (2 veya daha fazla özelliğin kullandığı parçalar)
    models/
      asset.dart
    widgets/
      pnl_badge.dart
      coin_tile.dart
      period_selector.dart
      glass_sheet.dart
      live_dot.dart

  features/
    auth/
      data/
        auth_repository.dart
      providers/
        auth_provider.dart
      presentation/
        login_screen.dart
        widgets/

    prices/                          (fiyat verisi, birçok özellik tüketir)
      data/
        price_service.dart           (Edge Function get-prices çağrısı)
        price_repository.dart
      domain/
        price_info.dart
      providers/
        prices_provider.dart

    transactions/                    (işlem ekleme, düzenleme, CSV)
      data/
        transaction_repository.dart
        csv_service.dart             (dosya seç ve oku)
      domain/
        transaction.dart
        csv_parser.dart              (doğrulama, satır hataları)
      providers/
        transactions_provider.dart
      presentation/
        add_transaction_screen.dart
        widgets/
          transaction_form.dart
          cost_preview_card.dart

    portfolio/                       (işlemlerden türeyen hesaplar, beyin burası)
      domain/
        position.dart
        realized_pnl.dart
        cost_calculator.dart         (ortalama maliyet ve K/Z, saf Dart)
        portfolio_calculator.dart    (toplam, dağılım, yoğunlaşma)
      providers/
        portfolio_provider.dart

    dashboard/
      presentation/
        dashboard_screen.dart
        widgets/
          portfolio_summary_card.dart
          asset_row.dart
          performance_chart.dart

    allocation/
      presentation/
        allocation_screen.dart
        widgets/
          donut_chart.dart
          allocation_table.dart

    history/
      presentation/
        history_screen.dart
        widgets/
          history_table.dart
          realized_pnl_table.dart
          history_filters.dart

    settings/
      data/
        settings_repository.dart
      providers/
        settings_provider.dart
      presentation/
        settings_screen.dart

test/
  features/
    portfolio/domain/cost_calculator_test.dart
    portfolio/domain/portfolio_calculator_test.dart
    transactions/domain/csv_parser_test.dart
```

### 6.4. Proje Takvimi ve Teslim Aşamaları

- **Aşama 1 (Tasarım & Wireframe):**
  - 6 ekranın el çizimi/Figma wireframe'i
  - Veritabanı şemasının Supabase'te oluşturulması, RLS kuralları
  - CoinGecko'dan örnek fiyat çekme denemesi
  - Flutter proje iskeleti ve klasör yapısı

- **Aşama 2 (Temel Fonksiyonlar & Arayüz):**
  - Giriş/Kayıt ekranı ve oturum yönetimi
  - Alış/Satış formu ve işlem kaydı
  - Ortalama maliyet ve K/Z hesaplama sınıfı (birim testlerle)
  - Dashboard: fiyat listesi, USD/TL geçişi, 60 sn yenileme, fiyat önbelleği
  - Varlık dağılım donut grafiği ve tablo
  - Kâr/Zarar geçmiş tablosu, filtreler
  - CSV içe aktarma, günlük/haftalık/aylık grafikler, Ayarlar ekranı

- **Aşama 3 (Test & İyileştirme):**
  - Hesaplamaların elle doğrulanması (örnek senaryolar)
  - Sınır durumları: fazla satış, boş portföy, internet kesintisi, API limit hatası
  - Yükleniyor / hata / boş durum ekranları
  - Performans ve arayüz düzeltmeleri, farklı ekran boyutlarında deneme
  - 2-3 kişiyle kullanılabilirlik testi

- **Aşama 4 (Final Teslim):**
  - README ve kurulum yönergesi
  - Ekran görüntüleri ve kısa demo videosu
  - Sunum hazırlığı
  - Son hata düzeltmeleri ve teslim

### 6.5. Notlar & Karşılaşılan Zorluklar

**Bilinen riskler ve planlanan çözümler:**

| Risk | Çözüm |
|---|---|
| CoinGecko Demo planı dakikalık ve aylık çağrı limiti içeriyor | Tüm coinleri tek toplu istekte çek, sonuçları `price_cache`'te 60 sn tut |
| Ücretsiz planda geçmiş veri sınırlı (yaklaşık 1 yıl) | Grafikler günlük/haftalık/aylık ile sınırlı tutulur |
| Fiyat anlık değil, yaklaşık 60 sn gecikmeli | Ekranda "son güncelleme saati" gösterilir |
| Float ile yuvarlama hatası | `numeric` (DB) ve `decimal` (Dart) kullanımı |
| Elde olmayan coinin satışı | Form doğrulamasında engellenir |
| Başka kullanıcıların verisine erişim | Supabase RLS kuralları |
| CSV hatalı biçimde gelebilir | Yüklemeden önce önizleme ve satır bazlı hata listesi |
| API anahtarının uygulamaya gömülmesi | Mümkünse Supabase Edge Function üzerinden çağır, anahtarı uygulama içine koyma |

**Notlar:**
- Uygulama **yatırım tavsiyesi vermez**; "tavsiye edilen kriptolar" bölümü yalnızca piyasa verisine dayalı bilgilendirmedir ve ekranda bu uyarı yer almalıdır.
- Vergi hesabı kapsam dışıdır; yalnızca gerçekleşmiş kâr dökümü sunulur.
- Borsa API entegrasyonu (BtcTürk, Binance) ilk sürüme dahil değildir, sonraki geliştirme olarak planlanır.

**Geliştirme sırasında doldurulacak not alanı:**
- _(Karşılaşılan hata ve çözümü)_
- _(Alınan tasarım kararları ve nedeni)_