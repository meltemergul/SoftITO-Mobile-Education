import 'package:decimal/decimal.dart';
import 'position.dart';

class PortfolioSummary {
  final Decimal totalValue;
  final Decimal totalCost;
  final Decimal totalUnrealizedPnl;
  final Decimal totalUnrealizedPnlPercentage;
  final String? concentratedAssetSymbol; // %50'den büyükse uyarı

  const PortfolioSummary({
    required this.totalValue,
    required this.totalCost,
    required this.totalUnrealizedPnl,
    required this.totalUnrealizedPnlPercentage,
    this.concentratedAssetSymbol,
  });
}

class PortfolioCalculator {
  PortfolioCalculator._();

  static PortfolioSummary calculateSummary(List<Position> positions) {
    Decimal totalValue = Decimal.zero;
    Decimal totalCost = Decimal.zero;

    for (final pos in positions) {
      totalValue += pos.currentValue;
      totalCost += pos.totalCost;
    }

    final totalUnrealizedPnl = totalValue - totalCost;
    final totalPercentage = totalCost > Decimal.zero
        ? (totalUnrealizedPnl / totalCost).toDecimal(scaleOnInfinitePrecision: 8) *
            Decimal.fromInt(100)
        : Decimal.zero;

    String? concentrated;
    if (totalValue > Decimal.zero) {
      for (final pos in positions) {
        final share = (pos.currentValue / totalValue).toDecimal(scaleOnInfinitePrecision: 4);
        if (share > Decimal.parse('0.5')) {
          concentrated = pos.asset.symbol;
          break;
        }
      }
    }

    return PortfolioSummary(
      totalValue: totalValue,
      totalCost: totalCost,
      totalUnrealizedPnl: totalUnrealizedPnl,
      totalUnrealizedPnlPercentage: totalPercentage,
      concentratedAssetSymbol: concentrated,
    );
  }
}
