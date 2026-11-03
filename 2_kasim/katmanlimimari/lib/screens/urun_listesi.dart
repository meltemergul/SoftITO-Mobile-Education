// Flutter Material tasarım bileşenlerini içe aktarır
import 'package:flutter/material.dart';

// Ürün modelini içe aktarır
import '../models/urun.dart';

// Ürün servisinin gerçek API implementasyonunu içe aktarır
import '../services/urun_servisi.dart';

// Soyut ürün servisi arayüzünü içe aktarır
import '../services/i_urun_servisi.dart';

// Ürün kartı widget'ını içe aktarır
import '../widgets/urun_karti.dart';

// Ürünleri API'den çekip liste halinde gösteren ana ekran
class UrunListesiEkrani extends StatefulWidget {
  // Widget'ın kurucu metodu
  const UrunListesiEkrani({super.key});

  // Ekranın durum sınıfını oluşturur
  @override
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState();
}

// Ekranın değişkenlerini ve işlemlerini yöneten State sınıfı
class _UrunListesiEkraniState extends State<UrunListesiEkrani> {
  // Arayüz üzerinden servis kullanarak API işlemlerini gerçekleştirir
  final IUrunServisi _servis = CanliApiUrunServisi();

  // API'den gelen ürünleri tutan liste
  List<UrunModel> _urunler = [];

  // Ürünlerin yüklenme durumunu kontrol eder
  bool _yukleniyor = true;

  // Oluşabilecek hatanın mesajını tutar
  String? _hataMesaji;

  // Ekran ilk açıldığında bir kez çalışır
  @override
  void initState() {
    super.initState();

    // Sayfa açılır açılmaz ürünleri API'den getirir
    _urunleriYukle();
  }

  // API üzerinden ürünleri asenkron olarak getirir
  Future<void> _urunleriYukle() async {
    // Yükleme durumunu başlatır ve eski hatayı temizler
    setState(() {
      _yukleniyor = true;
      _hataMesaji = null;
    });

    // API isteği sırasında oluşabilecek hataları yakalar
    try {
      // Servis üzerinden ürün listesini getirir
      final urunler = await _servis.urunleriGetir();

      // Widget hâlâ ekranda mı kontrol eder
      if (!mounted) return;

      // Gelen ürünleri ekrana aktarır
      setState(() {
        _urunler = urunler;

        // Yükleme işlemini bitirir
        _yukleniyor = false;
      });
    } catch (e) {
      // Widget hâlâ ekranda mı kontrol eder
      if (!mounted) return;

      // Hata durumunda ekranın durumunu günceller
      setState(() {
        _hataMesaji = 'Ürünler yüklenemedi.';

        // Yükleme animasyonunu durdurur
        _yukleniyor = false;
      });

      // Hatayı konsola yazdırır
      debugPrint('Hata: $e');
    }
  }

  // Ekranın görsel tasarımını oluşturur
  @override
  Widget build(BuildContext context) {
    // Sayfanın temel iskeletini oluşturur
    return Scaffold(
      // Üst başlık çubuğunu oluşturur
      appBar: AppBar(
        // Sayfa başlığını gösterir
        title: const Text('Mini Mağaza'),

        // Başlığı ortalar
        centerTitle: true,

        // Sağ üst köşedeki butonları tutar
        actions: [
          // Ürünleri yeniden yüklemek için yenileme butonu
          IconButton(
            // Yenileme simgesini gösterir
            icon: const Icon(Icons.refresh),

            // Butona basıldığında API isteğini tekrar yapar
            onPressed: _urunleriYukle,
          ),
        ],
      ),

      // Sayfanın ana içerik alanını oluşturur
      body:
          // Ürünler yükleniyorsa yükleme animasyonunu gösterir
          _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          // Hata oluşmuşsa hata mesajını gösterir
          : _hataMesaji != null
          ? Center(
              child: Column(
                // İçerikleri dikeyde ortalar
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // Hata mesajını ekranda gösterir
                  Text(_hataMesaji!),

                  // Yeniden deneme butonunu oluşturur
                  ElevatedButton(
                    // Basıldığında ürünleri tekrar yükler
                    onPressed: _urunleriYukle,

                    // Buton metni
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          // Ürün listesi boşsa bilgi mesajı gösterir
          : _urunler.isEmpty
          ? const Center(child: Text('Henüz ürün bulunamadı.'))
          // Ürünler geldiyse liste halinde ekranda gösterir
          : ListView.builder(
              // Liste etrafındaki boşlukları ayarlar
              padding: const EdgeInsets.all(12),

              // Listede gösterilecek ürün sayısını belirler
              itemCount: _urunler.length,

              // Her ürün için ayrı bir kart oluşturur
              itemBuilder: (context, index) {
                // Listedeki sıradaki ürünü alır
                final urun = _urunler[index];

                // Ürün kartının altına boşluk ekler
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  // Ürün bilgilerini UrunKarti widget'ına gönderir
                  child: UrunKarti(urun: urun),
                );
              },
            ),
    );
  }
}
