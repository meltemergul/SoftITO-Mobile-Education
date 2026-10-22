import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/widgets/app_card.dart';

class TodaySkeletonLoading extends StatelessWidget {
  const TodaySkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Günün İlhamı İskeleti
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: colors.backgroundAlt,
            borderRadius: AppRadius.cardRadius,
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Günün İlerlemesi İskeleti
        AppCard(
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.backgroundAlt,
                ),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: colors.backgroundAlt,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 20,
                      color: colors.backgroundAlt,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 6,
                      color: colors.backgroundAlt,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Alışkanlık Kartı İskeletleri
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.backgroundAlt,
                      borderRadius: AppRadius.cardRadius,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 16,
                          color: colors.backgroundAlt,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 12,
                          color: colors.backgroundAlt,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.backgroundAlt,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
