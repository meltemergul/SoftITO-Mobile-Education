---
name: girisim360-design
description: Girişim360 Flutter uygulamasında ürün arayüzü, UX akışları, Material 3 tasarım sistemi, tema, responsive düzen ve erişilebilirlik üzerinde çalışırken kullanılır.
---

# Girişim360 Design Skill

## Amaç

Girişim360 için tutarlı, güven veren, erişilebilir ve üretime uygun bir kullanıcı deneyimi tasarla. Bu beceri; ekran tasarımı, mevcut arayüzü iyileştirme, tasarım sistemi kurma, kullanıcı akışları oluşturma ve görsel tutarlılık denetimlerinde uygulanır.

`PROJECT.md` proje genelindeki bağlayıcı kuralları tanımlar. Bu skill tasarım kararlarının nasıl alınacağını açıklar. Çelişki durumunda `PROJECT.md` ve mevcut çalışan uygulamanın doğrulanmış davranışları önceliklidir.

## Çalışmaya başlamadan önce

1. Mevcut dosyaları, ekranları, yönlendirmeyi, tema altyapısını ve bağımlılıkları incele.
2. Kullanılan Flutter/Dart sürümlerini ve mevcut tasarım yaklaşımını doğrula.
3. Çalışan ekranları ve kullanıcı akışlarını sebepsiz yere yeniden yazma.
4. İstenen değişikliğin kapsamını belirle; ilgisiz ekranları değiştirme.
5. Proje içinde zaten bulunan ortak widget ve tema token'larını yeniden kullan.

## Tasarım ilkeleri

- **Önce kullanıcı amacı:** Her ekranın tek bir ana amacı ve açık bir birincil eylemi olsun.
- **Güven ve açıklık:** Girişim, mentor, hukuk ve finans bilgilerini anlaşılır biçimde sun; demo veya doğrulanmamış bilgileri gerçekmiş gibi gösterme.
- **Sadelik:** Görsel süsleme yerine okunabilirlik, hiyerarşi ve işlevselliği tercih et.
- **Tutarlılık:** Aynı tür eylemler, durumlar, boşluklar ve bileşenler uygulama genelinde aynı davranmalı.
- **Mobil öncelik:** Önce küçük ekranlarda kullanılabilirliği sağla; sonra tablet, web ve masaüstüne uyumlandır.
- **Kademeli açıklama:** Karmaşık özellikleri anlaşılır adımlara ayır; gereksiz form alanlarından kaçın.
- **Durumları tasarla:** Yalnızca başarı görünümünü değil yükleniyor, boş, hata, çevrimdışı, devre dışı ve erişim reddedildi durumlarını da ele al.

## Görsel kimlik ve tema

Material 3 kullan. Renk, tipografi, şekil, boşluk ve bileşen stillerini merkezi tema katmanından yönet.

### Renk yaklaşımı

- Koyu tema: Dark Navy / Obsidian yüzeyler, elektrik mavisi ve turkuaz vurgu, yüksek kontrastlı metin.
- Açık tema: Beyaz ve açık gri yüzeyler, kurumsal mavi ve turkuaz vurgu, koyu lacivert metin.
- Renkleri ekranlarda gelişigüzel sabit kodlama. `ColorScheme`, `ThemeData` ve ortak token'ları kullan.
- Renk yalnız başına anlam taşımamalı; hata, başarı ve durumlar ikon/metin gibi ek işaretlerle de anlatılmalı.
- Kontrastı erişilebilirlik açısından kontrol et; dekoratif renklerin metin okunabilirliğini düşürmesine izin verme.

### Tipografi ve boşluk

- Tema üzerinden tanımlanan `TextTheme` stillerini kullan.
- Başlık, gövde, açıklama, etiket ve yardımcı metin arasında belirgin hiyerarşi kur.
- Tutarlı bir boşluk ölçeği kullan; her ekranda rastgele padding değerleri üretme.
- Metinlerin büyütülmesi durumunda taşma ve kesilmeyi kontrol et.
- Uzun Türkçe metinleri, tarihleri, para tutarlarını ve dar ekranlarda satır kırılmasını test et.

### Bileşenler

- Buton, kart, form alanı, durum etiketi, dialog, bottom sheet, liste öğesi ve navigasyon bileşenlerini tekrar kullanılabilir tasarla.
- Ortak bileşenleri yalnızca gerçek tekrar veya ortak davranış olduğunda çıkar; erken soyutlama yapma.
- Birincil, ikincil ve yıkıcı eylemleri görsel olarak ayırt et.
- Silme, belge paylaşma veya başvuru gönderme gibi önemli eylemlerde uygun onay ve geri bildirim kullan.
- Dokunma hedefleri rahat kullanılabilir boyutta olmalı; küçük ikonları tek başına kritik eylem olarak sunma.
- Material 3 bileşenlerini kullanırken ürünün tema sistemine uygun şekilde özelleştir.

## Ekran ve kullanıcı akışları

Her yeni ekran için şu soruları yanıtla:

1. Kullanıcı bu ekrana neden geldi?
2. Ekrandaki en önemli bilgi nedir?
3. Birincil eylem nedir?
4. Veri yoksa ne gösterilecek?
5. İşlem sürerken ne gösterilecek?
6. Hata olursa kullanıcı nasıl devam edecek?
7. Kullanıcı bu ekrana hangi yollardan gelir ve buradan nereye gider?
8. Erişim yetkisi yoksa ne olacak?

Formlarda alanları mantıklı gruplara ayır, doğrulama mesajlarını alanın yanında göster ve kullanıcı girişlerini hata sonrası koru. Gereksiz adımları azalt; uzun formları gerektiğinde aşamalara böl ve ilerlemeyi belirt.

## Girişim360'a özgü UX kuralları

- Girişim aşamalarını anlaşılır bir zaman çizelgesi veya aşama göstergesiyle sun: Fikir, Doğrulama, İş planı, MVP/prototip, Şirketleşme, Pazara çıkış, Büyüme.
- İlerleme yüzdesinin nasıl hesaplandığını kullanıcıya anlaşılır kıl; yüzdeyi rastgele üretme.
- Görevlerde sorumlu kişi, son tarih ve tamamlanma durumunu görünür kıl.
- Mentor eşleşmelerinde uyum puanının tahmini veya kural tabanlı olduğunu açıklayabilecek bir alan bırak; puanı kesin başarı garantisi gibi gösterme.
- Hukuki süreçlerde genel bilgilendirme ile profesyonel hukuki danışmanlığı ayırt et.
- Belge listelerinde hassas dosya içeriğini gereksiz yere önizleme veya herkese açık yüzeylerde gösterme.
- Yapay zekâ iş planı analizlerinde varsayımları, eksik verileri ve önerileri açıkça ayır.
- Destek programlarında son başvuru tarihi, uygunluk ve kaynağın güncelliğini öne çıkar; doğrulanmamış veya süresi geçmiş programları işaretle.
- Toplulukta şikâyet, engelleme ve gizlilik kontrollerini bulunabilir ve anlaşılır tut.

## Responsive tasarım

- Sabit genişlik ve yükseklikleri yalnızca gerekli olduğunda kullan.
- Dar ekranlarda yatay taşma, kesilen metin ve sıkışık kontrolleri önle.
- Geniş ekranlarda içerik genişliğini kontrol et; her şeyi uçtan uca yayma.
- Navigasyonu platform ve ekran genişliğine uygun seç; mobil alt navigasyonu masaüstüne aynen taşımak zorunda değilsin.
- Klavye açıldığında form alanlarının görünür kalmasını sağla.
- Yatay/dikey yön değişimi ve farklı pencere boyutlarında ekranı kontrol et.

## Erişilebilirlik

- Metin ölçeklendirmesini destekle; sabit boyutlar yüzünden içeriği kesme.
- Anlamlı ikonlar için erişilebilir etiketler sağla.
- Durumları yalnızca renk ile ifade etme.
- Klavye ile gezinme ve odak sırasını özellikle web/masaüstünde kontrol et.
- Animasyonları ölçülü kullan; bilgiye erişimi geciktiren hareketlerden kaçın.
- Form alanlarında görünür etiketler ve açık hata mesajları kullan.

## Uygulama kuralları

- Renkleri, metin stillerini ve bileşen görünümlerini ekran içine dağıtma; merkezi tema altyapısını kullan.
- Statik widget'larda uygun olduğunda `const` kullan.
- Uzun widget ağaçlarını anlamlı alt widget'lara ayır.
- UI içinde iş kuralları, finansal hesaplama veya veri erişimi yazma.
- Tasarım amacıyla gereksiz paket ekleme.
- Gerçek veri mevcut değilse açıkça demo olarak işaretlenmiş tutarlı örnek veriler kullan.
- Tasarım değişikliklerinde mevcut yönlendirme ve erişilebilirlik davranışlarını koru.

## Doğrulama kontrol listesi

Bir tasarım değişikliğini teslim etmeden önce:

- [ ] Açık, koyu ve sistem temasıyla uyumlu mu?
- [ ] Mobil ve geniş ekranlarda düzen bozuluyor mu?
- [ ] Yükleniyor, hata, boş veri ve başarı durumları ele alındı mı?
- [ ] Metin ölçeklendirmesi ve Türkçe metinler kontrol edildi mi?
- [ ] Birincil eylem açık ve anlaşılır mı?
- [ ] Form doğrulaması ve işlem geri bildirimi var mı?
- [ ] Hassas bilgi yanlışlıkla açıkta kalıyor mu?
- [ ] Mevcut ortak bileşenler ve tema token'ları kullanıldı mı?
- [ ] İlgili analiz ve testler çalıştırıldı mı?

Test çalıştırılmadıysa başarılı olduğu iddia edilmemeli. Teslim raporunda değiştirilen ekranlar, bilinen sorunlar ve yapılan doğrulamalar belirtilmeli.
