import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageServisi {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UploadTask yuklemeBaslat({
    required File dosya,
    required String hedefDiizin,
    required String dosyaAdi,
  }) {
    final Reference ref = _storage.ref().child('$hedefDiizin/$dosyaAdi');
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {
        'yukleyen': 'Faik fahri fahrettin tek kişillik dev kadro',
      },
    );
    return ref.putFile(dosya, metadata);
  }
//yuklenme yuzdesi
  task.snapshot.listen((TaskSnapshot snapshot)
  {
    final double yuzde= snapshot.bytesTransferret / snapshot.totalBytes;
    print('yükleniyor %${yuzde * 100}.toStringAsFixed(1)}');
  })

  
}
