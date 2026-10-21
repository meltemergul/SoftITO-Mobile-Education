import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/models/asset.dart';
import '../../../../shared/widgets/coin_tile.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../portfolio/domain/cost_calculator.dart';
import '../../../prices/domain/price_info.dart';
import '../../../prices/providers/prices_provider.dart';
import '../../domain/transaction.dart';
import '../../providers/transactions_provider.dart';
import 'cost_preview_card.dart';

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({super.key});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isBuy = true;
  String _selectedCurrency = 'USD';
  Asset _selectedAsset = Asset.defaultAssets.first;
  DateTime _executedAt = DateTime.now();

  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  final _noteController = TextEditingController();

  String? _oversellError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_recalculatePreview);
    _priceController.addListener(_recalculatePreview);
    _feeController.addListener(_recalculatePreview);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_recalculatePreview);
    _priceController.removeListener(_recalculatePreview);
    _feeController.removeListener(_recalculatePreview);
    _quantityController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _recalculatePreview() {
    setState(() {
      _oversellError = null;
    });
  }

  void _useMarketPrice() {
    final prices = ref.read(pricesProvider).value ?? [];
    final idLower = _selectedAsset.id.toLowerCase();
    final cgLower = _selectedAsset.coingeckoId.toLowerCase();
    final symLower = _selectedAsset.symbol.toLowerCase();
    final curUpper = _selectedCurrency.toUpperCase();

    PriceInfo? match;
    for (final p in prices) {
      final target = p.assetId.toLowerCase();
      if ((target == idLower || target == cgLower || target == symLower || target == '$symLower-asset') &&
          p.currency.toUpperCase() == curUpper) {
        match = p;
        break;
      }
    }
    match ??= prices.where((p) => p.currency.toUpperCase() == curUpper).firstOrNull;

    if (match != null) {
      setState(() {
        _priceController.text = match!.price.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedAsset.symbol} güncel piyasa fiyatı uygulandı: ${_selectedCurrency == 'TRY' ? '₺' : '\$'}${match.price}',
          ),
          backgroundColor: AppColors.surface2,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Piyasa fiyatı henüz yüklenmedi.'),
          backgroundColor: AppColors.surface3,
        ),
      );
    }
  }

  void _openAssetSelector(List<Asset> assets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = assets.where((a) {
              final query = searchQuery.toLowerCase();
              return a.symbol.toLowerCase().contains(query) || a.name.toLowerCase().contains(query);
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Coin ara (BTC, Ethereum...)',
                      prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.borderDivider),
                      itemBuilder: (context, i) {
                        final asset = filtered[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: CoinTile(
                            symbol: asset.symbol,
                            name: asset.name,
                            imageUrl: asset.imageUrl,
                          ),
                          trailing: _selectedAsset.id == asset.id
                              ? Icon(Icons.check, color: AppColors.primary, size: 20)
                              : null,
                          onTap: () {
                            setState(() => _selectedAsset = asset);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _executedAt,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface1,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_executedAt),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface1,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    setState(() {
      _executedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitTransaction() async {
    setState(() => _oversellError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = Decimal.tryParse(_quantityController.text.trim()) ?? Decimal.zero;
    final price = Decimal.tryParse(_priceController.text.trim()) ?? Decimal.zero;
    final fee = Decimal.tryParse(_feeController.text.trim()) ?? Decimal.zero;

    // Mevcut pozisyonu hesapla ve fazla satış kontrolü yap
    final txList = ref.read(transactionsProvider).value ?? [];
    final assetTxs = txList.where((t) => t.assetId == _selectedAsset.id).toList();
    final currentPos = CostCalculator.calculatePosition(transactions: assetTxs, allowOversell: true);

    if (!_isBuy && quantity > currentPos.heldQuantity) {
      setState(() {
        _oversellError =
            'Yetersiz bakiye! Elinizde ${currentPos.heldQuantity} ${_selectedAsset.symbol} var, $quantity satamazsınız.';
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider);
      final newTx = AppTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user?.id ?? 'local-user',
        assetId: _selectedAsset.id,
        type: _isBuy ? TransactionType.buy : TransactionType.sell,
        quantity: quantity,
        price: price,
        priceCurrency: _selectedCurrency,
        fee: fee,
        executedAt: _executedAt,
        source: TransactionSource.manual,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        createdAt: DateTime.now().toUtc(),
      );

      await ref.read(transactionsProvider.notifier).addTransaction(newTx);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedAsset.symbol} ${_isBuy ? 'alış' : 'satış'} işlemi kaydedildi.',
          ),
          backgroundColor: AppColors.profit,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _oversellError = 'İşlem kaydedilemedi: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider).value ?? Asset.defaultAssets;

    // Canlı önizleme hesaplamaları
    final txList = ref.watch(transactionsProvider).value ?? [];
    final assetTxs = txList.where((t) => t.assetId == _selectedAsset.id).toList();
    final currentPos = CostCalculator.calculatePosition(transactions: assetTxs, allowOversell: true);

    final inputQuantity = Decimal.tryParse(_quantityController.text.trim()) ?? Decimal.zero;
    final inputPrice = Decimal.tryParse(_priceController.text.trim()) ?? Decimal.zero;
    final inputFee = Decimal.tryParse(_feeController.text.trim()) ?? Decimal.zero;

    final totalAmount = (inputQuantity * inputPrice) + inputFee;

    // Alış simülasyonu ile yeni ortalama maliyet önizlemesi
    Decimal simulatedAvgCost = currentPos.averageBuyPrice;
    Decimal? estimatedPnl;

    if (inputQuantity > Decimal.zero && inputPrice > Decimal.zero) {
      if (_isBuy) {
        final simulatedTxs = List<AppTransaction>.from(assetTxs)
          ..add(
            AppTransaction(
              id: 'simulated',
              userId: 'preview',
              assetId: _selectedAsset.id,
              type: TransactionType.buy,
              quantity: inputQuantity,
              price: inputPrice,
              priceCurrency: _selectedCurrency,
              fee: inputFee,
              executedAt: _executedAt,
              source: TransactionSource.manual,
              createdAt: _executedAt,
            ),
          );
        final simResult = CostCalculator.calculatePosition(transactions: simulatedTxs, allowOversell: true);
        simulatedAvgCost = simResult.averageBuyPrice;
      } else {
        // Satışta ortalama değişmez, gerçekleşecek kâr/zarar önizlenir
        estimatedPnl = ((inputPrice - currentPos.averageBuyPrice) * inputQuantity) - inputFee;
      }
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Alış / Satış Segment
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: AppSpacing.roundedCard,
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isBuy = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isBuy ? AppColors.profitBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _isBuy ? AppColors.profitBorder : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ALIŞ',
                        style: AppTextStyles.labelSm.copyWith(
                          color: _isBuy ? AppColors.profitText : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isBuy = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isBuy ? AppColors.lossBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: !_isBuy ? AppColors.lossBorder : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'SATIŞ',
                        style: AppTextStyles.labelSm.copyWith(
                          color: !_isBuy ? AppColors.lossText : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Coin Seçimi ve Para Birimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.inputInset,
              borderRadius: AppSpacing.roundedInput,
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openAssetSelector(assets),
                    child: Row(
                      children: [
                        CoinTile(
                          symbol: _selectedAsset.symbol,
                          name: _selectedAsset.name,
                          imageUrl: _selectedAsset.imageUrl,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                      ],
                    ),
                  ),
                ),
                // USD / TRY Seçici
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: AppSpacing.roundedPill,
                    border: Border.all(color: AppColors.borderCard),
                  ),
                  child: Row(
                    children: [
                      _buildCurrencyOption('USD'),
                      _buildCurrencyOption('TRY'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Miktar Alanı
          TextFormField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            style: AppTextStyles.labelNumericMd,
            decoration: InputDecoration(
              labelText: 'İşlem Miktarı (${_selectedAsset.symbol})',
              hintText: '0.00',
              prefixIcon: Icon(Icons.numbers, color: AppColors.textSecondary, size: 20),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Lütfen işlem miktarını girin.';
              }
              final d = Decimal.tryParse(val.trim());
              if (d == null || d <= Decimal.zero) {
                return 'Miktar sıfırdan büyük olmalıdır.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. Birim Fiyat Alanı + "Piyasa Fiyatını Kullan" Butonu
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            style: AppTextStyles.labelNumericMd,
            decoration: InputDecoration(
              labelText: 'Birim Fiyat ($_selectedCurrency)',
              hintText: '0.00',
              prefixIcon: Icon(Icons.attach_money, color: AppColors.textSecondary, size: 20),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton.icon(
                  onPressed: _useMarketPrice,
                  icon: Icon(Icons.bolt, size: 16, color: AppColors.primary),
                  label: Text('Piyasa', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Lütfen birim fiyatı girin.';
              }
              final d = Decimal.tryParse(val.trim());
              if (d == null || d <= Decimal.zero) {
                return 'Birim fiyat sıfırdan büyük olmalıdır.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // 5. Tarih ve Saat Seçici
          GestureDetector(
            onTap: _pickDateTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.inputInset,
                borderRadius: AppSpacing.roundedInput,
                border: Border.all(color: AppColors.borderCard),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('İşlem Tarihi', style: AppTextStyles.bodySm),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(_executedAt),
                    style: AppTextStyles.labelNumericMd.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 6. Komisyon (Opsiyonel)
          TextFormField(
            controller: _feeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            style: AppTextStyles.labelNumericMd,
            decoration: InputDecoration(
              labelText: 'Komisyon ($_selectedCurrency) - Opsiyonel',
              hintText: '0.00',
              prefixIcon: Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // 7. Not (Opsiyonel)
          TextFormField(
            controller: _noteController,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'İşlem Notu (Opsiyonel)',
              hintText: 'Örn: DCA Alımı, Binance, vb.',
              prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Hata uyarısı (Özellikle Yetersiz Bakiye)
          if (_oversellError != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
              decoration: BoxDecoration(
                color: AppColors.lossBg,
                borderRadius: AppSpacing.roundedCard,
                border: Border.all(color: AppColors.lossBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.lossText, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _oversellError!,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.lossText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // 8. Canlı Önizleme Kartı
          CostPreviewCard(
            isBuy: _isBuy,
            newAverageCost: simulatedAvgCost,
            totalAmount: totalAmount,
            heldQuantity: currentPos.heldQuantity,
            estimatedPnl: estimatedPnl,
            currency: _selectedCurrency,
            assetSymbol: _selectedAsset.symbol,
          ),
          const SizedBox(height: AppSpacing.xl),

          // 9. Ana CTA Kaydet Butonu
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitTransaction,
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.canvas),
                  )
                : Text(
                    _isBuy ? 'ALIŞ İŞLEMİNİ KAYDET' : 'SATIŞ İŞLEMİNİ KAYDET',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(String currency) {
    final isSelected = _selectedCurrency == currency;
    return GestureDetector(
      onTap: () => setState(() => _selectedCurrency = currency),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface3 : Colors.transparent,
          borderRadius: AppSpacing.roundedPill,
        ),
        child: Text(
          currency,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
