import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';
import '../widget/quick_water_buttons.dart';
import '../widget/water_log_list.dart';
import '../widget/water_progress_card.dart';

class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({super.key, required this.controller});

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
              WaterProgressCard(controller: controller),
              const SizedBox(height: 24),
              QuickWaterButtons(controller: controller),
              const SizedBox(height: 28),
              _LogSectionHeader(onReset: controller.resetDaily),
              const SizedBox(height: 12),
              WaterLogList(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _LogSectionHeader extends StatelessWidget {
  final VoidCallback onReset;

  const _LogSectionHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bugünkü Kayıtlar',
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
