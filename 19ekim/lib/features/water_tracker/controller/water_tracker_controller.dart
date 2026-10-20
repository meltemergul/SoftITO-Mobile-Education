import 'package:flutter/foundation.dart';
import '../models/water_log_model.dart';

class WaterTrackerController extends ChangeNotifier {
  int _baseDailyGoalMl = 2500;
  int _extraWorkoutWaterMl = 0;
  final List<WaterLog> _logs = [];

  int get baseDailyGoalMl => _baseDailyGoalMl;
  int get extraWorkoutWaterMl => _extraWorkoutWaterMl;
  int get dailyGoalMl => _baseDailyGoalMl + _extraWorkoutWaterMl;
  List<WaterLog> get logs => List.unmodifiable(_logs);

  int get currentAmountMl {
    return _logs.fold<int>(0, (total, log) => total + log.amountMl);
  }

  double get progressPercentage {
    if (dailyGoalMl == 0) return 0.0;
    final ratio = currentAmountMl / dailyGoalMl;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  int get remainingMl {
    final remaining = dailyGoalMl - currentAmountMl;
    return remaining > 0 ? remaining : 0;
  }

  void setDailyGoal(int goal) {
    if (goal > 0 && goal != _baseDailyGoalMl) {
      _baseDailyGoalMl = goal;
      notifyListeners();
    }
  }

  void setExtraWorkoutWater(int extraMl) {
    final validExtra = extraMl > 0 ? extraMl : 0;
    if (_extraWorkoutWaterMl != validExtra) {
      _extraWorkoutWaterMl = validExtra;
      notifyListeners();
    }
  }

  void addWater(int amountMl) {
    if (amountMl <= 0) return;
    final log = WaterLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    _logs.insert(0, log);
    notifyListeners();
  }

  void removeLog(String id) {
    _logs.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void resetDaily() {
    _logs.clear();
    notifyListeners();
  }
}
