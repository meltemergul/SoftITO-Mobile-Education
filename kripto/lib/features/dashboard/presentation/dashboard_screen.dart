import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/formatters.dart';
import '../../../shared/models/asset.dart';
import '../../../shared/widgets/live_dot.dart';
import '../../../shared/widgets/pnl_badge.dart';
import '../../../shared/widgets/state_views.dart';
import '../../portfolio/domain/position.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../prices/domain/price_info.dart';
import '../../prices/providers/prices_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'widgets/allocation_bar.dart';
import 'widgets/asset_row.dart';
import 'widgets/cumulative_return_chart.dart';
import 'widgets/portfolio_summary_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/trade_efficiency_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = '1G';

  PriceInfo? _priceFor(Asset asset, List<PriceInfo> prices, String currency) {
    final cur = currency.toUpperCase();
    final idLower = asset.id.toLowerCase();
    final cgLower = asset.coingeckoId.toLowerCase();
    final symLower = asset.symbol.toLowerCase();

    for (final p in prices) {
      if (p.currency.toUpperCase() != cur) continue;
      final target = p.assetId.toLowerCase();
      if (target == idLower ||
          target == cgLower ||
          target == symLower ||
          target == '$symLower-asset' ||
          target.contains(cgLower) ||
          cgLower.contains(target)) {
        return p;
      }
    }
    return null;
  }

  /// 24 saatlik portföy değişimi: her pozisyonun değeri, 24s önceki değerine göre.
  ({Decimal amount, Decimal percentage}) _change24h(
    List<Position> positions,
    List<PriceInfo> prices,
    String currency,
  ) {
    double now = 0;
    double before = 0;
    for (final pos in positions) {
      final value = pos.currentValue.toDouble();
      final change = _priceFor(pos.asset, prices, currency)?.change24h?.toDouble() ?? 0;
      now += value;
      before += value / (1 + change / 100);
    }
    final diff = now - before;
    final pct = before == 0 ? 0.0 : diff / before * 100;
    return (
      amount: Decimal.parse(diff.toStringAsFixed(2)),
      percentage: Decimal.parse(pct.toStringAsFixed(2)),
    );
  }

  List<AllocationSegment> _allocation(List<Position> positions, Decimal total) {
    if (total == Decimal.zero) return [];
    final sorted = [...positions]..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final segments = <AllocationSegment>[];
    double other = 0;
    for (int i = 0; i < sorted.length; i++) {
      final pct = sorted[i].currentValue.toDouble() / total.toDouble() * 100;
      if (i < 3) {
        segments.add(AllocationSegment(
          label: sorted[i].asset.symbol.toUpperCase(),
          percentage: pct,
          color: AppColors.chartPalette[i % AppColors.chartPalette.length],
        ));
      } else {
        other += pct;
      }
    }
    if (other > 0) {
      segments.add(AllocationSegment(label: 'Diğer', percentage: other, color: AppColors.chartOther));
    }
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final lastUpdate = ref.watch(lastPriceUpdateProvider);
    final txAsync = ref.watch(transactionsProvider);
    final summary = ref.watch(portfolioSummaryProvider);
    final positions = ref.watch(positionsProvider);
    final prices = ref.watch(pricesProvider).value ?? [];
    final assets = ref.watch(assetsProvider).value ?? Asset.defaultAssets;

    final change = _change24h(positions, prices, currency);
    final sortedPositions = [...positions]
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final salesList = ref.watch(allRealizedSalesProvider);
    final txList = txAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        toolbarHeight: 64,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryBright.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBright.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chronomind', style: AppTextStyles.headlineSm.copyWith(fontSize: 17)),
                Row(
                  children: [
                    const LiveDot(),
                    const SizedBox(width: 6),
                    Text(
                      lastUpdate != null
                          ? 'Canlı · ${AppFormatters.formatTime(lastUpdate)}'
                          : 'Canlı veri',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Fiyatları Yenile',
            onPressed: () async {
              await Future.wait([
                ref.read(pricesProvider.notifier).refresh(),
                ref.refresh(transactionsProvider.future),
              ]);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('CoinGecko fiyatları güncellendi.'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.surface3,
                  ),
                );
              }
            },
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        bottom: false,
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
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenMarginMobile,
                        AppSpacing.sm,
                        AppSpacing.screenMarginMobile,
                        AppSpacing.xxl,
                      ),
                      children: [
                        // 1. Konsolide Bakiye Kartı
                        PortfolioSummaryCard(
                          totalValue: summary.totalValue,
                          change24hAmount: change.amount,
                          change24hPercentage: change.percentage,
                          allTimePnl: summary.totalUnrealizedPnl,
                          allTimePnlPercentage: summary.totalUnrealizedPnlPercentage,
                          selectedCurrency: currency,
                          onCurrencyChanged: (c) =>
                              ref.read(currencyProvider.notifier).setCurrency(c),
                          isPrivate: isPrivate,
                          onPrivacyToggle: () => ref.read(privacyModeProvider.notifier).toggle(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // 2. Hızlı Aksiyonlar (İşlem ve Portföy Yönetimi)
                        QuickActionsGrid(
                          actions: [
                            QuickAction(
                              icon: Icons.add_rounded,
                              label: 'İşlem Ekle',
                              highlighted: true,
                              onTap: () => context.push('/add-transaction'),
                            ),
                            QuickAction(
                              icon: Icons.history_rounded,
                              label: 'K/Z Geçmişi',
                              onTap: () => context.go('/history'),
                            ),
                            QuickAction(
                              icon: Icons.donut_large_rounded,
                              label: 'Dağılım',
                              onTap: () => context.go('/allocation'),
                            ),
                            QuickAction(
                              icon: Icons.settings_outlined,
                              label: 'Ayarlar',
                              onTap: () => context.go('/settings'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 3. İşlem Verimliliği Kartı (Win Rate, Kâr Faktörü, Dağılım)
                        TradeEfficiencyCard(
                          sales: salesList,
                          positions: positions,
                          totalTransactionsCount: txList.length,
                          currency: currency,
                          onDetailsTap: () => context.go('/history'),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 4. Kümülatif Getiri Eğrisi (Canlı Grafik)
                        CumulativeReturnChart(
                          returnPercentage: summary.totalUnrealizedPnlPercentage,
                          period: _selectedPeriod,
                          onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
                          isPrivate: isPrivate,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 5. Varlık Dağılım Çubuğu
                        if (positions.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Varlık Dağılımı',
                            action: 'Detay',
                            onAction: () => context.go('/allocation'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AllocationBar(segments: _allocation(positions, summary.totalValue)),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // 5. Varlık Listesi
                        _SectionHeader(
                          title: 'Varlıklarım',
                          count: positions.length,
                          action: positions.isNotEmpty ? 'Tümünü Gör' : null,
                          onAction: () => context.go('/allocation'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (positions.isEmpty)
                          const _EmptyAssets()
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.surface1,
                              borderRadius: AppSpacing.roundedCard,
                              border: Border.all(color: AppColors.borderCard),
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < sortedPositions.length; i++)
                                  AssetRow(
                                    symbol: sortedPositions[i].asset.symbol,
                                    name: sortedPositions[i].asset.name,
                                    quantity: sortedPositions[i].quantity,
                                    totalValue: sortedPositions[i].currentValue,
                                    change24h: _priceFor(sortedPositions[i].asset, prices, currency)
                                        ?.change24h,
                                    pnlAmount: sortedPositions[i].unrealizedPnl,
                                    currency: currency,
                                    accent: i < 3
                                        ? AppColors.chartPalette[i]
                                        : AppColors.textSecondary,
                                    isPrivate: isPrivate,
                                    showDivider: i < sortedPositions.length - 1,
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xl),

                        // 6. Öne Çıkan Kriptolar
                        const _SectionHeader(title: 'Öne Çıkan Kriptolar'),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 126,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: assets.length,
                            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                            itemBuilder: (context, i) {
                              final asset = assets[i];
                              final p = _priceFor(asset, prices, currency);
                              return _MarketCard(
                                asset: asset,
                                price: p?.price,
                                change: p?.change24h,
                                currency: currency,
                                onTap: () => context.push('/add-transaction'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 7. Yasal uyarı
                        Text(
                          'Piyasa verileri bilgilendirme amaçlıdır, yatırım tavsiyesi değildir.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.count, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.headlineSm),
        if (count != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: AppSpacing.roundedPill,
            ),
            child: Text('$count',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ),
        ],
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.primaryBright,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyAssets extends StatelessWidget {
  const _EmptyAssets();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppSpacing.roundedCard,
            ),
            child: Icon(Icons.account_balance_wallet_outlined,
                color: AppColors.primaryBright, size: 26),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Henüz işlem kaydınız yok',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'İlk kripto varlık alımınızı ekleyerek portföyünüzü canlı takip edin.',
            style: AppTextStyles.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-transaction'),
            icon: Icon(Icons.add_rounded, size: 18),
            label: Text('İlk İşlemini Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBright,
              minimumSize: const Size(200, 46),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final Asset asset;
  final Decimal? price;
  final Decimal? change;
  final String currency;
  final VoidCallback? onTap;

  const _MarketCard({
    required this.asset,
    required this.price,
    required this.change,
    required this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedCard,
      child: Container(
        width: 176,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: AppColors.borderCard),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2236), AppColors.surface1],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    asset.symbol.isEmpty ? '?' : asset.symbol[0].toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryBright,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    asset.symbol.toUpperCase(),
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (change != null) PnlBadge(percentage: change!),
              ],
            ),
            Text(
              asset.name,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              price != null ? AppFormatters.formatCurrency(price!, currency) : '...',
              style: AppTextStyles.numeric(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
