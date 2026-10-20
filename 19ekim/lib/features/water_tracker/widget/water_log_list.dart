import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';
import '../models/water_log_model.dart';

class WaterLogList extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterLogList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final logs = controller.logs;

    if (logs.isEmpty) {
      return const _EmptyLogsPlaceholder();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final log = logs[index];
        return _WaterLogTile(
          log: log,
          onDelete: () => controller.removeLog(log.id),
        );
      },
    );
  }
}

class _EmptyLogsPlaceholder extends StatelessWidget {
  const _EmptyLogsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.water_drop, color: AppColors.surfaceBorder, size: 40),
          SizedBox(height: 8),
          Text(
            'Henüz su kaydı bulunmuyor.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _WaterLogTile extends StatelessWidget {
  final WaterLog log;
  final VoidCallback onDelete;

  const _WaterLogTile({required this.log, required this.onDelete});

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
          const Icon(Icons.water_drop, color: AppColors.neonWater, size: 20),
          const SizedBox(width: 12),
          Text(
            '+${log.amountMl} ml',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            log.formattedTime,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
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
