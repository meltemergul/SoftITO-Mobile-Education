// Mülakat için önemli:Sealed sınıflar dışardan extend edilmez switch içinde tüm alt sınıflar tüketilmek zorundadır.
sealed class OdemeDurumu {}

class OdemeBasarili extends OdemeDurumu {
  final ({String referansKodu, double tutar}) veri;
  OdemeBasarili(this.veri);
}

class OdemeBasarisiz extends OdemeDurumu {
  final String hataNedeni;
  OdemeBasarisiz(this.hataNedeni);
}

abstract class IBankServisi {
  Future<OdemeDurumu> odemeYap({required double miktar});
}

mixin GuvenlikDenetimMixin {
  bool tokenGecerliMi(String token) {
    return token.isNotEmpty && token.length >= 32;
  }
}

mixin AuditLogMixin {
  void islemiKaydet(String mesaj) {
    final zaman = DateTime.now().toIso8601String();
    print('Log - $zaman - $mesaj');
  }
}

class GarantiBankasiServisi
    with GuvenlikDenetimMixin, AuditLogMixin
    implements IBankServisi {
  final String apiAnahtari;

  GarantiBankasiServisi({required this.apiAnahtari});

  @override
  Future<OdemeDurumu> odemeYap({required double miktar}) async {
    if (!tokenGecerliMi(apiAnahtari)) {
      islemiKaydet('Ödeme Reddedildi: Geçersiz API anahtarı');
      return OdemeBasarisiz('Yetkilendirme hatası:Geçersiz Token');
    }
    await Future.delayed(const Duration(milliseconds: 1000));

    islemiKaydet(
      '$miktar tutarındaki ödeme Garanti Bankası tarafından ONAYLANDI',
    );
    return OdemeBasarili((
      referansKodu: 'GRNT-${DateTime.now().millisecondsSinceEpoch}',
      tutar: miktar,
    ));
  }
}

void odemeSonucunuEkranaBas(OdemeDurumu durum) {
  final mesaj = switch (durum) {
    OdemeBasarili b =>
      'Ödeme Başarılı! Referans Kodu: ${b.veri.referansKodu}, Tutar: ${b.veri.tutar}',
    OdemeBasarisiz h => 'Ödeme Başarısız! Hata Nedeni: ${h.hataNedeni}',
  };
  print(mesaj);
}

void main() async {
  final garantiBankasi = GarantiBankasiServisi(
    apiAnahtari: '12345678901234567890123456789012',
  );

  final odemeDurumu = await garantiBankasi.odemeYap(miktar: 550.0);
  odemeSonucunuEkranaBas(odemeDurumu);
}
