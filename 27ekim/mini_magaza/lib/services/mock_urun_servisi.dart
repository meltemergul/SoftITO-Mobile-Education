import '../models/kategori.dart';
import '../models/urun.dart';
import 'i_urun_servisi.dart';

class MockUrunServisi implements IUrunServisi{
  final List<Urun> _urunDeposu=const
  [Urun(id:1,baslik:"Macbook M5 Pro Laptop",
  aciklama:"Apple'ın en güçlü işlemcisine sahip yeni nesil Macbook Pro",
  fiyat:179999.99,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.elektronik,
  stokAdedi:5,
  ),Urun(id:2,baslik:"Apple İphone 18 Pro Max",
  aciklama:"Apple'ın en yeni akıllı telefonu,performans ve şıklığı bir arada sunuyor.",
  fiyat:250000.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.elektronik,
  stokAdedi:5,
  ),Urun(id:3,baslik:"Adidas Erkek Sneaker Ayakkabı",
  aciklama:"Günlük kullanıma uygun,şık ve trend erkek sneaker ayakkabısı",
  fiyat:3500.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.ayakkabi,
  stokAdedi:5,
  ),
  Urun(id:4,baslik:"Nike Erkek Sneaker Ayakkabı",
  aciklama:"Koşu ve spor antrenmanları için uygun,dayanıklı ve şık tasarımlı,şık ve trend erkek sneaker ayakkabısı",
  fiyat:1499.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.ayakkabi,
  stokAdedi:5,
  ),
  Urun(id:5,baslik:"Şık Kadın Elbise",
  aciklama:"Pembe rengi ile şık bir görünüm sunan,pamuklu kumaştan üretilmiş,dantel detaylı,günlük kullanıma uygun,şık ve trend kadın elbisesi",
  fiyat:1999.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.giyim,
  stokAdedi:5,
  ),
  Urun(id:6,baslik:"Apple Watch Series 9",
  aciklama:"Akıllı saat,kalp atış hızı ölçümü,EKG,kan oksijen seviyesi ölçümü,uyku takibi,spor modları,suya dayanıklı,şık ve trend akıllı saat",
  fiyat:15000.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.elektronik,
  stokAdedi:5,
  ), 
  Urun(id:7,baslik:"Apple Airpods Pro 2",
  aciklama:"Kulaklık ile müziğin tadını çıkarın",
  fiyat:5000.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.aksesuar,
  stokAdedi:5,
  ), 
  Urun(id:8,baslik:"Samsung Galaxy S26 Ultra",
  aciklama:"TelefonGalaxy S26 Ultra,120Hz yenileme hızına sahip AMOLED ekranı,yüksek çözünürlüklü kamerası,uzun pil ömrü ve güçlü işlemcisiyle göz dolduran,şık ve trend akıllı telefon",
  fiyat:129999.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.elektronik,
  stokAdedi:5,
  ),
    Urun(id:9,baslik:"Erkek Deri Ceket",
  aciklama:"Yumuşak deriden üretilmiş,şık ve modern tasarımlı,günlük kullanıma uygun,şık ve trend erkek deri ceketi",
  fiyat:1999.00,
  resimUrl:"https://picsum.photos/400/400",
  kategori:Kategori.giyim,
  stokAdedi:5,
  ),

  ];

@override 
Future<List<Urun>> tumUrunleriGetir() async {
  await Future.delayed(const Duration(milliseconds: 1500));
  return List.from(_urunDeposu);
}

@override 
Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori) async {
  await Future.delayed(const Duration(milliseconds: 400));
  if(kategori==Kategori.hepsi)
  {
    return List.from(_urunDeposu);
  }
  return _urunDeposu.where((urun) => urun.kategori == kategori).toList();
}

@override 
Future<List<Urun>> adaGoreAra(String aramaMetni) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if(aramaMetni.trim().isEmpty){
    return List.from(_urunDeposu);
  }
 return _urunDeposu.where((urun)
 {
    final baslikKucuk=urun.baslik.toLowerCase();
    final arananKucuk=aramaMetni.toLowerCase();
    return baslikKucuk.contains(arananKucuk);
 }).toList();

}

}
