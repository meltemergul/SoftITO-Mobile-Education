import '../entities/vehicle_listing_entity.dart';

/// Domain Hata Modeli (Sealed Failure)
sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'İnternet bağlantınızı kontrol edip tekrar deneyiniz.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'İşleme devam etmek için lütfen giriş yapınız (user-12345).']);
}

final class DateConflictFailure extends Failure {
  const DateConflictFailure([super.message = 'Seçtiğiniz tarihlerde araç uygun değildir veya başka bir rezervasyon bulunmaktadır.']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Sunucu yanıt vermedi. Lütfen daha sonra tekrar deneyiniz.']);
}

/// Fonksiyonel Sonuç Sarmalayıcı (Result Pattern)
sealed class Result<S, E extends Failure> {
  const Result();

  bool get isSuccess => this is Success<S, E>;
  bool get isError => this is Error<S, E>;

  S? get dataOrNull => switch (this) {
    Success<S, E>(data: final d) => d,
    Error<S, E>() => null,
  };
}

final class Success<S, E extends Failure> extends Result<S, E> {
  final S data;
  const Success(this.data);
}

final class Error<S, E extends Failure> extends Result<S, E> {
  final E failure;
  const Error(this.failure);
}

/// Araç İlan Repository Sözleşmesi
abstract interface class VehicleListingRepository {
  Future<Result<List<VehicleListingEntity>, Failure>> getListings({String? category});
  Future<Result<VehicleListingEntity, Failure>> getListingDetail(String listingId);
  Future<Result<RentalOfferEntity, Failure>> submitOffer({
    required String listingId,
    required String renterId,
    required DateTime startDate,
    required DateTime endDate,
    required String message,
  });
}
