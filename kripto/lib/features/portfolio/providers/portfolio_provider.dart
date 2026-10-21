import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/asset.dart';
import '../../prices/providers/prices_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../domain/cost_calculator.dart';
import '../domain/portfolio_calculator.dart';
import '../domain/position.dart';

final positionsProvider = Provider<List<Position>>((ref) {
  final txAsync = ref.watch(transactionsProvider);
  final pricesAsync = ref.watch(pricesProvider);
  final assetsAsync = ref.watch(assetsProvider);
  final selectedCurrency = ref.watch(currencyProvider);

  final transactions = txAsync.value ?? [];
  final prices = pricesAsync.value ?? [];
  final assets = assetsAsync.value ?? Asset.defaultAssets;

  if (transactions.isEmpty) return [];

  // 1. İşlemleri assetId'ye göre grupla
  final Map<String, List<AppTransaction>> groupedTxs = {};
  for (final tx in transactions) {
    if (tx.deletedAt != null) continue;
    groupedTxs.putIfAbsent(tx.assetId, () => []).add(tx);
  }

  final List<Position> positions = [];

  for (final entry in groupedTxs.entries) {
    final assetId = entry.key;
    final txs = entry.value;

    final asset = assets.firstWhere(
      (a) => a.id == assetId,
      orElse: () => Asset.defaultAssets.firstWhere(
        (a) => a.id == assetId || a.symbol == assetId,
        orElse: () => Asset(
          id: assetId,
          symbol: assetId.toUpperCase(),
          name: assetId,
          coingeckoId: assetId.toLowerCase(),
        ),
      ),
    );

    // Kronolojik replay ile maliyet ve eldeki miktarı hesapla
    final calc = CostCalculator.calculatePosition(transactions: txs, allowOversell: true);

    if (calc.heldQuantity > Decimal.zero) {
      // Güncel fiyatı önbellekten bul
      final priceMatch = prices.where((p) =>
          (p.assetId == asset.id || p.assetId == asset.coingeckoId) &&
          p.currency == selectedCurrency).firstOrNull;

      final currentPrice = priceMatch?.price ?? calc.averageBuyPrice;

      positions.add(
        Position(
          asset: asset,
          quantity: calc.heldQuantity,
          averageBuyPrice: calc.averageBuyPrice,
          currentPrice: currentPrice,
          currency: selectedCurrency,
        ),
      );
    }
  }

  return positions;
});

final portfolioSummaryProvider = Provider<PortfolioSummary>((ref) {
  final positions = ref.watch(positionsProvider);
  return PortfolioCalculator.calculateSummary(positions);
});

final allRealizedSalesProvider = Provider<List<RealizedSalePnl>>((ref) {
  final txAsync = ref.watch(transactionsProvider);
  final transactions = txAsync.value ?? [];

  if (transactions.isEmpty) return [];

  final Map<String, List<AppTransaction>> groupedTxs = {};
  for (final tx in transactions) {
    if (tx.deletedAt != null) continue;
    groupedTxs.putIfAbsent(tx.assetId, () => []).add(tx);
  }

  final List<RealizedSalePnl> allSales = [];
  for (final entry in groupedTxs.entries) {
    final calc = CostCalculator.calculatePosition(transactions: entry.value, allowOversell: true);
    allSales.addAll(calc.realizedSales);
  }

  allSales.sort((a, b) => b.executedAt.compareTo(a.executedAt));
  return allSales;
});
