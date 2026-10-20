import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

/// Egzersiz kayıtlarını yöneten ve otomatik su ihtiyacı bildiren Controller.
class WorkoutController {
  final void Function(int extraWaterMl, String workoutTitle)? onWorkoutAdded;

  final ValueNotifier<List<WorkoutModel>> workouts =
      ValueNotifier<List<WorkoutModel>>([]);
  final ValueNotifier<int> totalMinutes = ValueNotifier<int>(0);
  final ValueNotifier<int> totalCalories = ValueNotifier<int>(0);
  final ValueNotifier<int> totalExtraWater = ValueNotifier<int>(0);

  WorkoutController({this.onWorkoutAdded});

  /// Yeni bir egzersiz ekler ve otomatik ek su ihtiyacını tetikler
  void addWorkout({
    required String title,
    required WorkoutType type,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) return;

    final waterNeed =
        WorkoutModel.calculateWaterNeed(type, durationMinutes);
    final calories =
        WorkoutModel.calculateCalories(type, durationMinutes);

    final workout = WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.isEmpty ? type.label : title,
      type: type,
      durationMinutes: durationMinutes,
      caloriesBurned: calories,
      recommendedWaterMl: waterNeed,
      timestamp: DateTime.now(),
    );

    workouts.value = [workout, ...workouts.value];
    totalMinutes.value += durationMinutes;
    totalCalories.value += calories;
    totalExtraWater.value += waterNeed;

    // Su takipçisine otomatik hidrasyon ihtiyacını bildir
    onWorkoutAdded?.call(waterNeed, workout.title);
  }

  /// Egzersiz kaydını siler
  void removeWorkout(String id) {
    final index = workouts.value.indexWhere((w) => w.id == id);
    if (index != -1) {
      final removed = workouts.value[index];
      totalMinutes.value -= removed.durationMinutes;
      totalCalories.value -= removed.caloriesBurned;
      totalExtraWater.value -= removed.recommendedWaterMl;

      final updated = List<WorkoutModel>.from(workouts.value)..removeAt(index);
      workouts.value = updated;
    }
  }

  void dispose() {
    workouts.dispose();
    totalMinutes.dispose();
    totalCalories.dispose();
    totalExtraWater.dispose();
  }
}
