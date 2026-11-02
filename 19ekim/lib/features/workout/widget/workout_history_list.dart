import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../models/workout_model.dart';

// Tamamlanan egzersizlerin kronolojik geçmişini listeleyen bileşen.
class WorkoutHistoryList extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutHistoryList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final workouts = controller.workouts;

    // Eğer kullanıcı henüz hiç egzersiz kaydetmediyse boş durum tasarımı gösteriyorum
    if (workouts.isEmpty) {
      return const _EmptyWorkoutPlaceholder();
    }

    // ListView.separated ile her egzersiz kartının arasına 8px boşluk koyuyorum
    return ListView.separated(
      // Dıştaki SingleChildScrollView ile çakışmaması için shrinkWrap ve NeverScrollableScrollPhysics kullandım
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = workouts[index];
        return _WorkoutHistoryTile(
          item: item,
          // Silme butonuna basıldığında controller üzerinden kaydı siliyorum
          onDelete: () => controller.removeWorkout(item.id),
        );
      },
    );
  }
}

// Henüz egzersiz yapılmadığında ekranda beliren şık dumble ikonlu boş durum bileşeni
class _EmptyWorkoutPlaceholder extends StatelessWidget {
  const _EmptyWorkoutPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.fitness_center_outlined, color: AppColors.surfaceBorder, size: 40),
          SizedBox(height: 8),
          Text(
            'Henüz tamamlanan egzersiz kaydı yok.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// Listede tek bir egzersiz satırının kart tasarımı
class _WorkoutHistoryTile extends StatelessWidget {
  final WorkoutItem item;
  final VoidCallback onDelete;

  const _WorkoutHistoryTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
      ),
      child: Row(
        children: [
          // Sol başta neon enerji şimşeği ikonu
          const Icon(Icons.bolt, color: AppColors.neonEnergy, size: 22),
          const SizedBox(width: 12),

          // Egzersiz adı ve süre bilgisi (Expanded: Yatayda kalan yeri doldurur)
          Expanded(child: _WorkoutTileInfo(item: item)),

          // Sağ tarafta yakılan kalori ve gereken ek su miktarı
          _WorkoutMetricsColumn(item: item),

          // Silme butonu (çarpı ikonu)
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            onPressed: onDelete,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

// Egzersiz başlığını ve süre / kategori açıklamasını alt alta yazan bileşen
class _WorkoutTileInfo extends StatelessWidget {
  final WorkoutItem item;

  const _WorkoutTileInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Egzersiz adı (Örn: Kardiyo)
        Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        // Süre ve kategori (Örn: 30 dakika • Kardiyo)
        Text(
          '${item.durationMinutes} dakika • ${item.category}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

// Kartın sağında yer alan kalori ve ek su miktarını gösteren sütun
class _WorkoutMetricsColumn extends StatelessWidget {
  final WorkoutItem item;

  const _WorkoutMetricsColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Yazıları sağa yaslamak için
      mainAxisSize: MainAxisSize.min,
      children: [
        // Yakılan kalori (Örn: +240 kcal)
        Text(
          '+${item.caloriesBurned} kcal',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.neonCalorie,
            fontSize: 14,
          ),
        ),
        // İhtiyaç duyulan ek su (Örn: +246 ml su)
        Text(
          '+${item.recommendedWaterMl} ml su',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.neonWater,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

