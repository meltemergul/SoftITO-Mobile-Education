import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

class CoinTile extends StatelessWidget {
  final String symbol;
  final String name;
  final String? imageUrl;

  const CoinTile({
    super.key,
    required this.symbol,
    required this.name,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppSpacing.tokenIconSize,
          height: AppSpacing.tokenIconSize,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(10), // Squircle
            border: Border.all(color: AppColors.borderCard, width: 1),
          ),
          alignment: Alignment.center,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl!,
                    width: AppSpacing.tokenIconSize,
                    height: AppSpacing.tokenIconSize,
                    errorBuilder: (_, _, _) => _buildFallback(),
                  ),
                )
              : _buildFallback(),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol.toUpperCase(),
              style: AppTextStyles.headlineSm.copyWith(fontSize: 14),
            ),
            Text(
              name,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return Text(
      symbol.isNotEmpty ? symbol.substring(0, 1).toUpperCase() : '?',
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}
