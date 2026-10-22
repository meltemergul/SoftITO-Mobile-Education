# ARCHITECTURE SKILL — Lumora

> **Sürüm:** 1.0.0
> **Kapsam:** Teknik mimari, veri saklama, kimlik doğrulama, motivasyon sözü servisi, alan kuralları.
> **Görsel kimlik ve ekran şartnameleri:** `design-skill.md` (Vital Momentum tasarım sistemi). Bu dosya görsel kararları tekrar etmez.
> **Genel çerçeve:** `project.md`

---

## 1. Kararlar ve Varsayımlar

| Konu | Karar |
|---|---|
| Uygulama adı | **Lumora** |
| İstemci | Flutter (iOS & Android), Dart |
| Durum yönetimi | Riverpod |
| Backend | Node.js + Express (TypeScript) |
| Kalıcı veri | **JSON dosyaları** (veritabanı yok) |
| Kullanıcı girişi | E-posta + şifre, kullanıcılar `users.json` içinde |
| Motivasyon sözleri | Hugging Face Inference API (backend üzerinden) |
| Sosyal giriş | Google / Apple: yalnızca UI placeholder (Faz 2) |

> **Varsayım notu:** İstemci için Flutter, backend için Node/Express seçildi. Farklı bir yığın kullanılacaksa yalnızca Bölüm 2, 4 ve 5'teki araç isimleri değişir; katman ve sorumluluk ayrımı aynı kalır.

JSON dosya saklama **geçici bir çözümdür**. Mimari, ileride SQLite/PostgreSQL'e geçişin yalnızca repository uygulamasını değiştireceği şekilde kurulur (Bölüm 13).

---

## 2. Genel Mimari

```
┌────────────────────────┐        HTTPS / JSON        ┌─────────────────────────────┐
│  Flutter İstemci       │ ─────────────────────────► │  Express Backend            │
│  (feature-first)       │ ◄───────────────────────── │                             │
│                        │                            │  routes → controllers       │
│  presentation          │                            │     → services              │
│  domain                │                            │     → repositories          │
│  data (remote + local) │                            │     → JSON dosya deposu     │
└────────────────────────┘                            └───────┬──────────────┬──────┘
        ▲                                                     │              │
        │ yerel önbellek (oturum, bugünün verisi)             ▼              ▼
        │                                              data/*.json    Hugging Face API
```

İlkeler:
1. **İstemci Hugging Face'e doğrudan gitmez.** Token yalnızca backend'de durur; istemci `/quotes/daily` uç noktasını çağırır.
2. **Backend tek doğruluk kaynağıdır.** İstemci, çevrimdışıyken bugünün verisini yerel önbellekten gösterir ve işaretlemeleri kuyruğa alıp bağlantı gelince gönderir.
3. **Her katman yalnızca bir altındaki katmanı bilir.** Controller doğrudan dosyaya, servis HTTP'ye dokunmaz.
4. **Seri, XP ve seviye saklanmaz, loglardan hesaplanır** (Bölüm 9). Saklanan tek şey ham tamamlanma kayıtlarıdır.

---

## 3. İstemci: Feature-First Yapı

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # MaterialApp, tema bağlama
│   ├── router.dart               # go_router, auth guard
│   └── shell/                    # Alt sekme çubuğu (Bugün, Takvim, İstatistik, Rozetler, Profil)
├── core/
│   ├── theme/                    # Vital Momentum tokenları (renk, tipografi, radius)
│   ├── network/                  # Dio istemcisi, token interceptor, hata eşleme
│   ├── storage/                  # Güvenli oturum saklama, yerel önbellek
│   ├── utils/                    # Tarih/saat yardımcıları
│   └── widgets/                  # Ortak bileşenler (hap buton, kart, ilerleme halkası)
└── features/
    ├── auth/                     # Giriş, kayıt, şifre sıfırlama, misafir modu
    ├── home/                     # Bugün ekranı, günün ilerlemesi
    ├── quotes/                   # Günün ilhamı kartı (favori, paylaş)
    ├── habits/                   # Ekleme, düzenleme, silme, şablonlar, işaretleme
    ├── calendar/                 # Zincir matrisi, gün detayı
    ├── statistics/               # Başarı skoru, grafikler
    ├── badges/                   # Rozetler ve seviyeler
    └── profile/                  # Profil, ayarlar, veri dışa aktarma
```

Her özelliğin iç yapısı:

```
features/<feature>/
├── data/
│   ├── datasources/      # remote (API) ve local (önbellek) kaynaklar
│   ├── models/           # JSON ↔ model dönüşümü (fromJson / toJson)
│   └── repositories/     # Repository arayüzünün uygulaması
├── domain/
│   ├── entities/         # Saf Dart sınıfları, JSON bilmez
│   ├── repositories/     # Soyut arayüzler
│   └── usecases/         # Tek iş yapan sınıflar
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/        # Riverpod notifier'ları
```

Kurallar:
- Bağımlılık yönü: `presentation → domain ← data`. `domain` Flutter ve Dio'yu import etmez.
- Bir özellik başka bir özelliğin `data` veya `presentation` katmanına erişmez. Ortak ihtiyaç `core/` ya da ilgili `domain` arayüzü üzerinden çözülür. Örnek: `home` bugünün alışkanlıklarını `habits` özelliğinin domain use case'i ile alır.
- `core/`'a yalnızca en az iki özellik kullanıyorsa kod taşınır.
- Renk, font ve köşe yuvarlama değerleri yalnızca `core/theme` içinde tanımlanır; ekranlarda sabit renk kodu yazılmaz.

---

## 4. Backend Yapısı

```
backend/
├── src/
│   ├── server.ts
│   ├── config/               # Ortam değişkenleri (zod ile doğrulama)
│   ├── routes/               # auth, habits, logs, stats, badges, quotes, profile
│   ├── controllers/          # İstek/yanıt, giriş doğrulama
│   ├── services/             # İş kuralları (streak, xp, rozet, quote)
│   ├── repositories/         # Soyut arayüz + JSON uygulamaları
│   ├── storage/
│   │   └── jsonStore.ts      # Okuma/yazma, kilit, atomik yazma
│   ├── integrations/
│   │   └── huggingFace.ts    # HF istemcisi
│   ├── middleware/           # auth, hata yakalama, rate limit
│   └── domain/               # Tipler, sabitler (XP tablosu, rozet tanımları)
├── data/                     # Çalışma verisi (git'e eklenmez)
│   ├── users.json
│   ├── habits.json
│   ├── habit_logs.json
│   ├── user_settings.json
│   ├── favorites.json
│   └── quotes_cache.json
├── seed/
│   └── fallback_quotes.json  # Elle hazırlanmış yedek sözler (git'e eklenir)
└── .env.example
```

---

## 5. JSON Depolama Kuralları

### 5.1 Dosya şemaları

**`users.json`**
```json
[
  {
    "id": "usr_8f3a",
    "email": "selin@example.com",
    "passwordHash": "$2b$12$...",
    "displayName": "Selin Yılmaz",
    "username": "selin",
    "avatarUrl": null,
    "isGuest": false,
    "createdAt": "2026-10-22T13:05:00.000Z"
  }
]
```

**`habits.json`**
```json
[
  {
    "id": "hbt_21c9",
    "userId": "usr_8f3a",
    "name": "Su İçme",
    "icon": "water_drop",
    "category": "water",
    "unit": "ml",
    "dailyGoal": 2500,
    "step": 250,
    "repeatDays": [1, 2, 3, 4, 5, 6, 7],
    "reminderTime": "10:00",
    "archived": false,
    "createdAt": "2026-10-22T13:10:00.000Z"
  }
]
```
`category`: `water | book | sport | mind | custom`. `repeatDays`: 1 = Pazartesi … 7 = Pazar. `step`: sayaç türü alışkanlıklarda tek dokunuşta eklenen miktar. Silme işlemi `archived: true` yapar, geçmiş loglar korunur.

**`habit_logs.json`**
```json
[
  {
    "id": "log_77d1",
    "userId": "usr_8f3a",
    "habitId": "hbt_21c9",
    "date": "2026-10-22",
    "amount": 2000,
    "completed": false,
    "updatedAt": "2026-10-22T14:30:00.000Z"
  }
]
```
Bir alışkanlık için günde **tek kayıt** vardır (`userId + habitId + date` benzersiz). `date`, kullanıcının yerel gününe göre `YYYY-MM-DD` biçimindedir. `completed`, `amount >= dailyGoal` olduğunda servis tarafından `true` yapılır.

**`user_settings.json`**
```json
[
  {
    "userId": "usr_8f3a",
    "theme": "system",
    "weekStartsOn": 1,
    "timezone": "Europe/Istanbul",
    "notifications": {
      "smart": true,
      "morningMotivation": { "enabled": true, "time": "08:00" },
      "eveningChainCheck": { "enabled": true, "time": "21:30" },
      "soundAndHaptics": true
    },
    "streakFreezeCount": 2
  }
]
```

**`favorites.json`**: `{ "userId", "quoteId", "createdAt" }` kayıtları.

**`quotes_cache.json`**: Bölüm 7'de.

### 5.2 `jsonStore` sözleşmesi

Tüm dosya erişimi `jsonStore` üzerinden yapılır; servisler ve controller'lar `fs` kullanmaz.

1. **Atomik yazma:** Önce `dosya.tmp`'ye yazılır, sonra `rename` ile asıl dosyanın yerine geçirilir. Yazma sırasında çökme dosyayı bozmaz.
2. **Dosya başına yazma kuyruğu (mutex):** Aynı dosyaya eşzamanlı yazmalar sırayla işlenir. Oku-değiştir-yaz döngüsü kuyruk içinde tamamlanır; böylece güncellemeler birbirini ezmez.
3. **Bellek önbelleği:** Dosya açılışta okunur, bellekte tutulur, her yazmada diske yansıtılır.
4. **Şema doğrulama:** Okuma ve yazmada zod şemasıyla doğrulanır. Bozuk dosya tespit edilirse sunucu başlamaz ve `dosya.bak` yedeği öneren net bir hata verir.
5. **Yedek:** Her günün ilk yazmasında `data/backup/<tarih>/` altına kopya alınır, son 7 gün tutulur.
6. **Tek süreç:** JSON depolama yalnızca tek backend sürecinde güvenlidir. Birden fazla örnek çalıştırılacaksa veritabanına geçilmelidir.

### 5.3 Repository arayüzü

Servisler yalnızca arayüzü bilir:

```ts
interface HabitRepository {
  listByUser(userId: string): Promise<Habit[]>;
  getById(userId: string, id: string): Promise<Habit | null>;
  create(userId: string, input: NewHabit): Promise<Habit>;
  update(userId: string, id: string, patch: Partial<Habit>): Promise<Habit>;
  archive(userId: string, id: string): Promise<void>;
}
```
`JsonHabitRepository` bu arayüzü uygular. Diğer varlıklar için de aynı yaklaşım izlenir. Her sorgu `userId` ile sınırlanır; bir kullanıcı başkasının kaydına hiçbir koşulda erişemez.

---

## 6. Kimlik Doğrulama (Faz 1)

**Akış**
1. `POST /auth/register`: e-posta, şifre, görünen ad alır. E-posta küçük harfe çevrilip benzersizlik kontrol edilir.
2. `POST /auth/login`: e-posta ve şifre doğrulanır, JWT döner.
3. `POST /auth/guest`: misafir kullanıcı (`isGuest: true`) oluşturur. Misafir verisi aynı yapıda saklanır; kayıt olunduğunda `POST /auth/upgrade` ile aynı `userId` hesaba dönüştürülür ve veri kaybolmaz.
4. `POST /auth/forgot-password`: tek kullanımlık sıfırlama kodu üretir (30 dk geçerli, hash'i saklanır). E-posta servisi henüz yoktur; geliştirme ortamında kod sunucu loguna yazılır. Yanıt, e-postanın kayıtlı olup olmadığını **belli etmez**.
5. `POST /auth/reset-password`: kod ve yeni şifre ile şifreyi değiştirir.

**Kurallar**
- Şifre **bcrypt** (maliyet ≥ 12) ile hash'lenir. Düz şifre hiçbir yerde saklanmaz ve loglanmaz.
- Şifre en az 8 karakter olmalıdır.
- JWT süresi 7 gün, `JWT_SECRET` ortam değişkeninden gelir. İstemci token'ı **güvenli depolamada** (Keychain/Keystore) tutar, düz `SharedPreferences`'ta değil.
- Giriş ve şifre sıfırlama uç noktalarına IP başına rate limit uygulanır (ör. 10 istek / 15 dk).
- "Beni hatırla" kapalıysa token yalnızca oturum boyunca bellekte tutulur.
- Hata mesajları kullanıcı numaralandırmayı önler: yanlış e-posta ve yanlış şifre aynı mesajı verir.
- Google ve Apple butonları UI'da görünür ama "Yakında" durumunda pasiftir. Faz 2'de Firebase Auth veya Supabase Auth ile bağlanacağı için `AuthRepository` arayüzü sağlayıcıdan bağımsız tutulur.

> **Güvenlik uyarısı:** JSON dosyasında şifre hash'i tutmak, veritabanında tutmaktan daha zayıf bir koruma sağlamaz ama dosya izinleri kritiktir. `data/` klasörü yalnızca backend sürecinin okuyabileceği izinlerle çalışmalı ve asla bir statik dosya yolu olarak servis edilmemelidir.

---

## 7. Motivasyon Sözleri (Hugging Face)

### 7.1 Akış

```
İstemci ──GET /quotes/daily──► QuoteService
                                  │
        bugünün sözü cache'te mi? ├─ evet ─► döndür
                                  │
                                  └─ hayır ─► HF çağrısı (toplu 10 söz)
                                               ├─ başarılı ─► doğrula, cache'e yaz, döndür
                                               └─ hata/zaman aşımı ─► seed/fallback_quotes.json'dan seç
```

### 7.2 Hugging Face istemcisi

- Uç nokta: Hugging Face **Inference Providers**'ın OpenAI uyumlu sohbet arayüzü (`https://router.huggingface.co/v1/chat/completions`).
- Ortam değişkenleri: `HF_TOKEN`, `HF_MODEL` (model adı koda gömülmez), `HF_TIMEOUT_MS` (varsayılan 8000).
- Model ve uç nokta ayrıntıları değişebilir; uygulama sırasında güncel Hugging Face dokümantasyonundan doğrulanmalıdır.
- İstek, modelden **yalnızca JSON dizisi** döndürmesini ister:

```
Türkçe, 1-2 cümlelik, alışkanlık kazanmayı ve istikrarı teşvik eden
10 özgün motivasyon sözü üret. Gerçek kişilere atıf yapma.
Yalnızca şu biçimde JSON dizisi döndür: [{"text": "..."}]
```

- Yanıt parse edilir; her söz şu kontrollerden geçer: boş değil, 10–200 karakter, tekrar değil, küfür/yasaklı içerik filtresine takılmıyor. Geçmeyen sözler atılır.
- Başarısız çağrı **en fazla bir kez** yeniden denenir; sonra yedeğe düşülür. İstemciye hata dönmez.

### 7.3 Önbellek (`quotes_cache.json`)

```json
{
  "generatedAt": "2026-10-22",
  "language": "tr",
  "quotes": [
    { "id": "q_a1", "text": "...", "author": null, "source": "ai" }
  ]
}
```

- Günde en fazla **bir** HF çağrısı yapılır; 10 söz üretilip önbelleğe alınır. Kullanıcıya günün sözü, tarih ve `userId`'den deterministik seçilir (aynı gün aynı kullanıcı hep aynı sözü görür).
- Aynı anda gelen birçok isteğin HF'i tekrar tekrar çağırmasını önlemek için üretim tek bir "in-flight" promise ile paylaşılır.

### 7.4 Kaynak gösterimi kuralı

Tasarım örneğinde alıntı bir tarihî kişiye atfedilmiş (ör. Marcus Aurelius). **Yapay zeka modelleri alıntıları ve atıfları uydurabilir.** Bu yüzden:

- HF'ten gelen sözlerde `author` her zaman `null`'dır ve kartta yazar yerine "Lumora" ya da atıfsız gösterim kullanılır.
- Yazar gösterimi yalnızca elle doğrulanmış `seed/fallback_quotes.json` içindeki sözlerde yapılır.

### 7.5 Uç noktalar

| Metot | Yol | Açıklama |
|---|---|---|
| GET | `/quotes/daily` | Günün sözü |
| POST | `/quotes/:id/favorite` | Favoriye ekle |
| DELETE | `/quotes/:id/favorite` | Favoriden çıkar |

Paylaşma işlemi istemcide, sistem paylaşım menüsüyle yapılır; backend gerekmez.

---

## 8. API Özeti

Tüm uç noktalar (auth hariç) `Authorization: Bearer <token>` ister. Yanıtlar JSON'dur; hatalar `{ "error": { "code": "...", "message": "..." } }` biçimindedir.

| Alan | Uç noktalar |
|---|---|
| Auth | `POST /auth/register`, `/auth/login`, `/auth/guest`, `/auth/upgrade`, `/auth/forgot-password`, `/auth/reset-password` |
| Alışkanlıklar | `GET /habits`, `POST /habits`, `PATCH /habits/:id`, `DELETE /habits/:id`, `GET /habit-templates` |
| Bugün / loglar | `GET /today`, `PUT /habits/:id/logs/:date` (`{ amount }` veya `{ delta }`), `GET /logs?from=&to=` |
| Takvim | `GET /calendar?month=YYYY-MM`, `GET /calendar/day/:date` |
| İstatistik | `GET /stats?range=weekly|monthly|all` |
| Rozetler | `GET /badges`, `GET /level` |
| Profil | `GET /profile`, `PATCH /profile`, `GET /settings`, `PATCH /settings` |
| Veri | `GET /export?format=csv|json`, `DELETE /account` |

Hazır alışkanlık şablonları (kitap, su, koşu, erken uyuma, meditasyon vb.) sunucuda sabit bir listedir; kullanıcı verisi değildir.

---

## 9. Alan Kuralları (Domain)

Bu kuralların tamamı backend `services/` içinde, **saf fonksiyonlar** olarak yazılır ve birim testle korunur.

**Planlı gün:** Bir alışkanlık yalnızca `repeatDays` içindeki günlerde "planlıdır". Planlı olmayan günler seriyi **bozmaz** ve atlanır.

**Zincir (streak):**
- Bir gün, planlı ve `completed = true` ise zincire halka ekler.
- Mevcut seri: bugünden (bugün henüz tamamlanmadıysa dünden) geriye, kesintisiz tamamlanan planlı günlerin sayısıdır. Bugün henüz bitmediği için tamamlanmamış olması seriyi bozmaz.
- Planlı bir gün tamamlanmadan geçerse seri sıfırlanır; **dondurma hakkı** varsa o gün sayılmış kabul edilir ve hak bir azalır.
- En uzun seri tüm geçmiş loglardan hesaplanır.

**Tamamlanma:** Sayaç türü alışkanlıkta `amount >= dailyGoal` olduğunda `completed = true`. `delta` ile azaltma desteklenir ve `amount` 0'ın altına inmez. İşaretleme türü alışkanlıkta (hedef 1) tek dokunuş yeterlidir ve geri alınabilir.

**Günün ilerlemesi:** `tamamlanan planlı alışkanlık / bugünkü planlı alışkanlık`. Günün tüm görevleri bittiğinde "Gün Sonu Serisi" bonusu bir kez tetiklenir.

**XP ve seviye:**
- Bir alışkanlığın ilk kez tamamlanması +15 XP verir (sabit `domain/constants.ts` içinde).
- Tamamlamayı geri almak o günün XP'sini düşer; **aynı gün aynı alışkanlık tekrar tamamlanıp geri alınarak XP üretilemez** (XP, `completed` log sayısından hesaplandığı için kendiliğinden korunur).
- Toplam XP = tamamlanmış log sayısı × alışkanlık XP değeri + bonuslar. Seviye eşikleri sabit bir tabloda tutulur.

**Rozetler:** Tanımlar kodda sabittir (ör. 7 Gün Zincir, 14 Gün Demir İrade, Kitap Kurdu, Su Pınarı). Her rozetin bir `koşul(loglar) → ilerleme` fonksiyonu vardır; açılma tarihi ilk koşulun sağlandığı günden hesaplanır, ayrıca saklanmaz.

**İstatistik:** Başarı oranı = tamamlanan planlı gün / toplam planlı gün (seçili aralıkta). "En düzenli alışkanlık", aralıktaki en yüksek başarı oranına sahip alışkanlıktır; eşitlikte daha uzun mevcut seri kazanır.

**Saat dilimi:** "Gün" sınırı kullanıcının `timezone` ayarına göre belirlenir. Sunucu saati kullanılmaz.

---

## 10. İstemci Davranışı

- **Offline-first (bugün ekranı):** Son başarılı `/today` yanıtı yerel olarak saklanır. Bağlantı yokken işaretlemeler yerelde uygulanır ve `pendingOps` kuyruğuna eklenir; bağlantı gelince sırayla gönderilir. Çakışmada sunucu yanıtı geçerlidir.
- **Optimistic UI:** İşaretleme dokunuşu anında yansır, hata olursa geri alınır ve kısa bir hata mesajı gösterilir.
- **Yükleme ve hata durumları:** Her ekran `loading / data / empty / error` durumlarını açıkça işler. Boş durumlarda (alışkanlık yok, veri yok) yönlendirici metin ve "Yeni Alışkanlık" eylemi gösterilir.
- **Bildirimler:** Hatırlatma saatleri cihazda yerel bildirim olarak planlanır (sunucu push'u yok). Alışkanlık veya ayar değişince bildirimler yeniden planlanır. 21:30 zincir kontrolü, o gün tamamlanmamış planlı alışkanlık varsa gösterilir.
- **Misafir modu:** Misafir kullanıcıya "hesap oluştur" teşviki kibarca gösterilir, zorlanmaz.

---

## 11. Güvenlik ve Gizlilik

- Tüm giriş verisi controller'da zod ile doğrulanır.
- Her sorgu oturumdaki `userId` ile sınırlanır; ID tahmin ederek başkasının verisine erişim mümkün olmamalıdır.
- CORS yalnızca bilinen kaynaklara açılır, `helmet` ve rate limit etkindir.
- Loglara şifre, token ve e-posta yazılmaz.
- `DELETE /account` kullanıcının tüm kayıtlarını (kullanıcı, alışkanlık, log, ayar, favori) kalıcı siler. `GET /export` kullanıcının kendi verisini CSV/JSON verir.
- `HF_TOKEN`, `JWT_SECRET` yalnızca ortam değişkenlerinde durur, repoya eklenmez. `.env.example` yalnızca anahtar adlarını içerir.

---

## 12. Test ve Kalite

- **Birim testi (zorunlu):** streak, dondurma, tamamlanma, XP, rozet ve istatistik hesapları; sınır durumları (ay/yıl geçişi, saat dilimi, planlı olmayan günler).
- **Entegrasyon testi:** auth akışı, log güncelleme, `jsonStore` eşzamanlı yazma ve çökme senaryosu.
- **HF servisi:** Gerçek ağ çağrısı yapılmaz; sahte istemci ile başarılı, hatalı, bozuk JSON ve zaman aşımı yolları test edilir.
- **İstemci:** Use case ve notifier birim testleri; ana ekran ve alışkanlık formu için widget testleri.
- Statik analiz (`flutter analyze`, `eslint`, `tsc --noEmit`) birleştirme öncesi temiz olmalıdır.

---

## 13. JSON'dan Veritabanına Geçiş Yolu

1. Servisler yalnızca repository arayüzlerine bağımlı olduğu için `Json*Repository` yerine `Sqlite*Repository` yazmak yeterlidir.
2. Dosya şemaları tablo şemalarının birebir karşılığıdır (`userId + habitId + date` benzersiz anahtar dahil).
3. Tek seferlik bir betik JSON dosyalarını tablolara aktarır.
4. Geçişten önce çoklu süreç gereksinimi, kullanıcı sayısı ve dosya boyutu (`habit_logs.json` hızla büyür) değerlendirilmelidir.

---

## 14. Uygulama Sırası (Önerilen)

1. Backend iskeleti, `jsonStore`, config, hata yönetimi
2. Auth (kayıt, giriş, misafir, şifre sıfırlama) ve istemci auth ekranları
3. Alışkanlık CRUD + şablonlar
4. Bugün ekranı + log güncelleme + streak/XP servisleri
5. Quotes servisi (önce yedek liste, sonra Hugging Face bağlantısı)
6. Takvim
7. İstatistikler
8. Rozetler ve seviyeler
9. Profil, ayarlar, bildirimler, veri dışa aktarma ve hesap silme
10. Cilalama: boş/hata durumları, erişilebilirlik, performans