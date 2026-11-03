import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ogrenci_model.dart';

class FireStoreOgrenciServisi {
  final CollectionReference<Map<String, dynamic>> _ogrencilerKoleksiyonu =
      FirebaseFirestore.instance.collection('ogrenciler');

  // CREATE: Yeni öğrenci ekleme
  Future<void> ogrenciEkle({
    required String adSoyad,
    required String projeAdi,
    required int notu,
  }) async {
    try {
      await _ogrencilerKoleksiyonu.add({
        'adSoyad': adSoyad,
        'projeAdi': projeAdi,
        'notu': notu,
        'kayitTarihi': FieldValue.serverTimestamp(),
      });

      print('Öğrenci başarıyla kaydedildi');
    } catch (e) {
      print('Öğrenci ekleme başarısız: $e');
      rethrow;
    }
  }

  // Belirli bir ID ile öğrenci kaydetme
  Future<void> ogrenciIdIleKaydet({
    required String tcNo,
    required String adSoyad,
    required String projeAdi,
  }) async {
    await _ogrencilerKoleksiyonu.doc(tcNo).set({
      'adSoyad': adSoyad,
      'projeAdi': projeAdi,
      'güncellemeTarihi': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // READ: Tüm öğrencileri bir defalık getirme
  Future<List<OgrenciModel>> tumOgrencileriGetir() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _ogrencilerKoleksiyonu.orderBy('notu', descending: true).get();

      return snapshot.docs
          .map((doc) => OgrenciModel.fromFireStore(doc))
          .toList();
    } catch (e) {
      print('Veri çekme hatası: $e');
      rethrow;
    }
  }

  // READ: Öğrencileri canlı dinleme
  Stream<List<OgrenciModel>> ogrencileriDinle() {
    return _ogrencilerKoleksiyonu
        .orderBy('notu', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OgrenciModel.fromFireStore(doc))
              .toList();
        });
  }

  // UPDATE: Öğrencinin notunu güncelleme
  Future<void> ogrenciNotuGuncelle(String documentId, int yeniNot) async {
    await _ogrencilerKoleksiyonu.doc(documentId).update({
      'notu': yeniNot,
      'sonDuzenleme': FieldValue.serverTimestamp(),
    });
  }

  // DELETE: Öğrenciyi silme
  Future<void> ogrenciSil(String documentId) async {
    await _ogrencilerKoleksiyonu.doc(documentId).delete();

    print('$documentId referanslı veri silindi');
  }
}
