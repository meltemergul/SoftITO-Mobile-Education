import 'package:flutter/foundation.dart';
import '../models/water_tracker_model.dart';

/// Su takibi iş mantığı ve reaktif durum yöneticisi (ValueNotifier)
class WaterTrackerController {
  static final WaterTrackerController instance = WaterTrackerController();

  final ValueNotifier<WaterTrackerModel> state =
      ValueNotifier<WaterTrackerModel>(WaterTrackerModel.initial());

  /// Su tüketimi ekle (örn. 150ml, 250ml, 500ml)
  void addWater(int amountMl) {
    if (amountMl <= 0) return;
    final current = state.value;
    state.value = current.copyWith(
      currentWaterMl: current.currentWaterMl + amountMl,
      lastUpdated: DateTime.now(),
    );
  }

  /// Egzersizden gelen ek su ihtiyacını hedefe dahil et
  void addWorkoutExtra(int extraMl) {
    if (extraMl <= 0) return;
    final current = state.value;
    state.value = current.copyWith(
      workoutExtraMl: current.workoutExtraMl + extraMl,
      lastUpdated: DateTime.now(),
    );
  }

  /// Günlük sayacı sıfırla
  void resetWater() {
    final current = state.value;
    state.value = current.copyWith(
      currentWaterMl: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Bellek sızıntısını önlemek için dinleyicileri serbest bırak
  void dispose() {
    state.dispose();
  }
}
