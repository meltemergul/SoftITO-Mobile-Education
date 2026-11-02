// Flutter'ın Material tasarım bileşenlerini kullanabilmek için kütüphaneyi içe aktarıyoruz.
import 'package:flutter/material.dart';

// Kategorilerin bilgilerini (isim, renk, ikon) tuttuğumuz model sınıfını içe aktarıyoruz.
import '../models/category_model.dart';

// Kategorileri ekranda gösterecek sayfamızı oluşturuyoruz.
// StatelessWidget kullanıyoruz çünkü bu ekranda değişen bir state yönetmiyoruz.
// Ekran, CategoryModel içerisinde bulunan hazır kategori listesini gösteriyor.
class CategoriesScreen extends StatelessWidget {
  // Constructor (kurucu metot).
  // const kullanarak widget'ın mümkün olduğunda sabit oluşturulmasını sağlıyoruz.
  // super.key ile üst sınıf olan StatelessWidget'ın key parametresini iletiyoruz.
  const CategoriesScreen({super.key});

  // Widget'ın ekranda nasıl görüneceğini belirleyen build metodunu override ediyoruz.
  // context, widget'ın uygulama içerisindeki konumu ve tema gibi bilgilere erişmemizi sağlar.
  @override
  Widget build(BuildContext context) {
    // CategoryModel içerisindeki statik categories listesini alıyoruz.
    // Böylece kategorileri burada tekrar tek tek yazmak zorunda kalmıyoruz.
    final categories = CategoryModel.categories;

    // GridView.builder ile kategorileri ızgara (grid) şeklinde listeliyoruz.
    // builder kullanmamızın sebebi, öğelerin ihtiyaç duyuldukça oluşturulmasıdır.
    return GridView.builder(
      // GridView'in çevresine her yönden 20 piksel boşluk bırakıyoruz.
      padding: const EdgeInsets.all(20),

      // Listede kaç kategori varsa o kadar kutu oluşturulmasını sağlıyoruz.
      // length listenin eleman sayısını verir.
      itemCount: categories.length,

      // Grid yapısının kaç sütundan oluşacağını ve aralıklarını belirliyoruz.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // Ekranda yan yana 2 kategori kutusu gösteriyoruz.
        crossAxisCount: 2,

        // Yan yana bulunan kutular arasındaki yatay boşluğu belirliyoruz.
        crossAxisSpacing: 14,

        // Alt alta bulunan satırlar arasındaki dikey boşluğu belirliyoruz.
        mainAxisSpacing: 14,

        // Her kategori kutusunun yüksekliğini 150 piksel olarak ayarlıyoruz.
        mainAxisExtent: 150,
      ),

      // Her kategori kutusunun nasıl oluşturulacağını belirliyoruz.
      // context widget'ın bulunduğu ortamı, index ise listedeki elemanın sırasını belirtir.
      itemBuilder: (context, index) {
        // O an oluşturulan kutuya ait kategoriyi listeden alıyoruz.
        // index 0'dan başlar. Örneğin categories[0] ilk kategoriyi verir.
        final category = categories[index];

        // Container kullanarak kategori kutusunun dış görünümünü oluşturuyoruz.
        return Container(
          // Kutunun içerisindeki elemanlarla kenarları arasında 18 piksel boşluk bırakıyoruz.
          padding: const EdgeInsets.all(18),

          // Kutunun arka plan, kenarlık ve köşe tasarımını belirliyoruz.
          decoration: BoxDecoration(
            // Kategori kutusunun arka planını beyaz yapıyoruz.
            color: Colors.white,

            // Kutunun köşelerini 20 piksel yuvarlatıyoruz.
            borderRadius: BorderRadius.circular(20),

            // Kutunun etrafına açık gri renkte ince bir kenarlık ekliyoruz.
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),

          // Column ile kutunun içerisindeki elemanları dikey olarak sıralıyoruz.
          child: Column(
            // Elemanları yatay eksende sola hizalıyoruz.
            crossAxisAlignment: CrossAxisAlignment.start,

            // Elemanları dikey eksende ortalıyoruz.
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // İkonun etrafında renkli bir kutu oluşturuyoruz.
              Container(
                // İkonun çevresinde 12 piksel boşluk bırakıyoruz.
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  // Kategoriye ait rengin şeffaf bir tonunu arka plan olarak kullanıyoruz.
                  // withValues(alpha: 0.1) rengi %10 opaklıkta gösterir.
                  color: category.color.withValues(alpha: 0.1),

                  // İkonun arka plan kutusunun köşelerini yuvarlatıyoruz.
                  borderRadius: BorderRadius.circular(14),
                ),

                // CategoryModel'den gelen ikonu ve rengi kullanıyoruz.
                // Böylece her kategori kendi ikonuna ve rengine sahip oluyor.
                child: Icon(category.icon, color: category.color, size: 26),
              ),

              // İkon ile kategori adı arasında 12 piksel boşluk bırakıyoruz.
              const SizedBox(height: 12),

              // Kategorinin ismini ekranda metin olarak gösteriyoruz.
              Text(
                category.name,

                // Kategori isminin yazı boyutunu ve kalınlığını belirliyoruz.
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
