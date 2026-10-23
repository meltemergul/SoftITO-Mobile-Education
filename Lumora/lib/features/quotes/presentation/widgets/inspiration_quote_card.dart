import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimensions.dart';
import '../../../../core/theme/typography.dart';
import '../providers/daily_quote_provider.dart';

class InspirationQuoteCard extends ConsumerStatefulWidget {
  const InspirationQuoteCard({super.key});

  @override
  ConsumerState<InspirationQuoteCard> createState() => _InspirationQuoteCardState();
}

class _InspirationQuoteCardState extends ConsumerState<InspirationQuoteCard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dailyQuoteNotifierProvider.notifier).loadDailyQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(dailyQuoteNotifierProvider);
    final notifier = ref.read(dailyQuoteNotifierProvider.notifier);
    final quote = state.quote;

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
              if (quote != null)
                Row(
                  children: [
                    IconButton(
                      tooltip: quote.isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
                      icon: Icon(
                        quote.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: quote.isFavorite ? Colors.redAccent : colors.textOnPrimary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => notifier.toggleFavorite(),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    IconButton(
                      tooltip: 'Sözü Paylaş',
                      icon: Icon(
                        Icons.share_rounded,
                        color: colors.textOnPrimary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => notifier.shareQuote(),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          if (state.isLoading && quote == null) ...[
            const SizedBox(height: AppSpacing.s8),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Container(
              height: 16,
              width: 180,
              decoration: BoxDecoration(
                color: colors.textOnPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ] else if (quote != null) ...[
            Text(
              '"${quote.text}"',
              style: AppTypography.heading.copyWith(
                color: colors.textOnPrimary,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            // Yazar satırı yalnızca atıflı sözlerde gösterilir
            if (quote.author != null && quote.author!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              Text(
                '— ${quote.author!.trim()}',
                style: AppTypography.caption.copyWith(
                  color: colors.textOnPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ] else ...[
            Text(
              '"Her gün zincire eklenen bir halka, geleceğini inşa eder."',
              style: AppTypography.heading.copyWith(
                color: colors.textOnPrimary,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
