import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';

class WaterProgressCard extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterProgressCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            _ProgressCircle(controller: controller),
            const SizedBox(width: 24),
            Expanded(child: _ProgressStats(controller: controller)),
          ],
        ),
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  final WaterTrackerController controller;

  const _ProgressCircle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final percent = controller.progressPercentage;
    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 9,
            backgroundColor: AppColors.surfaceBorder,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonWater),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(percent * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonWater,
                  ),
                ),
                const Text(
                  'Hedef',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressStats extends StatelessWidget {
  final WaterTrackerController controller;

  const _ProgressStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Günlük Tüketim',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        _GoalRow(controller: controller),
        if (controller.extraWorkoutWaterMl > 0) ...[
          const SizedBox(height: 4),
          _WorkoutHydrationBadge(extraMl: controller.extraWorkoutWaterMl),
        ],
        const SizedBox(height: 8),
        _RemainingText(remainingMl: controller.remainingMl),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final WaterTrackerController controller;

  const _GoalRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${controller.currentAmountMl}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '/ ${controller.dailyGoalMl} ml',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _WorkoutHydrationBadge extends StatelessWidget {
  final int extraMl;

  const _WorkoutHydrationBadge({required this.extraMl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bolt, size: 14, color: AppColors.neonEnergy),
        const SizedBox(width: 4),
        Text(
          '+$extraMl ml egzersiz hidrasyonu',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.neonEnergy,
          ),
        ),
      ],
    );
  }
}

class _RemainingText extends StatelessWidget {
  final int remainingMl;

  const _RemainingText({required this.remainingMl});

  @override
  Widget build(BuildContext context) {
    return Text(
      remainingMl == 0
          ? 'Tebrikler! Günlük hedef tamamlandı.'
          : 'Kalan: $remainingMl ml',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: remainingMl == 0 ? AppColors.neonEnergy : AppColors.textSecondary,
      ),
    );
  }
}
