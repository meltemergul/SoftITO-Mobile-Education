import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';

// Egzersiz sayfasının en üstündeki gösterişli özet kartı bileşeni.
// Yakılan kaloriyi, ilerleme çubuğunu ve 3 ana istatistiği (süre, adet, ek su) gösterir.
class WorkoutSummaryCard extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Üst Kısım: "Yakılan Kalori" başlığı ve büyük kalori/hedef rakamları
            _SummaryHeader(controller: controller),
            const SizedBox(height: 16),

            // 2. Orta Kısım: Turuncu neon kalori ilerleme çubuğu
            _CalorieProgressBar(progress: controller.calorieProgress),
            const SizedBox(height: 16),

            // 3. Alt Kısım: Süre, Egzersiz Sayısı ve Ek Su İhtiyacını gösteren 3'lü sütun
            _StatsRow(controller: controller),
          ],
        ),
      ),
    );
  }
}

// Kartın üst başlık satırı (Yakılan Kalori / Hedef Kalori)
class _SummaryHeader extends StatelessWidget {
  final WorkoutController controller;

  const _SummaryHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol taraf: Başlıklar
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Yakılan Kalori',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            SizedBox(height: 2),
            Text(
              'Günlük Hedef',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        // Sağ taraf: Büyük kalori rakamı ve hedef
        Row(
          // crossAxisAlignment.baseline: Rakam ile 'kcal' yazısının tabanlarını eşitler
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${controller.totalCaloriesBurned}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.neonCalorie, // Ateş rengi turuncu
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/ ${controller.dailyCalorieGoal} kcal',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

// Kalori doluluk oranını gösteren yatay çizgi göstergesi
class _CalorieProgressBar extends StatelessWidget {
  final double progress;

  const _CalorieProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    // ClipRRect: Çizginin kenarlarını yuvarlatıp (BorderRadius.circular(8)) keskin köşeleri yumuşatmak için kullandım
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,      // 0.0 - 1.0 aralığındaki doluluk değeri
        minHeight: 10,        // Çubuğun kalınlığı
        backgroundColor: AppColors.surfaceBorder, // Boş alanın koyu kenarlık tonu
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCalorie), // Dolu alanın neon turuncusu
      ),
    );
  }
}

// Kartın altındaki 3'lü istatistik satırı
class _StatsRow extends StatelessWidget {
  final WorkoutController controller;

  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Metrikleri satıra eşit dağıtmak için
      children: [
        // 1. İstatistik: Toplam antrenman süresi
        _MetricItem(
          icon: Icons.timer_outlined,
          color: AppColors.neonEnergy,
          title: 'Toplam Süre',
          value: '${controller.totalDurationMinutes} dk',
        ),

        // Araya koyduğum şık dikey ayırıcı çizgi
        Container(width: 1, height: 28, color: AppColors.surfaceBorder),

        // 2. İstatistik: Tamamlanan egzersiz adedi
        _MetricItem(
          icon: Icons.fitness_center,
          color: AppColors.neonPurple,
          title: 'Tamamlanan',
          value: '${controller.workouts.length}',
        ),

        // Dikey ayırıcı çizgi
        Container(width: 1, height: 28, color: AppColors.surfaceBorder),

        // 3. İstatistik: Egzersizlerden gelen toplam ek su ihtiyacı
        _MetricItem(
          icon: Icons.water_drop,
          color: AppColors.neonWater,
          title: 'Ek Su İhtiyacı',
          value: '+${controller.totalRecommendedWaterMl} ml',
        ),
      ],
    );
  }
}

// İkon, minik başlık ve değerden oluşan tek bir metrik hücresi
class _MetricItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Renkli ikon
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        // Başlık ve değer alt alta
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

