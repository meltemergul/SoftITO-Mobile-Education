import 'package:decimal/decimal.dart';
import '../../../../core/errors.dart';
import '../../transactions/domain/transaction.dart';

class RealizedSalePnl {
  final String transactionId;
  final Decimal soldQuantity;
  final Decimal sellPrice;
  final Decimal averageBuyPrice;
  final Decimal fee;
  final Decimal netPnl;
  final DateTime executedAt;

  const RealizedSalePnl({
    required this.transactionId,
    required this.soldQuantity,
    required this.sellPrice,
    required this.averageBuyPrice,
    required this.fee,
    required this.netPnl,
    required this.executedAt,
  });
}

class PositionCalculationResult {
  final Decimal heldQuantity;
  final Decimal averageBuyPrice;
  final Decimal totalCost;
  final List<RealizedSalePnl> realizedSales;
  final Decimal totalRealizedPnl;

  const PositionCalculationResult({
    required this.heldQuantity,
    required this.averageBuyPrice,
    required this.totalCost,
    required this.realizedSales,
    required this.totalRealizedPnl,
  });
}

class CostCalculator {
  CostCalculator._();

  /// İşlemleri executed_at kronolojik sırasına göre tekrar oynatarak (replay)
  /// ortalama alış maliyetini, eldeki miktarı ve gerçekleşmiş K/Z dökümünü hesaplar.
  /// [allowOversell] false ise (varsayılan), eldeki miktardan fazla satışta ValidationError fırlatır.
  static PositionCalculationResult calculatePosition({
    required List<AppTransaction> transactions,
    bool allowOversell = false,
  }) {
    // Kronolojik sıra: executed_at artan sırada sıralanır
    final sorted = List<AppTransaction>.from(transactions)
      ..sort((a, b) => a.executedAt.compareTo(b.executedAt));

    Decimal heldQuantity = Decimal.zero;
    Decimal totalCost = Decimal.zero;
    final realizedSales = <RealizedSalePnl>[];
    Decimal totalRealizedPnl = Decimal.zero;

    for (final tx in sorted) {
      if (tx.deletedAt != null) {
        // Yumuşak silinmiş işlemler hesaplamaya dahil edilmez
        continue;
      }

      if (tx.type == TransactionType.buy) {
        // ALIŞ: toplam_maliyet += (miktar × fiyat) + komisyon; miktar += alış miktarı
        final txCost = (tx.quantity * tx.price) + tx.fee;
        totalCost += txCost;
        heldQuantity += tx.quantity;
      } else {
        // SATIŞ:
        if (tx.quantity > heldQuantity && !allowOversell) {
          throw ValidationError(
            'Yetersiz bakiye: Eldeki miktar ($heldQuantity), satış miktarı (${tx.quantity})',
          );
        }

        // Satış anındaki ortalama alış maliyeti
        final currentAvgBuyPrice = heldQuantity > Decimal.zero
            ? (totalCost / heldQuantity).toDecimal(scaleOnInfinitePrecision: 18)
            : Decimal.zero;

        // Gerçekleşmiş K/Z = (satış fiyatı − ortalama alış) × satılan miktar − komisyon
        final netPnl = ((tx.price - currentAvgBuyPrice) * tx.quantity) - tx.fee;

        realizedSales.add(
          RealizedSalePnl(
            transactionId: tx.id,
            soldQuantity: tx.quantity,
            sellPrice: tx.price,
            averageBuyPrice: currentAvgBuyPrice,
            fee: tx.fee,
            netPnl: netPnl,
            executedAt: tx.executedAt,
          ),
        );
        totalRealizedPnl += netPnl;

        // Eldeki stoktan satılan kısmın maliyeti düşülür
        final costSold = currentAvgBuyPrice * tx.quantity;
        totalCost -= costSold;
        heldQuantity -= tx.quantity;

        // Miktar sıfıra inerse maliyet tabanı sıfırlanır (eski ortalama taşınmaz)
        if (heldQuantity <= Decimal.zero) {
          heldQuantity = Decimal.zero;
          totalCost = Decimal.zero;
        }
      }
    }

    final averageBuyPrice = heldQuantity > Decimal.zero
        ? (totalCost / heldQuantity).toDecimal(scaleOnInfinitePrecision: 18)
        : Decimal.zero;

    return PositionCalculationResult(
      heldQuantity: heldQuantity,
      averageBuyPrice: averageBuyPrice,
      totalCost: totalCost,
      realizedSales: List.unmodifiable(realizedSales),
      totalRealizedPnl: totalRealizedPnl,
    );
  }
}
