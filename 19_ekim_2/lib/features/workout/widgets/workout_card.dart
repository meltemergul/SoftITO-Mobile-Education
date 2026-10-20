import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/workout_model.dart';

/// Yapılan egzersizi listeleyen neon temalı kart bileşeni.
class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildIconBadge(),
          const SizedBox(width: 14),
          Expanded(child: _buildInfoColumn(context)),
          _buildHydrationBadge(context),
        ],
      ),
    );
  }

  Widget _buildIconBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.neonOrange.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.fitness_center_rounded,
        color: AppColors.neonOrange,
        size: 24,
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.timer_outlined, size: 14, color: subTextColor),
            const SizedBox(width: 4),
            Text(
              '${workout.durationMinutes} dk',
              style: TextStyle(fontSize: 12, color: subTextColor),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.local_fire_department_rounded,
                size: 14, color: AppColors.neonOrange),
            const SizedBox(width: 4),
            Text(
              '${workout.caloriesBurned} kcal',
              style: TextStyle(fontSize: 12, color: subTextColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHydrationBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(isDark ? 25 : 20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withAlpha(isDark ? 60 : 50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop_rounded, size: 14, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                '+${workout.recommendedWaterMl} ml',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onDelete,
          child: Icon(Icons.delete_outline, size: 18, color: mutedColor),
        ),
      ],
    );
  }
}
