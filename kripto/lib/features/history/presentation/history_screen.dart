import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
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

  Rect _getShareOrigin() {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return const Rect.fromLTWH(0, 0, 300, 300);
  }

  Future<void> _exportTransactionsAsCsv(List<AppTransaction> transactions, List<Asset> assets) async {
    final origin = _getShareOrigin();

    try {
      final csvService = ref.read(csvServiceProvider);
      if (transactions.isEmpty) {
        await csvService.exportSampleTemplateCsvFile(sharePositionOrigin: origin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıtlı işlem olmadığından CSV başlık şablonu dışa aktarıldı.'),
              backgroundColor: AppColors.profit,
            ),
          );
        }
        return;
      }

      await csvService.exportTransactionsToCsvFile(transactions, assets, sharePositionOrigin: origin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${transactions.length} işlem .csv dosyası olarak hazırlandı.'),
            backgroundColor: AppColors.profit,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV dışa aktarma hatası: $e'),
            backgroundColor: AppColors.loss,
          ),
        );
      }
    }
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

