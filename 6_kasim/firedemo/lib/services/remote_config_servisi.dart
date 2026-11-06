import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigServisi {
  final FirebaseRemoteConfig _firebaseRemoteConfig =
      FirebaseRemoteConfig.instance;
  Future<void> baslat() async {
    await _firebaseRemoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _firebaseRemoteConfig.setDefaults(const {
      'kampanya_aktif': true,
      'kampanya_metni': 'Mobil. mezuniyet indrimi',
      'kampanya_indirim_orani': 30,
      'zorunlu_guncelleme': false,
      'en_dusuk_surum': '1.0.0',
    });

    try {
      await _firebaseRemoteConfig.fetchAndActivate();
    } catch (_) {}
  }

  bool get kampanyaAktifMi => _firebaseRemoteConfig.getBool('kampanya_aktif');
  String get kampanyaMetni => _firebaseRemoteConfig.getString('kampanya_metni');
  int get indirimOrani =>
      _firebaseRemoteConfig.getInt('kampanya_indirim_orani');
  bool get zorunluGuncellemeMi =>
      _firebaseRemoteConfig.getBool('zorunlu_guncelleme');
  String get enDusukSurum => _firebaseRemoteConfig.getString('en_dusuk_surum');
}
