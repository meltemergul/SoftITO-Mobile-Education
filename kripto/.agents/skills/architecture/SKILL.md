---
name: crypto-portfolio-architecture
description: Kripto kâr/zarar ve portföy takibi uygulamasının Flutter + Supabase mimarisini feature-first (özellik bazlı) klasör yapısıyla kurar ve korur. Özellik klasörleri, katman ve bağımlılık kuralları, durum yönetimi (Riverpod), veri akışı, fiyat yenileme, hata yönetimi, güvenlik ve test kurallarını uygular. Bu projede yeni özellik, servis, provider veya ekran eklerken ve kod nereye yazılmalı kararı verirken kullan.
---

# Mimari Skill: Flutter + Supabase (Feature-First)

Bu skill, kod tabanının nasıl düzenleneceğini ve parçaların birbirine nasıl bağlanacağını tanımlar. Proje orta seviye bir öğrenci projesidir, mimari **yeterince düzenli ama aşırı karmaşık olmayacak** şekilde tutulur.

Teknoloji: Flutter (Dart), Supabase (Auth, PostgreSQL, Realtime, Edge Functions), CoinGecko Demo API (yalnızca Edge Function üzerinden), Riverpod, `go_router`, `fl_chart`, `decimal`, `intl`, `csv`, `file_picker`.

## 1. Ne zaman kullanılır

- Yeni özellik veya ekran eklerken "kod nereye gider" sorusunda
- Servis, repository veya provider yazarken
- Veri akışı, yenileme veya hata yönetimi tasarlarken
- Mevcut kodu yeniden düzenlerken

Görünüm kuralları için `obsidian-precision-ui`, tablo ve SQL kuralları için `crypto-portfolio-database` skill'lerine bakılır.

## 2. Mimari ilkeler

1. **Özellik bazlı gruplama.** Bir özelliğin veri, mantık, durum ve arayüz dosyaları aynı klasörde durur. Bir özelliği anlamak için tek klasöre bakmak yeterli olmalı.
2. **Özellik içinde katmanlı, tek yönlü bağımlılık.** `presentation → providers → domain → data` sırasıyla, tersi olmaz.
3. **Hesaplama mantığı saf Dart'tır.** Ortalama maliyet ve K/Z hesabı Flutter, Supabase veya ağdan bağımsız olmalı, böylece kolay test edilir.
4. **Ekranlar ince, mantık ayrı.** Widget içinde sorgu veya hesap yazılmaz.
5. **Tek veri kaynağı.** Aynı veriyi iki yerde tutma, provider'lar paylaşılan kaynaktır.
6. **Sırlar sunucuda.** CoinGecko anahtarı ve `service_role` Edge Function'da kalır.
7. **Para `Decimal`'dir.** `double` yalnızca grafik çizimi için, görüntüleme anında dönüştürülür.

## 3. Klasör yapısı

```
lib/
  main.dart

  app/
    app.dart                         (MaterialApp, tema bağlama)
    router/
      app_router.dart                (rotalar, oturuma göre yönlendirme)
    theme/                           (bkz. obsidian-precision-ui skill)
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

    portfolio/                       (işlemlerden türeyen hesaplar, ekranı yok)
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

supabase/
  migrations/                        (bkz. crypto-portfolio-database skill)
  functions/
    get-prices/                      (Edge Function)

test/
  features/
    portfolio/domain/cost_calculator_test.dart
    portfolio/domain/portfolio_calculator_test.dart
    transactions/domain/csv_parser_test.dart
    transactions/data/transaction_repository_test.dart
```

Gerekmeyen alt klasörü açma. Örneğin yalnızca ekranı olan bir özellikte `data/` ve `providers/` klasörü oluşturulmaz.

## 4. Özellik içi katmanlar

Her özelliğin içinde aynı mantık geçerlidir:

```
presentation/   Ekran ve widget'lar
     ↓
providers/      Durum, yenileme, ekranlara veri sağlama
     ↓
domain/         Veri sınıfları ve saf hesaplama
     ↓
data/           Supabase, Edge Function, dosya erişimi (repository + service)
```

| Katman | Sorumluluk | Şunları bilir | Şunları bilmez |
|---|---|---|---|
| **presentation** | Görünüm ve kullanıcı etkileşimi | providers, domain, `shared/`, `app/theme` | Supabase, HTTP, SQL |
| **providers** | Durum, yenileme, paylaşım | data, domain | Widget ağacı, `BuildContext` |
| **domain** | Modeller, hesaplama, doğrulama | yalnızca Dart ve `decimal` | Flutter, ağ, veritabanı |
| **data** | Dış sistemlere erişim, hata dönüştürme | `core/`, domain | Widget, provider |

## 5. Özellikler arası bağımlılık kuralları

```
                ┌───────────┐
                │   app/    │  her şeyi birleştirir
                └─────┬─────┘
                      ↓
 ┌───────────────── features/ ─────────────────┐
 │  dashboard   allocation   history           │  (yalnızca ekran)
 │       ↓           ↓          ↓              │
 │          portfolio (hesap)                  │
 │            ↓            ↓                   │
 │      transactions     prices                │
 │                                             │
 │  auth    settings   (bağımsız)              │
 └───────────────────┬─────────────────────────┘
                     ↓
             shared/   core/
```

1. **Yalnızca ekranı olan özellikler** (`dashboard`, `allocation`, `history`) `portfolio` provider'larını okur.
2. **`portfolio`**, `transactions` ve `prices` provider'larını okuyup `Position` ve toplamları üretir. Bu iki özelliğin ekranını bilmez.
3. **`transactions` ve `prices`** birbirini bilmez.
4. **Bir özellik başka özelliğin `presentation/` klasörünü import etmez.** Başka özelliğe yalnızca `providers/` ve `domain/` üzerinden erişilir.
5. **`core/` hiçbir özelliği bilmez.** `shared/` yalnızca `core/`'u bilir.
6. İki özellik aynı widget veya modeli kullanıyorsa o parça `shared/` altına taşınır. Tek özellikte kullanılıyorsa o özellikte kalır.
7. Döngüsel bağımlılık (A → B → A) yasaktır. Oluşuyorsa ortak parça `shared/` veya yeni bir özelliğe çıkarılır.

## 6. Ana veri akışları

### 6.1 Açılış ve oturum

```
main() → Supabase.initialize → ProviderScope → app.dart
authProvider oturumu dinler → app_router yönlendirir
  oturum yok  → login_screen
  oturum var  → dashboard_screen
```

Oturum durumu tek `authStateProvider` üzerinden okunur, yönlendirme yalnızca `app_router.dart` içinde bu provider'a göre yapılır.

### 6.2 Fiyat yenileme (kritik akış)

```
dashboard açık
   │  her TTL saniyede (ve pull-to-refresh)
   ▼
prices_provider → price_repository → price_service
   ▼
Edge Function: get-prices
   ├─ price_cache taze mi? (fetched_at > now - TTL)
   │    evet → önbellekten döner (CoinGecko'ya gitmez)
   │    hayır → CoinGecko'ya TEK toplu istek → price_cache upsert → döner
   ▼
Flutter: PriceInfo listesi → portfolio_provider yeniden hesaplar → ekranlar güncellenir
```

Kurallar:
- **Zamanlayıcı yalnızca uygulama ön plandayken çalışır.** Arka plana geçince `WidgetsBindingObserver` ile durdurulur, dönünce hemen bir kez yenilenir. Zamanlayıcı yalnızca `prices_provider` içinde yaşar, ekranlar kendi zamanlayıcısını başlatmaz.
- Kullanıcıdan istek gelmedikçe sunucu CoinGecko'ya gitmez (kota koruması, bkz. veritabanı skill'indeki kota hesabı).
- Ağ hatasında **son bilinen fiyatlar gösterilir**, üstte "Çevrimdışı, son güncelleme 14:35" uyarısı çıkar. Ekran boş kalmaz.
- TTL tek sabitte (`core/constants.dart`) tanımlanır, kullanıcı ayarındaki yenileme sıklığı bu değeri aşağı çekemez (Edge Function alt sınır uygular).

### 6.3 İşlem ekleme

```
add_transaction_screen (form doğrulaması)
   ▼
transactions_provider.add() → transaction_repository → Supabase insert
   ▼
Realtime olayı → transactions_provider yenilenir
   ▼
portfolio_provider: cost_calculator ile replay → Position listesi
   ▼
dashboard, allocation ve history ekranları kendiliğinden güncellenir
```

- Form doğrulaması (negatif miktar, fazla satış) istemcide yapılır, veritabanı tetikleyicisi ikinci güvencedir.
- Kayıt başarısızsa form verisi korunur ve hata mesajı gösterilir.

### 6.4 CSV içe aktarma

```
settings_screen veya ilk açılış → csv_service (dosya seç) → csv_parser (doğrula)
   → hata varsa: satır hata listesi, yazma yok
   → hata yoksa: önizleme + onay → transaction_repository.bulkInsert (tek istek)
```

CSV akışının tamamı `transactions` özelliğinde yaşar. `settings` ekranı yalnızca giriş butonunu içerir ve `transactions` provider'ını tetikler.

## 7. Durum yönetimi (Riverpod)

| Provider türü | Kullanım | Konum |
|---|---|---|
| `Provider` | Repository ve servis örnekleri | Özelliğin `providers/` klasörü |
| `StreamProvider` / `AsyncNotifier` | Oturum, işlemler, fiyatlar | `auth`, `transactions`, `prices` |
| `Provider` (türetilmiş) | `portfolioProvider`: işlem + fiyat birleştirip `Position` ve toplamları üretir | `portfolio/providers` |
| `NotifierProvider` | Ayarlar (para birimi, tema, yenileme sıklığı), seçili zaman aralığı | `settings/providers` |

Kurallar:
- Durum **AsyncValue** ile modellenir: yükleniyor, hata ve veri durumları her ekranda ele alınır.
- Türetilmiş veri (`Position`, toplam K/Z) bir kez `portfolioProvider`'da hesaplanır, ekranlar yeniden hesaplamaz.
- USD/TL görüntüleme para birimi bir ayar provider'ıdır, değişince tüm değerler otomatik yeniden listelenir.
- `ref.watch` build içinde, `ref.read` olay işleyicilerinde kullanılır.
- Provider içinde `BuildContext` kullanılmaz.
- Provider dosyası kendi özelliğinde durur. Başka özelliğin provider'ı gerekiyorsa import edilir, kopyalanmaz.

## 8. Hata yönetimi

- `data` katmanı SDK hatalarını yakalar ve `core/errors.dart` içindeki `AppException` türlerine çevirir: `NetworkError`, `AuthError`, `ValidationError`, `RateLimitError`, `UnknownError`.
- Provider hatayı `AsyncValue.error` olarak yayar, ekran kullanıcı dostu Türkçe mesaj ve "Tekrar dene" butonu gösterir.
- Teknik ayrıntı (stack trace) kullanıcıya gösterilmez, geliştirme günlüğüne yazılır.
- Kota aşımı (`RateLimitError`): son önbellekteki fiyatlar gösterilir, hata değil bilgi mesajı çıkar.

| Durum | Davranış |
|---|---|
| İnternet yok | Son bilinen veri + çevrimdışı uyarısı |
| Oturum süresi doldu | Giriş ekranına yönlendir, form verisini kaybetme |
| Fiyat bulunamadı | O coin için "fiyat yok" göster, toplamı bu coin hariç hesapla ve bildir |
| Veritabanı hatası | Mesaj + tekrar dene, veriyi sessizce kaybetme |

## 9. Güvenlik

- İstemcide yalnızca Supabase `anon` anahtarı bulunur. `service_role` ve CoinGecko anahtarı **Edge Function ortam değişkenlerinde** (`supabase secrets set`) durur.
- Yetkilendirme istemci kodunda değil, **RLS** ile sağlanır (bkz. veritabanı skill).
- Oturum belirteçleri Supabase SDK'nın güvenli deposunda kalır, elle `SharedPreferences`'a yazılmaz.
- Şifre ve belirteç günlüklere yazılmaz.
- Biyometrik kilit istenirse `local_auth` ile uygulama açılışında ek katman olarak eklenir (opsiyonel).
- Hesap silme sunucu tarafı fonksiyonla yapılır, kullanıcının tüm verisi `on delete cascade` ile gider.

## 10. Test stratejisi

Orta seviye proje için hedef: **mantığı kapsamlı, arayüzü hafif test et.** Test klasörü `lib/` yapısını aynalar (`test/features/<özellik>/...`).

| Ne | Nasıl | Öncelik |
|---|---|---|
| `cost_calculator` | Birim testi | **Zorunlu** |
| `portfolio_calculator` | Birim testi | Yüksek |
| `csv_parser` | Birim testi | Yüksek |
| Repository'ler | Sahte (mock) servis ile | Orta |
| Ana ekranlar | Widget testi (yükleniyor, hata, boş, dolu) | Orta |

`cost_calculator` için en az şu senaryolar:
1. Tek alış: ortalama = alış fiyatı
2. İki alış (farklı fiyat): ağırlıklı ortalama
3. Kısmi satış: ortalama değişmez, gerçekleşmiş K/Z doğru
4. Tam satış sonrası yeniden alış: eski ortalama taşınmaz
5. Farklı sırada gelen kayıtlar: `executed_at` sırasına göre sonuç aynı
6. Komisyonlu işlem
7. Çok küçük miktarlar ve yuvarlama (`Decimal` ile kayıpsız)
8. Fazla satış: hata veya doğrulama sonucu

## 11. Adlandırma ve kod stili

- Dosyalar `snake_case.dart`, sınıflar `PascalCase`, değişkenler `camelCase`.
- Ekranlar `..._screen.dart`, provider'lar `..._provider.dart`, repository'ler `..._repository.dart` ile biter.
- Repository metotları eylem odaklıdır: `fetchAll`, `add`, `softDelete`, `bulkInsert`.
- Sabit sayı ve metinler `core/constants.dart` içinde toplanır.
- Bir dosya tek sorumluluk taşır; 300 satırı geçen widget'lar parçalanır.
- Kullanıcıya görünen tüm metinler Türkçe, kod ve değişken adları İngilizce.
- Import'larda özellikler arası erişim **paket yolu** ile yapılır (`package:uygulama/features/...`), göreli (`../../`) import yalnızca aynı özellik içinde kullanılır.

## 12. Yeni özellik ekleme kalıbı

Örnek: "Alarm" özelliği eklenecek. Kural: **yeni özellik = `features/` altında yeni klasör.**

1. **Veritabanı:** migration ile `alerts` tablosu + RLS (database skill)
2. **Klasör:** `features/alerts/` oluştur, yalnızca gereken alt klasörleri aç
3. **Domain:** `domain/alert.dart` (model), gerekirse tetiklenme koşulu hesabı (saf Dart + test)
4. **Data:** `data/alert_repository.dart` (Supabase erişimi)
5. **Providers:** `providers/alerts_provider.dart`
6. **Presentation:** ekran ve widget'lar, UI skill kurallarına uygun
7. **Rota:** `app/router/app_router.dart` içine ekle
8. **Test:** `test/features/alerts/...`
9. **Kontrol listesi:** aşağıdaki liste

Bu sıra (alttan üste) bağımlılık yönüyle aynıdır, her adım bir önceki üzerine kurulur.

## 13. Yapma listesi

- Widget içinde doğrudan `supabase.from(...)` veya HTTP çağrısı yazma.
- Ortalama maliyet veya K/Z hesabını ekran kodunun içine gömme.
- Başka özelliğin `presentation/` klasörünü import etme.
- Her ekranda ayrı fiyat zamanlayıcısı başlatma (tek `prices_provider` yeterli).
- CoinGecko'yu doğrudan mobil uygulamadan çağırma (kota ve anahtar güvenliği için Edge Function kullan).
- `double` ile para hesabı yapma.
- Hata yutma (`catch (_) {}`), her hata ya gösterilir ya kaydedilir.
- Her şeyi `shared/` klasörüne atma; yalnızca gerçekten 2+ özellikte kullanılanlar oraya taşınır.
- `core/` içine özelliğe özel kod koyma.
- Sabit değerleri (TTL, renk, metin) dağınık yazma.
- Büyük özellikleri tek seferde yazma, dikey dilimlerle (veritabanından ekrana) küçük parçalar halinde ilerle.

## 14. Teslim öncesi kontrol listesi

- [ ] Yeni kod doğru özellik klasöründe ve katman sırası korunuyor
- [ ] Özellikler arası import'larda `presentation` ihlali yok, döngüsel bağımlılık yok
- [ ] Ekranlarda Supabase veya HTTP çağrısı yok
- [ ] `cost_calculator` testleri geçiyor
- [ ] Her ekranda yükleniyor, hata, boş ve dolu durumlar var
- [ ] Çevrimdışı durumda son bilinen veri gösteriliyor
- [ ] Fiyat zamanlayıcısı arka planda duruyor, ön plana dönünce yenileniyor
- [ ] Gizli anahtarlar istemcide değil, Edge Function ortamında
- [ ] Para hesabında `Decimal` kullanılıyor
- [ ] Kullanıcı metinleri Türkçe, tutarlı biçimde (`tr_TR`)
- [ ] `shared/` yalnızca gerçekten ortak parçaları içeriyor
- [ ] README'de kurulum ve ortam değişkenleri anlatılıyor
