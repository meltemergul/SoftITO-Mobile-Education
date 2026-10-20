import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movira/app/app.dart';
import 'package:movira/app/theme/app_theme.dart';
import 'package:movira/features/listings/presentation/pages/vehicle_detail_page.dart';
import 'package:movira/features/listings/data/repositories/mock_vehicle_listing_repository.dart';

void main() {
  testWidgets('MoviraApp başlatma ve ana gezinme kontrolleri', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is NetworkImageLoadException) return;
      originalOnError?.call(details);
    };

    await tester.pumpWidget(const MoviraApp());

    // Ana AppBar ve Gezinme Barı
    expect(find.text('MOVIRA'), findsOneWidget);
    expect(find.text('Keşfet'), findsOneWidget);
    expect(find.text('İlan Ver'), findsOneWidget);
    expect(find.text('Teklifler'), findsOneWidget);
    expect(find.text('Mesajlar'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Listelerin yüklenmesini bekle
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('Renault Clio 1.0 TCe Touch (2023)'), findsOneWidget);

    FlutterError.onError = originalOnError;
  });

  testWidgets('Detay sayfası tıklanan araca göre marka ve dinamik fotoğraf sayısını gösterir',
      (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is NetworkImageLoadException) return;
      originalOnError?.call(details);
    };

    final listings = MockVehicleListingRepository.allListings;

    // 1. Renault Clio (4 Fotoğraf)
    final clio = listings.firstWhere((l) => l.id == 'listing_001');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: VehicleDetailPage(initialListing: clio),
      ),
    );
    await tester.pump();

    expect(find.text('Renault • 2023'), findsOneWidget);
    expect(find.text('1 / 4 Fotoğraf'), findsOneWidget);
    expect(find.text('Renault Clio 1.0 TCe Touch (2023)'), findsOneWidget);

    // 2. BMW 320i M Sport (4 Fotoğraf)
    final bmw = listings.firstWhere((l) => l.id == 'listing_002');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: VehicleDetailPage(initialListing: bmw),
      ),
    );
    await tester.pump();

    expect(find.text('BMW • 2024'), findsOneWidget);
    expect(find.text('1 / 4 Fotoğraf'), findsOneWidget);
    expect(find.text('BMW 320i M Sport (2024)'), findsOneWidget);

    // 3. Peugeot 3008 GT (3 Fotoğraf)
    final peugeot = listings.firstWhere((l) => l.id == 'listing_003');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: VehicleDetailPage(initialListing: peugeot),
      ),
    );
    await tester.pump();

    expect(find.text('Peugeot • 2023'), findsOneWidget);
    expect(find.text('1 / 3 Fotoğraf'), findsOneWidget);
    expect(find.text('Peugeot 3008 GT 1.5 BlueHDi (2023)'), findsOneWidget);

    // 4. Tesla Model Y (4 Fotoğraf)
    final tesla = listings.firstWhere((l) => l.id == 'listing_004');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: VehicleDetailPage(initialListing: tesla),
      ),
    );
    await tester.pump();

    expect(find.text('Tesla • 2024'), findsOneWidget);
    expect(find.text('1 / 4 Fotoğraf'), findsOneWidget);
    expect(find.text('Tesla Model Y Long Range AWD (2024)'), findsOneWidget);

    // 5. Mercedes-Benz C200 AMG (3 Fotoğraf)
    final mercedes = listings.firstWhere((l) => l.id == 'listing_005');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: VehicleDetailPage(initialListing: mercedes),
      ),
    );
    await tester.pump();

    expect(find.text('Mercedes-Benz • 2023'), findsOneWidget);
    expect(find.text('1 / 3 Fotoğraf'), findsOneWidget);
    expect(find.text('Mercedes-Benz C200 4MATIC AMG (2023)'), findsOneWidget);

    FlutterError.onError = originalOnError;
  });

  test('MockVehicleListingRepository tüm araçların marka bazlı gerçek fotoğraflarını sağlar', () async {
    final repo = MockVehicleListingRepository(simulatedDelay: Duration.zero);
    final result = await repo.getListings();

    expect(result.isSuccess, isTrue);
    final listings = result.dataOrNull!;
    expect(listings.length, 5);

    final clio = listings.firstWhere((l) => l.id == 'listing_001');
    expect(clio.vehicle.brand, 'Renault');
    expect(clio.vehicle.photoUrls.length, 4);

    final bmw = listings.firstWhere((l) => l.id == 'listing_002');
    expect(bmw.vehicle.brand, 'BMW');
    expect(bmw.vehicle.photoUrls.length, 4);

    final peugeot = listings.firstWhere((l) => l.id == 'listing_003');
    expect(peugeot.vehicle.brand, 'Peugeot');
    expect(peugeot.vehicle.photoUrls.length, 3);

    final tesla = listings.firstWhere((l) => l.id == 'listing_004');
    expect(tesla.vehicle.brand, 'Tesla');
    expect(tesla.vehicle.photoUrls.length, 4);

    final mercedes = listings.firstWhere((l) => l.id == 'listing_005');
    expect(mercedes.vehicle.brand, 'Mercedes-Benz');
    expect(mercedes.vehicle.photoUrls.length, 3);
  });
}
