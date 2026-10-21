# Kripto Portföy ve Kâr/Zarar Takip Uygulaması Tasarım Sistemi & Standartları

Bu doküman, **Chronomind** mobil finans ve portföy analitiği uygulamasının tasarım sistemi token'larını, sayfa mimarisini, kullanıcı akışlarını, bileşen kütüphanesini ve frontend geliştirme standartlarını tanımlar.

---

## 1. Uygulama Vizyonu ve Genel Bakış
**Chronomind**, bireysel ve kurumsal yatırımcılar için geliştirilmiş, borsa/cüzdan entegrasyonlu, gerçek zamanlı kâr/zarar (PnL), ortalama maliyet (DCA) ve piyasa analitiği sunan profesyonel düzeyde bir mobil fintech uygulamasıdır.

- **Platform / Form Faktörü:** Mobil (iOS & Android uyumlu responsive viewport: ~390px - 430px)
- **Tema:** **Saf Karanlık Mod (Dark Obsidian Precision)**:
  - Yalnızca derin obsidyen (`#051424`), siber-finans neon turkuaz (`#06B6D4`) ve zümrüt yeşili (`#10B981`) aksanlar kullanılır.
  - Açık tema (Light Mode) finansal veri netliği, OLED pil optimizasyonu ve terminal disiplini gereği kaldırılmış; saf karanlık mod standart hale getirilmiştir.
- **Tasarım Dili:** Yüksek kontrastlı veri hiyerarşisi, okunabilir monospaced sayısal değerler, yumuşatılmış mikro-etkileşimli kartlar, sıfır piksel taşması (Zero-Overflow Responsive).

---

## 2. Bilgi Mimarisi & Sayfa Hiyerarşisi

### 2.1. Navigasyon Çatısı
Uygulama 5 ana sekmeden ve modal/yığın (stack) alt ekranlardan oluşur:

1. **Giriş / Kayıt Ol (`AuthScreen`):** Karşılama, biyometrik giriş, OAuth ve misafir modu.
2. **Dashboard (`PortfolioOverviewScreen`):** Konsolide net portföy değeri, 24 saatlik değişim, toplam PnL, hızlı aksiyonlar ve varlık özeti.
3. **Varlıklar (`MarketsWatchlistScreen` & `CoinDetailScreen`):** Coin piyasa listesi, trendler, Korku/Açgözlülük indeksi, coin detay ve maliyet çizgisi.
4. **İşlem Ekle (`AddTransactionScreen`):** Merkezde yer alan öne çıkarılmış Floating Action Button (FAB) ile tetiklenen Alış/Satış/Transfer ekranı.
5. **Geçmiş / Analiz (`PnLAnalysisScreen` & `HistoryScreen`):** Kümülatif getiri eğrileri, gerçekleşmiş vs. gerçekleşmemiş kâr/zarar, başarı oranları (% win-rate), CSV veri dışa aktarımı.
6. **Ayarlar (`SettingsScreen`):** Arayüz Teması (Obsidian Precision Koyu), Para birimi (USD/TRY), Fiyat yenileme frekansı, CSV İçe/Dışa Aktarma, Hesap yönetimi.

### 2.2. Alt Gezinme Çubuğu (Bottom Navigation Bar)
```
[ 🏠 Dashboard ]  [ 🪙 Varlıklar ]  [ ( + ) İşlem Ekle ]  [ ⏱️ Geçmiş ]  [ ⚙️ Ayarlar ]
```

---

## 3. Tasarım Sistemi Token'ları (Design Tokens)

### 3.1. Renk Paleti (Saf Karanlık Obsidian Token'ları)

| Token İsmi | Hex Kodu | Kullanım Alanı |
| :--- | :--- | :--- |
| `canvas / background` | `#051424` | Ana sayfa arka planı (derin petrol / obsidyen) |
| `surface-dim` | `#010F1F` | En alt katman, gölgeli alanlar, modal arka planı |
| `surface-card / surface1` | `#0D1C2D` | Birincil veri kartları, liste elemanları |
| `surface2` | `#13263B` | İç içe kartlar, ikincil kutular, chip zeminleri |
| `surface3` | `#1F344D` | Seçili durumlar, aktif buton zeminleri |
| `surface-border` | `#1F344D` | İnce ayırıcı çizgiler, kart sınırları |
| `primary` / `cyan` | `#06B6D4` | Marka rengi, aktif sekmeler, butonlar, ana vurgular |
| `primaryBright` | `#22D3EE` | Vurgulu neon ikonlar, parlak linkler |
| `success` / `profit` | `#10B981` | Pozitif PnL, yükseliş eğilimleri, aktif bağlantı rozeti |
| `danger` / `loss` | `#EF4444` | Negatif PnL, düşüş oranları, satış aksiyonları |
| `text-primary` | `#F8FAFC` | Başlıklar, birincil bakiye tutarları |
| `text-secondary` | `#94A3B8` | Açıklamalar, etiketler, dipnotlar |
| `text-muted` | `#64748B` | Pasif metinler, timestamp'ler, grid çizgileri |
| `input-inset` | `#0A1929` | Arama & metin giriş kutusu içi |

### 3.2. Piksel Taşması ve Esneklik Standartları (Zero-Overflow Standard)
- **Satır İçi Metinler (Inline Row Texts):** Para birimi simgesi, yüzde rozeti veya aksiyon butonu içeren tüm `Row` içindeki metin blokları (`Text`) kesinlikle `Flexible` veya `Expanded` içine alınmalı, `overflow: TextOverflow.ellipsis` ve `maxLines: 1` ile sınırlandırılmalıdır.
- **Konsolide Bakiyeler:** Display boyutundaki büyük parasal değerler `FittedBox(fit: BoxFit.scaleDown)` ile sarılarak dar ekranlarda (iPhone SE / 375px) bile taşması önlenmelidir.
- **Diyaloglar & Bottom Sheet'ler:** Modal pencereler (`AlertDialog`, `GlassSheet`) içerik boyutu bilinmeyen durumlarda `SingleChildScrollView` ve `SafeArea` ile sarılmalıdır.

### 3.3. Tipografi (Typography)
- **Ana Yazı Tipi:** `Plus Jakarta Sans` veya `Inter`
- **Sayısal & Finansal Veriler:** `tabular-nums` (sayıların hizada kalması için sabit genişlikli rakamlar)
- **Hiyerarşi:**
  - `Display / Total Balance`: 32px – 36px, Bold (Font-weight: 700-800)
  - `Section Title`: 16px – 18px, Semi-Bold (Font-weight: 600)
  - `Body / Coin Name`: 14px – 15px, Medium (Font-weight: 500)
  - `Caption / Micro Label`: 11px – 12px, Regular/Medium (Font-weight: 400-500)

### 3.4. Boşluk & Köşe Yuvarlama (Spacing & Radius)
- **Border Radius:**
  - `card`: `16px` (`rounded-2xl`)
  - `button / input`: `12px` (`rounded-xl`)
  - `badge / pill`: `9999px` (`rounded-full`)
- **Spacing Scale:** 4px bazlı ritim (4, 8, 12, 16, 20, 24, 32px)

---

## 4. Ekran Detayları ve Fonksiyonel Gereksinimler

### 4.1. Portföy Genel Bakış (Dashboard)
- **Konsolide Bakiye Kartı:** Toplam varlık değeri ($84,250.60), 24s net değişim miktarı ve yüzdesi, tüm zamanlar PnL.
- **Gizlilik Toggle'ı:** Tutar gizleme/gösterme (göz ikonu).
- **Hızlı Aksiyonlar:** 4'lü buton ızgarası (Yatır, Çek, İşlem Ekle, Varlık Dağılımı).
- **Varlık Dağılım Çubuğu:** Renk kodlu segmentli progress bar (BTC %48.5, ETH %27.2, SOL %14.3, Diğer %10.0).
- **Varlık Listesi:** Coin simgesi, adı, sembolü, elde tutulan adet, toplam USD değeri, 24s getiri yüzdesi ve bireysel kâr tutarı.

### 4.2. Kâr / Zarar & Performans Analizi (P&L Analytics)
- **Zaman Dilimi Seçicisi:** Segment kontrolü (`24S`, `7G`, `30G`, `90G`, `1Y`, `Tümü`).
- **PnL Ayrımı:**
  - *Gerçekleşmemiş Kâr (Unrealized):* Açık pozisyonların anlık getirisi.
  - *Gerçekleşmiş Kâr (Realized):* Kapatılan işlemlerin net bakiyesi.
- **Kümülatif Getiri Eğrisi:** Düşüş (Dip) ve Zirve (ATH) noktalarını etiketleyen degrade dolgulu çizgi grafiği.
- **Verimlilik Metrikleri:** Kazanma Oranı (% Win Rate çemberi), Kâr/Zarar Faktörü (Profit Factor), Ortalama İşlem Kârı.
- **Aylık Performans Karşılaştırması:** Geçmiş ayların getiri barları.

### 4.3. Varlık Detayı (Coin Detail - Bitcoin)
- **Başlık & Fiyat Alanı:** Anlık kur, 24s değişim, favoriye ekleme ve alarm kurma butonları.
- **Pozisyon Kartı:** Kullanıcının portföyündeki adedi, toplam değeri, **Ortalama Maliyeti (DCA)** ve bu coinden elde edilen toplam net kâr.
- **Maliyet Çizgili Fiyat Grafiği:** Anlık fiyat ile ortalama alış seviyesini kıyaslayan referans çizgisi kesikli hatla gösterilir.
- **Piyasa İstatistikleri:** 24s En Yüksek/En Düşük barı, Market Cap, Hacim, Dolaşımdaki Arz.
- **İşlem Geçmişi:** İlgili coine ait geçmiş Alış/Satış/Transfer kayıtları.

### 4.4. Yeni İşlem Ekleme (Add Transaction Modal)
- **İşlem Tipi Seçici:** `Alış` (Yeşil) / `Satış` (Kırmızı) / `Transfer` (Nötr).
- **Girdi Alanları:**
  - Varlık seçimi (Açılır liste).
  - Alınan/Satılan miktar (Maksimum butonuyla).
  - Birim alış fiyatı (Anlık piyasa fiyatını getirme butonuyla).
  - Toplam hesaplanan tutar (USDT / Yerel Para Birimi).
  - Borsa / Cüzdan seçimi (Binance TR, MetaMask, Soğuk Cüzdan vb.).
  - Tarih, saat, komisyon ve kişisel not alanı.
- **Portföy Simülasyon Kartı:** Bu işlem onaylandığında yeni ortalama maliyetin (DCA) nasıl güncelleneceğini anlık gösterir.

### 4.5. Piyasalar ve İzleme Listesi (Markets & Watchlist)
- **Arama Çubuğu:** Coin ve sembol arama.
- **Piyasa Nabzı:** Canlı Korku & Açgözlülük İndeksi (0-100 skala), Global Market Cap, BTC Dominansı.
- **Kategori Hapları (Filter Chips):** Takip Listem, Tümü, Yapay Zeka (AI), Layer 1, DeFi, Meme.
- **Sıralı Coin Listesi:** Piyasa değerine veya 24s değişime göre sıralama opsiyonu.
- **Hızlı Fiyat Alarmı:** Fiyat hedefi tetikleyici kartı.

### 4.6. Ayarlar ve Güvenlik (Settings)
- **Arayüz Teması:** Karanlık Mod, Aydınlık Mod ve Sistem Teması arasında anlık geçiş ve SharedPreferences ile kalıcı saklama.
- **Hesaplama Tercihleri:**
  - Varsayılan Para Birimi (`USD`, `TRY`).
  - Fiyat Yenileme Sıklığı (30 sn, 60 sn, 300 sn).
- **Veri Dışa Aktarma (CSV):** `share_plus` ile iOS ve iPadOS uyumlu, `sharePositionOrigin` korumalı, boş portföylerde bile başlık satırlı standart şablon indirme desteği.
- **Güvenlik Katmanı:** Çıkış yapma ve verileri kalıcı olarak sıfırlama.

### 4.7. Giriş & Kimlik Doğrulama (Auth)
- **Güvenlik Rozetleri:** Uçtan uca şifreleme ve Supabase Auth entegrasyonu.
- **Giriş Yöntemleri:** E-posta/Şifre formu ve otomatik oturum yönetimi.

---

## 5. UI Bileşen Kütüphanesi & Kodlama Kuralları

### 5.1. Dinamik Tema Mimarisi Standardı (Flutter)
- Renkler statik sabitler yerine `AppColors.canvas`, `AppColors.surface1`, `AppColors.textPrimary` dinamik getter'ları ile çağrılır.
- Tema modu `themeModeProvider` (Riverpod) ile yönetilir ve `AppColors.setBrightness()` üzerinden senkronize edilir.

### 5.2. CSV Dışa Aktarma ve Paylaşım Standardı
- `share_plus` çağrılarında iOS / iPadOS çökmesini engellemek için her zaman `sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size` koordinatı iletilir.
- Kullanıcının işlemi olmasa bile dışa aktarma hatası üretilmez; geçerli sütun başlıklarını içeren boş `.csv` şablonu indirtilir.

---

## 6. Geliştirme ve Gelecek İterasyon İlkeleri
1. **Veri Bütünlüğü ve Şeffaflık:** Fiyat ve kâr hesaplamalarında kullanıcının seçtiği yöntem (DCA vs. FIFO) her zaman açıkça belirtilmelidir.
2. **Çift Tema Desteği:** Tüm yeni bileşenler hem Karanlık (Obsidian) hem de Aydınlık (Solar Platinum) modda kontrast testi yapılmalıdır.
3. **Mikro-Etkileşimler:** Fiyat alarmları, işlem ekleme ve filtre geçişlerinde anlık görsel geri bildirim sunulmalıdır.
4. **Platform Uyumluluğu:** Paylaşım, indirme ve harici sayfa açma gibi işletim sistemi etkileşimlerinde platform origin koordinatları eksiksiz sağlanmalıdır.
