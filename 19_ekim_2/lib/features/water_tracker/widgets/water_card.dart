import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/water_record_model.dart';

/// Geçmiş su tüketim kayıt satırını gösteren kart widget'ı.
class WaterRecordCard extends StatelessWidget {
  final WaterRecordModel record;

  const WaterRecordCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final hour = record.timestamp.hour.toString().padLeft(2, '0');
    final minute = record.timestamp.minute.toString().padLeft(2, '0');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(isDark ? 25 : 20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.water_drop_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.source,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  '$hour:$minute',
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${record.amountMl} ml',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
