# Design Skill --- Material Design 3

## Amaç

Araç kiralama uygulamasında tutarlı, erişilebilir ve güven veren mobil
deneyim tasarla. Bu yönergeleri `PROJECT.md` ile birlikte uygula.

## Tasarım ilkeleri

-   Material Design 3 bileşenlerini ve Flutter tema sistemini temel al.
-   Önce küçük ekranlarda iOS ve Android kullanımını düşün; platforma
    özgü davranışları gerektiğinde koru.
-   Görsel öncelik açık olsun: araç fotoğrafı, fiyat, uygunluk, puan ve
    temel eylem ilk bakışta anlaşılabilsin.
-   Liste yoğunluğu ile okunabilirlik arasında denge kur; kartları
    gereksiz bilgiyle doldurma.
-   Tutarlı boşluk, tipografi, ikon, köşe yarıçapı ve renk tokenları
    kullan.
-   Marka renkleri onaylanana kadar renkleri ekranlara sabitleme; tema
    üzerinden yönet.

## Tema sistemi

-   `ThemeData` ve `ColorScheme` tabanlı Material 3 teması kullan.
-   Açık/koyu tema ve sistem temasını izleme davranışını merkezi yönet.
-   Bileşen görünümlerini `ThemeData` alt temaları üzerinden özelleştir.
-   Renkleri yalnızca anlam taşımak için kullan; durumlar sadece renkle
    anlatılmamalı.
-   Kontrastı ve metin ölçeklemesini kontrol et; metin boyutunu sabit
    piksel varsayımıyla kilitleme.

## App Icon Tasarımı

Ana renk kırmızı olsun. Modern, güçlü ve premium bir kırmızı tonu kullan.
Arka plan koyu bordo veya koyu kırmızı tonlarında olabilir.
İkonun merkezinde otomobil ve hareket hissini birleştiren özgün bir M harfi veya Movira monogramı bulunsun.
Tasarım modern, minimal, profesyonel ve kolay hatırlanabilir olsun.
Material Design 3 estetiğiyle uyumlu olsun.
İkon küçük boyutlarda da net ve ayırt edilebilir görünmeli.
Gereksiz detaylardan, kalabalık şekillerden ve hazır şablon hissinden kaçın.
Görsel kimlik, güvenilir ve modern bir araç kiralama platformunu temsil etmeli.
App icon içerisinde uygulama adı yazmak zorunlu değil; öncelik güçlü bir sembol oluşturmaktır. Uygulama adı arayüzde Movira olarak gösterilmelidir.

## İkon Dosyaları ve Entegrasyon

İkonun kaynak görselini ve gerekli platform boyutlarını projeye ekle.

Android launcher icon ve iOS App Icon yapılandırmalarını tamamla.

Mevcut proje yapısına uygun bir yöntem kullan; gerekiyorsa flutter_launcher_icons paketini değerlendir.

Android adaptive icon desteğini ve iOS ikon gereksinimlerini dikkate al.

İkonu yalnızca tasarım örneği olarak bırakma; gerçek uygulama ikonu olarak kullanılacak şekilde yapılandır.

## Ortak bileşenler

İhtiyaç duyuldukça yeniden kullanılabilir bileşenler oluştur: -
Birincil, ikincil, metin ve tehlike eylemi butonları - Form alanları ve
doğrulama mesajları - Araç ilanı kartı ve araç fotoğraf galerisi -
Filtre çipleri ve filtreleme paneli - Fiyat özeti ve kiralama tarih
aralığı görünümü - Yıldız puanı, ortalama puan ve yorum sayısı -
Teklif/kiralama durum etiketi - Boş durum, yükleniyor göstergesi, hata
paneli ve yeniden dene eylemi - Onay/uyarı diyalogları - Mesaj listesi
ve mesaj yazma alanı

Bileşen oluşturmak için gerçek tekrar veya tutarlı davranış ihtiyacı
olmalı; yalnızca soyutlama olsun diye tek kullanımlık widget'ları
genelleştirme.

## Ekran ve akış yönergeleri

### Keşfet / araç listesi

-   Arama, filtre ve sıralama erişilebilir olmalı.
-   Kartlarda fotoğraf, araç adı, temel özellikler, fiyat birimi ve puan
    gibi karar vermeyi sağlayan bilgiler gösterilebilir.
-   Filtrelerin etkin olduğu görünür olmalı; tümünü temizleme seçeneği
    sun.
-   Boş sonuçta filtreleri değiştirmeye yönelik öneri ver.

### Araç detay

-   Fotoğraf galerisi, araç özellikleri, fiyat, minimum kiralama süresi,
    uygunluk ve teslim koşullarını bölümlere ayır.
-   Araç sahibi/galeri bilgisi, puan ve yorum sayısı görünür olsun.
-   Soru sorma ve teklif verme eylemlerini net ayır.
-   Oturum gerektiren eylemlerde kullanıcıyı bağlamı koruyarak girişe
    yönlendir.

### İlan oluşturma/düzenleme

-   Uzun formları mantıklı bölümlere ayır; gerekirse adımlı form kullan.
-   Zorunlu alanları ve hata mesajlarını açık göster.
-   Fotoğraf seçimi, yükleme ilerlemesi, yeniden deneme ve kapak
    fotoğrafı seçimi anlaşılır olmalı.
-   Formdan ayrılırken kaydedilmemiş değişiklikler varsa uygun uyarı
    göster.

### Teklifler ve kiralamalar

-   Durum, tarih aralığı, teklif tutarı ve karşı taraf net görünmeli.
-   Yalnızca o durum için geçerli eylemleri göster.
-   Kabul/ret gibi önemli işlemlerde gerekiyorsa onay iste; sonuç
    durumunu güncelle.
-   Kabul edildi ifadesini ödeme tamamlandı veya kiralama kesinleşti
    anlamında kullanma; ürün akışına uygun metin seç.

### Mesajlaşma

-   Konuşmanın hangi ilana ait olduğu anlaşılmalı.
-   Gönderim durumu, hata ve tekrar dene davranışı tasarlanmalı.
-   Katılımcıların kimliği ve özel bilgiler gereğinden fazla
    gösterilmemeli.

### Yorum ve galeriler

-   Araç, araç sahibi ve galeri puanlarını birbirine karıştırma.
-   Yıldız sayısını metin veya erişilebilir etiketle de ifade et.
-   Yorumun hangi kiralamaya dayandığı ve yorum yapma uygunluğu iş
    kuralıyla uyumlu olmalı.

## Formlar ve validasyon

-   Her alan için uygun `keyboardType`, `textInputAction`, etiket ve
    yardımcı metin seç.
-   Hataları yalnızca snackbar veya diyalogla bildirme; mümkünse alanın
    yanında göster.
-   Alanlar arası odak sırasını ve gönderim sonrası ilk hatalı alana
    yönelmeyi düşün.
-   Gönderim sürerken yükleniyor göstergesi kullan ve tekrar gönderimi
    engelle.
-   Fiyat, tarih, telefon ve metin alanları için doğrulama kurallarını
    iş katmanıyla tutarlı tut.

## Diyaloglar ve snackbar

-   Diyalogları kısa, odaklı kararlar ve geri dönüşü zor işlemler için
    kullan.
-   Başlık, açıklama ve buton metinleri yapılacak sonucu açıkça ifade
    etsin.
-   Yıkıcı eylemlerde iptal seçeneği görünür olmalı.
-   Uzun form veya çok adımlı iş akışını dar bir diyaloga yerleştirme.
-   Snackbar kısa geri bildirim içindir; önemli veya kalıcı hatalarda
    ekranda daha kalıcı bir açıklama sun.

## Erişilebilirlik ve uyarlanabilirlik

-   Anlamlı ikonlara erişilebilir etiket ekle; yalnızca renge dayalı
    ayrım yapma.
-   Dokunma alanlarını yeterince büyük tut.
-   Küçük ekranlarda taşma, büyük yazı boyutunda kırpılma ve yatay
    kaydırma sorunlarını kontrol et.
-   Yüksek kontrast, ekran okuyucu ve semantik sıralamayı gözet.
-   Fotoğraflara uygun açıklama/alternatif metin sağla.
-   Farklı ekran boyutlarında ana eylemler erişilebilir kalmalı.

## Tasarım teslim kontrol listesi

-   [ ] Tema tokenları kullanılıyor; ekranlara rastgele renk
    sabitlenmemiş.
-   [ ] Yükleniyor, boş, hata ve başarı durumları tasarlandı.
-   [ ] Form alanları etiketli ve doğrulama mesajları anlaşılır.
-   [ ] Diyaloglar yalnızca gerektiği yerde kullanılıyor.
-   [ ] Yıldız, fiyat, tarih ve durumlar anlaşılır biçimde sunuluyor.
-   [ ] Büyük metin, ekran okuyucu ve dar ekran davranışı gözden
    geçirildi.
-   [ ] Aynı işlevdeki bileşenler ekranlar arasında tutarlı.
