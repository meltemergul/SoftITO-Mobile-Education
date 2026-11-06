import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyicsServisi {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> kullaniciTanit({
    required String uid,
    required String rol,
  }) async {
    await _crashlytics.setUserIdentifier(uid);
    await _crashlytics.setCustomKey('rol', rol);
    await _crashlytics.setCustomKey('platform', 'flutter');
  }

  void logEkle(String mesaj) {
    _crashlytics.log(mesaj);
  }

  Future<void> sessizHataKaydet(dynamic hata, StackTrace stack) async {
    await _crashlytics.recordError(hata, stack, fatal: false);
    //fatal false hata arka tarafta kalıyor
  }

  void kastenCokertme() {
    _crashlytics.crash();
  }
}
