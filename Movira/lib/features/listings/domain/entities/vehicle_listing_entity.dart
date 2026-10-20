import 'package:flutter/material.dart';

/// Araç Sınıfları (PROJECT.md Madde 4.2 & 4.3)
enum VehicleClass {
  economy('Ekonomik', Icons.directions_car_filled_outlined),
  comfort('Konfor', Icons.airport_shuttle_outlined),
  suv('SUV / 4x4', Icons.terrain_outlined),
  premium('Premium / Lüks', Icons.diamond_outlined),
  van('Minibüs / Panelvan', Icons.local_shipping_outlined);

  final String label;
  final IconData icon;
  const VehicleClass(this.label, this.icon);
}

/// Vites Tipi
enum TransmissionType {
  automatic('Otomatik'),
  manual('Manuel');

  final String label;
  const TransmissionType(this.label);
}

/// Yakıt Tipi
enum FuelType {
  gasoline('Benzin'),
  diesel('Dizel'),
  hybrid('Hibrit'),
  electric('Elektrik');

  final String label;
  const FuelType(this.label);
}

/// Teklif Durumları (PROJECT.md Madde 4.5 & state_flow.md)
enum OfferStatus {
  pending('Beklemede', Color(0xFFF59E0B)),
  accepted('Kabul Edildi', Color(0xFF10B981)),
  rejected('Reddedildi', Color(0xFFEF4444)),
  withdrawn('Geri Çekildi', Color(0xFF6B7280)),
  expired('Süresi Doldu', Color(0xFF9CA3AF));

  final String label;
  final Color badgeColor;
  const OfferStatus(this.label, this.badgeColor);
}

/// Kiralama Fiyat Değeri (Parasal hassasiyet için güvenli nesne)
@immutable
class RentalPrice {
  final double amount;
  final String currency;

  const RentalPrice(this.amount, {this.currency = '₺'});

  String get formatted => '$currency${amount.toStringAsFixed(0)}';
  String get formattedWithPeriod => '$formatted / gün';

  RentalPrice multiply(int count) => RentalPrice(amount * count, currency: currency);

  @override
  String toString() => formatted;
}

/// Araç Varlığı (Domain Entity)
@immutable
class VehicleEntity {
  final String id;
  final String brand;
  final String model;
  final int year;
  final VehicleClass vehicleClass;
  final TransmissionType transmission;
  final FuelType fuel;
  final int seatCount;
  final List<String> photoUrls;
  final List<String> features;

  const VehicleEntity({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.vehicleClass,
    required this.transmission,
    required this.fuel,
    required this.seatCount,
    required this.photoUrls,
    required this.features,
  });

  String get fullName => '$brand $model ($year)';
}

/// Araç İlan Varlığı (Domain Entity)
@immutable
class VehicleListingEntity {
  final String id;
  final String title;
  final String description;
  final VehicleEntity vehicle;
  final RentalPrice dailyPrice;
  final RentalPrice depositPrice;
  final int minRentalDays;
  final String pickupLocation;
  final double ratingAverage;
  final int reviewCount;
  final String hostName;
  final double hostRating;
  final bool isAvailable;

  const VehicleListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.vehicle,
    required this.dailyPrice,
    required this.depositPrice,
    required this.minRentalDays,
    required this.pickupLocation,
    required this.ratingAverage,
    required this.reviewCount,
    required this.hostName,
    required this.hostRating,
    this.isAvailable = true,
  });
}

/// Teklif Varlığı (Domain Entity)
@immutable
class RentalOfferEntity {
  final String id;
  final String listingId;
  final String renterId;
  final String renterName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final RentalPrice totalPrice;
  final String message;
  final OfferStatus status;
  final DateTime createdAt;

  const RentalOfferEntity({
    required this.id,
    required this.listingId,
    required this.renterId,
    required this.renterName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    required this.message,
    required this.status,
    required this.createdAt,
  });
}
