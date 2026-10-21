---
name: obsidian-precision-ui
description: Kripto kâr/zarar ve portföy takibi uygulaması için "Obsidian Precision Financial" koyu tema tasarım sistemine göre Flutter arayüzü üretir veya düzenler. Dashboard, işlem formu, varlık dağılımı, geçmiş tablosu, giriş ve ayarlar ekranlarında renk, tipografi, boşluk, kart, rozet, form ve grafik kurallarını uygular. Bu projede ekran, widget, tema veya bileşen yazılırken kullan.
---

# Obsidian Precision Financial: UI Skill

Bu skill, kripto portföy takip uygulamasının arayüzünü tutarlı üretmek içindir. Hedef kitle: yüksek tutarlı dijital varlık yatırımcıları, trader'lar ve veriyi hızlı okumak isteyen kullanıcılar. Estetik: koyu, sakin, keskin, finansal terminal hissi veren ama lüks teknoloji duruşlu bir arayüz.

Teknoloji: **Flutter (Dart)**, grafikler için `fl_chart`, yazı tipleri için `google_fonts`, durum yönetimi `riverpod` veya `provider`.

## 1. Ne zaman kullanılır

- Yeni ekran, widget veya tema dosyası yazılırken
- Mevcut bir ekranın görünümü bu sisteme uydurulurken
- Renk, boşluk, tipografi veya bileşen kararı gerektiğinde

Bu skill iş mantığını (ortalama maliyet, K/Z hesabı, API) kapsamaz, yalnızca görünüm ve etkileşim kurallarını kapsar.

## 2. Tasarım ilkeleri

1. **Milisaniyede okunabilirlik:** Kâr, zarar, toplam değer ve yüzdeler ilk bakışta okunmalı. Ekran başına en fazla 3 baskın sayı.
2. **Gürültüsüz derinlik:** Ağır gölge yok. Derinlik yüzey tonları, 1px ince çerçeve ve hafif ışıma (glow) ile verilir.
3. **Sakin güven:** Volatil piyasada panik hissi vermeyen, düzenli ve boşluklu yerleşim.
4. **Renk tek başına anlam taşımaz:** Kâr/zarar rengi her zaman ok veya işaretle (`+`, `-`, ▲, ▼) birlikte gösterilir (renk körlüğü ve erişilebilirlik).
5. **Sayılar titremez:** Tüm finansal rakamlar tabular (eşit genişlikli) rakamla yazılır, fiyat değişince yerleşim kaymaz.

## 3. Renk sistemi (kanonik değerler)

> Not: Tasarım dosyasında iki set vardı. Kod tarafında **aşağıdaki "metin bölümündeki" değerler esas alınır**, çünkü bileşen tanımları bunlara dayanıyor. Üstteki Material tarzı jeton listesi (`#051424` vb.) yalnızca yedek referanstır, aynı projede ikisini karıştırma.

### Yüzeyler
| Jeton | Hex | Kullanım |
|---|---|---|
| `canvas` | `#0B0F19` | Uygulama zemini |
| `surface1` | `#111827` | Kart ve panel |
| `surface2` | `#1E293B` | Yükseltilmiş modül, input, alt gezinme, sheet |
| `surface3` | `#334155` | Aktif çip dolgusu, basılı durum, kenarlık |
| `inputInset` | `#0E1422` | Form alanı içi |

### Marka ve etkileşim
| Jeton | Hex | Kullanım |
|---|---|---|
| `primary` | `#06B6D4` | Ana CTA, aktif gösterge, canlı fiyat işareti |
| `secondary` | `#3B82F6` | Analitik vurgu, ikincil bağlantı |

### Kâr / Zarar
| Jeton | Hex | Kullanım |
|---|---|---|
| `profit` | `#10B981` | Temel kâr rengi |
| `profitText` | `#34D399` | Kâr metni (yüksek görünürlük) |
| `profitMuted` | `#059669` | Soluk kenarlık |
| `loss` | `#EF4444` | Temel zarar rengi |
| `lossText` | `#F87171` | Zarar metni |
| `lossMuted` | `#DC2626` | Soluk kenarlık |

### Metin
| Jeton | Hex | Kullanım |
|---|---|---|
| `textPrimary` | `#F8FAFC` | Başlık, rakam, ticker |
| `textSecondary` | `#94A3B8` | Etiket, meta veri, miktar |
| `textMuted` | `#64748B` | Ayraç, boş durum, pasif |

### Yarı saydam değerler
- Kart kenarlığı: beyaz %6 (`rgba(255,255,255,0.06)`)
- Sheet/modal kenarlığı: beyaz %12
- Satır alt çizgisi: beyaz %3
- Kâr arka planı: `#10B981` %12, kenarlık %25
- Zarar arka planı: `#EF4444` %12, kenarlık %25
- Cyan odak kenarlığı: `#06B6D4` %30

## 4. Tipografi

| Rol | Yazı tipi | Boyut / Satır | Ağırlık | Harf aralığı |
|---|---|---|---|---|
| headline-xl | Plus Jakarta Sans | 32 / 40 | 700 | -0.03em |
| headline-xl-mobile | Plus Jakarta Sans | 28 / 36 | 700 | -0.025em |
| headline-lg | Plus Jakarta Sans | 24 / 32 | 600 | -0.02em |
| headline-md | Plus Jakarta Sans | 20 / 28 | 600 | -0.015em |
| headline-sm | Plus Jakarta Sans | 16 / 24 | 600 | -0.01em |
| body-lg | Inter | 16 / 24 | 400 | 0 |
| body-md | Inter | 14 / 20 | 400 | 0 |
| body-sm | Inter | 12 / 16 | 400 | 0 |
| label-numeric-lg | Plus Jakarta Sans | 24 / 28 | 700 | -0.02em |
| label-numeric-md | Plus Jakarta Sans | 16 / 20 | 600 | -0.01em |
| label-sm | Inter | 11 / 14 | 500 | +0.04em, BÜYÜK HARF |
| caption | Inter | 10 / 12 | 500 | +0.05em, BÜYÜK HARF |

Kurallar:
- **Başlıklar ve tüm finansal rakamlar:** Plus Jakarta Sans + tabular rakam (`FontFeature.tabularFigures()`).
- **Gövde ve yoğun liste içeriği:** Inter.
- **Mikro etiket ve rozet:** büyük harf, geniş harf aralığı.
- Mobilde ana değer için `headline-xl-mobile` kullan.

## 5. Boşluk ve yerleşim

4px/8px ızgara. Jetonlar: `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`.

- **Mobil:** tek sütun, yatay dış kenar boşluğu **16px**, kartlar arası **12-16px**.
- **Tablet:** kenar boşluğu 24px, 6-12 sütunlu ızgara. Portföy özet kartı ile varlık listesi yan yana.
- **Masaüstü/geniş:** kenar boşluğu 32px.
- **Dikey ritim:**
  - Sıkı gruplar (ticker, coin adı, mini grafik): 4-8px
  - Kart iç boşluğu: 16px (kompakt liste satırında 12px)
  - Bölümler arası: 24px

## 6. Derinlik ve yüzeyler

| Seviye | Yüzey | Kenarlık |
|---|---|---|
| 0 Zemin | `canvas` | yok |
| 1 Kart | `surface1` | 1px beyaz %6 |
| 2 Sheet / Modal / Overlay | `surface2` %85 opak + `BackdropFilter` blur 16 | 1px beyaz %12 |

- **Gölge kullanma.** Derinlik yüzey tonu ve ince çerçeveyle sağlanır.
- **Işıma:** Toplam portföy değeri alanının arkasına çok hafif cyan radyal gradient (üstten merkezli, `#06B6D4` %15 → saydam, yarıçap yaklaşık %70). Kâr/zarar rozetlerinin arkasında hafif yeşil/kırmızı parıltı.

## 7. Şekil

- Kart ve veri modülleri: **8px** köşe.
- Input ve arama: **8px**.
- Buton: **8px**.
- **Hap (pill, tam yuvarlak):** yalnızca zaman aralığı seçici (1S, 24S, 7G, 30G, 1Y, TÜMÜ), aktif filtreler ve K/Z rozetleri.
- Checkbox: 4px köşe.
- Token ikonu: 32px "squircle".

## 8. Bileşen kuralları

### Butonlar ve zaman seçici
- **Ana CTA:** `primary` dolgu, `canvas` renkli kalın metin, 8px köşe, hover/basılı durumda hafif cyan ışıma.
- **İkincil:** `surface2` dolgu, 1px beyaz %8 kenarlık, `textPrimary` metin.
- **Zaman aralığı seçici:** `surface1` zeminli grup kapsayıcı. Aktif seçenek `surface2` dolgu, `primary` metin, 1px cyan %30 kenarlık, hap şekilli.

### Portföy özet kartı
- `surface1`, üstte çok ince vurgu çizgisi (beyaz %10).
- İçerik: toplam portföy değeri (`label-numeric-lg` veya `headline-xl-mobile`), 24 saatlik tutar değişimi, yüzde rozeti.
- USD / TL anahtarı kartın sağ üstünde.
- Arkada cyan radyal ışıma.

### Varlık satırı (liste öğesi)
Düz yatay satır, alt çizgisi beyaz %3. Soldan sağa:
1. 32px token ikonu (squircle)
2. Sembol (`headline-sm`) + altında miktar (`body-sm`, `textSecondary`)
3. Mini sparkline (vektör, 2px çizgi, trend rengine göre yeşil/kırmızı)
4. Sağa yaslı: güncel fiyat (`label-numeric-md`) + altında K/Z rozeti

### K/Z rozeti
| Durum | Arka plan | Metin | Kenarlık | Önek |
|---|---|---|---|---|
| Pozitif | `#10B981` %12 | `profitText` | `#10B981` %25 | `+` veya ▲ |
| Negatif | `#EF4444` %12 | `lossText` | `#EF4444` %25 | `-` veya ▼ |
| Sıfır | `surface3` | `textSecondary` | yok | yok |

Hap şekilli, `label-sm` ölçüsünde, tabular rakam.

### Form alanları
- Zemin `inputInset`, 1px beyaz %8 kenarlık, 8px köşe.
- Odakta kenarlık `primary`, ofset halka yok.
- Tutar ve miktar alanları tabular rakam; sağa yaslı yazım tercih edilir.
- Etiketler `label-sm`, `textSecondary`. Hata durumunda `lossText` kenarlık ve altta kısa hata metni.

### Checkbox ve segment seçici
- Checkbox 4px köşe, slate kenarlık. Seçilince `primary` dolgu, `canvas` renkli onay işareti.

### Donut grafik (varlık dağılımı)
- Ortada toplam değer (`label-numeric-lg`) ve altında küçük etiket.
- Dilimler için kontrastlı bir palet: `primary`, `secondary`, `profit`, `#A78BFA`, `#F59E0B`, `#F472B6`, kalanlar için `surface3`. Dilimler arası ince `canvas` renkli boşluk.
- Dilime dokununca ilgili coin detayı açılır (alt sheet).

### Tablo (K/Z geçmişi)
- Başlık satırı `label-sm`, `textSecondary`. Satırlar flush, ince alt çizgi.
- Rakam sütunları sağa yaslı, tabular.
- Net kâr/zarar sütunu rozet veya renkli metin + işaret ile gösterilir.

### Canlı veri göstergesi
- Küçük `primary` nokta (nabız animasyonu) ve "Son güncelleme: 14:35" metni (`caption`, `textMuted`).
- Fiyat değiştiğinde kısa (300ms) yeşil/kırmızı parlama, ardından normale dönüş. Bu animasyon aşırı olmamalı.

## 9. Ekran bazlı uygulama

| Ekran | Anahtar bileşenler |
|---|---|
| **Giriş / Kayıt** | `canvas` zemin, ortada logo, input alanları, ana CTA, "Şifremi unuttum" bağlantısı (`secondary` renk). Kayıt sonrası "Manuel giriş / CSV yükle" iki kartlı seçim |
| **Dashboard** | Özet kartı, USD/TL anahtarı, zaman seçici, performans grafiği, varlık satırları, "öne çıkan kriptolar" yatay kart kaydırma, yatırım tavsiyesi değildir notu |
| **İşlem formu** | Alış/Satış segment anahtarı (alış `profit`, satış `loss` ton), coin arama, miktar/fiyat alanları, USD/TL seçici, "Piyasa fiyatını kullan" ikincil butonu, canlı önizleme kartı, ana CTA |
| **Varlık dağılımı** | Donut, altında varlık tablosu (adet, ort. alış, anlık değer, K/Z tutarı ve %), toplam satırı |
| **K/Z geçmişi** | İki sekme (İşlem Geçmişi / Gerçekleşmiş Kâr), filtre çipleri, tablo, alt toplam, CSV dışa aktarma |
| **Ayarlar** | Gruplanmış liste kartları, anahtarlar (switch, `primary`), tema ve para birimi seçimi, tehlikeli işlemler (hesabı sil) `loss` renkli |

Alt gezinme çubuğu: `surface2` zemin, aktif öğe `primary`, pasif `textMuted`. Ortadaki "+" (işlem ekle) vurgulu ve diğerlerinden belirgin.

## 10. Flutter uygulama rehberi

### Tema dosyası yapısı
```
lib/theme/
  app_colors.dart      (renk jetonları)
  app_text_styles.dart (tipografi)
  app_spacing.dart     (boşluk ve köşe)
  app_theme.dart       (ThemeData.dark tabanlı)
```

### Renk jetonları (örnek)
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const canvas = Color(0xFF0B0F19);
  static const surface1 = Color(0xFF111827);
  static const surface2 = Color(0xFF1E293B);
  static const surface3 = Color(0xFF334155);
  static const inputInset = Color(0xFF0E1422);

  static const primary = Color(0xFF06B6D4);
  static const secondary = Color(0xFF3B82F6);

  static const profit = Color(0xFF10B981);
  static const profitText = Color(0xFF34D399);
  static const loss = Color(0xFFEF4444);
  static const lossText = Color(0xFFF87171);

  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
}
```

### Tabular rakam
```dart
TextStyle numeric(double size, FontWeight w) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: w,
  color: AppColors.textPrimary,
  fontFeatures: const [FontFeature.tabularFigures()],
);
```

### Kart
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.surface1,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
  ),
  child: ...,
)
```

### Cam efektli sheet
`ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16))` + `surface2` %85 opak dolgu + 1px beyaz %12 kenarlık.

### Genel Flutter kuralları
- `ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: AppColors.canvas, ...)` ile temayı tek yerden tanımla, ekranlarda sabit renk kodu yazma.
- Renk, boşluk ve köşe değerlerini yalnızca `AppColors`, `AppSpacing` ve `AppTextStyles` üzerinden kullan.
- Para ve yüzde biçimlendirmesi için `intl` (`NumberFormat`), Türkçe yerel ayarla (`tr_TR`).
- Tekrar eden öğeleri widget olarak çıkar: `PnlBadge`, `AssetRow`, `PortfolioSummaryCard`, `PeriodSelector`, `GlassSheet`, `LiveDot`.

## 11. Erişilebilirlik ve etkileşim

- Metin/zemin kontrastı: ana metin `textPrimary` zemin üzerinde yüksek kontrast, `textMuted` yalnızca ikincil ve pasif öğede.
- Dokunma hedefi en az **44x44 px**.
- Kâr/zarar yalnızca renkle değil işaret ve ok ile de belirtilir.
- Önemli işlem butonları ekranın alt yarısında (tek elle kullanım).
- Yükleniyor durumunda iskelet (skeleton) yer tutucu, dönen çember yerine tercih edilir. Hata ve boş durumlarda kısa açıklama ve bir eylem butonu.
- Hareketi azalt ayarı açıksa nabız ve parlama animasyonlarını kapat.
- Bakiye gizleme (göz simgesi) isteniyorsa tutarlar "••••" ile maskelenir, yüzdeler görünür kalabilir.

## 12. Yapma listesi

- Ağır gölge, canlı gradyan dolgu ve oversize yuvarlak köşe kullanma.
- Aynı ekranda 3'ten fazla vurgu rengi kullanma.
- Kâr/zarar için yalnızca renge güvenme.
- Finansal rakamlarda tabular olmayan yazı tipi kullanma.
- Hap şekli yalnızca zaman seçici, filtre ve rozetler için kullan, kartlara ve normal butonlara uygulama.
- Sabit hex kodunu widget içine gömme, jeton kullan.
- Tasarım dosyasındaki iki farklı renk setini aynı projede karıştırma.
- "Tavsiye edilen kripto" gibi bölümlerde yatırım tavsiyesi dili kullanma, bilgilendirme notu ekle.

## 13. Teslim öncesi kontrol listesi

- [ ] Tüm renkler `AppColors` jetonlarından geliyor
- [ ] Finansal rakamlar tabular ve doğru yazı tipinde
- [ ] Kâr/zarar rozetlerinde renk + işaret birlikte var
- [ ] Kartlar 8px köşe, 1px beyaz %6 kenarlık, gölgesiz
- [ ] Mobil 16px kenar boşluğu, kartlar arası 12-16px
- [ ] Boş, yükleniyor ve hata durumları tasarlandı
- [ ] Zaman aralığı seçici hap şeklinde, aktif durumu doğru
- [ ] Dokunma hedefleri en az 44px
- [ ] Son güncelleme saati ve USD/TL geçişi Dashboard'da görünüyor
- [ ] Küçük ve büyük ekranda taşma olmadan test edildi
