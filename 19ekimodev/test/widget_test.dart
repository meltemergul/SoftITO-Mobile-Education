import 'package:can_bagim/features/blood_values/models/blood_metric_model.dart';
import 'package:can_bagim/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BloodMetricModel.status', () {
    const base = BloodMetricModel(
      id: 'hb',
      title: 'Hemoglobin',
      currentValue: 13,
      minThreshold: 12.5,
      maxThreshold: 16.5,
      unit: 'g/dL',
    );

    test('aralık içi uygun', () => expect(base.status, MetricStatus.eligible));
    test(
      'eşiğin %90 içi uyarı',
      () => expect(
        base.copyWith(currentValue: 11.5).status,
        MetricStatus.warning,
      ),
    );
    test(
      'çok düşük uygun değil',
      () => expect(
        base.copyWith(currentValue: 9).status,
        MetricStatus.ineligible,
      ),
    );
  });

  testWidgets('sekmeler arası gezinme ve tema geçişi', (tester) async {
    await tester.pumpWidget(const CanBagimApp());
    await tester.pumpAndSettle();
    expect(find.text('Bağış Uygunluk Değerleri'), findsOneWidget);

    await tester.tap(find.text('Acil'));
    await tester.pumpAndSettle();
    expect(find.text('Ankara Şehir Hastanesi'), findsOneWidget);

    await tester.tap(find.text('İstatistik'));
    await tester.pumpAndSettle();
    expect(find.text('Aylık Bağış Sayıları'), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    await tester.tap(find.byIcon(Icons.light_mode).last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
