import 'package:cloud_firestore/cloud_firestore.dart';

class OgrenciModel {
  final String id;
  final String adSoyad;
  final String projeAdi;
  final int notu;
  final DateTime kayitTarihi;

  const OgrenciModel({
    required this.id,
    required this.adSoyad,
    required this.projeAdi,
    required this.notu,
    required this.kayitTarihi,
  });

  // Firestore belgesini OgrenciModel nesnesine dönüştürür.
  factory OgrenciModel.fromFireStore(DocumentSnapshot doc) {
    final veri = doc.data() as Map<String, dynamic>? ?? {};

    return OgrenciModel(
      id: doc.id,
      adSoyad: veri['adSoyad'] as String? ?? 'İsimsiz öğrenci',
      projeAdi: veri['projeAdi'] as String? ?? 'Henüz proje yok',
      notu: (veri['notu'] as num?)?.toInt() ?? 0,
      kayitTarihi:
          (veri['kayitTarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
