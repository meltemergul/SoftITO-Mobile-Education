// Girişim360 — Ana Widget ve Navigasyon Testi

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:girisim360/app/app.dart';
import 'package:girisim360/core/theme/theme_controller.dart';
import 'package:girisim360/features/startup/data/datasources/startup_local_datasource.dart';
import 'package:girisim360/features/startup/data/repositories/startup_repository_impl.dart';
import 'package:girisim360/features/startup/presentation/controllers/startup_controller.dart';

void main() {
  testWidgets('Girisim360App başlatılmalı, navigasyon ve dinamik aşama kontrolü çalışmalıdır', (WidgetTester tester) async {
    final themeController = ThemeController();
    final dataSource = StartupLocalDataSource();
    final repository = StartupRepositoryImpl(dataSource);
    final startupController = StartupController(repository);

    await tester.pumpWidget(Girisim360App(
      themeController: themeController,
      startupController: startupController,
    ));
    await tester.pumpAndSettle();

    // 1. Ana Sayfa Başlığı ve Girişim Adı Doğrulanmalı
    expect(find.text('Girişim360'), findsOneWidget);
    expect(find.text('BioLoop Tarım Teknolojileri'), findsOneWidget);

    // 2. Navigasyon sekmeleri doğrulanmalı
    expect(find.widgetWithText(NavigationDestination, 'Ana Sayfa'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Girişim'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Mentorluk'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Hukuk'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Destekler'), findsOneWidget);

    // 3. Girişim Yönetimi sekmesine geçiş
    await tester.tap(find.widgetWithText(NavigationDestination, 'Girişim'));
    await tester.pumpAndSettle();

    expect(find.text('Girişim Yönetimi'), findsOneWidget);
    expect(find.text('Girişim Aşaması'), findsOneWidget);

    // 4. Mentorluk sekmesine geçiş
    await tester.tap(find.widgetWithText(NavigationDestination, 'Mentorluk'));
    await tester.pumpAndSettle();
    expect(find.text('Mentor Eşleşmesi'), findsOneWidget);

    // 5. Hukuk sekmesine geçiş
    await tester.tap(find.widgetWithText(NavigationDestination, 'Hukuk'));
    await tester.pumpAndSettle();
    expect(find.text('Hukuki Süreçler & İş Planı'), findsOneWidget);

    // 6. Destekler sekmesine geçiş
    await tester.tap(find.widgetWithText(NavigationDestination, 'Destekler'));
    await tester.pumpAndSettle();
    expect(find.text('Destek ve Teşvikler'), findsOneWidget);

    // 7. Tema değiştirme testi
    await tester.tap(find.widgetWithText(NavigationDestination, 'Ana Sayfa'));
    await tester.pumpAndSettle();

    expect(themeController.isDarkMode, isTrue);
    final themeButton = find.byTooltip('Aydınlık Temaya Geç');
    expect(themeButton, findsOneWidget);
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    expect(themeController.isDarkMode, isFalse);
  });
}
