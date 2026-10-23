import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/widgets/app_card.dart';

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Genel Skor İskeleti
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.inactive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.inactive,
                        borderRadius: AppRadius.pillRadius,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                Container(
                  width: 100,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.inactive,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.inactive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 110,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.inactive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Çubuk Grafik İskeleti
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.inactive,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final heights = [60.0, 90.0, 40.0, 110.0, 80.0, 130.0, 70.0];
                    return Container(
                      width: 28,
                      height: heights[index],
                      decoration: BoxDecoration(
                        color: colors.inactive,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Kategori İskeleti
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colors.inactive,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                ...List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.inactive,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
