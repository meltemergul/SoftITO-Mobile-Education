import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../models/workout_model.dart';

// Kullanıcının en çok yaptığı egzersizleri (Kardiyo, Ağırlık vb.)
// tek dokunuşla hızlıca kaydetmesini sağlayan ızgara (Grid) bileşeni.
class QuickWorkoutPresets extends StatelessWidget {
  final WorkoutController controller;
  // Egzersiz başarıyla eklendiğinde SnackBar göstermek için üst widget'a bildiren callback
  final void Function(WorkoutItem item)? onWorkoutAdded;

  const QuickWorkoutPresets({
    super.key,
    required this.controller,
    this.onWorkoutAdded,
  });

  // Önceden tanımladığım hazır spor şablonları:
  // Her şablonun süresi, yakacağı ortalama kalori ve ona özel neon rengi/ikonu var.
  static const List<_PresetWorkout> _presets = [
    _PresetWorkout(
      title: 'Kardiyo',
      category: 'Kardiyo',
      durationMinutes: 30,
      caloriesBurned: 240,
      icon: Icons.directions_run,
      color: AppColors.neonEnergy, // Canlı yeşil
    ),
    _PresetWorkout(
      title: 'Ağırlık',
      category: 'Fitness',
      durationMinutes: 45,
      caloriesBurned: 320,
      icon: Icons.fitness_center,
      color: AppColors.neonPurple, // Mor vurgu
    ),
    _PresetWorkout(
      title: 'HIIT',
      category: 'Yoğun',
      durationMinutes: 20,
      caloriesBurned: 220,
      icon: Icons.bolt,
      color: AppColors.neonCalorie, // Ateş turuncusu
    ),
    _PresetWorkout(
      title: 'Bisiklet',
      category: 'Kardiyo',
      durationMinutes: 35,
      caloriesBurned: 260,
      icon: Icons.directions_bike,
      color: AppColors.neonWater, // Neon su mavisi
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        const Text(
          'Hızlı Egzersiz Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Şablonları 2x2 ızgara şeklinde çizen widget
        _PresetsGrid(
          presets: _presets,
          onTap: (preset) {
            // Şablona tıklandığında controller'a yeni egzersiz ekletiyorum
            final item = controller.addWorkout(
              title: preset.title,
              category: preset.category,
              durationMinutes: preset.durationMinutes,
              caloriesBurned: preset.caloriesBurned,
            );
            // Ekleme başarılı olduysa üst widget'a iletip SnackBar açtırıyorum
            if (item != null && onWorkoutAdded != null) {
              onWorkoutAdded!(item);
            }
          },
        ),
      ],
    );
  }
}

// 2 sütunlu şablon ızgarasını oluşturan bileşen
class _PresetsGrid extends StatelessWidget {
  final List<_PresetWorkout> presets;
  final void Function(_PresetWorkout preset) onTap;

  const _PresetsGrid({required this.presets, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // GridView.builder: Elemanları grid (ızgara) düzeninde performanslı oluşturur
    return GridView.builder(
      // 'shrinkWrap: true': GridView'ın ana SingleChildScrollView içinde kendi boyutu kadar yer kaplamasını sağlar
      shrinkWrap: true,
      // 'physics: const NeverScrollableScrollPhysics()': Sayfa içinde çift kaydırma çubuğu olmasını engeller
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,       // Yan yana 2 kutu
        crossAxisSpacing: 10,     // Kutular arası yatay boşluk
        mainAxisSpacing: 10,      // Kutular arası dikey boşluk
        childAspectRatio: 2.2,    // Genişliğin yüksekliğe oranı (kutuların yatay dikdörtgen olması için)
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final item = presets[index];
        return _PresetTile(preset: item, onTap: () => onTap(item));
      },
    );
  }
}

// Hazır egzersiz şablonunun veri yapısını tutan yardımcı model
class _PresetWorkout {
  final String title;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final IconData icon;
  final Color color;

  const _PresetWorkout({
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.icon,
    required this.color,
  });
}

// Izgaradaki tek bir egzersiz kutusunun tasarımı
class _PresetTile extends StatelessWidget {
  final _PresetWorkout preset;
  final VoidCallback onTap;

  const _PresetTile({required this.preset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
        ),
        child: Row(
          children: [
            // İkonun arkasında yarı saydam (alpha: 0.15) şık bir neon daire oluşturmak için CircleAvatar kullandım
            CircleAvatar(
              radius: 18,
              backgroundColor: preset.color.withValues(alpha: 0.15),
              child: Icon(preset.icon, color: preset.color, size: 20),
            ),
            const SizedBox(width: 10),
            // Başlık, süre ve kalori metinleri
            Expanded(child: _PresetTileText(preset: preset)),
          ],
        ),
      ),
    );
  }
}

// Egzersiz kutusu içindeki başlık ve alt metinleri düzenleyen bileşen
class _PresetTileText extends StatelessWidget {
  final _PresetWorkout preset;

  const _PresetTileText({required this.preset});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Egzersiz adı
        Text(
          preset.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        // Süre ve kalori (Örn: 30 dk • 240 kcal)
        Text(
          '${preset.durationMinutes} dk • ${preset.caloriesBurned} kcal',
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

