import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chronomind/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders logo, form fields, and toggles between login and signup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    // Marka ve form elemanları görünür
    expect(find.text('Chronomind'), findsOneWidget);
    expect(find.text('GİRİŞ YAP'), findsNWidgets(2)); // Segment + CTA butonu
    expect(find.text('KAYIT OL'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // E-posta ve şifre

    // KAYIT OL sekmesine dokunulduğunda şifre tekrar alanı açılır
    await tester.tap(find.text('KAYIT OL'));
    await tester.pump();

    expect(find.text('HESAP OLUŞTUR'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3)); // E-posta, şifre, şifre tekrarı
  });

  testWidgets('LoginScreen validates empty input fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();

    // Boş alanlarla giriş butonuna tıkla
    await tester.tap(find.widgetWithText(ElevatedButton, 'GİRİŞ YAP'));
    await tester.pump();

    expect(find.text('Lütfen e-posta adresinizi girin.'), findsOneWidget);
    expect(find.text('Lütfen şifrenizi girin.'), findsOneWidget);
  });
}
