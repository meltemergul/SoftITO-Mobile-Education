import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/widgets/app_card.dart';

class CalendarSkeleton extends StatelessWidget {
  const CalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // İstikrar Özeti İskeleti
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.inactive,
                    borderRadius: AppRadius.cardRadius,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.inactive,
                    borderRadius: AppRadius.cardRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Matris İskeleti
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            children: [
              Container(
                height: 20,
                width: 140,
                decoration: BoxDecoration(
                  color: colors.inactive,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 28,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: colors.inactive.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
