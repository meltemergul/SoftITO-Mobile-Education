import '../../domain/entities/vehicle_listing_entity.dart';

/// Araç Detay Ekran Durumu (Sealed Class)
sealed class VehicleDetailState {
  const VehicleDetailState();
}

final class VehicleDetailInitial extends VehicleDetailState {
  const VehicleDetailInitial();
}

final class VehicleDetailLoading extends VehicleDetailState {
  const VehicleDetailLoading();
}

final class VehicleDetailSuccess extends VehicleDetailState {
  final VehicleListingEntity listing;
  final DateTime startDate;
  final DateTime endDate;
  final bool isSubmittingOffer;
  final bool isFavorite;
  final int selectedPhotoIndex;
  final String currentUserId;

  const VehicleDetailSuccess({
    required this.listing,
    required this.startDate,
    required this.endDate,
    this.isSubmittingOffer = false,
    this.isFavorite = false,
    this.selectedPhotoIndex = 0,
    this.currentUserId = 'user-12345',
  });

  int get totalDays {
    final diff = endDate.difference(startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  RentalPrice get calculatedTotalPrice => listing.dailyPrice.multiply(totalDays);

  VehicleDetailSuccess copyWith({
    VehicleListingEntity? listing,
    DateTime? startDate,
    DateTime? endDate,
    bool? isSubmittingOffer,
    bool? isFavorite,
    int? selectedPhotoIndex,
    String? currentUserId,
  }) {
    return VehicleDetailSuccess(
      listing: listing ?? this.listing,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isSubmittingOffer: isSubmittingOffer ?? this.isSubmittingOffer,
      isFavorite: isFavorite ?? this.isFavorite,
      selectedPhotoIndex: selectedPhotoIndex ?? this.selectedPhotoIndex,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

final class VehicleDetailEmpty extends VehicleDetailState {
  final String message;
  const VehicleDetailEmpty(this.message);
}

final class VehicleDetailError extends VehicleDetailState {
  final String message;
  final bool canRetry;
  const VehicleDetailError({required this.message, this.canRetry = true});
}
