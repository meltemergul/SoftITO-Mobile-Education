import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';

class InspirationQuoteCard extends StatefulWidget {
  const InspirationQuoteCard({super.key});

  @override
  State<InspirationQuoteCard> createState() => _InspirationQuoteCardState();
}

class _InspirationQuoteCardState extends State<InspirationQuoteCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardRadius,
        gradient: LinearGradient(
          colors: [
            colors.primaryStrong,
            colors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: colors.textOnPrimary.withValues(alpha: 0.8),
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    'Günün İlhamı',
                    style: AppTypography.caption.copyWith(
                      color: colors.textOnPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.redAccent : colors.textOnPrimary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: colors.textOnPrimary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Söz panoya kopyalandı!')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            '"Engeller yolun kendisidir. Kararlılıkla atılan her adım seni hedefine yaklaştırır."',
            style: AppTypography.heading.copyWith(
              color: colors.textOnPrimary,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            '— Marcus Aurelius',
            style: AppTypography.caption.copyWith(
              color: colors.textOnPrimary.withValues(alpha: 0.85),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
