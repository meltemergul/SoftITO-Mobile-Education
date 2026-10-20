import '../../domain/entities/vehicle_listing_entity.dart';
import '../../domain/repositories/vehicle_listing_repository.dart';

/// Demo / Mock Repository Gerçeklemesi
/// Marka ve modele göre gerçek araç fotoğraflarını ve ilan detaylarını sağlar.
class MockVehicleListingRepository implements VehicleListingRepository {
  static final List<VehicleListingEntity> _allListings = [
    // 1. Renault Clio
    VehicleListingEntity(
      id: 'listing_001',
      title: 'Renault Clio 1.0 TCe Touch (2023)',
      description: 'Aracımız düzenli yetkili servis bakımlı, sigara içilmemiş ve kaskoludur. '
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
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/2019_Renault_Clio_Iconic_Front.jpg/1280px-2019_Renault_Clio_Iconic_Front.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/2019_Renault_Clio_Iconic_Rear.jpg/1280px-2019_Renault_Clio_Iconic_Rear.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/2019_Renault_Clio_Iconic_TCe_100_Interior.jpg/1280px-2019_Renault_Clio_Iconic_TCe_100_Interior.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/2020_Renault_Clio_Play_TCe.jpg/1280px-2020_Renault_Clio_Play_TCe.jpg',
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
    ),

    // 2. BMW 320i M Sport
    VehicleListingEntity(
      id: 'listing_002',
      title: 'BMW 320i M Sport (2024)',
      description: 'Lüks ve performans bir arada. M Sport gövde kiti, açılır cam tavan, '
          'Harman Kardon ses sistemi ve şerit takip asistanı bulunmaktadır. Özel teslimat.',
      vehicle: const VehicleEntity(
        id: 'veh_002',
        brand: 'BMW',
        model: '320i M Sport',
        year: 2024,
        vehicleClass: VehicleClass.premium,
        transmission: TransmissionType.automatic,
        fuel: FuelType.gasoline,
        seatCount: 5,
        photoUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/2019_BMW_320d_xDrive_M_Sport_2.0_Front.jpg/1280px-2019_BMW_320d_xDrive_M_Sport_2.0_Front.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/2019_BMW_320d_xDrive_M_Sport_2.0_Rear.jpg/1280px-2019_BMW_320d_xDrive_M_Sport_2.0_Rear.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/2019_BMW_330i_M_Sport_%2818%29.jpg/1280px-2019_BMW_330i_M_Sport_%2818%29.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/2019_BMW_3_series.jpg/1280px-2019_BMW_3_series.jpg',
        ],
        features: [
          'Harman Kardon Ses Sistemi',
          'Açılır Panoramik Cam Tavan',
          'M Deri Direksiyon',
          'Hayalet Gösterge Paneli',
          '360 Derece Çevre Kamerası',
          'Head-up Display',
        ],
      ),
      dailyPrice: const RentalPrice(3850),
      depositPrice: const RentalPrice(10000),
      minRentalDays: 2,
      pickupLocation: 'İstanbul, Beşiktaş / Levent Teslimat',
      ratingAverage: 5.0,
      reviewCount: 42,
      hostName: 'Mehmet Kaya (Kurumsal Galeri)',
      hostRating: 4.98,
      isAvailable: true,
    ),

    // 3. Peugeot 3008 GT
    VehicleListingEntity(
      id: 'listing_003',
      title: 'Peugeot 3008 GT 1.5 BlueHDi (2023)',
      description: 'Geniş bagaj hacmi, yüksek konfor ve ekonomik dizel motor. '
          'Aile gezileri ve uzun yol seyahatleri için ideal SUV donanımı.',
      vehicle: const VehicleEntity(
        id: 'veh_003',
        brand: 'Peugeot',
        model: '3008 GT',
        year: 2023,
        vehicleClass: VehicleClass.suv,
        transmission: TransmissionType.automatic,
        fuel: FuelType.diesel,
        seatCount: 5,
        photoUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Peugeot_3008_GT_HYBRID4_%283LA-P845G06H%29_front.jpg/1280px-Peugeot_3008_GT_HYBRID4_%283LA-P845G06H%29_front.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Peugeot_3008_GT_HYBRID4_%283LA-P845G06H%29_rear.jpg/1280px-Peugeot_3008_GT_HYBRID4_%283LA-P845G06H%29_rear.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Peugeot_3008_GT_HYBRID4_%283LA-P845G06H%29_interior.jpg/1280px-Peugeot_3008_GT_HYBRID4_%283LA-P845G06H%29_interior.jpg',
        ],
        features: [
          'i-Cockpit Dijital Gösterge',
          'Grip Control Çekiş Sistemi',
          'Masajlı Ön Koltuklar',
          'Kablosuz Şarj',
          'Otomatik Bagaj Kapağı',
          'Kör Nokta Uyarı Sistemi',
        ],
      ),
      dailyPrice: const RentalPrice(2250),
      depositPrice: const RentalPrice(6000),
      minRentalDays: 2,
      pickupLocation: 'İzmir, Adnan Menderes Havalimanı',
      ratingAverage: 4.82,
      reviewCount: 28,
      hostName: 'Ayşe Demir (Bireysel Araç Sahibi)',
      hostRating: 4.90,
      isAvailable: true,
    ),

    // 4. Tesla Model Y
    VehicleListingEntity(
      id: 'listing_004',
      title: 'Tesla Model Y Long Range AWD (2024)',
      description: 'Sıfır emisyon, maksimum hızlanma ve Autopilot konforu. '
          'Supercharger ağına uyumlu, teslimatta tam şarj garantili elektrikli SUV.',
      vehicle: const VehicleEntity(
        id: 'veh_004',
        brand: 'Tesla',
        model: 'Model Y Long Range',
        year: 2024,
        vehicleClass: VehicleClass.comfort,
        transmission: TransmissionType.automatic,
        fuel: FuelType.electric,
        seatCount: 5,
        photoUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Tesla_Model_Y_1X7A6211.jpg/1280px-Tesla_Model_Y_1X7A6211.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Tesla_Model_Y_1X7A7391.jpg/1280px-Tesla_Model_Y_1X7A7391.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Tesla_Model_Y_IMG_9499_%28cropped%29.jpg/1280px-Tesla_Model_Y_IMG_9499_%28cropped%29.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Tesla_Model_Y_2025_interior.jpg/1280px-Tesla_Model_Y_2025_interior.jpg',
        ],
        features: [
          'Tesla Gelişmiş Autopilot',
          '15 İnç Dokunmatik Merkez Ekran',
          'Panoramik Tam Cam Tavan',
          'Isıtmalı 5 Koltuk ve Direksiyon',
          'Premium Ses Sistemi (14 Hoparlör)',
          'Sentry Mode Güvenlik',
        ],
      ),
      dailyPrice: const RentalPrice(4200),
      depositPrice: const RentalPrice(12000),
      minRentalDays: 1,
      pickupLocation: 'Ankara, Çankaya / Esenboğa Teslimat',
      ratingAverage: 4.95,
      reviewCount: 51,
      hostName: 'Can Yıldız (EV Filo Yöneticisi)',
      hostRating: 4.97,
      isAvailable: true,
    ),

    // 5. Mercedes-Benz C200 AMG
    VehicleListingEntity(
      id: 'listing_005',
      title: 'Mercedes-Benz C200 4MATIC AMG (2023)',
      description: 'Prestij ve zarafet. AMG iç/dış tasarım paketi, Burmester ses sistemi '
          've 64 renkli ambiyans aydınlatması ile kusursuz sürüş deneyimi.',
      vehicle: const VehicleEntity(
        id: 'veh_005',
        brand: 'Mercedes-Benz',
        model: 'C200 4MATIC AMG',
        year: 2023,
        vehicleClass: VehicleClass.premium,
        transmission: TransmissionType.automatic,
        fuel: FuelType.gasoline,
        seatCount: 5,
        photoUrls: [
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/MERCEDES-BENZ_C-CLASS_LWB_%28V206%29_China.jpg/1280px-MERCEDES-BENZ_C-CLASS_LWB_%28V206%29_China.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/MERCEDES-BENZ_C-CLASS_LWB_%28W206%29_China_%2812%29.jpg/1280px-MERCEDES-BENZ_C-CLASS_LWB_%28W206%29_China_%2812%29.jpg',
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/MERCEDES-BENZ_C-CLASS_LWB_%28W206%29_China_%2817%29.jpg/1280px-MERCEDES-BENZ_C-CLASS_LWB_%28W206%29_China_%2817%29.jpg',
        ],
        features: [
          'AMG Tasarım Konsepti',
          'Burmester 3D Surround Ses',
          'Dijital Işık Farları (Digital Light)',
          '64 Renkli Ambiyans Aydınlatma',
          'MBUX Yeni Nesil Multimedya',
          'Hafızalı Elektrikli Koltuklar',
        ],
      ),
      dailyPrice: const RentalPrice(4100),
      depositPrice: const RentalPrice(11000),
      minRentalDays: 2,
      pickupLocation: 'Antalya, Havalimanı & Lara Teslimat',
      ratingAverage: 4.96,
      reviewCount: 39,
      hostName: 'Serdar Aydın (Antalya VIP Kiralama)',
      hostRating: 4.99,
      isAvailable: true,
    ),
  ];

  static List<VehicleListingEntity> get allListings => _allListings;

  final Duration simulatedDelay;

  MockVehicleListingRepository({this.simulatedDelay = const Duration(milliseconds: 200)});

  @override
  Future<Result<List<VehicleListingEntity>, Failure>> getListings({String? category}) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    if (category == null || category == 'Tümü') {
      return Success(_allListings);
    }

    final filtered = _allListings.where((item) {
      if (category == 'Ekonomik') return item.vehicle.vehicleClass == VehicleClass.economy;
      if (category == 'Konfor') return item.vehicle.vehicleClass == VehicleClass.comfort;
      if (category == 'SUV / 4x4') return item.vehicle.vehicleClass == VehicleClass.suv;
      if (category == 'Premium') return item.vehicle.vehicleClass == VehicleClass.premium;
      if (category == 'Elektrik') return item.vehicle.fuel == FuelType.electric;
      return true;
    }).toList();

    return Success(filtered);
  }

  @override
  Future<Result<VehicleListingEntity, Failure>> getListingDetail(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    if (listingId == 'error_trigger') {
      return const Error(NetworkFailure('Sunucuyla bağlantı kurulamadı. Ağınızı kontrol ediniz.'));
    }

    if (listingId == 'empty_trigger') {
      return const Error(ValidationFailure('İlan bulunamadı veya yayından kaldırılmış.'));
    }

    final found = _allListings.firstWhere(
      (element) => element.id == listingId,
      orElse: () => _allListings.first,
    );

    return Success(found);
  }

  @override
  Future<Result<RentalOfferEntity, Failure>> submitOffer({
    required String listingId,
    required String renterId,
    required DateTime startDate,
    required DateTime endDate,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (renterId.isEmpty) {
      return const Error(AuthFailure('Teklif vermek için oturum açmalısınız (user-12345).'));
    }

    final totalDays = endDate.difference(startDate).inDays;
    if (totalDays <= 0) {
      return const Error(ValidationFailure('Bitiş tarihi başlangıç tarihinden sonra olmalıdır.'));
    }

    final found = _allListings.firstWhere(
      (element) => element.id == listingId,
      orElse: () => _allListings.first,
    );

    final dummyOffer = RentalOfferEntity(
      id: 'off_${DateTime.now().millisecondsSinceEpoch}',
      listingId: listingId,
      renterId: renterId,
      renterName: 'Mert Demir ($renterId)',
      startDate: startDate,
      endDate: endDate,
      totalDays: totalDays,
      totalPrice: found.dailyPrice.multiply(totalDays),
      message: message,
      status: OfferStatus.pending,
      createdAt: DateTime.now(),
    );

    return Success(dummyOffer);
  }
}
