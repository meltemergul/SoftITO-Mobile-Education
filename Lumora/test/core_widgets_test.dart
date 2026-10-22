import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/core/theme/colors.dart';
import 'package:lumora/core/widgets/app_pill_button.dart';
import 'package:lumora/core/widgets/app_card.dart';
import 'package:lumora/core/widgets/app_text_field.dart';
import 'package:lumora/core/widgets/app_toggle.dart';
import 'package:lumora/core/widgets/app_segmented_control.dart';
import 'package:lumora/core/widgets/app_filter_chip.dart';

Widget wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('Core Theme & Widgets Test', () {
    testWidgets('AppColorsExtension theme extension doğru renkleri sağlar',
        (tester) async {
      late AppColorsExtension colors;

      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (context) {
              colors = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors.primary, const Color(0xFF10B981));
      expect(colors.primaryStrong, const Color(0xFF059669));
      expect(colors.streak, const Color(0xFFF97316));
      expect(colors.water, const Color(0xFF0284C7));
      expect(colors.mind, const Color(0xFF7C3AED));
    });

    testWidgets('AppPillButton birincil ve ikincil durumları doğru çalışır',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppPillButton(
            label: 'Kaydet',
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.text('Kaydet'), findsOneWidget);
      await tester.tap(find.text('Kaydet'));
      expect(tapped, isTrue);

      // Loading durumu
      await tester.pumpWidget(
        wrapWithTheme(
          AppPillButton(
            label: 'Yükleniyor',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Yükleniyor'), findsNothing);
    });

    testWidgets('AppCard tıklama ve içerik gösterimi', (tester) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          AppCard(
            onTap: () => cardTapped = true,
            child: const Text('Kart İçeriği'),
          ),
        ),
      );

      expect(find.text('Kart İçeriği'), findsOneWidget);
      await tester.tap(find.text('Kart İçeriği'));
      expect(cardTapped, isTrue);
    });

    testWidgets('AppTextField şifre göster/gizle ikonu çalışır',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const AppTextField(
            label: 'Şifre',
            isPassword: true,
          ),
        ),
      );

      expect(find.text('Şifre'), findsOneWidget);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, isTrue);

      // Göster ikonuna tıkla
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      final updatedEditable =
          tester.widget<EditableText>(find.byType(EditableText));
      expect(updatedEditable.obscureText, isFalse);
    });

    testWidgets('AppToggle durum değişimi ve saat seçici gösterimi',
        (tester) async {
      bool switchValue = false;
      bool timeTapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return AppToggle(
                title: 'Hatırlatıcı',
                time: '08:00',
                value: switchValue,
                onChanged: (val) => setState(() => switchValue = val),
                onTimeTap: () => timeTapped = true,
              );
            },
          ),
        ),
      );

      expect(find.text('Hatırlatıcı'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);

      await tester.tap(find.text('08:00'));
      expect(timeTapped, isTrue);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(switchValue, isTrue);
    });

    testWidgets('AppSegmentedControl seçenek değişimi tetikler',
        (tester) async {
      int selected = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return AppSegmentedControl(
                options: const ['Giriş Yap', 'Kayıt Ol'],
                selectedIndex: selected,
                onSelected: (val) => setState(() => selected = val),
              );
            },
          ),
        ),
      );

      expect(find.text('Giriş Yap'), findsOneWidget);
      expect(find.text('Kayıt Ol'), findsOneWidget);

      await tester.tap(find.text('Kayıt Ol'));
      await tester.pump();
      expect(selected, 1);
    });

    testWidgets('AppFilterChip seçim durumunu tetikler', (tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        wrapWithTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return AppFilterChip(
                label: 'Su',
                isSelected: isSelected,
                onSelected: (val) => setState(() => isSelected = val),
              );
            },
          ),
        ),
      );

      expect(find.text('Su'), findsOneWidget);
      await tester.tap(find.text('Su'));
      await tester.pump();
      expect(isSelected, isTrue);
    });
  });
}
