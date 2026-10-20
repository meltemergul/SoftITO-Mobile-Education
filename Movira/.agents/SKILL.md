# General Engineering Skill

## Amaç

Araç kiralama platformunda tüm görevlerde ortak kalite, iletişim ve
çalışma kurallarını uygula. Bu skill, `PROJECT.md` ve ilgili şu kaynaklarla
birlikte bağlayıcı olarak kullanılır:
- **Tasarım Yönergeleri:** [.agents/skills/design/SKILL.md](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/design/SKILL.md)
- **Mimari İlkeleri:** [.agents/skills/architecture/SKILL.md](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/architecture/SKILL.md)
- **Durum Yönetimi ve Veri Akışı Kılavuzu:** [.agents/skills/references/state_flow.md](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/references/state_flow.md)
- **Referans Ekran Uygulaması:** [.agents/skills/examples/sample_screen.dart](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/examples/sample_screen.dart)
- **Modül ve Katman Üretici Betiği:** [.agents/skills/scripts/generate_feautre.sh](file:///Users/d1-1/Documents/GitHub/SoftITO-Mobile-Education/Movira/.agents/skills/scripts/generate_feautre.sh)

## İşe başlamadan önce

1.  İlgili `PROJECT.md`, `pubspec.yaml`, kaynak dosyalar, testler ve git
    değişikliklerini incele.
2.  İstenen işi ve kabul ölçütlerini belirle; kapsam dışı işleri ekleme.
3.  Mevcut mimariyi, kod stilini ve bağımlılıkları koru. Depoyu
    incelemeden dosya veya paket varmış gibi davranma.
4.  Gereksinimlerde çelişki varsa en küçük güvenli adımı seç ve
    belirsizliği açıkça belirt.

## Uygulama kuralları

-   Küçük, anlaşılır ve gözden geçirilebilir değişiklikler yap.
-   Dart null safety kullan; `dynamic`, zorlayıcı `!` ve gereksiz `late`
    kullanımından kaçın.
-   Kullanıcıya görünen metinleri Türkçe ve tutarlı yaz; yerelleştirme
    altyapısı varsa ona uy.
-   Yükleniyor, boş, hata, başarı ve tekrar dene durumlarını gereken
    yerlerde ele al.
-   İş mantığını widget içine yığma; sorumlulukları ayır.
-   Gizli anahtar, kişisel veri veya erişim belirteci ekleme/loglama.
-   Ağ hatalarını kullanıcıya anlaşılır sun; teknik ayrıntıları güvenli
    biçimde kaydet.
-   Sahte veri kullanılıyorsa demo/mock olduğu açıkça belli olsun;
    üretim entegrasyonu gibi gösterme.
-   İlgisiz dosyaları yeniden biçimlendirme veya değiştirme.

## Formlar ve etkileşimler

-   Form doğrulaması kullanıcı deneyimini iyileştirir; güvenlik
    açısından sunucu doğrulaması yine gerekir.
-   Hata mesajı ilgili alanın yakınında, anlaşılır ve eyleme dönük
    olmalı.
-   Butonlar yüklenirken çift gönderimi engellemeli ve uygun durumda
    devre dışı kalmalı.
-   Geri dönüşü zor işlemlerde onay diyaloğu kullan; her küçük işlem
    için diyalog açma.
-   Ekran okuyucu, klavye/odak sırası, metin ölçekleme ve kontrastı
    gözet.

## Güvenlik ve iş kuralları

-   İlan sahipliği, teklif katılımcılığı, mesaj erişimi ve yorum
    uygunluğu gibi kuralların sunucuda doğrulanması gerektiğini unutma.
-   Tarih aralıkları, saat dilimi, para birimi ve eşzamanlı
    güncellemeleri dikkatle ele al.
-   Tamamlanmamış kiralama için yorum bırakılmasını istemci ve sunucu
    akışında engelleyecek gereksinimi koru.

## Doğrulama

Mümkünse görev sonunda: 1. `dart format` (değişen Dart dosyaları için)
2. `flutter analyze` 3. İlgili unit/widget testleri 4. Etkilenen kritik
akışların testleri

Komutları çalıştırmadıysan çalıştırılmış gibi söyleme. Başarısızlıkları
ve ortam kaynaklı engelleri raporla.

## Teslim özeti

-   Yapılan değişiklikler
-   Etkilenen dosyalar
-   Çalıştırılan kontroller ve sonuçları
-   Bilinen eksikler / ürün kararları
