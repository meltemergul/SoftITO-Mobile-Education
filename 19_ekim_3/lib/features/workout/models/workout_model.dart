import 'package:flutter/foundation.dart';

/// Egzersiz türleri ve yoğunluk katsayıları
enum WorkoutType {
  running('Koşu', 12, 10.0), // ml/dk, kcal/dk
  cycling('Bisiklet', 9, 8.0),
  strength('Ağırlık Antrenmanı', 7, 6.0),
  cardio('HIIT / Kardiyo', 14, 11.0),
  yoga('Yoga / Esneme', 4, 3.5);

  final String label;
  final int waterPerMinuteMl; // Dakika başına önerilen ek su
  final double caloriesPerMinute;

  const WorkoutType(this.label, this.waterPerMinuteMl, this.caloriesPerMinute);
}

/// Tekil egzersiz kayıt modeli
@immutable
class WorkoutItem {
  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final int caloriesBurned;
  final int calculatedExtraWaterMl;
  final DateTime date;

  const WorkoutItem({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.calculatedExtraWaterMl,
    required this.date,
  });

  WorkoutItem copyWith({
    String? id,
    WorkoutType? type,
    int? durationMinutes,
    int? caloriesBurned,
    int? calculatedExtraWaterMl,
    DateTime? date,
  }) {
    return WorkoutItem(
      id: id ?? this.id,
      type: type ?? this.type,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      calculatedExtraWaterMl:
          calculatedExtraWaterMl ?? this.calculatedExtraWaterMl,
      date: date ?? this.date,
    );
  }

  factory WorkoutItem.create({
    required WorkoutType type,
    required int durationMinutes,
  }) {
    final calories = (durationMinutes * type.caloriesPerMinute).round();
    final water = durationMinutes * type.waterPerMinuteMl;
    return WorkoutItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      durationMinutes: durationMinutes,
      caloriesBurned: calories,
      calculatedExtraWaterMl: water,
      date: DateTime.now(),
    );
  }

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      id: json['id'] as String? ?? '',
      type: WorkoutType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => WorkoutType.cardio,
      ),
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      calculatedExtraWaterMl: json['calculatedExtraWaterMl'] as int? ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'calculatedExtraWaterMl': calculatedExtraWaterMl,
      'date': date.toIso8601String(),
    };
  }
}

/// Egzersiz modülü ana state modeli
@immutable
class WorkoutStateModel {
  final List<WorkoutItem> workouts;
  final int totalCalories;
  final int totalExtraWaterMl;

  const WorkoutStateModel({
    required this.workouts,
    required this.totalCalories,
    required this.totalExtraWaterMl,
  });

  factory WorkoutStateModel.initial() {
    return const WorkoutStateModel(
      workouts: [],
      totalCalories: 0,
      totalExtraWaterMl: 0,
    );
  }

  WorkoutStateModel copyWith({
    List<WorkoutItem>? workouts,
    int? totalCalories,
    int? totalExtraWaterMl,
  }) {
    return WorkoutStateModel(
      workouts: workouts ?? this.workouts,
      totalCalories: totalCalories ?? this.totalCalories,
      totalExtraWaterMl: totalExtraWaterMl ?? this.totalExtraWaterMl,
    );
  }
}
