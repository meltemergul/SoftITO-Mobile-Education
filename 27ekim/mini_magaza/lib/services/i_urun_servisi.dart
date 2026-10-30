// Metotların Parametre ve Dönüş Tiplerinde Kullanılan Modeller.
import '../models/kategori.dart';
import '../models/urun.dart';

// Ürün Servisi Sözleşmesi (Interface). Baştaki "I" Harfi "Interface" Anlamına Gelir.
// abstract: Bu Sınıftan Doğrudan Nesne Oluşturulamaz, Sadece Şablon Görevi Görür.
// Ekran Bu Sözleşmeyi Tanır; Gerçek API Servisi Yazılınca Ekranda Tek Satır Değişir.
// Bu Yaklaşıma Dependency Inversion (Bağımlılığı Soyutlamaya Yapmak) Denir.
abstract class IUrunServisi {
  // Future: Sonucun Hemen Değil, İleride Geleceğini Belirtir (Ağ İsteği, Veritabanı Vb.).
  // Tüm Ürünleri Getirir.
  Future<List<Urun>> tumUrunleriGetir();

  // Sadece Verilen Kategorideki Ürünleri Getirir.
  Future<List<Urun>> kategoriyeGoreGetir(Kategori kategori);

  // Başlığında Arama Metni Geçen Ürünleri Getirir.
  Future<List<Urun>> adaGoreAra(String aramaMetni);
}