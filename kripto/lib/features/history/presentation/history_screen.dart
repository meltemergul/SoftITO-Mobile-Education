import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/models/asset.dart';
import '../../../shared/widgets/state_views.dart';
import '../../portfolio/providers/portfolio_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'widgets/history_filters.dart';
import 'widgets/history_table.dart';
import 'widgets/realized_pnl_table.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  int _selectedTab = 0;

  void _exportTransactionsAsCsv(List<AppTransaction> transactions, List<Asset> assets) {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dışa aktarılacak işlem bulunmuyor.'),
          backgroundColor: AppColors.surface3,
        ),
      );
      return;
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon');

    for (final tx in transactions) {
      final asset = assets.firstWhere(
        (a) => a.id == tx.assetId,
        orElse: () => Asset(
          id: tx.assetId,
          symbol: tx.assetId.toUpperCase(),
          name: tx.assetId,
          coingeckoId: tx.assetId.toLowerCase(),
        ),
      );

      final dateStr = tx.executedAt.toLocal().toString().substring(0, 16);
      final typeStr = tx.type == TransactionType.buy ? 'BUY' : 'SELL';
      buffer.writeln('$dateStr,${asset.symbol},$typeStr,${tx.quantity},${tx.price},${tx.priceCurrency},${tx.fee}');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text('CSV Dışa Aktarma', style: AppTextStyles.headlineSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${transactions.length} işlem CSV formatına dönüştürüldü:', style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 160,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.inputInset,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  buffer.toString(),
                  style: AppTextStyles.caption.copyWith(fontFamily: 'monospace', color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final txAsync = ref.watch(transactionsProvider);
    final txList = txAsync.value ?? [];
    final salesList = ref.watch(allRealizedSalesProvider);
    final assets = ref.watch(assetsProvider).value ?? Asset.defaultAssets;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Kâr / Zarar Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            tooltip: 'CSV Olarak Dışa Aktar',
            onPressed: () => _exportTransactionsAsCsv(txList, assets),
          ),
        ],
      ),
      body: SafeArea(
        child: txAsync.isLoading && !txAsync.hasValue
            ? const LoadingView(message: 'İşlem geçmişi yükleniyor...')
            : txAsync.hasError && !txAsync.hasValue
                ? ErrorView(
                    message: 'İşlemler yüklenirken bir bağlantı hatası oluştu.',
                    onRetry: () => ref.refresh(transactionsProvider),
                  )
                : txList.isEmpty
                    ? EmptyStateView(
                        icon: Icons.history_rounded,
                        title: 'İşlem Geçmişi Boş',
                        message:
                            'Henüz kayıtlı bir alım veya satım işleminiz bulunmuyor. Yeni bir işlem ekleyerek portföyünüzü ve K/Z geçmişinizi oluşturabilirsiniz.',
                        actionLabel: 'İŞLEM EKLE',
                        onAction: () => context.push('/add-transaction'),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
                        child: Column(
                          children: [
                            HistoryFilters(
                              selectedTab: _selectedTab,
                              onTabChanged: (tab) => setState(() => _selectedTab = tab),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (_selectedTab == 0)
                              HistoryTable(transactions: txList, currency: currency)
                            else
                              RealizedPnlTable(sales: salesList, currency: currency),
                          ],
                        ),
                      ),
      ),
    );
  }
}

