import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutController extends ChangeNotifier {
  int _dailyCalorieGoal = 600;
  final List<WorkoutItem> _workouts = [];

  int get dailyCalorieGoal => _dailyCalorieGoal;
  List<WorkoutItem> get workouts => List.unmodifiable(_workouts);

  int get totalCaloriesBurned {
    return _workouts.fold<int>(0, (total, item) => total + item.caloriesBurned);
  }

  int get totalDurationMinutes {
    return _workouts.fold<int>(0, (total, item) => total + item.durationMinutes);
  }

  /// Tüm egzersizlerden kaynaklanan toplam ek hidrasyon ihtiyacı (ml)
  int get totalRecommendedWaterMl {
    return _workouts.fold<int>(0, (total, item) => total + item.recommendedWaterMl);
  }

  double get calorieProgress {
    if (_dailyCalorieGoal == 0) return 0.0;
    final ratio = totalCaloriesBurned / _dailyCalorieGoal;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  void setDailyCalorieGoal(int goal) {
    if (goal > 0 && goal != _dailyCalorieGoal) {
      _dailyCalorieGoal = goal;
      notifyListeners();
    }
  }

  WorkoutItem? addWorkout({
    required String title,
    required String category,
    required int durationMinutes,
    required int caloriesBurned,
  }) {
    if (durationMinutes <= 0 || caloriesBurned <= 0) return null;
    final item = WorkoutItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      category: category,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      timestamp: DateTime.now(),
    );
    _workouts.insert(0, item);
    notifyListeners();
    return item;
  }

  void removeWorkout(String id) {
    _workouts.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void resetDaily() {
    _workouts.clear();
    notifyListeners();
  }
}
