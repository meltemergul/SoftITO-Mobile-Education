import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

// Egzersiz modülünün iş mantığını (Business Logic) ve durumunu (State) yöneten sınıfım.
// 'ChangeNotifier' sınıfından türettim, böylece egzersiz eklendiğinde veya silindiğinde
// 'notifyListeners()' çağırarak arayüze haber verebiliyorum.
class WorkoutController extends ChangeNotifier {
  int _dailyCalorieGoal = 600;         // Günlük hedeflenen yakılacak kalori (kcal)
  final List<WorkoutItem> _workouts = []; // Yapılan egzersizlerin tutulduğu özel liste

  // Dışarıdan hedefe ve egzersiz listesine salt-okunur erişim sağlamak için getter'lar:
  int get dailyCalorieGoal => _dailyCalorieGoal;

  // List.unmodifiable ile dışarıdan listenin doğrudan bozulmasını (örn: workouts.add yapılmasını) engelliyorum
  List<WorkoutItem> get workouts => List.unmodifiable(_workouts);

  // Gün boyunca yakılan toplam kaloriyi hesaplıyorum.
  // 'fold' metodu: Başlangıç değeri 0 olan bir toplam değişkenine her egzersizin 'caloriesBurned' değerini ekler.
  int get totalCaloriesBurned {
    return _workouts.fold<int>(0, (total, item) => total + item.caloriesBurned);
  }

  // Toplam antrenman süresini (dakika) hesaplayan getter
  int get totalDurationMinutes {
    return _workouts.fold<int>(0, (total, item) => total + item.durationMinutes);
  }

  /// Tüm egzersizlerden kaynaklanan toplam ek hidrasyon ihtiyacı (ml)
  // Bu getter çok önemli! Egzersizlerden çıkan ek su ihtiyacını toplayıp
  // main.dart üzerinden Su Takibi controller'ına aktaracağız.
  int get totalRecommendedWaterMl {
    return _workouts.fold<int>(0, (total, item) => total + item.recommendedWaterMl);
  }

  // İlerleme çubuğunda (ProgressBar) göstermek için 0.0 - 1.0 aralığında oran hesabı
  double get calorieProgress {
    if (_dailyCalorieGoal == 0) return 0.0;
    final ratio = totalCaloriesBurned / _dailyCalorieGoal;
    // Hedef aşılırsa çubuk patlamasın diye en fazla 1.0 (%100) döndürüyorum
    return ratio > 1.0 ? 1.0 : ratio;
  }

  // Kullanıcı günlük kalori hedefini güncellemek isterse
  void setDailyCalorieGoal(int goal) {
    if (goal > 0 && goal != _dailyCalorieGoal) {
      _dailyCalorieGoal = goal;
      notifyListeners();
    }
  }

  // Yeni bir egzersiz ekleme metodu.
  // Dönüş tipini 'WorkoutItem?' yaptım: Eğer ekleme başarılı olursa oluşturulan nesneyi geri döndürür,
  // böylece View katmanı bu nesneyi alıp kullanıcıya "Şu kadar su içmelisin" şeklinde SnackBar gösterebilir!
  WorkoutItem? addWorkout({
    required String title,
    required String category,
    required int durationMinutes,
    required int caloriesBurned,
  }) {
    // Geçersiz değer kontrolü
    if (durationMinutes <= 0 || caloriesBurned <= 0) return null;

    final item = WorkoutItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // Benzersiz ID
      title: title,
      category: category,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      timestamp: DateTime.now(),
    );

    // Yeni egzersizi listenin başına ekliyorum
    _workouts.insert(0, item);

    // Dinleyicileri haberdar edip ekranı yeniliyorum
    notifyListeners();

    // Eklenen nesneyi UI'ın kullanabilmesi için geri döndürüyorum
    return item;
  }

  // ID'ye göre egzersiz kaydını listeden silme
  void removeWorkout(String id) {
    _workouts.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Tüm egzersiz kayıtlarını temizleyen metod
  void resetDaily() {
    _workouts.clear();
    notifyListeners();
  }
}

