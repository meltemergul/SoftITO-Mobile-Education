import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/workout_controller.dart';
import '../models/workout_model.dart';
import '../widget/quick_workout_presets.dart';
import '../widget/workout_history_list.dart';
import '../widget/workout_summary_card.dart';

class WorkoutView extends StatelessWidget {
  final WorkoutController controller;
  final void Function(int amountMl)? onQuickWaterAdd;

  const WorkoutView({
    super.key,
    required this.controller,
    this.onQuickWaterAdd,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkoutSummaryCard(controller: controller),
              const SizedBox(height: 24),
              QuickWorkoutPresets(
                controller: controller,
                onWorkoutAdded: (item) => _showHydrationAlert(context, item),
              ),
              const SizedBox(height: 28),
              _WorkoutSectionHeader(onReset: controller.resetDaily),
              const SizedBox(height: 12),
              WorkoutHistoryList(controller: controller),
            ],
          ),
        );
      },
    );
  }

  void _showHydrationAlert(BuildContext context, WorkoutItem item) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.neonWater, width: 1),
        ),
        content: _HydrationAlertContent(item: item),
        action: onQuickWaterAdd != null
            ? SnackBarAction(
                label: 'İçtim',
                textColor: AppColors.neonEnergy,
                onPressed: () => onQuickWaterAdd!(item.recommendedWaterMl),
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

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
