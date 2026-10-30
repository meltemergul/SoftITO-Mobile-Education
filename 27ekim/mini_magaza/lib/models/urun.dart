// Ürünün Kategorisi, Kategori Enum'u Tipinde Olacağı İçin İçeri Aktarılır.
import 'kategori.dart';
import 'degerlendirme.dart';

// Bir Ürünün Hangi Bilgilerden Oluştuğunu Tanımlayan Saf Veri Sınıfı (Model).
// Tüm Alanlar final: Nesne Oluşturulduktan Sonra Değiştirilemez (Immutable).
class Urun {
  // Benzersiz Kimlik. Favori Güncellenirken Ürünü Listede Bulmak İçin Kullanılır.
  final int id;
  // Ürün Adı.
  final String baslik;
  // Ürünün Uzun Açıklaması.
  final String aciklama;
  // Ondalıklı Fiyat.
  final double fiyat;
  // İnternetten Yüklenecek Resmin Adresi.
  final String resimUrl;
  // Kategori Enum'undan Bir Değer.
  final Kategori kategori;
  // Stokta Kaç Adet Var.
  final int stokAdedi;
  // Kullanıcı Bu Ürünü Favoriledi Mi?
  final bool favoriMi;
  final Degerlendirme degerlendirme;

  // Süslü Parantez = İsimli Parametreler. Kullanımı: Urun(id: 1, baslik: "...").
  // const Kurucu Sayesinde Değerleri Derleme Anında Belli Olan Ürünler Tek Kopya Tutulur.
  const Urun({
    // required: Bu Parametrenin Verilmesi Zorunlu.
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.fiyat,
    required this.resimUrl,
    required this.kategori,
    required this.stokAdedi,
    // Zorunlu Değil; Verilmezse Varsayılan Değer false Olur.
    this.favoriMi = false,
    this.degerlendirme = const Degerlendirme(puan: 0.0, oySayisi: 0),
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      id: json['id'] as int,
      baslik: json['title'] as String,
      fiyat: (json['price'] as num).toDouble(),
      aciklama: json['description'] as String,
      kategori: Kategori.values.byName(json['category'] as String),
      resimUrl: json['image'] as String,
      degerlendirme: json['rating'] != null
          ? Degerlendirme.fromJson(json['rating'] as Map<String, dynamic>)
          : const Degerlendirme(puan: 0.0, oySayisi: 0),
      favoriMi: false,
      stokAdedi: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  // "Kopyala Ama Şu Alanları Değiştir" Metodu.
  // Alanlar final Olduğu İçin Ürünü Değiştirmek Yerine Değişmiş Yeni Bir Kopya Üretilir.
  // Örn: urun.copyWith(favoriMi: true) → Diğer Her Şeyi Aynı, Favorisi true Yeni Ürün.
  Urun copyWith({
    // "?" = Nullable: Parametre Verilmezse null Olarak Kalır.
    int? id,
    String? baslik,
    String? aciklama,
    double? fiyat,
    String? resimUrl,
    Kategori? kategori,
    int? stokAdedi,
    bool? favoriMi,
    Degerlendirme? degerlendirme,
  }) {
    // Yepyeni Bir Urun Nesnesi Döndürülür; Eski Nesneye Dokunulmaz.
    return Urun(
      // "??" Operatörü: Soldaki null İse Sağdakini Kullan.
      // Yani Yeni Değer Verildiyse Onu, Verilmediyse Mevcut Değeri (this.id) Al.
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      fiyat: fiyat ?? this.fiyat,
      resimUrl: resimUrl ?? this.resimUrl,
      kategori: kategori ?? this.kategori,
      stokAdedi: stokAdedi ?? this.stokAdedi,
      favoriMi: favoriMi ?? this.favoriMi,
      degerlendirme: degerlendirme ?? this.degerlendirme,
    );
  }

  // Object Sınıfındaki toString Metodunu Eziyoruz (Override).
  // print(urun) Yapıldığında Okunaklı Bir Çıktı Versin Diye.
  @override
  String toString() {
    // "$degisken" Yazımı, Değişkenin Değerini String'in İçine Gömer (Interpolation).
    return 'Urun(id: $id, baslik: $baslik, fiyat: $fiyat ₺, favoriMi: $favoriMi)';
  }
}