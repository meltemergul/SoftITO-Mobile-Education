import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ogrenci_model.dart';

class FireStoreOgrenciServisi {
  // Firestore üzerindeki ogrenciler koleksiyonuna erişmek için referans oluşturuyorum.
  // Map<String, dynamic> kullanarak koleksiyondaki verilerin String anahtarlı
  // ve farklı veri tiplerinde olabileceğini belirtiyorum.
  final CollectionReference<Map<String, dynamic>> _ogrencilerKoleksiyonu =
      FirebaseFirestore.instance.collection('ogrenciler');

  // CREATE: Firestore'a yeni öğrenci eklemek için kullandığım metot.
  Future<void> ogrenciEkle({
    required String adSoyad, // Öğrencinin adını ve soyadını alıyorum.
    required String projeAdi, // Öğrencinin proje adını alıyorum.
    required int notu, // Öğrencinin notunu tam sayı olarak alıyorum.
  }) async {
    try {
      // add() ile Firestore'a yeni bir belge ekliyorum.
      // Belge ID'sini Firestore otomatik olarak oluşturuyor.
      await _ogrencilerKoleksiyonu.add({
        'adSoyad': adSoyad,
        'projeAdi': projeAdi,
        'notu': notu,

        // Kayıt zamanını Firestore sunucusunun belirlemesini sağlıyorum.
        'kayitTarihi': FieldValue.serverTimestamp(),
      });

      print('Öğrenci başarıyla kaydedildi');
    } catch (e) {
      // Kayıt sırasında oluşabilecek hataları yakalıyorum.
      print('Öğrenci ekleme başarısız: $e');

      // Hatayı tekrar fırlatarak çağırdığım yerde de yakalanmasını sağlıyorum.
      rethrow;
    }
  }

  // Belirlediğim bir belge ID'si ile öğrenci kaydetmek için kullandığım metot.
  Future<void> ogrenciIdIleKaydet({
    required String tcNo,
    required String adSoyad,
    required String projeAdi,
  }) async {
    // doc(tcNo) ile belge ID'sini kendim belirliyorum.
    // set() ile verileri kaydediyorum.
    await _ogrencilerKoleksiyonu.doc(tcNo).set(
      {
        'adSoyad': adSoyad,
        'projeAdi': projeAdi,

        // Belgenin güncellenme zamanını sunucudan alıyorum.
        'güncellemeTarihi': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    ); // merge: true sayesinde mevcut alanları koruyorum.
  }

  // READ: Firestore'daki tüm öğrencileri tek seferlik getirmek için kullandığım metot.
  Future<List<OgrenciModel>> tumOgrencileriGetir() async {
    try {
      // Öğrencileri notlarına göre büyükten küçüğe sıralayarak getiriyorum.
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _ogrencilerKoleksiyonu.orderBy('notu', descending: true).get();

      // Gelen belgeleri OgrenciModel nesnelerine dönüştürüp liste halinde döndürüyorum.
      return snapshot.docs
          .map((doc) => OgrenciModel.fromFireStore(doc))
          .toList();
    } catch (e) {
      // Verileri getirirken oluşabilecek hataları yakalıyorum.
      print('Veri çekme hatası: $e');
      rethrow;
    }
  }

  // READ: Öğrenci listesini canlı olarak takip etmek için kullandığım metot.
  Stream<List<OgrenciModel>> ogrencileriDinle() {
    // snapshots() sayesinde koleksiyondaki değişiklikleri anlık dinliyorum.
    return _ogrencilerKoleksiyonu
        .orderBy('notu', descending: true)
        .snapshots()
        .map((snapshot) {
          // Gelen her belgeyi OgrenciModel nesnesine dönüştürüyorum.
          return snapshot.docs
              .map((doc) => OgrenciModel.fromFireStore(doc))
              .toList();
        });
  }

  // UPDATE: Öğrencinin notunu güncellemek için kullandığım metot.
  Future<void> ogrenciNotuGuncelle(String documentId, int yeniNot) async {
    // Belge ID'sine göre ilgili öğrenciyi bulup sadece notunu güncelliyorum.
    await _ogrencilerKoleksiyonu.doc(documentId).update({
      'notu': yeniNot,

      // Son düzenleme zamanını Firestore sunucusundan alıyorum.
      'sonDuzenleme': FieldValue.serverTimestamp(),
    });
  }

  // DELETE: Firestore'dan öğrenciyi silmek için kullandığım metot.
  Future<void> ogrenciSil(String documentId) async {
    // Belge ID'sini kullanarak ilgili öğrenciyi koleksiyondan siliyorum.
    await _ogrencilerKoleksiyonu.doc(documentId).delete();

    print('$documentId referanslı veri silindi');
  }
}
