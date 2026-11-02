import 'package:flutter/foundation.dart';

class SepetKontrolu {
  static final SepetKontrolu ornek = SepetKontrolu._dahili();
  SepetKontrolu._dahili();

  // Getter yok: doğrudan public ve final
  final ValueNotifier<int> urunSayisi = ValueNotifier<int>(0);

  void sepeteEkle() {
    urunSayisi.value++;
  }

  void sepetiSifirla() {
    urunSayisi.value = 0;
  }
}
