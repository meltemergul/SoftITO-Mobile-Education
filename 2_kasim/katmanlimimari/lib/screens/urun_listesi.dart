// Flutter Material tasarım bileşenlerini içe aktarır
import 'package:flutter/material.dart';

// Ürün veri modelini içe aktarır
import '../models/urun.dart';
// Kategori enum ve extension yapısını içe aktarır
import '../services/urun_servisi.dart';
import '../services/i_urun_servisi.dart';
import '../widgets/urun_karti.dart';

// Canlı API'den ürünleri çeken, filtreleyen ve 4 durumu yöneten durumlu (Stateful) ana ekran widget'ı
class UrunListesiEkrani extends StatefulWidget {
  // Widget ağacı için kurucu metot
  const UrunListesiEkrani({super.key});

  // Ekranın durum (state) yöneticisini oluşturan metot
  @override
  // UrunListesiEkraniState durum nesnesini bağlar
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState();
  // UrunListesiEkrani sınıfının kapanış parantezi
}

// Ekranın durum değişkenlerini, API çağrılarını ve UI mantığını barındıran State sınıfı
class _UrunListesiEkraniState extends State<UrunListesiEkrani> {
  // Polimorfizm prensibi ile soyut arayüze bağlanan API servis referansı
  final IUrunServisi _servis = CanliApiUrunServisi();

  // API'den gelen orijinal ve eksiksiz ürün havuzu
  List<UrunModel> _tumUrunler = [];

  // Asenkron veri çekme işleminin devam edip etmediğini tutan bayrak
  bool _yukleniyor = true;
  // Ağ veya sunucu hatası oluştuğunda hata metnini tutan değişken (hata yoksa null'dır)
  String? _hataMesaji;
  // Kullanıcının o anda seçili tuttuğu kategori filtresi (varsayılan: hepsi)

  // Widget ilk kez belleğe yüklendiğinde bir kez çalışan yaşam döngüsü metodu
  @override
  // initState metodunun gövdesi
  void initState() {
    // Üst sınıfın initState metodunu çağırır
    super.initState();
    // Sayfa açılır açılmaz ürünleri API'den çekmeye başlar
    _urunleriYukle();
    // initState metodunun kapanış parantezi
  }

  // FakeStore REST API'den ürünleri asenkron olarak çeken ana fonksiyon
  Future<void> _urunleriYukle() async {
    // Ekranı 'Yükleniyor' moduna sokmak ve eski hataları temizlemek için setState çağrılır
    setState(() {
      // Yüklenme animasyonunu başlatır
      _yukleniyor = true;
      // Varsa önceki hata mesajını sıfırlar
      _hataMesaji = null;
      // setState kapanışı
    });

    // Olası ağ kopmaları, zaman aşımı ve format hataları için try bloğu
    try {
      // Servis üzerinden HTTP GET isteğini atar ve ürün listesini bekler
      final urunler = await _servis.urunleriGetir();
      // Widget ağaçta hâlâ aktif mi kontrol eder (kullanıcı sayfa yüklenirken geri çıktıysa hata almamak için)
      if (!mounted) return;

      // Veriler başarıyla geldiyse durumu günceller
      setState(() {
        // Ham ürün listesini kaydeder
        _tumUrunler = urunler;
        // Başlangıçta tüm ürünleri filtreli listeye de aktarır
        // Yüklenme bayrağını kapatır
        _yukleniyor = false;
        // setState kapanışı
      });
      // Varsa mevcut filtreleri yeni listeye uygular
      // Ağ, zaman aşımı veya sunucu kaynaklı bir hata yakalandığında
    } catch (hata) {
      // Widget ağaçta hâlâ aktif mi kontrol eder
      if (!mounted) return;
      // Ekranı 'Hata' durumuna geçirmek için setState çağrılır
      setState(() {
        // Kullanıcıya gösterilecek anlaşılır hata metnini oluşturur
        _hataMesaji = 'Ürünler yüklenirken bir sorun oluştu.\nİnternet bağlantınızı kontrol edin.';
        // Yüklenme durumunu kapatır
        _yukleniyor = false;
        // setState kapanışı
      });
      // try-catch kapanışı
    }
    // _urunleriYukle fonksiyonu kapanış parantezi
  }

  // Ekranın görsel ağacını kuran ana build fonksiyonu
  @override
  // BuildContext parametresini alan build fonksiyonu
  Widget build(BuildContext context) {
    // Temel sayfa iskeletini sağlayan Scaffold
    return Scaffold(
      // Sayfanın üst başlık çubuğu
      appBar: AppBar(
        // Başlık metni
        title: const Text('Mini Mağaza (Canlı API)'),
        // Başlığı ortalar
        centerTitle: true,
        // AppBar sağ üst köşesindeki hızlı işlem butonları
        actions: [
          // Elle yenileme yapmayı sağlayan yenile butonu
          IconButton(
            // Yenile simgesi
            icon: const Icon(Icons.refresh),
            // Tıklanınca ürünleri sıfırdan çeker
            onPressed: _urunleriYukle,
            // Ekran okuyucular için ipucu metni
            tooltip: 'Yenile',
            // IconButton kapanışı
          ),
          // actions listesi kapanışı
        ],
        // AppBar kapanışı
      ),
      // Sayfanın ana gövdesini oluşturan dikey sütun (Column)
      body: Column(
        // Sütun içi alt bileşenler listesi
        children: [
          // Canlı arama kutusunun dış kenar boşluklarını belirleyen Padding
          Padding(
            // Yatayda 16, dikeyde 8 piksel boşluk
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Kullanıcının metin girdiği TextField bileşeni

            // Padding kapanışı
          ),

          // 4 piksel dikey boşluk
          const SizedBox(height: 4),
          // Kalan ekran alanını kaplayan ve 4 asenkron durumu yöneten Expanded bileşeni

          // Column çocukları kapanışı
        ],
        // Column kapanışı
      ),
      // Scaffold kapanışı
    );
    // build metodu kapanış parantezi
  }
}
