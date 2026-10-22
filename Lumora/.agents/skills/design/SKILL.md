# DESIGN SKILL — Lumora

> **Sürüm:** 1.0.0
> **Tasarım sistemi:** Vital Momentum
> **Platform:** Mobil (iOS & Android), dikey yön
> **Birincil dil:** Türkçe
> **Teknik mimari:** `architecture-skill.md` · **Genel çerçeve:** `project.md`

Bu dosya Lumora'nın görsel kimliğini, ortak bileşenlerini ve ekran şartnamelerini tanımlar. Kaynak, tasarım ekibinin hazırladığı 6 ekranlık tasarımdır. Tasarımda **olmayan** ya da bu dosyayı yazarken **ben tamamladığım** yerler "Önerilen" etiketiyle işaretlidir; onay beklerler.

---

## 1. Ürün Hissi

Lumora, James Clear'ın "Atomik Alışkanlıklar" ve Jerry Seinfeld'in "Zinciri Kırma" yöntemlerinden esinlenir. Günlük mikro-rutinleri (su, kitap, spor, meditasyon) görselleştirerek istikrara çevirir.

Tasarım ilkeleri:
1. **Pozitif ivme:** Başarı kutlanır, kaçırılan gün cezalandırılmaz. Yeşil ilerlemeyi, turuncu seriyi (ateş) temsil eder.
2. **Tek dokunuşla ilerleme:** Bugün ekranında bir alışkanlığı işaretlemek en fazla bir dokunuştur.
3. **Yumuşak ve net:** Büyük yuvarlak köşeler, bol boşluk, belirgin hiyerarşi.
4. **Zincir metaforu:** Takvim, seri rozetleri ve logo "halka" motifini taşır.

---

## 2. Tasarım Tokenları

Tüm değerler yalnızca `core/theme` altında tanımlanır. Ekranlarda ham renk kodu veya sayı yazılmaz.

### 2.1 Renk

| Token | Değer | Kullanım |
|---|---|---|
| `primary` | `#10B981` | Başarı, tamamlanma, ilerleme dolguları, rozet ikonları |
| `primaryStrong` | `#059669` | Ana buton zemini, basılı durum, vurgulu yeşil |
| `streak` | `#F97316` | Aktif seri, alev ikonu, kısmi gün noktası |
| `streakStrong` | `#EA580C` | Seri vurgusu, basılı durum |
| `background` | `#FAF8FF` | Ekran zemini (soğuk beyaz) |
| `backgroundAlt` | `#F8FAFC` | Alternatif zemin, bölüm arkaları |
| `surface` | `#FFFFFF` | Kart yüzeyleri |
| `border` | `#E2E8F0` | Kenarlıklar, ayırıcılar |
| `inactive` | `#F1F5F9` | Pasif zeminler, boş halkalar, kapalı toggle izi |

Kategori renkleri (alışkanlık ikonu, ilerleme çubuğu ve grafik dilimi için):

| Kategori (`category`) | Ad | Değer |
|---|---|---|
| `water` | Okyanus Mavisi | `#0284C7` |
| `book` | Amber / Altın | `#D97706` |
| `sport` | Enerji Mercanı | `#EA580C` |
| `mind` | Zihin (meditasyon) | *Tasarımda tanımsız, Önerilen: mor `#7C3AED`* |
| `custom` | Özel | `primary` |

Kategori rengi, alışkanlığın ikon zeminini (rengin %12 saydam tonu), ilerleme çubuğunu ve istatistik dilimini boyar.

### 2.2 Tipografi

- **Font ailesi:** Plus Jakarta Sans (`sans-serif` yedek). Paket olarak uygulamayla birlikte gelir, ağdan yüklenmez.
- Ağırlıklar: 400, 500, 600, 700, 800.
- **Ölçek (Önerilen; tasarımda boyutlar belirtilmemiş):**

| Stil | Boyut / Satır | Ağırlık | Kullanım |
|---|---|---|---|
| `display` | 32 / 40 | 800 | Büyük yüzde, seviye sayısı |
| `title` | 22 / 28 | 700 | Ekran başlıkları |
| `heading` | 18 / 24 | 700 | Kart başlıkları |
| `body` | 16 / 24 | 500 | Ana metin, giriş alanları |
| `bodySmall` | 14 / 20 | 500 | İkincil metin |
| `caption` | 12 / 16 | 600 | Etiketler, rozet metni, XP çipi |

Büyük sistem yazı boyutlarında düzen bozulmamalı; sabit yükseklikli metin kapları kullanılmaz.

### 2.3 Şekil, boşluk, derinlik

- **Köşe:** Kartlar ve girişler `rounded-2xl` (**16 px**). Butonlar, çipler, rozetler ve toggle'lar `rounded-full` (hap).
- **Boşluk:** 4 px tabanlı ölçek (4, 8, 12, 16, 20, 24, 32). Ekran yan boşluğu **16 px**. *(Önerilen)*
- **Derinlik:** Kartlar beyaz yüzey + `border` kenarlığı ile ayrılır, gölge hafif ve dağınıktır; ağır gölge kullanılmaz. *(Önerilen)*
- **İkonlar:** Tek bir yuvarlak hatlı ikon ailesi (Material Symbols Rounded). Alışkanlık ikonu `habit.icon` alanındaki ada karşılık gelir (ör. `water_drop`).

### 2.4 Tema

Tasarım yalnızca **açık tema** için hazırlanmıştır. Profil ekranında tema ayarı ve `settings.theme = system|light|dark` bulunduğundan koyu tema gerekir, ancak **koyu palet tasarımda tanımlı değildir** ve ayrıca tasarlanmalıdır. Bunun için renkler anlamsal isimlerle (`primary`, `surface`, `background`…) kullanılır, böylece koyu palet sonradan yalnızca `core/theme` içine eklenir.

---

## 3. Erişilebilirlik Notu (Önemli)

Tasarımdaki iki ana renk beyaz zeminde/beyaz yazıyla yetersiz kontrast verir (yaklaşık değerler):

| Kombinasyon | Kontrast | Sonuç |
|---|---|---|
| Beyaz yazı üzerinde `#10B981` | ~2,5 : 1 | Metin için yetersiz |
| Beyaz yazı üzerinde `#059669` | ~3,8 : 1 | Yalnızca büyük/kalın metinde yeterli |
| Beyaz yazı üzerinde `#F97316` | ~2,8 : 1 | Metin için yetersiz |
| Beyaz yazı üzerinde `#EA580C` | ~3,6 : 1 | Yalnızca büyük/kalın metinde yeterli |

Kurallar:
- Dolgulu butonlarda zemin `primaryStrong`, yazı beyaz ve **en az 16 px / 700**.
- Beyaz zeminde **yeşil renkli küçük metin** gerekiyorsa `#047857` (yaklaşık 5,5 : 1) kullanılır, `primary` değil.
- `primary` ve `streak` küçük metin değil; ikon, dolgu, halka ve grafik için kullanılır.
- Anlam yalnızca renkle verilmez: tamamlanan gün hem yeşil dolgu hem onay işareti, kısmi gün hem turuncu hem nokta/şekil taşır.
- Dokunma hedefi en az **48 × 48 px**.
- Her ikon buton ve grafik için anlamlı erişilebilirlik etiketi (ör. "250 mililitre su ekle").

---

## 4. Kabuklar (Shell)

| Kabuk | Kullanım | İçerik |
|---|---|---|
| `mobile_blank` | Giriş & Kayıt Ol | Üst çubuk ve alt sekme yok; odaklanmış ekran |
| `mobile_tab` | Diğer 5 ana ekran | Üst uygulama çubuğu + alt sekme çubuğu |

**Alt sekme çubuğu (5 sekme):** Bugün · Takvim · İstatistik · Rozetler · Profil. Aktif sekme `primaryStrong` ikon + etiket, pasifler gri. Sekme durumu korunur (sekme değişince kaydırma konumu kaybolmaz).

---

## 5. Ortak Bileşenler

| Bileşen | Tanım |
|---|---|
| **Hap buton (birincil)** | `primaryStrong` zemin, beyaz yazı, sağ tarafta isteğe bağlı ok ikonu, `rounded-full`, tam genişlik olabilir |
| **Hap buton (ikincil)** | `surface` zemin, `border` kenarlık, koyu yazı (sosyal giriş butonları vb.) |
| **Kart** | `surface`, `rounded-2xl`, `border`, 16 px iç boşluk |
| **Metin girişi** | `rounded-2xl`, `border`; odakta `primary` kenarlık; hata durumunda kırmızı kenarlık ve altında hata metni; şifre alanında göster/gizle ikonu |
| **Toggle** | Açıkken `primary` iz, kapalıyken `inactive`; saatli toggle'larda yanında saat seçici |
| **Sekme seçici (segmented)** | Hap şeklinde 2–3 seçenek, aktif olan `primaryStrong` zeminli |
| **Filtre çipi** | Hap, seçiliyken `primary` zemin; yatay kaydırılabilir |
| **Dairesel ilerleme** | İz `inactive`, dolgu `primary`, ortada yüzde; dolarken animasyonlu |
| **Zincir halkası** | Gün göstergesi: tamamlanmış = `primary` dolgulu halka + onay; boş = `inactive` halka; kısmi = turuncu nokta; bugün = alev rozetli vurgu |
| **Seri etiketi** | Alev ikonu + "14 Gün" (`streak` tonları), küçük hap |
| **XP çipi** | "+15 XP", `caption`, `primary` açık zemin |
| **İlerleme çubuğu** | `inactive` iz, kategori renginde dolgu, yuvarlak uçlar |
| **Çubuk grafik** | 7 sütun (Pzt–Paz), tepe günleri vurgulu; dokununca değer balonu |
| **FAB** | Hap biçimli genişletilmiş buton, "+ Yeni Alışkanlık", `primaryStrong`, sağ altta alt sekmenin üstünde |
| **Rozet kartı** | Açık: renkli ikon, ad, XP ve tarih. Kilitli/devam eden: soluk ikon, ilerleme (yüzde veya 14/21) |

---

## 6. Ekranlar

Her ekranın "Veri kaynağı" satırı `architecture-skill.md` içindeki uç noktaları gösterir.

### 6.1 Giriş & Kayıt Ol

- **Kabuk:** `mobile_blank`
- **Veri kaynağı:** `POST /auth/login`, `/auth/register`, `/auth/guest`, `/auth/forgot-password`
- **Bileşenler:**
  - Üstte marka logosu (yeşil zincir ikonu + alev rozeti), **"Lumora"** adı ve "Pozitif Rutinler" etiketi
  - Sekme seçici: "Giriş Yap" / "Kayıt Ol"
  - E-posta (veya telefon) alanı ve şifre alanı (göster/gizle)
  - "Beni hatırla" onay kutusu ve "Şifremi unuttum?" bağlantısı
  - Birincil CTA: "Giriş Yap" (ok ikonlu)
  - "Google ile Devam Et" ve "Apple ile Giriş Yap" butonları
- **Notlar:**
  - Sosyal giriş butonları şimdilik **yalnızca görsel yer tutucudur**; pasif görünür ve dokunulunca "Yakında" bilgisi verir (Faz 2).
  - "Kayıt Ol" sekmesine görünen ad alanı eklenir. *(Önerilen: tasarım yalnızca "Giriş Yap" durumunu gösteriyor)*
  - Misafir olarak devam etme bağlantısı sayfanın altında ikincil metin bağlantısı olarak durur. *(Önerilen; mimaride misafir modu var, tasarımda yok)*
- **Durumlar:** Gönderiliyor (CTA içinde yükleme göstergesi, tekrar dokunma kapalı), hata (genel hata mesajı, hangi alanın yanlış olduğu belli edilmez).

### 6.2 Bugün & Motivasyon

- **Kabuk:** `mobile_tab`, aktif sekme "Bugün"
- **Veri kaynağı:** `GET /today`, `PUT /habits/:id/logs/:date`, `GET /quotes/daily`
- **Bileşenler (yukarıdan aşağı):**
  1. **Günün İlhamı kartı:** Yeşil degrade zemin, söz metni, favorile ve paylaş butonları. Yazar satırı yalnızca doğrulanmış yedek sözlerde gösterilir (ör. "Marcus Aurelius"); yapay zeka sözlerinde "Lumora" yazılır veya atıf gösterilmez (bkz. mimari Bölüm 7.4).
  2. **Günün İlerlemesi:** Dairesel gösterge (örnek %75), "3/4 hedef", kazanılan XP.
  3. **Alışkanlık listesi** (her biri bir kart):
     - **İşaretleme türü (Kitap Okuma, Sabah Koşusu):** Tamamlanınca yeşil onay rozeti, "+15 XP" çipi, varsa seri etiketi ("14 Gün Zincir"). Dokununca tamamla/geri al.
     - **Sayaç türü (Su İçme):** "2.0 / 2.5 L" göstergesi, ilerleme çubuğu, `+250ml` ve `−` hızlı butonları.
     - **Zamanlı hatırlatıcılı (Akşam Meditasyonu):** Saat bilgisi (21:30) ve "Başla" eylem butonu.
  4. **FAB:** "+ Yeni Alışkanlık".
- **Davranış:** İşaretleme anında yansır (optimistic), hata olursa geri alınır. Günün son görevi bitince ilerleme halkası %100'e dolar ve kısa bir kutlama animasyonu oynar; "Gün Sonu Serisi" bonusu bir kez gösterilir.
- **Durumlar:** Yükleme (kart iskeletleri), boş (alışkanlık yok: yönlendirici metin + "Yeni Alışkanlık"), bugün planlı alışkanlık yok ("Bugün dinlenme günü"), çevrimdışı (küçük bilgi şeridi, işaretlemeler kuyruğa alınır).

### 6.3 Takvim & Hedefler

- **Kabuk:** `mobile_tab`, aktif sekme "Takvim"
- **Veri kaynağı:** `GET /calendar?month=`, `GET /calendar/day/:date`
- **Bileşenler:**
  - **Ay seçici:** Başlık (ör. "Mart 2025 · Zinciri Kırma Takvimi"), önceki/sonraki ay okları. Haftanın ilk günü `settings.weekStartsOn`'a göre.
  - **Aylık İstikrar Özeti:** Zincirin kırılmadığı gün sayısı (örnek 24 Gün) ve en uzun seri (örnek 38 Gün).
  - **Zincir matrisi (ısı haritası):** Tamamlanan gün yeşil dolgulu halka, kısmi gün turuncu nokta, bugün alev rozetli vurgu; gelecekteki günler soluk.
  - **Aktif Hedef Zincirleri:** Her hedef için kategori renginde ilerleme çubuğu ve son 7 günün mikro zincir halkaları.
  - **Günün Zincir Sözü:** Kitap ve defter görselli mikro motivasyon kartı.
- **Etkileşim:** Güne dokununca alt sayfa (bottom sheet) açılır: o günün alışkanlıkları, tamamlanma durumu ve miktarlar. *(Gün detayı proje kapsamında var; tasarımda ayrı bir görünümü yok, Önerilen)*
- **Durumlar:** Yükleme, o ayda veri yok (matris boş halkalarla gösterilir, "Bu ayda henüz kayıt yok").

### 6.4 İstatistikler & Grafikler

- **Kabuk:** `mobile_tab`, aktif sekme "İstatistik"
- **Veri kaynağı:** `GET /stats?range=`
- **Bileşenler:**
  - **Zaman aralığı filtresi:** "Haftalık", "Aylık", "Tüm Zamanlar".
  - **Genel Başarı Skoru:** Büyük yüzde (örnek %92) ve geçen haftaya göre trend rozeti (+%8).
  - **Rutin Performansı çubuk grafiği:** Pazartesi–Pazar, gün bazında başarı seviyesi, haftanın zirve günleri vurgulu.
  - **Kategori Dağılımı:** Kategori başına yüzde (örnek: Su %96, Kitap %88, Spor ve Egzersiz %82), kategori renginde çubuklar.
  - **En Verimli Saatler:** Odak pencereleri (örnek: Sabah 08:30, Akşam 21:00).
  - **Haftalık Özet & Momentum kartı:** Başarı mesajı ve "Usta Disiplinci" rozetine ilerleme.
- **Notlar:** Proje kapsamındaki "en düzenli alışkanlık", "mevcut ve en uzun seri", "toplam tamamlanan gün" ve alışkanlık bazında ilerleme grafikleri bu tasarımda ayrı bir bölüm olarak yok. *(Önerilen: "Kategori Dağılımı"nın altına "Alışkanlık Detayı" listesi eklenir; her satır seri ve toplam gün bilgisini taşır.)*
- **Durumlar:** Veri yetersiz (ilk günlerde grafik yerine "İstatistikler birkaç günlük veriyle oluşur" mesajı).

### 6.5 Rozetler & Seviyeler

- **Kabuk:** `mobile_tab`, aktif sekme "Rozetler"
- **Veri kaynağı:** `GET /badges`, `GET /level`
- **Bileşenler:**
  - **Kullanıcı Seviyesi:** Kalkan görseli, "Seviye 7: Alışkanlık Mimarı", XP ilerleme çubuğu (örnek 2.450 / 3.000 XP).
  - **Yeni Başarım kartı:** Yeni açılan rozet için tebrik kutusu (örnek "14 Günlük Demir İrade"). Görüldükten sonra kaybolur.
  - **Kategori filtresi:** Tümü, Zincirler, Spor & Sağlık, Zihin.
  - **Rozet ızgarası:**
    - Açılanlar: renkli ikon, kazanılan XP, tarih (örnek: 7 Gün Zincir, Alev Tutkunu, Kitap Kurdu)
    - Devam edenler/kilitliler: ilerleme göstergesi (Su Pınarı %70, Maraton Ruhu 14/21, Zen Zihin %35)
  - **Sonraki Büyük Eşik:** Kullanıcıyı motive eden dinamik ipucu kutusu.
- **Durumlar:** Hiç rozet yok (ilk rozete ne kadar kaldığını gösteren kutu öne çıkar).

### 6.6 Profil & Ayarlar

- **Kabuk:** `mobile_tab`, aktif sekme "Profil"
- **Veri kaynağı:** `GET/PATCH /profile`, `GET/PATCH /settings`, `GET /export`, `DELETE /account`
- **Bileşenler:**
  - **Profil başlığı:** Avatar, ad (örnek "Selin Yılmaz"), kullanıcı adı, katılım tarihi.
  - **Hızlı metrikler:** En İyi Seri (örnek 14 Gün), Toplam Hedef (örnek 42), Mevcut Seviye (örnek 7).
  - **Tercihler & Akıllı Hatırlatıcılar:** Akıllı Bildirimler (toggle), Sabah Motivasyonu (08:00, saat seçicili toggle), Akşam Zincir Kontrolü (21:30, saat seçicili toggle), Titreşim & Ses Efektleri (toggle).
  - **Hedef Yönetimi:** Günlük su ve kitap hedefleri için hızlı düzenleme butonları.
  - **Birlikte Güçlüyüz:** "Arkadaşını Davet Et" kartı ve bağlantıyı kopyala butonu.
  - **Hesap & Sistem:** Tema ayarı, CSV/PDF veri dışa aktarma, bulut senkronizasyonu, çıkış butonu.
- **Notlar:**
  - Davet bağlantısı ve "bulut senkronizasyonu" için şu an backend uç noktası yoktur (JSON depolama aşamasında). Bu bileşenler **görsel yer tutucu** olarak kalır, işlevleri sonraki sürüme bırakılır.
  - Veri dışa aktarma şimdilik CSV ve JSON'u destekler; PDF sonraki sürüme kalır.
  - Proje kapsamındaki **haftanın ilk günü** ayarı bu tasarımda yoktur. *(Önerilen: "Tercihler" bölümüne "Haftanın ilk günü" satırı eklenir.)*
  - **Hesabı sil** işlemi, "Hesap & Sistem" altında en sonda, onay penceresi ile gösterilir. *(Önerilen)*

---

## 7. Tasarımda Olmayan Ekranlar (Önerilen)

Projede zorunlu olan ama gönderilen tasarımda yer almayan ekranlar. Aynı tokenlar ve bileşenlerle çizilmelidir; tasarım ekibinden onay alınmalıdır.

**Alışkanlık Ekle / Düzenle** (alt sayfa veya tam ekran):
- Üstte hazır şablonlar (yatay çip/kart: Kitap, Su, Koşu, Erken Uyuma, Meditasyon…)
- Ad alanı ve ikon seçici (ızgara)
- Kategori seçimi (kategori rengini belirler)
- Günlük hedef sayısı ve ölçü birimi (ml, sayfa, dakika, kez…), sayaç türü için adım miktarı
- Tekrar günleri: 7 hap buton (Pzt–Paz)
- Hatırlatma saati seçici ve aç/kapat
- Alt kısımda sabit "Kaydet" hap butonu; düzenlemede ayrıca "Sil" (onay penceresiyle, geçmiş korunur uyarısı)

**Şifremi Unuttum / Şifre Sıfırla:** `mobile_blank`, e-posta alanı → kod ve yeni şifre alanı.

---

## 8. Hareket ve Geri Bildirim

- **Süre:** Çoğu geçiş 150–250 ms; yüzde halkası ve çubuklar 400–600 ms.
- **Tamamlama:** Onay işareti için kısa ölçek animasyonu, halka dolarken hafif titreşim (`settings.soundAndHaptics` açıksa).
- **Seri kutlaması:** Yeni rekor veya rozet açılınca alev/konfeti animasyonu; en fazla bir kez, atlanabilir ve kısa.
- **Hareketi azalt:** Sistem "hareketi azalt" ayarı açıksa animasyonlar kapatılır, durum değişimi anında gösterilir.
- **Yükleme:** Tam ekran dönen gösterge yerine kart iskeletleri (skeleton).
- **Hata:** Ağ hatasında kısa snackbar + "Tekrar dene". Çevrimdışıyken bilgi şeridi.

---

## 9. Metin ve Ton

- Türkçe, samimi ve sade; "sen" dili.
- Başarı vurgulanır, başarısızlık yargılanmaz. Örnek: "Zinciri kırdın" yerine "Yeniden başlamak için harika bir gün."
- Tarih ve saat biçimi Türkiye yerel ayarına göre (24 saat, gün.ay.yıl), ay ve gün adları Türkçe.
- Sayılar Türkçe biçimiyle gösterilir (örnek: 2.450 XP).

---

## 10. Tasarım–Kod Eşlemesi

| Tasarım öğesi | Kod konumu |
|---|---|
| Renk, tipografi, köşe, boşluk tokenları | `core/theme/` |
| Hap buton, kart, toggle, ilerleme halkası, zincir halkası, XP çipi | `core/widgets/` |
| Alt sekme çubuğu ve kabuklar | `app/shell/` |
| Ekranlar | `features/<özellik>/presentation/screens/` |
| Özelliğe özgü bileşenler (rozet kartı, çubuk grafik, takvim matrisi) | `features/<özellik>/presentation/widgets/` |

Bir bileşen ikinci bir özellikte de gerekirse `core/widgets/`'a taşınır.

---

## 11. Açık Noktalar

Tasarım ekibiyle netleştirilmesi gerekenler:
1. **Koyu tema paleti** tanımlı değil.
2. **Alışkanlık Ekle/Düzenle** ekranı ve **şifre sıfırlama** ekranları çizilmemiş.
3. **Zihin** kategorisinin rengi tanımsız (mor önerildi).
4. **Ana renklerin kontrastı** küçük metin için yetersiz (Bölüm 3); düzeltme yaklaşımı onaylanmalı.
5. **Davet** ve **bulut senkronizasyonu** özellikleri için ürün kararı gerekli (şu an yer tutucu).
6. Tasarımdaki **ünlü kişi atfı** (Marcus Aurelius) ile yapay zeka sözlerinin atıfsız gösterimi arasındaki fark.
7. **Tipografi ölçeği ve boşluk sistemi** tasarımda sayısal olarak verilmemiş (bu dosyada önerildi).