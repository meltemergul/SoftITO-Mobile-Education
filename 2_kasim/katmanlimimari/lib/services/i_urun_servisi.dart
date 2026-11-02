import '../models/urun.dart';

abstract class IUrunServisi {
  Future<List<UrunModel>> urunleriGetir();
}
