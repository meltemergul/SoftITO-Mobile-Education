// Dosya işlemlerini gerçekleştirebilmek için Dart'ın io kütüphanesini ekler.
import 'dart:io';

// Firebase Storage üzerinde dosya yükleme, indirme ve silme işlemlerini yapabilmek için kullanılır.
import 'package:firebase_storage/firebase_storage.dart';

// Cihazın kamerasından veya galerisinden görsel seçebilmek için kullanılır.
import 'package:image_picker/image_picker.dart';

// Firebase Storage işlemlerini yöneten servis sınıfıdır.
class StorageServisi {
  // Firebase Storage bağlantısını oluşturur.
  // Bu nesne üzerinden dosya yükleme ve silme işlemleri yapılır.
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Kamera ve galeriden görsel seçmek için ImagePicker nesnesi oluşturur.
  final ImagePicker _picker = ImagePicker();

  // Kullanıcının kameradan veya galeriden görsel seçmesini sağlayan metottur.
  // kameradan parametresi true gelirse kamera, false gelirse galeri açılır.
  Future<File?> gorselSec({bool kameradan = false}) async {
    // Seçilen görseli XFile türünde alır.
    final XFile? xFile = await _picker.pickImage(
      // kameradan değerine göre görsel kaynağını belirler.
      source: kameradan ? ImageSource.camera : ImageSource.gallery,

      // Görselin kalitesini 80 olarak ayarlar.
      imageQuality: 80,

      // Görselin maksimum genişliğini 1200 piksel ile sınırlar.
      maxWidth: 1200,
    );

    // Kullanıcı görsel seçmeden işlemi iptal ederse null döndürür.
    if (xFile == null) return null;

    // Seçilen görseli File türüne dönüştürerek geri döndürür.
    return File(xFile.path);
  }

  // Seçilen görseli Firebase Storage'a yükleme işlemini başlatır.
  // UploadTask döndürdüğü için yükleme işlemi takip edilebilir.
  UploadTask yuklemeBaslat({
    required File dosya,
    required String dosyaAdi,
    String klasor = 'yuklemeler',
  }) {
    // Firebase Storage içerisinde dosyanın yükleneceği yolu belirler.
    // Dosya, belirtilen klasörün altına dosya adıyla kaydedilir.
    final Reference ref = _storage.ref().child('$klasor/$dosyaAdi');

    // Yüklenecek dosyanın türü ve ek bilgilerini belirler.
    final metadata = SettableMetadata(
      // Dosyanın PNG görseli olduğunu belirtir.
      contentType: 'image/png',

      // Dosyaya ek bilgi ekler.
      // Bu örnekte görseli ekleyen kişi belirtilmiştir.
      customMetadata: {'ekleyen': 'meltem'},
    );

    // Belirlenen dosyayı ve metadata bilgilerini Firebase Storage'a yükler.
    return ref.putFile(dosya, metadata);
  }

  // Firebase Storage'a yüklenen dosyanın indirme bağlantısını getirir.
  Future<String> urlGetir(Reference ref) async {
    // Dosyanın erişilebilir indirme URL bilgisini döndürür.
    return await ref.getDownloadURL();
  }

  // Firebase Storage içerisinde belirtilen dosyayı siler.
  Future<void> dosyaSil(String dosyaYolu) async {
    // Silinecek dosyanın Storage içerisindeki yolunu referans olarak oluşturur.
    final Reference ref = _storage.ref().child(dosyaYolu);

    // Belirlenen dosyayı Firebase Storage'dan siler.
    await ref.delete();
  }
}
