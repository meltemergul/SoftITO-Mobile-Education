import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class HataServisi {
  //servis oluştur
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  Future<void> kullaniciTanit({
    //kullanici tanit ve crash olarak eşleştirdik
    required String uid,
    required String rol,
    required String paket,
  }) async {
    await _crashlytics.setUserIdentifier(uid);
    await _crashlytics.setCustomKey('kullanici_rolu', rol);
    await _crashlytics.setCustomKey('uyelik_tipi', paket);
  }

  void ayakIziBirak(String adim) {
    //her adimi log olarak kaydetti
    _crashlytics.log('kullanıcı işlemi: $adim');
  }

  Future<void> sessizHataKaydet(dynamic hata, StackTrace stack) async {
    await _crashlytics.recordError(hata, stack, fatal: true);
  }


  
  ElevatedButton(onPressed:(){
    FirebaseCrashlytics.instance.crash();
  },
  child:const Text('Çökme testi gönder');
  )

}

//import 'dart:ui';

//import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';

//void main() async {
//WidgetsFlutterBinding.ensureInitialized();
// await Firebase.initializeApp();
// FlutterError.onError = (erordetails) {
// FirebaseCrashlytics.instance.recordFlutterError(erordetails);
//};
// PlatformDispatcher.instance.onError = (error, stack) {
// FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//return true;
// };
//}
// uygulamada meydana gelen hataları yakalayıp Firebase Crashlytics paneline göndermektir.
//Böylece uygulama kullanıcıların telefonlarında hata verdiğinde, geliştirici olarak hatanın
// ne olduğunu ve nereden kaynaklandığını takip edilebilir.
