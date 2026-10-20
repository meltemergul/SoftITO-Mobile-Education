import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_record_model.dart';
import '../widgets/quick_water_buttons.dart';
import '../widgets/water_card.dart';
import '../widgets/water_progress_indicator.dart';

/// Su takip ana ekran görünümü (Clean UI & StatelessWidget).
class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;
  final ThemeController themeController;

  const WaterTrackerView({
    super.key,
    required this.controller,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNotificationBanner(context),
            const SizedBox(height: 16),
            _buildProgressSection(),
            const SizedBox(height: 20),
            _buildWorkoutExtraHydrationBanner(context),
            const SizedBox(height: 24),
            _buildQuickAddSection(context),
            const SizedBox(height: 24),
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text('susadım v1'),
        ],
      ),
      actions: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController.themeMode,
          builder: (context, mode, _) {
            final isDark = mode == ThemeMode.dark;
            return IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppColors.neonCyan : AppColors.lightPrimary,
              ),
              tooltip: isDark ? 'Aydınlık Moda Geç' : 'Karanlık Moda Geç',
              onPressed: themeController.toggleTheme,
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          tooltip: 'Sıfırla',
          onPressed: controller.resetWater,
        ),
      ],
    );
  }

  Widget _buildNotificationBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return ValueListenableBuilder<String?>(
      valueListenable: controller.alertMessage,
      builder: (context, message, _) {
        if (message == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(isDark ? 25 : 18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withAlpha(isDark ? 90 : 80)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.clearAlert,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.currentWater,
      builder: (context, current, _) {
        return ValueListenableBuilder<int>(
          valueListenable: controller.workoutExtraGoal,
          builder: (context, extra, _) {
            final totalGoal = controller.totalDailyGoal;
            final progress = controller.progressRatio;
            return WaterProgressIndicator(
              currentWater: current,
              totalGoal: totalGoal,
              progress: progress,
            );
          },
        );
      },
    );
  }

  Widget _buildWorkoutExtraHydrationBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceLight = isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ValueListenableBuilder<int>(
      valueListenable: controller.workoutExtraGoal,
      builder: (context, extra, _) {
        if (extra == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neonOrange.withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.fitness_center_rounded,
                  color: AppColors.neonOrange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Egzersiz Hidrasyon Desteği',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Bugün yapılan antrenmanlar için hedefe +$extra ml su eklendi.',
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAddSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı Su Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        QuickWaterButtons(
          onAdd: (amount, label) => controller.addWater(amount, source: label),
        ),
      ],
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bugünkü Tüketim Kayıtları',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<WaterRecordModel>>(
          valueListenable: controller.records,
          builder: (context, list, _) {
            if (list.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  'Henüz su kaydı bulunmuyor. Bir bardak suyla başla!',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                return WaterRecordCard(record: list[index]);
              },
            );
          },
        ),
      ],
    );
  }
}
