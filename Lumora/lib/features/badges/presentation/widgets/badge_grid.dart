import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/badge_entity.dart';
import 'badge_item_card.dart';

class BadgeGrid extends StatelessWidget {
  const BadgeGrid({
    super.key,
    required this.badges,
  });

  final List<BadgeEntity> badges;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
          vertical: AppSpacing.s32,
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.military_tech_outlined,
              size: 48,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              'Bu kategoride rozet bulunmuyor',
              style: AppTypography.body.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: badges.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.s12,
        mainAxisSpacing: AppSpacing.s12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        return BadgeItemCard(badge: badges[index]);
      },
    );
  }
}
