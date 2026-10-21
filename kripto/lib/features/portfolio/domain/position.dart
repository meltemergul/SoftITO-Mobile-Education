import 'package:decimal/decimal.dart';
import '../../../shared/models/asset.dart';

class Position {
  final Asset asset;
  final Decimal quantity;
  final Decimal averageBuyPrice;
  final Decimal currentPrice;
  final String currency; // 'USD' | 'TRY'

  const Position({
    required this.asset,
    required this.quantity,
    required this.averageBuyPrice,
    required this.currentPrice,
    required this.currency,
  });

  Decimal get totalCost => quantity * averageBuyPrice;
  Decimal get currentValue => quantity * currentPrice;
  Decimal get unrealizedPnl => currentValue - totalCost;

  Decimal get unrealizedPnlPercentage {
    if (averageBuyPrice == Decimal.zero) return Decimal.zero;
    return (unrealizedPnl / averageBuyPrice).toDecimal(scaleOnInfinitePrecision: 8) *
        Decimal.fromInt(100);
  }
}
