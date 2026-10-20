import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';

class QuickWaterButtons extends StatelessWidget {
  final WaterTrackerController controller;

  const QuickWaterButtons({super.key, required this.controller});

  static const List<int> _amounts = [200, 330, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Su Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _amounts.map((amount) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _QuickAddButton(
                  amount: amount,
                  onTap: () => controller.addWater(amount),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.water_drop_outlined,
              color: AppColors.neonWater,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              '+$amount',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'ml',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
