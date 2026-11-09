enum IslemTipi { gelir, gider }

class Islem {
  final String id;
  final String baslik;
  final double miktar;
  final IslemTipi tip;
  final DateTime tarih;

  const Islem({
    required this.baslik,
    required this.id,
    required this.miktar,
    required this.tarih,
    required this.tip,
  });
}
