import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigServisi {
  final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;

  Future<void> baslat() async {
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(
          seconds: 10,
        ), //ilk çekeceğimiz veriyi 10 sn bekledik
        minimumFetchInterval:
            Duration.zero, //cash bellek süremiz sıfır beklemeden
      ),
    );
    await _rc.setDefaults(const {
      'kampnya_aktif': false,
      'kampanya_metni': 'bugün beratta kampanya var 3 kere ders anlatacakmış',
      'zorunlu_surum': '1.0.1',
    });

    await _rc.fetchAndActivate(); //configere göre kendini aayrlacak default paramaleri ayarlıcak uzak verileri çekecek
  }

  bool get kampanyaAktifMi => _rc.getBool('kampnaya_aktif');
  String get kampanyaMetni => _rc.getString('kampnaya_metni');
  String get zorunluSurum => _rc.getString('zorunlu_surum'); //force update
}
