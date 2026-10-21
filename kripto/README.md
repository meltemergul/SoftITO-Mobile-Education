# Chronomind — Kripto Kâr/Zarar & Portföy Takibi

Chronomind, kripto varlık yatırımlarınızı canlı piyasa verileriyle takip eden, ortalama maliyet (DCA) ve gerçekleşmiş/gerçekleşmemiş kâr-zarar (P&L) hesaplarını hassas matematiksel doğrulukla (`Decimal`) yürüten modern bir mobil portföy takip uygulamasıdır.

Tasarımı, finansal hassasiyet ve odaklanma için özel olarak kurgulanmış **"Obsidian Precision Financial"** koyu tema sistemine dayanır.

---

## 🚀 Temel Özellikler

- **Hassas Ortalama Maliyet Motoru (DCA Replay):** Kronolojik işlem akışı üzerinden ağırlıklı ortalama maliyet hesabı, sıfırlanan bakiyelerde maliyetin arındırılması ve tam satış kâr/zarar tespiti.
- **Kayan Nokta Hatasızlığı:** Para ve adet değerlerinin tamamında `double` yerine `Decimal` kullanımı (`numeric(38,18)` veritabanı hassasiyeti).
- **Canlı Piyasa Fiyatları & Akıllı Önbellek:** Supabase Edge Function üzerinden CoinGecko Demo API entegrasyonu; 60 saniyelik merkezi TTL önbelleği ile kota koruması.
- **Batarya ve Veri Tasarrufu:** Uygulama arka plana geçtiğinde fiyat sorguları otomatik duraklatılır, ön plana dönüldüğünde anında tazelenir.
- **Çevrimdışı Dayanıklılık:** Ağ kopmalarında veya API kota dolumlarında ekranlar boş kalmaz; son bilinen geçerli fiyatlar gösterilir.
- **Çift Para Birimi:** USD ve TRY desteği ile anlık portföy değerleme.
- **İnteraktif Grafikler:** `fl_chart` tabanlı performans ve portföy dağılım donut grafikleri.
- **CSV İçe & Dışa Aktarma:** İşlemleri toplu içe aktarma (import) ve cihazlar arası taşıma için CSV formatında dışa aktarma (export).
- **Güvenlik & Çoklu Kullanıcı:** Supabase Row Level Security (RLS) ile kullanıcıların yalnızca kendi portföy ve işlem verilerine erişimi garanti edilir.
- **Fazla Satış Koruması:** Hem arayüzde hem de veritabanı tetikleyicisi (`sell_guard`) seviyesinde bakiyeden fazla satış engellenir.

---

## 🛠️ Mimari ve Teknoloji Yığını

- **İstemci:** Flutter (Android & iOS)
- **Durum Yönetimi:** Flutter Riverpod 3.x (`NotifierProvider`, `AsyncValue`)
- **Navigasyon:** GoRouter
- **Grafikler:** `fl_chart`
- **Veritabanı & Backend:** Supabase (PostgreSQL 15+, Row Level Security, Realtime, Edge Functions)
- **Tasarım:** Obsidian Precision Financial Dark Theme (`#0B0F19` canvas, `#111827` surface1, Tabular Figures)

---

## 📂 Klasör Yapısı (Feature-First)

```text
lib/
├── app/
│   ├── app.dart                   # Root widget ve GoRouter yapılandırması
│   ├── routes.dart                # Sayfa yönlendirme tanımları
│   └── theme/                     # Obsidian Precision renk, tipografi, boşluk jetonları
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_text_styles.dart
│       └── app_theme.dart
├── core/
│   ├── constants.dart             # TTL, zamanlayıcı ve global sabitler
│   ├── formatters.dart            # tr_TR uyumlu para, tarih ve adet biçimlendiriciler
│   └── services/                  # Supabase istemci ve çekirdek servisler
├── features/
│   ├── allocation/                # 6c Varlık Dağılımı ve Donut grafik
│   ├── auth/                      # Oturum yönetimi, Giriş/Kayıt ekranı
│   ├── dashboard/                 # 6b Ana Dashboard, özet kartı, canlı izleme
│   ├── history/                   # 6d K/Z Geçmişi, filtreler ve CSV dışa aktar
│   ├── portfolio/                 # Pozisyonlar, özet hesabı ve DCA maliyet motoru
│   ├── prices/                    # Fiyat servisi, önbellek ve arka plan gözlemcisi
│   ├── settings/                  # 6e Ayarlar ve CSV içe aktarma
│   └── transactions/              # 6a Alış/Satış formu ve validasyonlar
└── shared/                        # Paylaşılan ortak modeller ve widget'lar
    ├── models/                    # Asset (Kripto varlık) modeli
    └── widgets/                   # PnlBadge, CoinTile, LiveDot, StateViews, GlassSheet
```

---

## ⚙️ Kurulum ve Çalıştırma

### 1. Ön Koşullar

- **Flutter SDK:** 3.19.0 veya üzeri (`flutter doctor` ile doğrulayın)
- **Dart SDK:** 3.3.0 veya üzeri
- **Supabase CLI:** (Opsiyonel, yerel veritabanı veya migration yönetimi için)

### 2. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 3. Ortam Değişkenleri (.env)

Proje kök dizininde yer alan `.env.example` dosyasını `.env` olarak kopyalayın:

```bash
cp .env.example .env
```

`.env` dosyasını kendi Supabase proje bilgilerinizle doldurun:

```ini
# Supabase Yapılandırması
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...

# Fiyat Yapılandırması
PRICE_CACHE_TTL_SECONDS=60
DEFAULT_CURRENCY=USD
```

> **ÖNEMLİ:** Gizli servis anahtarları (`SUPABASE_SERVICE_ROLE_KEY`, `COINGECKO_API_KEY`) kesinlikle istemci koduna veya `.env` dosyasına yazılmaz; yalnızca Supabase Edge Function Secrets üzerinde tanımlanır.

### 4. Supabase Veritabanı ve Migration Kurulumu

`supabase/migrations/` klasöründeki SQL dosyalarını Supabase Dashboard SQL Editor'de veya Supabase CLI aracılığıyla sırasıyla çalıştırın:

1. `001_init.sql` — Tablo şemaları (`portfolios`, `transactions`, `price_cache`), indeksler ve `numeric(38,18)` kolonlar.
2. `002_rls.sql` — Row Level Security (RLS) politikaları.
3. `003_sell_guard.sql` — Yetersiz bakiye fazla satış engelleme tetikleyicisi.
4. `004_views.sql` — `security_invoker = true` özellikli portföy eldeki varlıklar görünümü (`holdings`).
5. `005_realtime.sql` — `transactions` ve `price_cache` için Realtime yayını.
6. `006_seed_assets.sql` — Desteklenen temel varlıklar katalog tohum verisi.

### 5. Edge Function Kurulumu (`get-prices`)

Edge Function, CoinGecko API'den toplu fiyatları çeker ve veritabanındaki 60 saniyelik `price_cache` tablosunu yönetir.

```bash
# CoinGecko Demo Key ve Service Role anahtarını Edge Function'a tanımlayın
supabase secrets set COINGECKO_API_KEY=CG-your-demo-key
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Edge Function'ı deploy edin
supabase functions deploy get-prices
```

### 6. Uygulamayı Başlatma

```bash
flutter run
```

---

## 🧪 Testlerin Çalıştırılması

Projede maliyet hesaplama motoru, RLS senaryoları, çevrimdışı fiyat davranışı, form validasyonları ve ekran durumları için kapsamlı testler mevcuttur.

```bash
# Tüm birim ve widget testlerini çalıştırın
flutter test

# Yalnızca DCA Replay maliyet motoru testlerini çalıştırın
flutter test test/features/portfolio/domain/cost_calculator_test.dart

# Statik kod analizini çalıştırın
flutter analyze
```

---

## 📊 CSV İçe ve Dışa Aktarma Formatı

İşlemlerinizi toplu içe aktarmak veya dışa aktarmak için aşağıdaki CSV başlık yapısı kullanılır:

```csv
tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon
2026-03-01 10:30,BTC,BUY,0.05,62500.00,USD,1.50
2026-03-05 14:15,ETH,BUY,1.25,3400.00,USD,2.00
2026-03-10 18:00,BTC,SELL,0.02,68000.00,USD,1.20
```

- `islem_tipi`: `BUY` (Alış) veya `SELL` (Satış)
- `para_birimi`: `USD` veya `TRY`
- `miktar` ve `fiyat`: Pozitif ondalıklı sayılar (Nokta ayracı ile)

---

## 🎨 Tasarım Standartları (Obsidian Precision)

- **Tuval (Canvas):** `#0B0F19` (Derin obsidyen siyahı)
- **Kartlar (Surface1):** `#111827` (8px köşe yuvarlaklığı, 1px beyaz `%6` kenarlık, sıfır gölge)
- **Vurgu & Birincil:** `#38BDF8` (Elektrik mavisi)
- **Kâr Göstergesi:** `#10B981` arka plan tonu, `+` işareti ve yukarı ok
- **Zarar Göstergesi:** `#EF4444` arka plan tonu, eksi işareti ve aşağı ok
- **Rakamlar:** Tabular Figures (`FontFeature.tabularFigures()`) ile kusursuz dikey sütun hizası

---

## 📄 Lisans
Bu proje MIT lisansı ile lisanslanmıştır.
