import 'package:flutter/foundation.dart';

/// Su takibi değişmez (immutable) veri modeli
@immutable
class WaterTrackerModel {
  final int currentWaterMl;
  final int baseGoalMl;
  final int workoutExtraMl;
  final DateTime lastUpdated;

  const WaterTrackerModel({
    required this.currentWaterMl,
    required this.baseGoalMl,
    required this.workoutExtraMl,
    required this.lastUpdated,
  });

  /// Toplam günlük hedef (temel hedef + egzersizden gelen ek su ihtiyacı)
  int get totalGoalMl => baseGoalMl + workoutExtraMl;

  /// Hedefe ulaşma oranı (0.0 - 1.0 aralığı)
  double get progressRatio {
    if (totalGoalMl == 0) return 0.0;
    return (currentWaterMl / totalGoalMl).clamp(0.0, 1.0);
  }

  /// Hedefe kalan miktar
  int get remainingMl {
    final diff = totalGoalMl - currentWaterMl;
    return diff > 0 ? diff : 0;
  }

  WaterTrackerModel copyWith({
    int? currentWaterMl,
    int? baseGoalMl,
    int? workoutExtraMl,
    DateTime? lastUpdated,
  }) {
    return WaterTrackerModel(
      currentWaterMl: currentWaterMl ?? this.currentWaterMl,
      baseGoalMl: baseGoalMl ?? this.baseGoalMl,
      workoutExtraMl: workoutExtraMl ?? this.workoutExtraMl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory WaterTrackerModel.initial() {
    return WaterTrackerModel(
      currentWaterMl: 0,
      baseGoalMl: 2000,
      workoutExtraMl: 0,
      lastUpdated: DateTime.now(),
    );
  }

  factory WaterTrackerModel.fromJson(Map<String, dynamic> json) {
    return WaterTrackerModel(
      currentWaterMl: json['currentWaterMl'] as int? ?? 0,
      baseGoalMl: json['baseGoalMl'] as int? ?? 2000,
      workoutExtraMl: json['workoutExtraMl'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentWaterMl': currentWaterMl,
      'baseGoalMl': baseGoalMl,
      'workoutExtraMl': workoutExtraMl,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
