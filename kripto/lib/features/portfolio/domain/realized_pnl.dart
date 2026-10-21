import 'package:decimal/decimal.dart';
import '../../../shared/models/asset.dart';

class RealizedPnl {
  final String transactionId;
  final Asset asset;
  final Decimal soldQuantity;
  final Decimal sellPrice;
  final Decimal averageBuyPriceAtSale;
  final Decimal fee;
  final String currency;
  final DateTime executedAt;

  const RealizedPnl({
    required this.transactionId,
    required this.asset,
    required this.soldQuantity,
    required this.sellPrice,
    required this.averageBuyPriceAtSale,
    required this.fee,
    required this.currency,
    required this.executedAt,
  });

  Decimal get netRealizedPnl =>
      ((sellPrice - averageBuyPriceAtSale) * soldQuantity) - fee;
}
