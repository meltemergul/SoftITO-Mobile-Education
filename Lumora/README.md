# Lumora — Alışkanlık ve Rutin Takip Uygulaması

> **Tasarım Sistemi:** Vital Momentum  
> **Platformlar:** Mobil (iOS, Android), macOS Desktop, Web  
> **Mimari:** Clean Architecture & Feature-First (Flutter Riverpod) + Node.js / Express (TypeScript)  
> **Metodoloji:** Atomic Habits & "Don't Break the Chain" (Zinciri Kırma)

---

## 🌟 Proje Hakkında

Lumora; günlük mikro-rutinleri (su içme, kitap okuma, spor, meditasyon vb.) görselleştirerek pozitif bir istikrara dönüştüren modern bir alışkanlık ve zincir takip platformudur. 

- **Bugün Ekranı:** Tek dokunuşla hızlı alışkanlık tamamlama, sayaç ve zamanlı rutinler, günlük XP ve seri takibi, Hugging Face destekli günün ilham sözü.
- **Takvim (Isı Haritası):** Ay bazında zinciri kırma matrisi, tamamlanan ve kısmi gün ayrımı, gün detayları.
- **İstatistikler:** Genel başarı puanı, haftalık ivme, 7 günlük rutin çubuk grafiği, kategori dağılımı, en verimli saatler ve alışkanlık detay listesi.
- **Rozetler & Seviye:** 7 Gün Zincir, 14 Gün Demir İrade, Maraton Ruhu vb. otomatik hesaplanan başarım rozetleri, seviye kalkanı ve XP ilerleme çubuğu.
- **Profil & Ayarlar:** Kişisel bilgiler, akıllı bildirimler, sabah motivasyonu (08:00) ve akşam zincir kontrolü (21:30), su & kitap hedef yönetimi, tema seçimi (Sistem / Açık / Koyu), CSV ve JSON formatında veri dışa aktarımı, onaylı kalıcı hesap silme.

---

## 🛠️ Teknoloji Yığını

### Backend
- **Çalışma Zamanı & Dil:** Node.js (v20+), TypeScript (v5.7+)
- **Sunucu & Ağ:** Express.js, Helmet, CORS, Express-Rate-Limit
- **Doğrulama & Şema:** Zod
- **Şifreleme & Kimlik:** Bcrypt (cost 12), JWT (JsonWebToken)
- **Depolama:** JSONStore (atomik yazma, dosya kilidi/mutex, otomatik yedekleme)
- **Yapay Zekâ Entegrasyonu:** Hugging Face Inference API (Günün motivasyon sözleri)
- **Test & Kalite:** Vitest, ESLint, TypeScript Compiler (`tsc`)

### Frontend (Flutter Client)
- **Framework & Dil:** Flutter (v3.27+), Dart (v3.6+)
- **Durum Yönetimi:** Riverpod 2.x/3.x (`NotifierProvider`, `ConsumerWidget`)
- **Yönlendirme (Routing):** GoRouter (StatefulShellRoute tab navigasyonu ve Auth Guard)
- **Ağ İstemcisi:** Dio (Interceptors, Auth token yönetimi)
- **Güvenli Depolama:** FlutterSecureStorage (Keychain / Keystore)
- **Yerel Bildirimler:** FlutterLocalNotificationsPlugin & Timezone
- **Erişilebilirlik:** WCAG AA kontrast uyumu, min 48x48px dokunma hedefleri, Semantics etiketleri, renge ek sembol/ikon ilkeleri, "Hareketi Azalt" (Reduce Motion) desteği.

---

## ⚙️ Gereksinimler

1. **Flutter SDK:** 3.24 veya daha yenisi ([Kurulum Kılavuzu](https://flutter.dev/docs/get-started/install))
2. **Node.js:** v20.x veya daha yenisi ([Node.js İndir](https://nodejs.org/))
3. **npm:** v10.x veya daha yenisi

---

## 🔐 Ortam Değişkenleri (.env)

Backend dizininde bir `.env` dosyası oluşturulmalıdır. Örnek şablon `backend/.env.example` dosyasında yer almaktadır:

```bash
# backend/.env
PORT=3000
JWT_SECRET=super_secret_jwt_key_for_lumora_12345
HF_TOKEN=hf_your_huggingface_token_here
HF_MODEL=google/gemma-2-9b-it
HF_TIMEOUT_MS=8000
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173,http://127.0.0.1:3000
```

> **Güvenlik Notu:** `JWT_SECRET` ve `HF_TOKEN` değerleri kesinlikle versiyon kontrolüne (Git) eklenmez; `.gitignore` içerisinde korunmaktadır.

---

## 🚀 Projeyi Çalıştırma

### 1. Backend Sunucusunu Başlatma

```bash
# Backend klasörüne geçin
cd backend

# Bağımlılıkları yükleyin
npm install

# Geliştirme modunda başlatın (otomatik yeniden yükleme)
npm run dev

# veya Üretim derlemesi oluşturup çalıştırmak için:
npm run build
npm start
```
Sunucu varsayılan olarak `http://localhost:3000` adresinde çalışacaktır. Sağlık kontrolü için `http://localhost:3000/health` uç noktasına istek atabilirsiniz.

---

### 2. Flutter Uygulamasını Çalıştırma

Projenin kök dizininde:

```bash
# Bağımlılıkları indirin
flutter pub get

# Bağlı cihazları listeleyin
flutter devices

# Uygulamayı varsayılan hedefte çalıştırın
flutter run

# Veya belirli bir platformda çalıştırmak için:
flutter run -d macos      # macOS masaüstü uygulaması
flutter run -d chrome     # Web tarayıcısı
flutter run -d <cihaz_id> # Android / iOS emülatörü veya fiziksel cihaz
```

---

## 🧪 Test ve Kalite Kontrol Komutları

### Backend Testleri ve Statik Analiz

```bash
cd backend

# 1. TypeScript Tür Kontrolü
npx tsc --noEmit

# 2. ESLint Kod Analizi
npm run lint

# 3. Vitest Entegrasyon ve Birim Testleri
npm test
```
*Tüm test paketleri (Auth, Habits, Today, Quotes, Calendar, Stats, Badges, Profile, JSONStore, Domain Rules) 65/65 test başarımıyla çalışır.*

### Flutter Testleri ve Statik Analiz

Proje kök dizininde:

```bash
# 1. Flutter Statik Kod Analizi
flutter analyze

# 2. Tüm Birim ve Widget Testlerini Çalıştırma
flutter test

# Veya belirli bir özellik testini çalıştırmak için:
flutter test test/profile_test.dart
flutter test test/badges_test.dart
flutter test test/statistics_test.dart
flutter test test/habits_test.dart
flutter test test/calendar_test.dart
```
*Tüm 83 Flutter birim ve UI widget testi eksiksiz olarak geçer.*

---

## 🔒 Mimari ve Güvenlik Uyumu (Architecture Section 11)

| # | Güvenlik / Mimari Maddesi | Durum | Açıklama |
|---|---|:---:|---|
| 1 | Giriş verilerinin Zod ile doğrulanması | **GEÇTİ** | Tüm controller istek gövdesi ve parametreleri Zod şemaları ile doğrulanır. |
| 2 | Veri izolasyonu (`userId` kısıtlaması) | **GEÇTİ** | Tüm sorgular JWT'den çözülen `userId` ile sınırlandırılmıştır; yetkisiz veri erişimi engellenir. |
| 3 | CORS, Helmet ve Rate Limiting | **GEÇTİ** | Helmet devrededir, CORS izin verilen kaynaklarla sınırlandırılmıştır, auth ve genel uç noktalarda rate limit etkindir. |
| 4 | Loglarda hassas veri koruması | **GEÇTİ** | Sunucu loglarına şifre, token ve e-posta yazılmaz. |
| 5 | Kalıcı Hesap Silme & Veri Dışa Aktarımı | **GEÇTİ** | `DELETE /account` ile tüm kayıtlar kaskat silinir; `GET /export` ile CSV ve JSON çıktısı üretilir. |
| 6 | Gizli anahtarların env üzerinde tutulması | **GEÇTİ** | `HF_TOKEN`, `JWT_SECRET` yalnızca `.env` dosyasında saklanır; `.gitignore` ile dışlanır. |

---

## ♿ Erişilebilirlik ve Tasarım Standartları (Vital Momentum)

- **Dokunma Hedefleri:** Tüm interaktif bileşenler en az 48 × 48 px dokunma alanına sahiptir (`AppSpacing.minTouchTarget`).
- **Kontrast (WCAG AA):** Dolgulu butonlarda `primaryStrong` (#059669) zemin ve beyaz yazı (min 16px / 700) kullanılmıştır. Beyaz zemindeki küçük yeşil metinlerde `#047857` (5,5:1 kontrast) tercih edilmiştir.
- **Renge Ek Şekil / İkon:** Durumlar sadece renkle değil; onay işaretleri (`Icons.check_rounded`), noktalar, alev ikonları ve rozetlerle desteklenir.
- **Hareketi Azalt (Reduce Motion):** Sistem seviyesinde "Hareketi Azalt" (`disableAnimations`) açık olduğunda tüm geçiş animasyonları anında sıfır gecikmeyle hedef konuma oturur.
- **Dört Temel Durum:** Tüm ekranlarda `loading` (iskelet animasyonları), `data`, `empty` (yönlendirici buton ve açıklama) ve `error` (hata kartı ve "Tekrar Dene" butonu) durumları eksiksiz işlenir.
