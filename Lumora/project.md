# Lumora — Alışkanlık Takip Uygulaması

## 1. Amaç

İnsanların kitap okumak, su içmek, spor yapmak, erken uyumak gibi küçük ama faydalı alışkanlıklar kazanmasını ve motivasyonlarını kaybetmeden devam etmesini sağlamak.

Temel fikir **"zinciri kırma"**: Her gün tamamlanan alışkanlık zincire bir halka ekler; kullanıcı zinciri koparmamak için devam eder.

## 2. Kapsam (Özellikler)

### 2.1 Ana Ekran — "Bugün ne yaptın?"
- Karşılama mesajı ve günlük motivasyon sözü (Hugging Face API üzerinden)
- Bugünün alışkanlıklarını (kitap, erken uyuma, koşu vb.) listeleme ve işaretleme
- Yeni alışkanlık ekleme düğmesi
- Alt navigasyon

### 2.2 Alışkanlık Ekleme ve Düzenleme
- Hazır alışkanlık şablonları
- Alışkanlık adı ve ikonu
- Günlük hedef ve ölçü birimi
- Tekrarlanacak günleri seçme
- Hatırlatma saati
- Kaydetme, düzenleme ve silme

### 2.3 Takvim ve Geçmiş
- Aylık takvim görünümü
- Tamamlanan günleri görsel olarak işaretleme
- Gün seçildiğinde alışkanlık detaylarını gösterme
- Önceki günlerin sonuçlarını görüntüleme

### 2.4 İstatistikler
- Haftalık ve aylık başarı oranı
- En düzenli alışkanlık
- Mevcut ve en uzun seri
- Toplam tamamlanan günler
- Alışkanlık bazında ilerleme grafikleri

### 2.5 Profil ve Ayarlar
- Kullanıcı adı ve profil bilgileri
- Açık/koyu tema
- Bildirim tercihleri
- Haftanın ilk günü ve diğer yerel ayarlar
- Veri yönetimi ve uygulama bilgileri

## 3. Mimari: Feature-First

Kod, katmanlara göre değil **özelliklere göre** gruplanır. Her özellik kendi içinde bağımsızdır ve kendi katmanlarını (data / domain / presentation) barındırır. Birden fazla özelliğin kullandığı kod `core/` altında, uygulama başlangıcı `app/` altında yer alır.

```
lib/
├── app/                      # Uygulama kabuğu: başlangıç, router, tema, alt navigasyon
├── core/                     # Özellikler arası paylaşılan kod
│   ├── database/             # Yerel veritabanı kurulumu
│   ├── network/              # HTTP istemcisi
│   ├── notifications/        # Yerel bildirim servisi
│   ├── utils/                # Tarih, seri hesaplama vb. yardımcılar
│   └── widgets/              # Ortak UI bileşenleri
└── features/
    ├── auth/                 # Giriş, kayıt, şifre sıfırlama, misafir modu
    ├── home/                 # Ana ekran (Bugün)
    ├── quotes/               # Günün motivasyon sözü
    ├── habits/               # Alışkanlık ekleme, düzenleme, silme, şablonlar
    ├── calendar/             # Aylık takvim ve geçmiş
    ├── statistics/           # İstatistikler ve grafikler
    ├── badges/               # Rozetler ve seviyeler
    └── profile/              # Profil ve ayarlar
```

Her özellik klasörünün iç yapısı:

```
features/<feature>/
├── data/            # Veri kaynakları, modeller, repository uygulamaları
├── domain/          # Varlıklar (entity), repository arayüzleri, use case'ler
└── presentation/    # Ekranlar, widget'lar, durum yönetimi
```

### Mimari Kuralları
1. Bir özellik, başka bir özelliğin iç katmanlarına doğrudan erişmez; ortak ihtiyaç `core/` veya `domain` arayüzleri üzerinden karşılanır.
2. `presentation` → `domain` ← `data` yönünde bağımlılık (domain hiçbir katmana bağımlı değildir).
3. Paylaşılan kod yalnızca birden fazla özellik gerçekten kullanıyorsa `core/`'a taşınır.
4. Kullanıcı girişi ve tüm veriler şimdilik backend'de JSON dosyalarında saklanır; istemci çevrimdışıyken bugünün verisini yerel önbellekten gösterir. Ayrıntılar `architecture-skill.md` içindedir.

## 4. Veri Modeli (Genel Taslak)

- **Habit**: id, ad, ikon, günlük hedef, ölçü birimi, tekrar günleri, hatırlatma saati, oluşturulma tarihi
- **HabitLog**: habitId, tarih, tamamlanan miktar, tamamlandı mı
- **UserProfile**: kullanıcı adı, profil bilgileri
- **AppSettings**: tema, bildirim tercihleri, haftanın ilk günü, dil/bölge

## 5. Dış Servisler

- **Hugging Face API**: Ana ekrandaki günlük motivasyon sözünü üretmek için. İstek istemciden değil backend'den yapılır, sonuç günlük önbelleğe alınır. Hata olursa yerel yedek söz listesi gösterilir. API anahtarı koda gömülmez; ortam değişkeni ile verilir.

## 6. Genel İlkeler

- **Dil**: Arayüz Türkçe; yerelleştirmeye açık yapı.
- **Çevrimdışı öncelik**: Temel tüm işlevler internetsiz çalışır.
- **Tema**: Açık ve koyu tema desteği.
- **Gizlilik**: Kullanıcı verisi cihazda tutulur; dışa/içe aktarma ve silme imkânı sunulur.
- **Basitlik**: Bir alışkanlığı işaretlemek en fazla bir dokunuş olmalı.

## 7. Ekran Akışı (Alt Navigasyon)

| Sekme | Özellik |
|---|---|
| Bugün | `features/home` |
| Takvim | `features/calendar` |
| İstatistik | `features/statistics` |
| Profil | `features/profile` |

Alışkanlık ekleme/düzenleme (`features/habits`), ana ekrandaki "+" düğmesinden veya bir alışkanlığa dokunarak açılır.

## 8. Sonraki Adım

Ayrıntılar skill dosyalarındadır. Bu dosya yalnızca projenin genel çerçevesini tanımlar.

- `design-skill.md`: tasarım sistemi (Vital Momentum) ve ekran şartnameleri
- `architecture-skill.md`: teknik mimari, JSON veri saklama, kimlik doğrulama, Hugging Face motivasyon servisi, alan kuralları