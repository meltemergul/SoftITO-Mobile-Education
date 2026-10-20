import 'package:flutter/foundation.dart';
import '../models/water_record_model.dart';

/// Su takip mantığını ve ValueNotifier durumlarını yöneten Controller sınıfı.
class WaterTrackerController {
  // Temel günlük hedef (varsayılan 2000 ml)
  static const int defaultBaseGoal = 2000;

  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);
  final ValueNotifier<int> baseGoal = ValueNotifier<int>(defaultBaseGoal);
  final ValueNotifier<int> workoutExtraGoal = ValueNotifier<int>(0);
  final ValueNotifier<List<WaterRecordModel>> records =
      ValueNotifier<List<WaterRecordModel>>([]);
  final ValueNotifier<String?> alertMessage = ValueNotifier<String?>(null);

  /// Egzersizlerden gelen ek su miktarı dahil toplam hedef
  int get totalDailyGoal => baseGoal.value + workoutExtraGoal.value;

  /// Hedefe ulaşma yüzdesi (0.0 - 1.0)
  double get progressRatio {
    if (totalDailyGoal == 0) return 0.0;
    final ratio = currentWater.value / totalDailyGoal;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  /// Su tüketimi ekler
  void addWater(int amount, {String source = 'Manuel'}) {
    if (amount <= 0) return;
    currentWater.value += amount;

    final newRecord = WaterRecordModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amount,
      timestamp: DateTime.now(),
      source: source,
    );
    records.value = [newRecord, ...records.value];

    if (currentWater.value >= totalDailyGoal) {
      alertMessage.value =
          'Tebrikler! Günlük su hedefine başarıyla ulaştın. Harika gidiyorsun!';
    } else {
      alertMessage.value = '+$amount ml su kaydedildi.';
    }
  }

  /// Egzersiz yapıldığında günlük su hedefini otomatik artırır
  void addWorkoutHydrationNeed(int extraMl, String workoutTitle) {
    if (extraMl <= 0) return;
    workoutExtraGoal.value += extraMl;
    alertMessage.value =
        '$workoutTitle egzersizi için +$extraMl ml hidrasyon ihtiyacı hedefinize eklendi!';
  }

  /// Su tüketimini ve kayıtlarını sıfırlar
  void resetWater() {
    currentWater.value = 0;
    records.value = [];
    alertMessage.value = 'Günlük su tüketim verileri sıfırlandı.';
  }

  /// Bildirim mesajını temizler
  void clearAlert() {
    alertMessage.value = null;
  }

  /// Controller kaynaklarını serbest bırakır
  void dispose() {
    currentWater.dispose();
    baseGoal.dispose();
    workoutExtraGoal.dispose();
    records.dispose();
    alertMessage.dispose();
  }
}
