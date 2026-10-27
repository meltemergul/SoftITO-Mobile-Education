import 'kategori.dart';

class Urun {
  final int id;
  final String baslik;
  final Kategori kategori;
  final String aciklama;
  final double fiyat;
  final String resimUrl;
  final int stokAdedi;
  final bool favoriMi;

  const Urun({
    required this.id,
    required this.baslik,
    required this.kategori,
    required this.aciklama,
    required this.fiyat,
    required this.resimUrl,
    required this.stokAdedi,
    this.favoriMi=false,
  });


Urun copyWith({
    int? id,
    String? baslik,
    String? aciklama,
    double? fiyat,
    String? resimUrl,
    Kategori? kategori,
    int? stokAdedi,
    bool? favoriMi,
  }){
    return Urun(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      fiyat: fiyat ?? this.fiyat,
      resimUrl: resimUrl ?? this.resimUrl,
      kategori: kategori ?? this.kategori,
      stokAdedi: stokAdedi ?? this.stokAdedi,
      favoriMi: favoriMi ?? this.favoriMi,
    );
  }
  @override
  String toString(){
    return "Urun(id: $id, baslik: $baslik, fiyat: $fiyat ₺,favoriMi: $favoriMi)";
  }

}