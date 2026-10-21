import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/formatters.dart';
import '../../../../shared/models/asset.dart';
import '../../../transactions/domain/transaction.dart';
import '../../../transactions/providers/transactions_provider.dart';

class HistoryTable extends ConsumerWidget {
  final List<AppTransaction> transactions;
  final String currency;

  const HistoryTable({
    super.key,
    required this.transactions,
    required this.currency,
  });

  void _confirmDelete(BuildContext context, WidgetRef ref, String txId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text('İşlemi Sil', style: AppTextStyles.headlineSm),
        content: Text(
          'Bu işlemi silmek istediğinizden emin misiniz? (Ortalama maliyet ve kâr/zararınız yeniden hesaplanacaktır.)',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(transactionsProvider.notifier).softDeleteTransaction(txId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('İşlem silindi.'),
                    backgroundColor: AppColors.loss,
                  ),
                );
              }
            },
            child: const Text('SİL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: AppSpacing.roundedCard,
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.history_outlined, color: AppColors.textMuted, size: 36),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Henüz geçmiş işlem bulunmuyor',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final assets = ref.watch(assetsProvider).value ?? Asset.defaultAssets;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppSpacing.roundedCard,
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        children: [
          // Tablo Başlığı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TARİH / VARLIK', style: AppTextStyles.labelSm),
                Text('TİP / TUTAR', style: AppTextStyles.labelSm),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDivider),

          // Satırlar
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderDivider),
            itemBuilder: (context, i) {
              final tx = transactions[i];
              final isBuy = tx.type == TransactionType.buy;
              final asset = assets.firstWhere(
                (a) => a.id == tx.assetId,
                orElse: () => Asset(
                  id: tx.assetId,
                  symbol: tx.assetId.toUpperCase(),
                  name: tx.assetId,
                  coingeckoId: tx.assetId.toLowerCase(),
                ),
              );

              final totalTxAmount = (tx.quantity * tx.price) + tx.fee;

              return Dismissible(
                key: Key(tx.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.lossBg,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_outline, color: AppColors.lossText),
                ),
                confirmDismiss: (_) async {
                  _confirmDelete(context, ref, tx.id);
                  return false;
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Text(asset.symbol, style: AppTextStyles.headlineSm.copyWith(fontSize: 15)),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isBuy ? AppColors.profitBg : AppColors.lossBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: isBuy ? AppColors.profitBorder : AppColors.lossBorder),
                        ),
                        child: Text(
                          isBuy ? 'ALIŞ' : 'SATIŞ',
                          style: AppTextStyles.caption.copyWith(
                            color: isBuy ? AppColors.profitText : AppColors.lossText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${AppFormatters.formatDateTime(tx.executedAt)} • ${AppFormatters.formatQuantity(tx.quantity)} adet @ ${AppFormatters.formatCurrency(tx.price, tx.priceCurrency)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppFormatters.formatCurrency(totalTxAmount, tx.priceCurrency),
                        style: AppTextStyles.labelNumericMd,
                      ),
                      if (tx.fee > Decimal.zero)
                        Text(
                          'Kom: ${AppFormatters.formatCurrency(tx.fee, tx.priceCurrency)}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                        ),
                    ],
                  ),
                  onLongPress: () => _confirmDelete(context, ref, tx.id),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
