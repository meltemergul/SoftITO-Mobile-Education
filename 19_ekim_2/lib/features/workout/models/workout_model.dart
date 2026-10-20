/// Egzersiz türlerini ve hidrasyon/kalori katsayılarını tanımlar.
enum WorkoutType {
  cardio('Kardiyo / Koşu', 10, 8),
  weightLifting('Ağırlık & Fitness', 8, 6),
  hiit('HIIT / Yoğun Antrenman', 14, 11),
  yogaPilates('Yoga & Esneme', 5, 4),
  swimming('Yüzme', 7, 7);

  final String label;
  /// Dakika başına gereken yaklaşık ek su miktarı (ml)
  final int waterPerMinuteMl;
  /// Dakika başına yaklaşık yakılan kalori
  final int caloriesPerMinute;

  const WorkoutType(this.label, this.waterPerMinuteMl, this.caloriesPerMinute);
}

/// Yapılan egzersiz kaydını temsil eden immutable veri modeli.
class WorkoutModel {
  final String id;
  final String title;
  final WorkoutType type;
  final int durationMinutes;
  final int caloriesBurned;
  final int recommendedWaterMl;
  final DateTime timestamp;

  const WorkoutModel({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.recommendedWaterMl,
    required this.timestamp,
  });

  /// Süre ve tipe göre tavsiye edilen su miktarını hesaplar
  static int calculateWaterNeed(WorkoutType type, int durationMinutes) {
    return type.waterPerMinuteMl * durationMinutes;
  }

  /// Süre ve tipe göre yakılan kaloriyi hesaplar
  static int calculateCalories(WorkoutType type, int durationMinutes) {
    return type.caloriesPerMinute * durationMinutes;
  }

  WorkoutModel copyWith({
    String? id,
    String? title,
    WorkoutType? type,
    int? durationMinutes,
    int? caloriesBurned,
    int? recommendedWaterMl,
    DateTime? timestamp,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      recommendedWaterMl: recommendedWaterMl ?? this.recommendedWaterMl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: WorkoutType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WorkoutType.cardio,
      ),
      durationMinutes: json['durationMinutes'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      recommendedWaterMl: json['recommendedWaterMl'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'recommendedWaterMl': recommendedWaterMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
