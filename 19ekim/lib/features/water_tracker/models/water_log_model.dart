// Bu model sınıfını içilen her bir su kaydını (log) temsil etmek için oluşturdum.
// Bir veri modeli (Model) olarak görev yapıyor.
class WaterLog {
  // Alanları (fields) 'final' yaptım çünkü bir kayıt oluştuktan sonra değiştirilmesini istemiyorum (Immutability prensibi).
  final String id;          // Her kaydı listeden silerken ayırt edebilmek için benzersiz kimlik (ID)
  final int amountMl;       // İçilen su miktarı (mililitre cinsinden)
  final DateTime timestamp; // Suyun içildiği tarih ve saat

  // 'const' constructor kullanarak bu modelden değişmez nesneler üretebiliyorum, bu da bellek performansını artırıyor.
  // 'required' anahtar kelimesi ile nesne oluşturulurken bu üç alanın da verilmesini zorunlu kıldım.
  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  // Kullanıcı arayüzünde (UI) saati "14:05" formatında göstermek için bu yardımcı getter'ı yazdım.
  // padLeft(2, '0') ne işe yarıyor?
  // Eğer dakika veya saat tek haneli gelirse (örneğin saat 9, dakika 5),
  // başına '0' ekleyerek "09:05" şeklinde 2 basamaklı görünmesini sağlıyor.
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

