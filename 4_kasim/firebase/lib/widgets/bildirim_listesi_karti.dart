// Flutter'ın arayüz bileşenlerini kullanabilmek için Material kütüphanesini projeye dahil eder.
import 'package:flutter/material.dart';

// Bildirim bilgilerinin tutulduğu model sınıfını projeye dahil eder.
import '../models/bildirim_modeli.dart';

// Bildirimleri listeleyen kart tasarımını oluşturan StatelessWidget sınıfı.
class BildirimListesiKarti extends StatelessWidget {
  // Gelen bildirimleri liste halinde tutar.
  final List<BildirimModeli> bildirimler;

  // Cihazın Firebase Cloud Messaging (FCM) token bilgisini tutar.
  // String? olduğu için null değer alabilir.
  final String? token;

  // Kullanıcının bildirim konusuna abone olup olmadığını belirtir.
  final bool konuyaAboneMi;

  // Abonelik durumu değiştiğinde yeni değeri dışarıya iletir.
  final ValueChanged<bool> onAboneDegisti;

  // Sınıfın constructor metodu.
  // Dışarıdan gönderilmesi gereken değerleri zorunlu olarak alır.
  const BildirimListesiKarti({
    super.key,
    required this.bildirimler,
    required this.token,
    required this.konuyaAboneMi,
    required this.onAboneDegisti,
  });

  // Kartın ekranda nasıl görüneceğini belirleyen build metodu.
  @override
  Widget build(BuildContext context) {
    // Bildirim alanını bir Card içerisinde gösterir.
    return Card(
      elevation: 0, // Kartın gölgesini kaldırır.
      shape: RoundedRectangleBorder(
        // Kartın köşelerini yuvarlatır.
        borderRadius: BorderRadius.circular(16),

        // Kartın etrafına açık gri renkte bir kenarlık ekler.
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        // Kartın içeriğine her yönden 16 birim boşluk verir.
        padding: const EdgeInsets.all(16),

        // İçindeki bileşenleri dikey olarak sıralar.
        child: Column(
          // Bileşenleri yatayda mümkün olduğunca geniş alana yayar.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık ve abonelik anahtarının bulunduğu satır.
            Row(
              children: [
                // Bildirim simgesini gösterir.
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF006C4A),
                ),

                // Simge ile başlık arasına boşluk ekler.
                const SizedBox(width: 8),

                // Başlığın kalan alanı kaplamasını sağlar.
                const Expanded(
                  child: Text(
                    'FCM Bildirim Merkezi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(15, 231, 118, 38),
                    ),
                  ),
                ),

                // Kullanıcının bildirim konusuna abone olmasını veya abonelikten çıkmasını sağlar.
                Switch(
                  // Anahtarın açık veya kapalı olacağını belirler.
                  value: konuyaAboneMi,

                  // Anahtarın durumu değiştiğinde ilgili callback fonksiyonunu çalıştırır.
                  onChanged: onAboneDegisti,

                  activeColor: const Color.fromARGB(15, 160, 40, 50),
                ),
              ],
            ),

            // Abonelik durumuna göre kullanıcıya bilgilendirme mesajı gösterir.
            Text(
              konuyaAboneMi ? 'tüm sınıf yayını aktif' : 'yayın kapalı',
              style: TextStyle(
                fontSize: 12,

                // Abonelik açıksa farklı, kapalıysa gri renk kullanır.
                color: konuyaAboneMi
                    ? const Color.fromARGB(15, 24, 59, 17)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Durum yazısı ile token alanı arasına boşluk ekler.
            const SizedBox(height: 12),

            // Cihazın FCM token bilgisini göstermek için bir alan oluşturur.
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Token alanının arka plan rengini belirler.
                color: const Color(0XFF0F172A),

                // Alanın köşelerini yuvarlatır.
                borderRadius: BorderRadius.circular(8),
              ),

              // Token başlığını ve token bilgisini dikey sıralar.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Token alanının başlığını gösterir.
                  const Text(
                    "Cihazın FCM Tokeni",
                    style: TextStyle(
                      color: Color.fromARGB(255, 26, 40, 52),
                      fontSize: 11,
                    ),
                  ),

                  // Başlık ile token bilgisi arasına boşluk ekler.
                  const SizedBox(height: 2),

                  // Token bilgisinin kullanıcı tarafından seçilip kopyalanabilmesini sağlar.
                  SelectableText(
                    // Token henüz gelmediyse kullanıcıya bilgilendirme mesajı gösterir.
                    token ?? 'token alınıyor',
                    style: const TextStyle(
                      color: Color(0XFF388888),
                      fontSize: 11,

                      // Token bilgisini sabit genişlikli yazı tipiyle gösterir.
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            // Token alanı ile bildirim listesi arasına boşluk ekler.
            const SizedBox(height: 14),

            // Gelen bildirimlerin sayısını başlıkta gösterir.
            Text(
              'Gelen bildirimler ( ${bildirimler.length}):',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color.fromARGB(0, 5, 249, 253),
              ),
            ),

            // Başlık ile bildirim listesi arasına boşluk ekler.
            const SizedBox(height: 8),

            // Bildirim listesinde eleman olup olmadığını kontrol eder.
            // Liste boşsa boş mesajı, doluysa bildirim listesini gösterir.
            bildirimler.isEmpty
                // Henüz bildirim gelmediyse bu alan çalışır.
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: Text(
                      'henüz gelen bildirim yok',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                // Bildirim varsa liste halinde ekranda gösterir.
                : ListView.separated(
                    // Listenin kendi içeriği kadar yer kaplamasını sağlar.
                    shrinkWrap: true,

                    // Dışarıdaki kaydırma alanıyla çakışmaması için
                    // listenin kendi kaydırmasını kapatır.
                    physics: const NeverScrollableScrollPhysics(),

                    // Listede kaç bildirim olduğunu belirtir.
                    itemCount: bildirimler.length,

                    // Bildirimlerin arasına ince bir ayırıcı çizgi ekler.
                    separatorBuilder: (_, __) => const Divider(height: 1),

                    // Listedeki her bir bildirimin nasıl oluşturulacağını belirler.
                    itemBuilder: (context, index) {
                      // Herhangi bir bildirim öğesi henüz oluşturulmamış.
                      // Burada bildirimler[index] kullanılarak
                      // ilgili bildirimin bilgileri ekrana yazdırılabilir.
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
