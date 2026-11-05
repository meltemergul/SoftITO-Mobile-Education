// Bildirim bilgilerinin tutulacağı model sınıfıdır.
class BildirimModeli {
  // Her bildirime ait benzersiz kimliği tutar.
  final String id;

  // Bildirimin başlık bilgisini tutar.
  final String baslik;

  // Bildirimin açıklama veya içerik bilgisini tutar.
  final String icerik;

  // Bildirimin oluşturulduğu tarih ve saati tutar.
  final DateTime tarih;

  // Bildirimin okunup okunmadığını belirtir.
  final bool okunduMu;

  // Model sınıfının constructor metodudur.
  // Gerekli alanların dışarıdan gönderilmesini sağlar.
  const BildirimModeli({
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.tarih,

    // Okunma durumu belirtilmezse varsayılan olarak false kabul edilir.
    this.okunduMu = false,
  });

  // Mevcut bildirim nesnesini değiştirmeden,
  // istenilen alanları güncelleyerek yeni bir nesne oluşturur.
  BildirimModeli copyWith({
    String? id,
    String? baslik,
    String? icerik,
    DateTime? tarih,
    bool? okunduMu,
  }) {
    // Yeni bir BildirimModeli nesnesi oluşturup geri döndürür.
    return BildirimModeli(
      // Yeni bir id gönderilmediyse mevcut id değerini kullanır.
      id: id ?? this.id,

      // Yeni bir başlık gönderilmediyse mevcut başlığı kullanır.
      baslik: baslik ?? this.baslik,

      // Yeni bir içerik gönderilmediyse mevcut içeriği kullanır.
      icerik: icerik ?? this.icerik,

      // Yeni bir tarih gönderilmediyse mevcut tarihi kullanır.
      tarih: tarih ?? this.tarih,

      // Yeni bir okunma durumu gönderilmediyse mevcut değeri korur.
      okunduMu: okunduMu ?? this.okunduMu,
    );
  }
}
