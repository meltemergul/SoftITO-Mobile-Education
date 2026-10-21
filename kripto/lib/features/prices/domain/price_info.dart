import 'package:decimal/decimal.dart';

class PriceInfo {
  final String assetId;
  final String currency; // 'USD' | 'TRY'
  final Decimal price;
  final Decimal? change24h;
  final DateTime fetchedAt;

  const PriceInfo({
    required this.assetId,
    required this.currency,
    required this.price,
    this.change24h,
    required this.fetchedAt,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      assetId: json['asset_id'] as String,
      currency: json['currency'] as String,
      price: Decimal.parse(json['price'].toString()),
      change24h: json['change_24h'] != null
          ? Decimal.parse(json['change_24h'].toString())
          : null,
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_id': assetId,
      'currency': currency,
      'price': price.toString(),
      'change_24h': change24h?.toString(),
      'fetched_at': fetchedAt.toUtc().toIso8601String(),
    };
  }
}
