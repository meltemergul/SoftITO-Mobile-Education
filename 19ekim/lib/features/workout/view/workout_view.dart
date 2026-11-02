import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../models/workout_model.dart';
import '../widget/quick_workout_presets.dart';
import '../widget/workout_history_list.dart';
import '../widget/workout_summary_card.dart';

// Egzersiz & Kalori ekranının ana görünüm (View) bileşeni.
class WorkoutView extends StatelessWidget {
  final WorkoutController controller;

  // Bu callback (geri çağırma fonksiyonu) çok havalı bir özellik sağlıyor:
  // Egzersiz ekledikten sonra açılan SnackBar'da kullanıcı "İçtim" butonuna basarsa,
  // main.dart seviyesindeki Su Takibi controller'ına su ekleme emri gönderiyoruz!
  final void Function(int amountMl)? onQuickWaterAdd;

  const WorkoutView({
    super.key,
    required this.controller,
    this.onQuickWaterAdd,
  });

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder: WorkoutController'ı dinleyerek egzersiz eklendiğinde/silindiğinde
    // sadece bu ekranı verimli şekilde günceller.
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bölüm: Yakılan kalori, süre, egzersiz adedi ve ek su özet kartı
              WorkoutSummaryCard(controller: controller),
              const SizedBox(height: 24),

              // 2. Bölüm: Hızlı egzersiz kartları (Kardiyo, Ağırlık, HIIT, Bisiklet)
              QuickWorkoutPresets(
                controller: controller,
                // Yeni bir egzersiz eklendiğinde ekranda hidrasyon uyarısı (SnackBar) gösteriyorum
                onWorkoutAdded: (item) => _showHydrationAlert(context, item),
              ),
              const SizedBox(height: 28),

              // 3. Bölüm: "Egzersiz Geçmişi" başlığı ve Sıfırla butonu
              _WorkoutSectionHeader(onReset: controller.resetDaily),
              const SizedBox(height: 12),

              // 4. Bölüm: Tamamlanan egzersizlerin listesi
              WorkoutHistoryList(controller: controller),
            ],
          ),
        );
      },
    );
  }

  // Egzersiz tamamlandığında ekranın altından kayan modern bir bilgilendirme çubuğu (SnackBar) gösteriyorum
  void _showHydrationAlert(BuildContext context, WorkoutItem item) {
    // Eğer ekranda daha önceden kalma bir SnackBar varsa beklemeden hemen kapat
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating, // Ekranın altına yapışık olmak yerine havada yüzen (floating) modern kart
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.neonWater, width: 1), // Neon su mavisi kenarlık
        ),
        content: _HydrationAlertContent(item: item),
        // Eğer dışarıdan onQuickWaterAdd fonksiyonu iletildiyse bir "İçtim" butonu ekle
        action: onQuickWaterAdd != null
            ? SnackBarAction(
                label: 'İçtim',
                textColor: AppColors.neonEnergy, // Canlı neon yeşil buton yazısı
                onPressed: () => onQuickWaterAdd!(item.recommendedWaterMl),
              )
            : null,
        duration: const Duration(seconds: 4), // 4 saniye boyunca ekranda kalır
      ),
    );
  }
}

// SnackBar'ın içindeki ikon ve açıklamaları tutan özel bileşen
class _HydrationAlertContent extends StatelessWidget {
  final WorkoutItem item;

  const _HydrationAlertContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.water_drop, color: AppColors.neonWater, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.title} tamamlandı (+${item.caloriesBurned} kcal)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'Gereken ek su: +${item.recommendedWaterMl} ml hedefinize eklendi.',
                style: const TextStyle(color: AppColors.neonWater, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Egzersiz geçmişi başlığını ve sıfırlama butonunu içeren satır
class _WorkoutSectionHeader extends StatelessWidget {
  final VoidCallback onReset;

  const _WorkoutSectionHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Egzersiz Geçmişi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onReset,
          child: const Text(
            'Sıfırla',
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

