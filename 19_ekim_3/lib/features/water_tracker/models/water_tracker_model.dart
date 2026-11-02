import 'package:flutter/foundation.dart';

// Su takibine ait verileri değiştirilemez (immutable) bir model içerisinde tutuyorum.
@immutable
class WaterTrackerModel {
  // Kullanıcının gün içerisinde tükettiği toplam su miktarını mililitre cinsinden tutuyorum.
  final int currentWaterMl;

  // Kullanıcının günlük temel su hedefini mililitre cinsinden tutuyorum.
  final int baseGoalMl;

  // Egzersiz sonucunda günlük hedefe eklenen su miktarını tutuyorum.
  final int workoutExtraMl;

  // Su takibi verilerinin en son ne zaman güncellendiğini tutuyorum.
  final DateTime lastUpdated;

  // Model oluşturulurken tüm alanların verilmesini zorunlu kılıyorum.
  const WaterTrackerModel({
    required this.currentWaterMl,
    required this.baseGoalMl,
    required this.workoutExtraMl,
    required this.lastUpdated,
  });

  // Temel hedef ile egzersizden gelen ek su ihtiyacını toplayarak
  // kullanıcının toplam günlük su hedefini hesaplıyorum.
  int get totalGoalMl => baseGoalMl + workoutExtraMl;

  // Tüketilen suyun toplam hedefe oranını hesaplıyorum.
  double get progressRatio {
    // Hedef sıfırsa sıfıra bölme hatasını önlüyorum.
    if (totalGoalMl == 0) return 0.0;

    // Tüketilen su miktarını toplam hedefe bölüyorum.
    // clamp ile sonucu 0.0 ile 1.0 arasında tutuyorum.
    return (currentWaterMl / totalGoalMl).clamp(0.0, 1.0);
  }

  // Kullanıcının günlük hedefine ulaşması için içmesi gereken kalan suyu hesaplıyorum.
  int get remainingMl {
    // Hedeften tüketilen miktarı çıkarıyorum.
    final diff = totalGoalMl - currentWaterMl;

    // Kalan miktar negatifse 0 döndürüyorum.
    // Böylece hedef aşıldığında negatif su miktarı göstermiyorum.
    return diff > 0 ? diff : 0;
  }

  // Modelin mevcut değerlerini koruyarak yalnızca istenen alanları
  // güncelleyebileceğim yeni bir model nesnesi oluşturuyorum.
  WaterTrackerModel copyWith({
    int? currentWaterMl,
    int? baseGoalMl,
    int? workoutExtraMl,
    DateTime? lastUpdated,
  }) {
    return WaterTrackerModel(
      // Yeni değer verilmişse onu, verilmemişse mevcut değeri kullanıyorum.
      currentWaterMl: currentWaterMl ?? this.currentWaterMl,
      baseGoalMl: baseGoalMl ?? this.baseGoalMl,
      workoutExtraMl: workoutExtraMl ?? this.workoutExtraMl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Uygulama ilk açıldığında kullanılacak varsayılan su takip modelini oluşturuyorum.
  factory WaterTrackerModel.initial() {
    return WaterTrackerModel(
      currentWaterMl: 0,
      baseGoalMl: 2000,
      workoutExtraMl: 0,
      lastUpdated: DateTime.now(),
    );
  }

  // JSON formatındaki verileri WaterTrackerModel nesnesine dönüştürüyorum.
  // Böylece kayıtlı verileri uygulama içerisinde kullanabiliyorum.
  factory WaterTrackerModel.fromJson(Map<String, dynamic> json) {
    return WaterTrackerModel(
      // JSON içerisinde değer yoksa varsayılan olarak 0 kullanıyorum.
      currentWaterMl: json['currentWaterMl'] as int? ?? 0,
      baseGoalMl: json['baseGoalMl'] as int? ?? 2000,
      workoutExtraMl: json['workoutExtraMl'] as int? ?? 0,

      // Tarih verisi varsa DateTime nesnesine dönüştürüyorum.
      // Yoksa mevcut tarihi kullanıyorum.
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  // Model nesnesini JSON formatına dönüştürüyorum.
  // Böylece verileri yerel depolama veya API üzerinden saklayabiliyorum.
  Map<String, dynamic> toJson() {
    return {
      'currentWaterMl': currentWaterMl,
      'baseGoalMl': baseGoalMl,
      'workoutExtraMl': workoutExtraMl,

      // DateTime değerini JSON'da saklanabilecek String formatına dönüştürüyorum.
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
