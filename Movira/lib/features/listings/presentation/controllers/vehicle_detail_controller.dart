import 'package:flutter/foundation.dart';
import '../../domain/entities/vehicle_listing_entity.dart';
import '../../domain/repositories/vehicle_listing_repository.dart';
import '../../data/repositories/mock_vehicle_listing_repository.dart';
import 'vehicle_detail_state.dart';

/// Araç Detay Controller (ValueNotifier Tabanlı)
class VehicleDetailController extends ValueNotifier<VehicleDetailState> {
  final VehicleListingRepository _repository;
  String _currentListingId = 'listing_001';

  VehicleDetailController({
    VehicleListingRepository? repository,
    VehicleListingEntity? initialListing,
  })  : _repository = repository ?? MockVehicleListingRepository(),
        super(initialListing != null
            ? VehicleDetailSuccess(
                listing: initialListing,
                startDate: DateTime.now().add(const Duration(days: 1)),
                endDate: DateTime.now().add(const Duration(days: 4)),
                currentUserId: 'user-12345',
              )
            : const VehicleDetailInitial()) {
    if (initialListing != null) {
      _currentListingId = initialListing.id;
    }
  }

  void setInitialListing(VehicleListingEntity listing) {
    _currentListingId = listing.id;
    final now = DateTime.now();
    value = VehicleDetailSuccess(
      listing: listing,
      startDate: now.add(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 4)),
      currentUserId: 'user-12345',
    );
  }

  Future<void> loadListing(String listingId) async {
    _currentListingId = listingId;
    value = const VehicleDetailLoading();

    final result = await _repository.getListingDetail(listingId);

    switch (result) {
      case Success(data: final listing):
        final now = DateTime.now();
        value = VehicleDetailSuccess(
          listing: listing,
          startDate: now.add(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 4)),
          currentUserId: 'user-12345',
        );
      case Error(failure: final failure):
        if (failure is ValidationFailure) {
          value = VehicleDetailEmpty(failure.message);
        } else {
          value = VehicleDetailError(message: failure.message);
        }
    }
  }

  void updateDateRange(DateTime start, DateTime end) {
    final currentState = value;
    if (currentState is VehicleDetailSuccess) {
      value = currentState.copyWith(startDate: start, endDate: end);
    }
  }

  void selectPhotoIndex(int index) {
    final currentState = value;
    if (currentState is VehicleDetailSuccess) {
      value = currentState.copyWith(selectedPhotoIndex: index);
    }
  }

  void toggleFavorite() {
    final currentState = value;
    if (currentState is VehicleDetailSuccess) {
      value = currentState.copyWith(isFavorite: !currentState.isFavorite);
    }
  }

  Future<Result<RentalOfferEntity, Failure>> submitOffer(String message) async {
    final currentState = value;
    if (currentState is! VehicleDetailSuccess) {
      return const Error(ValidationFailure('Geçerli bir ilan seçilmedi.'));
    }

    value = currentState.copyWith(isSubmittingOffer: true);

    final result = await _repository.submitOffer(
      listingId: currentState.listing.id,
      renterId: currentState.currentUserId,
      startDate: currentState.startDate,
      endDate: currentState.endDate,
      message: message,
    );

    if (value is VehicleDetailSuccess) {
      value = (value as VehicleDetailSuccess).copyWith(isSubmittingOffer: false);
    }

    return result;
  }

  void retry() => loadListing(_currentListingId);
}
