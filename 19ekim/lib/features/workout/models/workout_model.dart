// Tamamlanan her bir egzersiz aktivitesini temsil etmek için bu model sınıfını oluşturdum.
class WorkoutItem {
  // Tüm değişkenleri 'final' tanımlayarak modelin değiştirilemez (immutable) olmasını sağladım.
  final String id;              // Egzersiz kaydını silerken veya ararken kullanacağım benzersiz kimlik
  final String title;           // Egzersiz başlığı (Örn: "Kardiyo Koşu", "Ağırlık Antrenmanı")
  final String category;        // Kategori (Örn: "Kardiyo", "Fitness", "HIIT")
  final int durationMinutes;    // Egzersiz süresi (dakika cinsinden)
  final int caloriesBurned;     // Yakılan tahmini enerji (kcal cinsinden)
  final DateTime timestamp;     // Egzersizin tamamlandığı anın tarih ve saati

  // 'const' constructor: Aynı verilerle oluşturulan nesnelerin bellekte tek bir yerde tutulmasını sağlar.
  const WorkoutItem({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
  });

  /// Egzersiz yoğunluğu ve kaloriye bağlı önerilen ek hidrasyon ihtiyacı (ml)
  // Spor yaparken terle kaybedilen sıvıyı telafi etmek için bu dinamik hesaplama getter'ını yazdım.
  // Mantık:
  // 1) Egzersiz süresine göre: Her dakika için yaklaşık 5 ml su kaybı
  // 2) Kaloriye göre: Yakılan her kalori için yaklaşık 0.4 ml ek su (round ile en yakın tam sayıya yuvarladım)
  // Toplamı kullanıcıya "Bu egzersizden sonra şu kadar su içmelisin" tavsiyesi olarak dönüyor.
  int get recommendedWaterMl {
    final fromDuration = durationMinutes * 5;
    final fromCalories = (caloriesBurned * 0.4).round();
    return fromDuration + fromCalories;
  }

  // Saati ekranda "18:45" şeklinde temiz ve iki basamaklı gösterebilmek için yazdığım getter.
  // padLeft(2, '0') tek haneli sayıların (örn: 7) önüne '07' ekler.
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

