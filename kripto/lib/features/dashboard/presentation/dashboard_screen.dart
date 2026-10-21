import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/formatters.dart';
import '../../../shared/models/asset.dart';
import '../../../shared/widgets/live_dot.dart';
import '../../../shared/widgets/period_selector.dart';
import '../../../shared/widgets/pnl_badge.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../prices/providers/prices_provider.dart';
import '../../settings/providers/settings_provider.dart';
import 'widgets/asset_row.dart';
import 'widgets/performance_chart.dart';
import 'widgets/portfolio_summary_card.dart';

import '../../../shared/widgets/state_views.dart';
import '../../transactions/providers/transactions_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = '1G';

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final lastUpdate = ref.watch(lastPriceUpdateProvider);
    final txAsync = ref.watch(transactionsProvider);
    final summary = ref.watch(portfolioSummaryProvider);
    final positions = ref.watch(positionsProvider);
    final prices = ref.watch(pricesProvider).value ?? [];
    final assets = ref.watch(assetsProvider).value ?? Asset.defaultAssets;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Row(
          children: [
            const LiveDot(),
            const SizedBox(width: AppSpacing.sm),
            Text('Chronomind', style: AppTextStyles.headlineSm),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screenMarginMobile),
            child: Center(
              child: Text(
                lastUpdate != null
                    ? 'Son güncelleme: ${AppFormatters.formatTime(lastUpdate)}'
                    : 'Canlı Veri',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: txAsync.isLoading && !txAsync.hasValue
            ? const LoadingView(message: 'Portföy verileri hazırlanıyor...')
            : txAsync.hasError && !txAsync.hasValue
                ? ErrorView(
                    message: 'İşlemler yüklenirken bağlantı hatası oluştu.',
                    onRetry: () => ref.refresh(transactionsProvider),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface2,
                    onRefresh: () async {
                      await Future.wait([
                        ref.read(pricesProvider.notifier).refresh(),
                        ref.refresh(transactionsProvider.future),
                      ]);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                // 1. Toplam Portföy Değeri Kartı
                PortfolioSummaryCard(
                  totalValue: summary.totalValue,
                  pnlPercentage: summary.totalUnrealizedPnlPercentage,
                  selectedCurrency: currency,
                  onCurrencyChanged: (c) => ref.read(currencyProvider.notifier).setCurrency(c),
                ),
                const SizedBox(height: AppSpacing.lg),

                // 2. Performans Başlığı ve Zaman Aralığı Seçici
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PERFORMANS', style: AppTextStyles.labelSm),
                    PeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onSelected: (p) => setState(() => _selectedPeriod = p),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // 3. Performans Çizgi Grafiği
                const PerformanceChart(),
                const SizedBox(height: AppSpacing.xl),

                // 4. Varlıklarım Bölümü
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('VARLIKLARIM (${positions.length})', style: AppTextStyles.labelSm),
                    if (positions.isNotEmpty)
                      GestureDetector(
                        onTap: () => context.go('/allocation'),
                        child: Text(
                          'Tümünü Gör',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                if (positions.isEmpty) ...[
                  // Boş Durum
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      borderRadius: AppSpacing.roundedCard,
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 36),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Henüz işlem kaydınız yok',
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'İlk kripto varlık alımınızı ekleyerek portföyünüzü canlı takip edin.',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/add-transaction'),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('İLK İŞLEMİNİ EKLE'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Varlık Listesi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      borderRadius: AppSpacing.roundedCard,
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: positions.length,
                      itemBuilder: (context, i) {
                        final pos = positions[i];
                        return AssetRow(
                          symbol: pos.asset.symbol,
                          name: pos.asset.name,
                          quantity: pos.quantity,
                          currentPrice: pos.currentPrice,
                          pnlPercentage: pos.unrealizedPnlPercentage,
                          currency: currency,
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // 5. Öne Çıkan Kriptolar (Piyasa Verileri)
                Text('ÖNE ÇIKAN KRİPTOLAR', style: AppTextStyles.labelSm),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: assets.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final asset = assets[i];
                      final pMatch = prices.where((p) =>
                          (p.assetId == asset.id || p.assetId == asset.coingeckoId) &&
                          p.currency == currency).firstOrNull;

                      final price = pMatch?.price;
                      final change = pMatch?.change24h;

                      return Container(
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface1,
                          borderRadius: AppSpacing.roundedCard,
                          border: Border.all(color: AppColors.borderCard),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    asset.symbol,
                                    style: AppTextStyles.headlineSm.copyWith(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (change != null) PnlBadge(percentage: change),
                              ],
                            ),
                            Text(
                              asset.name,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              price != null ? AppFormatters.formatCurrency(price, currency) : '--',
                              style: AppTextStyles.labelNumericMd.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // 6. Yatırım Tavsiyesi Değildir Uyarısı
                Center(
                  child: Text(
                    'Uyarı: Piyasa verileri bilgilendirme amaçlıdır, kesinlikle yatırım tavsiyesi içermez.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
