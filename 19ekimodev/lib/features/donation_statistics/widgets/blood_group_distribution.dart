import 'package:flutter/material.dart';

import '../models/donation_statistics_model.dart';

class BloodGroupDistribution extends StatelessWidget {
  final List<BloodGroupShareModel> shares;

  const BloodGroupDistribution({super.key, required this.shares});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxPercent = shares.fold<double>(
      1,
      (m, s) => s.percent > m ? s.percent : m,
    );

    return Column(
      children: [
        for (final share in shares)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    share.group,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: share.percent / maxPercent,
                      minHeight: 10,
                      color: colors.primary,
                      backgroundColor: colors.primary.withAlpha(30),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '%${share.percent.toStringAsFixed(0)}',
                    textAlign: TextAlign.end,
                    style: textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
