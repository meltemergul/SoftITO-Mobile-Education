---
name: girisim360-general
description: Girişim360 Flutter projesinde görevleri analiz etmek, PROJECT.md kurallarını izlemek, uygun uzmanlık skill'lerini seçmek, güvenli ve doğrulanabilir değişiklikler yapmak ve işi raporlamak için genel ajan çalışma rehberi.
---

# Girişim360 — Genel Çalışma Skill'i

## 1. Amaç ve kapsam

Bu skill, Girişim360 projesinde çalışan ajanın genel çalışma yöntemini tanımlar. Tasarım kararlarının ayrıntılarını `design/SKILL.md`, mimari ve veri akışı kararlarının ayrıntılarını `architecture/SKILL.md` belirler.

Bu dosya, uzmanlık skill'lerinin yerine geçmez; görevleri doğru yönlendirir ve proje genelinde tutarlı bir iş akışı sağlar.

## 2. Talimat önceliği

Talimatlar çeliştiğinde şu sırayı uygula:

1. Sistem, güvenlik ve platform kuralları.
2. Kullanıcının bu görev için verdiği açık talimatlar.
3. Proje kökündeki `PROJECT.md`.
4. İlgili uzmanlık skill'leri.
5. Mevcut kod tabanı ve yerleşik proje örüntüleri.
6. Genel varsayımlar ve kişisel tercihler.

`PROJECT.md` veya kullanıcı talimatlarıyla çelişen bir uygulamayı sessizce seçme. Çatışma önemliyse kısa biçimde belirt ve netleştirme iste.

## 3. Her görevde izlenecek iş akışı

### Adım 1 — Bağlamı incele

- Proje kökünü ve kullanılan araçları belirle.
- `PROJECT.md` dosyasını oku; ilgili kuralları ve kabul kriterlerini çıkar.
- İlgili dosyaları, mevcut mimariyi, benzer özellikleri ve çalışma ağacındaki kullanıcı değişikliklerini incele.
- Kullanıcının yaptığı değişiklikleri izinsiz silme veya üzerine yazma.
- Dosya ya da proje bağlamı erişilebilir değilse erişimin varmış gibi davranma.

### Adım 2 — İsteği tanımla

- İstenen sonucu ve kapsamı kısa biçimde belirle.
- Görevi gerekli olduğunda alt işlere ayır.
- Belirsizlik sonucu, veri güvenliğini veya mimariyi ciddi biçimde etkiliyorsa soru sor.
- Küçük ve düşük riskli ayrıntılarda proje örüntülerine uygun, geri alınabilir varsayımlar yap ve gerektiğinde bunları belirt.
- Kullanıcı yalnızca analiz veya plan istediyse kodu değiştirmeye geçme.

### Adım 3 — Uygun skill'i seç

- **UI/UX, ekran düzeni, tema, tipografi, erişilebilirlik veya responsive davranış:** `design/SKILL.md`
- **Katmanlar, feature yapısı, state management, repository, API, veri modelleri, yönlendirme veya güvenlik sınırları:** `architecture/SKILL.md`
- **Hem arayüz hem yapısal değişiklik:** İki skill'i de uygula.
- **Genel bakım, hata düzeltme, test veya dokümantasyon:** Bu skill'i ve ilgiliyse uzmanlık skill'lerini kullan.

Bir skill'in varlığını veya aracın onu otomatik yüklediğini doğrulamadan otomatik keşif gerçekleştiğini iddia etme. Gerekli dosyaları doğrudan incele.

### Adım 4 — Önce planla, sonra uygula

- Görevle ilgili dosyaları ve olası yan etkileri belirle.
- En küçük, tutarlı ve sürdürülebilir değişikliği tercih et.
- Mevcut adlandırma, klasör yapısı, kod stili ve bağımlılık kararlarıyla uyumlu kal.
- İlgisiz dosyalarda düzenleme yapma.
- Yeni paket eklemeden önce mevcut bağımlılıkları ve yerleşik Flutter/Dart çözümlerini değerlendir. Yeni bağımlılığın neden gerekli olduğunu açıkla.
- Büyük kapsamlı değişikliklerde uygulamadan önce kısa bir plan sun.
- Kullanıcının açıkça istemediği kapsam genişletmelerinden kaçın.

### Adım 5 — Kalite ve güvenlik

- Kodun okunabilir, bakımı kolay ve tek bir sorumluluğa odaklı olmasını sağla.
- Uygun yerlerde hata durumlarını, yükleniyor ve boş durumları ele al.
- Hassas verileri, API anahtarlarını, parolaları veya erişim belirteçlerini kaynak koda ya da loglara koyma.
- Kimlik doğrulama, yetkilendirme ve kullanıcı girdilerini güvenilir kabul etme.
- Gerçek olmayan backend endpoint'leri, API yanıtları, test sonuçları veya ürün davranışları uydurma.
- Yeni iş mantığı için uygun birim/widget/integrasyon testleri ekle veya mevcut testleri güncelle.
- Kullanıcının isteği dışında gerçek sistemlerde geri döndürülemez işlemler yapma.

### Adım 6 — Değişikliği doğrula

Mümkün ve proje ortamında destekleniyorsa uygun kontrolleri çalıştır:

- `dart format` veya proje tarafından kullanılan biçimlendirme kontrolü
- `flutter analyze`
- İlgili birim ve widget testleri
- Etkilenen akışlar için gereken diğer kontroller

Yalnızca gerçekten çalıştırdığın kontrolleri başarılı olarak raporla. Çalıştırılamayan testleri, ortam kısıtlarını ve kalan riskleri açıkça belirt. Kontrol çalıştırılmadıysa sonucu doğrulanmış gibi sunma.

### Adım 7 — Sonucu raporla

Tamamlandığında kısa ve somut bir teslim özeti ver:

1. **Yapılanlar:** Eklenen veya değiştirilen davranışlar.
2. **Dosyalar:** Önemli dosya yolları.
3. **Mimari/tasarım kararları:** Yalnızca anlamlıysa.
4. **Doğrulama:** Çalıştırılan komutlar ve gerçek sonuçları.
5. **Eksikler ve riskler:** Tamamlanmayan işler veya doğrulanamayan noktalar.
6. **Sonraki adım:** Gerekiyorsa en yararlı devam işi.

Tamamlanmamış bir görevi tamamlandı olarak tanımlama.

## 4. Girişim360'a özgü ilkeler

- Uygulamanın temel dili Türkçedir; kullanıcıya görünen metinler tutarlı ve anlaşılır Türkçe olmalıdır.
- Mobil deneyim önceliklidir; web ve masaüstü desteğini etkileyen kararlar mevcut proje gereksinimleriyle uyumlu olmalıdır.
- Material 3, tema sistemi ve ortak bileşenleri yeniden kullan; aynı çözümü gereksiz yere çoğaltma.
- Feature-first klasör yapısını ve presentation/domain/data sorumluluk ayrımını koru.
- İş mantığını widget'lara veya veri erişimini doğrudan ekranlara yığma.
- Girişimci, mentor, iş planı, hukuki süreç, topluluk ve destek programları gibi alanlarda kullanıcı verilerinin gizliliğini gözet.
- Backend veya harici servis henüz mevcut değilse entegrasyon varmış gibi davranma; sınırları açıkça tanımla ve proje kararlarına uygun bir arayüz hazırla.
- Kullanıcı tarafından onaylanmamış ürün kapsamı, veri toplama veya izin davranışları ekleme.

## 5. Kaçınılması gereken davranışlar

- `PROJECT.md` dosyasını veya ilgili skill'i okumadan büyük değişikliklere başlamak.
- İhtiyaç olmadan mimariyi yeniden yazmak ya da çok sayıda dosyayı değiştirmek.
- Hata mesajlarını gizlemek, testleri kaldırarak sorunu çözülmüş göstermek veya analiz uyarılarını açıklamadan görmezden gelmek.
- Çalıştırılmamış testler için başarılı sonucu iddia etmek.
- Uydurma endpoint, veri, ekran, paket sürümü veya dosya yolu sunmak.
- Kullanıcı değişikliklerini izinsiz geri almak.
- Görevle ilgisiz refactor, stil değişikliği veya bağımlılık eklemek.

## 6. Son kontrol listesi

Görevi teslim etmeden önce kendine sor:

- [ ] `PROJECT.md` ve ilgili uzmanlık skill'leri dikkate alındı mı?
- [ ] Değişiklik, kullanıcının isteğinin sınırları içinde mi?
- [ ] Mevcut mimari ve kod stili korundu mu?
- [ ] Güvenlik, hata durumları ve kullanıcı verileri değerlendirildi mi?
- [ ] Uygun test veya analiz kontrolleri çalıştırıldı mı; çalıştırılamadıysa belirtildi mi?
- [ ] Sonuç, dosyalar ve kalan işler doğru şekilde raporlandı mı?
