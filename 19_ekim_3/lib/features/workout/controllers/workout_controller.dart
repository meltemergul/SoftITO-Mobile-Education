import 'package:flutter/foundation.dart';
import '../../water_tracker/controllers/water_tracker_controller.dart';
import '../models/workout_model.dart';

/// Egzersiz takibi iş mantığı ve reaktif durum yöneticisi
class WorkoutController {
  static final WorkoutController instance = WorkoutController();

  final ValueNotifier<WorkoutStateModel> state =
      ValueNotifier<WorkoutStateModel>(WorkoutStateModel.initial());

  /// Yeni bir egzersiz ekle ve su ihtiyacını otomatik hesapla
  void addWorkout(WorkoutType type, int durationMinutes) {
    if (durationMinutes <= 0) return;

    final item = WorkoutItem.create(
      type: type,
      durationMinutes: durationMinutes,
    );

    final current = state.value;
    final updatedList = [item, ...current.workouts];
    final totalCalories = current.totalCalories + item.caloriesBurned;
    final totalWater = current.totalExtraWaterMl + item.calculatedExtraWaterMl;

    state.value = current.copyWith(
      workouts: updatedList,
      totalCalories: totalCalories,
      totalExtraWaterMl: totalWater,
    );

    // Otomatik olarak su takip modülünün hedefini güncelle
    WaterTrackerController.instance
        .addWorkoutExtra(item.calculatedExtraWaterMl);
  }

  /// Tüm egzersizleri temizle
  void clearWorkouts() {
    state.value = WorkoutStateModel.initial();
  }

  void dispose() {
    state.dispose();
  }
}
