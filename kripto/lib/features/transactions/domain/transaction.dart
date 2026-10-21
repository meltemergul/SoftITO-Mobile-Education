import 'package:decimal/decimal.dart';

enum TransactionType { buy, sell }

enum TransactionSource { manual, csv }

class AppTransaction {
  final String id;
  final String userId;
  final String assetId;
  final TransactionType type;
  final Decimal quantity;
  final Decimal price;
  final String priceCurrency; // 'USD' | 'TRY'
  final Decimal fee;
  final String? feeCurrency;
  final DateTime executedAt;
  final TransactionSource source;
  final String? note;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const AppTransaction({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.type,
    required this.quantity,
    required this.price,
    required this.priceCurrency,
    required this.fee,
    this.feeCurrency,
    required this.executedAt,
    required this.source,
    this.note,
    required this.createdAt,
    this.deletedAt,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      assetId: json['asset_id'] as String,
      type: json['type'] == 'BUY' ? TransactionType.buy : TransactionType.sell,
      quantity: Decimal.parse(json['quantity'].toString()),
      price: Decimal.parse(json['price'].toString()),
      priceCurrency: json['price_currency'] as String,
      fee: Decimal.parse((json['fee'] ?? 0).toString()),
      feeCurrency: json['fee_currency'] as String?,
      executedAt: DateTime.parse(json['executed_at'] as String),
      source: json['source'] == 'CSV' ? TransactionSource.csv : TransactionSource.manual,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'asset_id': assetId,
      'type': type == TransactionType.buy ? 'BUY' : 'SELL',
      'quantity': quantity.toString(),
      'price': price.toString(),
      'price_currency': priceCurrency,
      'fee': fee.toString(),
      'fee_currency': feeCurrency,
      'executed_at': executedAt.toUtc().toIso8601String(),
      'source': source == TransactionSource.csv ? 'CSV' : 'MANUAL',
      'note': note,
      'created_at': createdAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }
}
