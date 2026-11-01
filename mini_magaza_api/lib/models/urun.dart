import 'kategori.dart';
import 'degerlendirme.dart';

class Urun {
  final int id;
  final String baslik;
  final double fiyat;
  final String aciklama;
  final Kategori kategori;
  final String resimUrl;
  final Degerlendirme degerlendirme;
  final bool stoktaVarMi;

  const Urun({
    required this.id,
    required this.baslik,
    required this.fiyat,
    required this.aciklama,
    required this.kategori,
    required this.resimUrl,
    required this.degerlendirme,
    this.stoktaVarMi = true,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      id: (json['id'] as num).toInt(),
      baslik: json['title'] as String? ?? 'İsimsiz Ürün',
      fiyat: (json['price'] as num?)?.toDouble() ?? 0.0,
      aciklama: json['description'] as String? ?? '',
      kategori: KategoriExtension.apiMetnindenUret(
        json['category'] as String? ?? '',
      ),
      resimUrl: json['image'] as String? ?? '',
      degerlendirme: json['rating'] != null
          ? Degerlendirme.fromJson(json['rating'] as Map<String, dynamic>)
          : const Degerlendirme(puan: 0.0, oySayisi: 0),
      stoktaVarMi: ((json['rating']?['count'] as num?)?.toInt() ?? 10) > 0,
    );
  }

  Urun copyWith({
    int? id,
    String? baslik,
    double? fiyat,
    String? aciklama,
    Kategori? kategori,
    String? resimUrl,
    Degerlendirme? degerlendirme,
    bool? stoktaVarMi,
  }) {
    return Urun(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      fiyat: fiyat ?? this.fiyat,
      aciklama: aciklama ?? this.aciklama,
      kategori: kategori ?? this.kategori,
      resimUrl: resimUrl ?? this.resimUrl,
      degerlendirme: degerlendirme ?? this.degerlendirme,
      stoktaVarMi: stoktaVarMi ?? this.stoktaVarMi,
    );
  }
}
