// ==============================================================================
// Movira — Referans Ekran ve Mimari Gösterim Uygulaması (Sample Screen Showcase)
// Dosya: .agents/skills/examples/sample_screen.dart
//
// Bu dosya; PROJECT.md, design/SKILL.md, architecture/SKILL.md ve
// references/state_flow.md belgelerindeki tüm mimari, durum yönetimi ve
// Material 3 tasarım ilkelerini eksiksiz sergileyen referans ekrandır.
//
// Temel Özellikler:
// 1. Material 3 Tasarım Sistemi: Kırmızı (Crimson) ana renk, koyu bordo/antrasit koyu tema.
// 2. Tema Yönetimi: ValueNotifier<ThemeMode> ile ağır setState olmaksızın anlık tema geçişi.
// 3. Feature-First Katman Ayrımı: Presentation, Domain ve Data (Mock) katmanları.
// 4. Standart 5 Durum: Initial, Loading, Success, Empty, Error durumlarının tümü.
// 5. Dart 3 Standartları: Sealed classes, pattern matching, records ve null safety.
// 6. İş Kuralları: Tarih seçimi, çakışma kontrolü, teklif durumu, fiyat hesaplama.
// 7. Oturum Yönetimi: 'user-12345' test oturum kimliği ile korumalı işlem kontrolü.
// 8. Erişilebilirlik ve Dokunma Alanları: 48dp min dokunma alanı, semantik etiketler.
// ==============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

// ==============================================================================
// 1. DOMAIN KATMANI (Entities, Enums, Failures & Repository Interface)
// ==============================================================================

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

/// Teklif Durumları (PROJECT.md Madde 4.5 & state_flow.md Madde 3.3)
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

  RentalPrice multiply(int count) =>
      RentalPrice(amount * count, currency: currency);

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

/// Domain Hata Modeli (Sealed Failure)
sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'İnternet bağlantınızı kontrol edip tekrar deneyiniz.',
  ]);
}

final class AuthFailure extends Failure {
  const AuthFailure([
    super.message =
        'İşleme devam etmek için lütfen giriş yapınız (user-12345).',
  ]);
}

final class DateConflictFailure extends Failure {
  const DateConflictFailure([
    super.message = 'Seçtiğiniz tarihlerde araç uygun değildir veya başka bir rezervasyon bulunmaktadır.',
  ]);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Sunucu yanıt vermedi. Lütfen daha sonra tekrar deneyiniz.',
  ]);
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
  Future<Result<VehicleListingEntity, Failure>> getListingDetail(
    String listingId,
  );
  Future<Result<RentalOfferEntity, Failure>> submitOffer({
    required String listingId,
    required String renterId,
    required DateTime startDate,
    required DateTime endDate,
    required String message,
  });
}

// ==============================================================================
// 2. DATA KATMANI (Mock Repository - Gerçek Olmayan API İddiası Yoktur)
// ==============================================================================

/// Demo / Mock Repository Gerçeklemesi
class MockVehicleListingRepository implements VehicleListingRepository {
  @override
  Future<Result<VehicleListingEntity, Failure>> getListingDetail(
    String listingId,
  ) async {
    // Ağ gecikmesi simülasyonu
    await Future.delayed(const Duration(milliseconds: 600));

    if (listingId == 'error_trigger') {
      return const Error(
        NetworkFailure(
          'Sunucuyla bağlantı kurulamadı. Ağınızı kontrol ediniz.',
        ),
      );
    }

    if (listingId == 'empty_trigger') {
      return const Error(
        ValidationFailure('İlan bulunamadı veya yayından kaldırılmış.'),
      );
    }

    // Örnek Başarılı Movira İlanı
    final dummyListing = VehicleListingEntity(
      id: listingId,
      title: '2023 Renault Clio 1.0 TCe Touch — Temiz, Ekonomik ve Şehir İçi Uyumlu',
      description:
          'Aracımız düzenli yetkili servis bakımlı, sigara içilmemiş ve kaskoludur. '
          'Şehir içi düşük yakıt tüketimi sunar. Havalimanı veya merkezi teslimat imkanı mevcuttur.',
      vehicle: const VehicleEntity(
        id: 'veh_001',
        brand: 'Renault',
        model: 'Clio Touch',
        year: 2023,
        vehicleClass: VehicleClass.economy,
        transmission: TransmissionType.automatic,
        fuel: FuelType.gasoline,
        seatCount: 5,
        photoUrls: [
          'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800',
          'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?w=800',
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
        ],
        features: [
          'Geri Görüş Kamerası',
          'Apple CarPlay & Android Auto',
          'Hız Sabitleyici',
          'Park Sensörü',
          'Bluetooth',
          'Yokuş Kalkış Desteği',
        ],
      ),
      dailyPrice: const RentalPrice(1350),
      depositPrice: const RentalPrice(3500),
      minRentalDays: 2,
      pickupLocation: 'İstanbul, Kadıköy / Sabiha Gökçen Teslimat',
      ratingAverage: 4.88,
      reviewCount: 36,
      hostName: 'Ahmet Yılmaz (Süper Ev Sahibi)',
      hostRating: 4.95,
      isAvailable: true,
    );

    return Success(dummyListing);
  }

  @override
  Future<Result<RentalOfferEntity, Failure>> submitOffer({
    required String listingId,
    required String renterId,
    required DateTime startDate,
    required DateTime endDate,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    // Oturum Kontrolü (PROJECT.md Madde 4.1: Şimdilik user-12345 ile girilecek)
    if (renterId.isEmpty) {
      return const Error(
        AuthFailure('Teklif vermek için oturum açmalısınız (user-12345).'),
      );
    }

    final totalDays = endDate.difference(startDate).inDays;
    if (totalDays <= 0) {
      return const Error(
        ValidationFailure('Bitiş tarihi başlangıç tarihinden sonra olmalıdır.'),
      );
    }

    final dummyOffer = RentalOfferEntity(
      id: 'off_${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      renterId: renterId,
      renterName: 'Mert Demir ($renterId)',
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      totalPrice: RentalPrice(1350.0 * totalDays),
      message: message,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
    );

    return Success(dummyOffer);
  }
}

// ==============================================================================
// 3. PRESENTATION KATMANI (State, Controller & UI)
// ==============================================================================

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

  RentalPrice get calculatedTotalPrice =>
      listing.dailyPrice.multiply(totalDays);

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

/// Araç Detay Controller (ValueNotifier Tabanlı)
class VehicleDetailController extends ValueNotifier<VehicleDetailState> {
  final VehicleListingRepository _repository;
  String _currentListingId = 'listing_001';

  VehicleDetailController({VehicleListingRepository? repository})
    : _repository = repository ?? MockVehicleListingRepository(),
      super(const VehicleDetailInitial());

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
          currentUserId:
              'user-12345', // PROJECT.md: Şimdilik user-12345 ile girilecek
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
      value = (value as VehicleDetailSuccess).copyWith(
        isSubmittingOffer: false,
      );
    }

    return result;
  }

  void retry() => loadListing(_currentListingId);
}

// ==============================================================================
// 4. MOVIRA TEMA SİSTEMİ & GİRİŞ UYGULAMASI (Theme & App Entry)
// ==============================================================================

/// Global Tema Durum Yöneticisi (PROJECT.md Madde 1 & 6)
final ValueNotifier<ThemeMode> globalThemeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

void main() {
  runApp(const MoviraSampleApp());
}

class MoviraSampleApp extends StatelessWidget {
  const MoviraSampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Modern Kırmızı (Crimson) Paleti
    const primaryRed = Color(0xFFDC2626);
    const darkBordeauxBg = Color(0xFF140707);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: globalThemeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Movira Araç Kiralama',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          // Açık Tema (Material 3)
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryRed,
              brightness: Brightness.light,
              primary: primaryRed,
              surface: const Color(0xFFFAFAFA),
            ),
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF111827),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          // Koyu Tema (Koyu Bordo / Antrasit Material 3)
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryRed,
              brightness: Brightness.dark,
              primary: const Color(0xFFEF4444),
              surface: const Color(0xFF200E0E),
              background: darkBordeauxBg,
            ),
            scaffoldBackgroundColor: darkBordeauxBg,
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Color(0xFF1C0A0A),
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          home: const VehicleDetailShowcaseScreen(),
        );
      },
    );
  }
}

// ==============================================================================
// 5. ANA EKRAN GÖRÜNÜMÜ (VehicleDetailShowcaseScreen)
// ==============================================================================

class VehicleDetailShowcaseScreen extends StatefulWidget {
  const VehicleDetailShowcaseScreen({super.key});

  @override
  State<VehicleDetailShowcaseScreen> createState() =>
      _VehicleDetailShowcaseScreenState();
}

class _VehicleDetailShowcaseScreenState
    extends State<VehicleDetailShowcaseScreen> {
  late final VehicleDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VehicleDetailController();
    _controller.loadListing('listing_001');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movira Araç Detayı',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          // Tema Geçiş Butonu (ValueNotifier<ThemeMode> Gösterimi)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: globalThemeNotifier,
            builder: (context, currentMode, _) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                onPressed: () {
                  globalThemeNotifier.value = isDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),
          // Favori Butonu
          ValueListenableBuilder<VehicleDetailState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final isFav = state is VehicleDetailSuccess && state.isFavorite;
              return IconButton(
                tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? theme.colorScheme.primary : null,
                ),
                onPressed: state is VehicleDetailSuccess
                    ? _controller.toggleFavorite
                    : null,
              );
            },
          ),
          // Simülasyon Menüsü (Tüm Durumları Test Etmek İçin)
          PopupMenuButton<String>(
            tooltip: 'Durum Test Menüsü',
            icon: const Icon(Icons.tune_outlined),
            onSelected: (value) {
              switch (value) {
                case 'success':
                  _controller.loadListing('listing_001');
                  break;
                case 'loading':
                  _controller.value = const VehicleDetailLoading();
                  break;
                case 'empty':
                  _controller.loadListing('empty_trigger');
                  break;
                case 'error':
                  _controller.loadListing('error_trigger');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'success',
                child: Text('✅ Başarılı Durumu (Success)'),
              ),
              const PopupMenuItem(
                value: 'loading',
                child: Text('⏳ Yükleniyor (Loading)'),
              ),
              const PopupMenuItem(
                value: 'empty',
                child: Text('📭 Boş Durum (Empty)'),
              ),
              const PopupMenuItem(
                value: 'error',
                child: Text('⚠️ Hata Durumu (Error)'),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<VehicleDetailState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          return switch (state) {
            VehicleDetailInitial() => const Center(
              child: Text('İlan yüklenmeye hazır.'),
            ),
            VehicleDetailLoading() => _buildLoadingState(context),
            VehicleDetailEmpty(message: final msg) => _buildEmptyState(
              context,
              msg,
            ),
            VehicleDetailError(message: final msg, canRetry: final retryable) =>
              _buildErrorState(context, msg, retryable),
            VehicleDetailSuccess() => _buildSuccessContent(context, state),
          };
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<VehicleDetailState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          if (state is! VehicleDetailSuccess) return const SizedBox.shrink();
          return _buildPersistentBottomBar(context, state);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DURUM WIDGETLARI (Loading, Empty, Error)
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Araç ve ilan bilgileri yükleniyor...',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'İlan Bulunamadı',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _controller.loadListing('listing_001'),
              icon: const Icon(Icons.refresh),
              label: const Text('Varsayılan İlanı Yükle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool canRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bir Sorun Oluştu',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            if (canRetry)
              ElevatedButton.icon(
                onPressed: _controller.retry,
                icon: const Icon(Icons.replay_outlined),
                label: const Text('Yeniden Dene'),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BAŞARILI DURUM İÇERİĞİ (Success Content)
  // ---------------------------------------------------------------------------

  Widget _buildSuccessContent(
    BuildContext context,
    VehicleDetailSuccess state,
  ) {
    final listing = state.listing;
    final vehicle = listing.vehicle;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Fotoğraf Galerisi / Banner
          _buildPhotoGallery(context, state),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Başlık, Sınıf ve Puan Satırı
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vehicle.vehicleClass.label,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            listing.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Konum ve Puan Özeti
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.pickupLocation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.ratingAverage.toStringAsFixed(1)} (${listing.reviewCount})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // 3. Hızlı Araç Özellikleri Kartları (Badges)
                Text(
                  'Temel Özellikler',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFeatureChip(
                      context,
                      Icons.speed_outlined,
                      vehicle.transmission.label,
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      context,
                      Icons.local_gas_station_outlined,
                      vehicle.fuel.label,
                    ),
                    const SizedBox(width: 8),
                    _buildFeatureChip(
                      context,
                      Icons.airline_seat_recline_normal_outlined,
                      '${vehicle.seatCount} Koltuk',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Kiralama Tarih Seçimi Kartı
                _buildDateSelectionCard(context, state),
                const SizedBox(height: 20),

                // 5. İlan Sahibi Bilgisi & İletişim
                _buildHostInfoCard(context, listing),
                const SizedBox(height: 20),

                // 6. Donanım ve Özellikler Listesi
                Text(
                  'Araç Donanımı',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vehicle.features.map((feature) {
                    return Chip(
                      avatar: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(
                        feature,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.5),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 7. Açıklama
                Text(
                  'İlan Açıklaması',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, VehicleDetailSuccess state) {
    final photos = state.listing.vehicle.photoUrls;
    final selectedIndex = state.selectedPhotoIndex;

    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          color: Colors.black12,
          child: Image.network(
            photos[selectedIndex],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        // Fotoğraf Sayacı Rozeti
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${selectedIndex + 1} / ${photos.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Küçük Resim Seçici Şeridi
        if (photos.length > 1)
          Positioned(
            bottom: 12,
            left: 12,
            child: Row(
              children: List.generate(photos.length, (idx) {
                final isSelected = idx == selectedIndex;
                return GestureDetector(
                  onTap: () => _controller.selectPhotoIndex(idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: NetworkImage(photos[idx]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionCard(
    BuildContext context,
    VehicleDetailSuccess state,
  ) {
    final theme = Theme.of(context);
    final startStr =
        '${state.startDate.day}.${state.startDate.month}.${state.startDate.year}';
    final endStr =
        '${state.endDate.day}.${state.endDate.month}.${state.endDate.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kiralama Tarihleri',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _pickDateRange(context, state),
                icon: const Icon(Icons.calendar_month_outlined, size: 16),
                label: const Text('Değiştir', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alış Tarihi',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        startStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'İade Tarihi',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        endStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam Süre: ${state.totalDays} Gün',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Tahmini Tutar: ${state.calculatedTotalPrice.formatted}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostInfoCard(
    BuildContext context,
    VehicleListingEntity listing,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            foregroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.hostName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.hostRating.toStringAsFixed(1)} Araç Sahibi Puanı',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Araç sahibine mesajlaşma paneli açılıyor...'),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Soru Sor', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ALT SABİT AKSİYON ÇUBUĞU (Bottom Persistent Action Bar)
  // ---------------------------------------------------------------------------

  Widget _buildPersistentBottomBar(
    BuildContext context,
    VehicleDetailSuccess state,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.calculatedTotalPrice.formatted,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${state.totalDays} gün için toplam (${state.listing.dailyPrice.formatted}/gün)',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: state.isSubmittingOffer
                    ? null
                    : () => _showOfferDialog(context, state),
                child: state.isSubmittingOffer
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Teklif Oluştur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ETKİLEŞİM DİYALOGLARI (Date Picker & Offer Dialog)
  // ---------------------------------------------------------------------------

  Future<void> _pickDateRange(
    BuildContext context,
    VehicleDetailSuccess state,
  ) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(
        start: state.startDate,
        end: state.endDate,
      ),
      helpText: 'Kiralama Tarih Aralığı Seçiniz',
      cancelText: 'Vazgeç',
      confirmText: 'Uygula',
    );

    if (pickedRange != null) {
      _controller.updateDateRange(pickedRange.start, pickedRange.end);
    }
  }

  void _showOfferDialog(BuildContext context, VehicleDetailSuccess state) {
    final messageController = TextEditingController(
      text: 'Merhaba, aracı belirtilen tarihlerde kiralamak istiyorum.',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Kiralama Teklifi Gönder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.listing.vehicle.fullName} için ${state.totalDays} günlük kiralama teklifi oluşturuyorsunuz.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Teklif Tutarı:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        state.calculatedTotalPrice.formatted,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Araç Sahibine Not / Mesaj',
                    hintText: 'Teslimat yeri veya özel isteklerinizi belirtebilirsiniz...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final result = await _controller.submitOffer(
                  messageController.text,
                );
                if (!context.mounted) return;

                switch (result) {
                  case Success(data: final offer):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.shade700,
                        content: Text(
                          'Teklifiniz başarıyla iletildi! (Durum: ${offer.status.label}, Kiracı: ${offer.renterName})',
                        ),
                      ),
                    );
                  case Error(failure: final failure):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red.shade700,
                        content: Text(failure.message),
                      ),
                    );
                }
              },
              child: const Text('Onayla ve Gönder'),
            ),
          ],
        );
      },
    );
  }
}
