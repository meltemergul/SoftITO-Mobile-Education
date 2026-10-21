import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/formatters.dart';
import '../../../shared/widgets/glass_sheet.dart';
import '../../../shared/widgets/pnl_badge.dart';
import '../../../shared/widgets/state_views.dart';
import '../../portfolio/domain/position.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'widgets/allocation_table.dart';
import 'widgets/donut_chart.dart';

class AllocationScreen extends ConsumerStatefulWidget {
  const AllocationScreen({super.key});

  @override
  ConsumerState<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends ConsumerState<AllocationScreen> {
  AllocationSort _sort = AllocationSort.byValue;

  void _showPositionDetails(Position pos, String currency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GlassSheet(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surface3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${pos.asset.name} (${pos.asset.symbol})', style: AppTextStyles.headlineSm),
                  PnlBadge(percentage: pos.unrealizedPnlPercentage),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Divider(height: 1, color: AppColors.borderDivider),
              const SizedBox(height: AppSpacing.md),
              _buildDetailRow('Eldeki Adet', AppFormatters.formatQuantity(pos.quantity)),
              _buildDetailRow('Ortalama Maliyet', AppFormatters.formatCurrency(pos.averageBuyPrice, currency)),
              _buildDetailRow('Güncel Fiyat', AppFormatters.formatCurrency(pos.currentPrice, currency)),
              _buildDetailRow('Toplam Değer', AppFormatters.formatCurrency(pos.currentValue, currency)),
              _buildDetailRow(
                'Kâr / Zarar Tutarı',
                AppFormatters.formatCurrency(pos.unrealizedPnl, currency),
                valColor: pos.unrealizedPnl >= Decimal.zero ? AppColors.profitText : AppColors.lossText,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: AppTextStyles.labelNumericMd.copyWith(color: valColor ?? AppColors.textPrimary),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final txAsync = ref.watch(transactionsProvider);
    final summary = ref.watch(portfolioSummaryProvider);
    final positions = ref.watch(positionsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text('Varlık Dağılımı'),
      ),
      body: SafeArea(
        child: txAsync.isLoading && !txAsync.hasValue
            ? const LoadingView(message: 'Varlık dağılımı hesaplanıyor...')
            : txAsync.hasError && !txAsync.hasValue
                ? ErrorView(
                    message: 'Veriler yüklenirken bağlantı hatası oluştu.',
                    onRetry: () => ref.refresh(transactionsProvider),
                  )
                : positions.isEmpty
                    ? EmptyStateView(
                        icon: Icons.pie_chart_outline_rounded,
                        title: 'Varlık Dağılımı Boş',
                        message:
                            'Portföyünüzde henüz açık bir pozisyon bulunmuyor. Kripto alım işlemi eklediğinizde dağılım grafiği ve ağırlıklar burada görüntülenecektir.',
                        actionLabel: 'İŞLEM EKLE',
                        onAction: () => context.push('/add-transaction'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Donut Grafik
                            DonutChart(
                              positions: positions,
                              totalValue: summary.totalValue,
                              currency: currency,
                              onPositionSelected: (pos) => _showPositionDetails(pos, currency),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 2. Yoğunlaşma Uyarısı (Concentration warning if a single coin is > 50%)
                            if (summary.concentratedAssetSymbol != null) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
                                decoration: BoxDecoration(
                                  color: const Color(0x1FF59E0B), // Amber %12
                                  borderRadius: AppSpacing.roundedCard,
                                  border: Border.all(color: const Color(0x40F59E0B)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFBBF24), size: 20),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Yoğunlaşma Uyarısı: ${summary.concentratedAssetSymbol} portföyünüzün %50\'sinden fazlasını oluşturuyor.',
                                        style: AppTextStyles.bodySm.copyWith(color: const Color(0xFFFBBF24)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],

                            // 3. Varlık Tablosu
                            AllocationTable(
                              positions: positions,
                              currency: currency,
                              sort: _sort,
                              onSortChanged: (s) => setState(() => _sort = s),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }
}
