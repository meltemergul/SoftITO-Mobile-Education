import 'package:flutter/foundation.dart';
import '../models/water_log_model.dart';

// Su takibi modülünün durum yönetimini (State Management) bu controller ile yönetiyorum.
// Flutter'ın yerleşik sınıfıdır. Veriler değiştiğinde `notifyListeners()` metodunu çağırarak
// bu sınıfı dinleyen (ListenableBuilder vb.) widget'ların kendilerini yeniden çizmesini (rebuild) sağlar.
class WaterTrackerController extends ChangeNotifier {
  // Değişkenleri alt çizgi (_) ile 'private' yaptım ki dışarıdan doğrudan değiştirilemesin (Kapsülleme - Encapsulation).
  int _baseDailyGoalMl = 2500;       // Kullanıcının varsayılan günlük su hedefi (ml)
  int _extraWorkoutWaterMl = 0;      // Yapılan egzersizlerden gelen ek su ihtiyacı (ml)
  final List<WaterLog> _logs = [];   // Eklenen su kayıtlarını tuttuğum iç liste

  // Dışarıdan bu değerleri sadece okuyabilmek için getter'lar tanımladım:
  int get baseDailyGoalMl => _baseDailyGoalMl;
  int get extraWorkoutWaterMl => _extraWorkoutWaterMl;

  // Toplam günlük hedef: Temel hedef + Egzersizden gelen ek miktar
  int get dailyGoalMl => _baseDailyGoalMl + _extraWorkoutWaterMl;

  // Neden 'List.unmodifiable'?
  // Dışarıdan birisi `controller.logs.add(...)` diyerek listeyi doğrudan manipüle etmesin diye.
  // Liste sadece salt-okunur (read-only) olarak dışarıya açılır; ekleme ve silme sadece controller metodlarıyla yapılır.
  List<WaterLog> get logs => List.unmodifiable(_logs);

  // Gün içinde toplam içilen su miktarını hesaplayan getter.
  // Dart'ın 'fold' metodunu kullandım: 0 başlangıç değerinden başlayarak listedeki her bir kaydın
  // amountMl değerini toplar (JavaScript'teki 'reduce' fonksiyonu gibi).
  int get currentAmountMl {
    return _logs.fold<int>(0, (total, log) => total + log.amountMl);
  }

  // İlerleme çubuğu veya dairesel gösterge için 0.0 ile 1.0 arasında bir oran döndürür.
  double get progressPercentage {
    // 0'a bölme hatasını (division by zero) engellemek için kontrol koydum
    if (dailyGoalMl == 0) return 0.0;
    final ratio = currentAmountMl / dailyGoalMl;
    // Eğer hedeften fazla su içilirse gösterge taşmasın, maksimum 1.0 (%100) kalsın
    return ratio > 1.0 ? 1.0 : ratio;
  }

  // Hedefe ulaşmak için kalan su miktarını hesaplıyorum.
  // Negatif değer çıkmasın diye hedef aşıldığında 0 döndürüyorum.
  int get remainingMl {
    final remaining = dailyGoalMl - currentAmountMl;
    return remaining > 0 ? remaining : 0;
  }

  // Kullanıcı temel su hedefini değiştirmek isterse
  void setDailyGoal(int goal) {
    if (goal > 0 && goal != _baseDailyGoalMl) {
      _baseDailyGoalMl = goal;
      // Ekrandaki göstergelerin güncellenmesi için dinleyicilere haber veriyorum
      notifyListeners();
    }
  }

  // Egzersiz modülünden gelen ek su ihtiyacını güncelleyen metod
  void setExtraWorkoutWater(int extraMl) {
    final validExtra = extraMl > 0 ? extraMl : 0;
    if (_extraWorkoutWaterMl != validExtra) {
      _extraWorkoutWaterMl = validExtra;
      // Hedef değiştiği için UI'ın yeniden çizilmesini tetikliyorum
      notifyListeners();
    }
  }

  // Yeni su içme kaydı ekleyen metod
  void addWater(int amountMl) {
    // 0 veya negatif miktar girilmesini engelliyorum
    if (amountMl <= 0) return;

    // Benzersiz bir ID üretmek için o anki zamanın mikrosaniyesini kullandım (pratik ve çakışmasız)
    final log = WaterLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );

    // Son eklenen kaydın listenin en başında görünmesi için 'add' yerine 'insert(0, ...)' kullandım
    _logs.insert(0, log);

    // Ekranı güncelle
    notifyListeners();
  }

  // Belirli bir su kaydını silmek için
  void removeLog(String id) {
    _logs.removeWhere((item) => item.id == id);
    // Kayıt silindiğinde toplam miktar ve liste değiştiği için haber veriyorum
    notifyListeners();
  }

  // Gün sonunda veya kullanıcı istediğinde tüm kayıtları sıfırlayan metod
  void resetDaily() {
    _logs.clear();
    notifyListeners();
  }
}

