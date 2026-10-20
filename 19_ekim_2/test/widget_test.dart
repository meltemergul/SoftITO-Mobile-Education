import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/core/theme/theme_controller.dart';
import 'package:susadim/features/water_tracker/controllers/water_tracker_controller.dart';
import 'package:susadim/features/workout/controllers/workout_controller.dart';
import 'package:susadim/features/workout/models/workout_model.dart';
import 'package:susadim/main.dart';

void main() {
  group('ThemeController Tests', () {
    test('Varsayılan tema modu karanlık olmalıdır', () {
      final controller = ThemeController();
      expect(controller.themeMode.value, ThemeMode.dark);
      expect(controller.isDarkMode, true);
    });

    test('toggleTheme karanlık ve aydınlık arasında geçiş yapmalıdır', () {
      final controller = ThemeController();
      controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.light);
      expect(controller.isDarkMode, false);

      controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.dark);
      expect(controller.isDarkMode, true);
    });
  });

  group('WaterTrackerController Tests', () {
    test('İlk su miktarı 0 ve hedef varsayılan olmalıdır', () {
      final controller = WaterTrackerController();
      expect(controller.currentWater.value, 0);
      expect(controller.totalDailyGoal, 2000);
      expect(controller.progressRatio, 0.0);
    });

    test('Su eklendiğinde miktar artmalı ve kayıt düşmelidir', () {
      final controller = WaterTrackerController();
      controller.addWater(250, source: 'Bardak');
      expect(controller.currentWater.value, 250);
      expect(controller.records.value.length, 1);
      expect(controller.records.value.first.amountMl, 250);
      expect(controller.records.value.first.source, 'Bardak');
    });

    test('Sıfırlama işlemi tüm değerleri temizlemelidir', () {
      final controller = WaterTrackerController();
      controller.addWater(500);
      controller.resetWater();
      expect(controller.currentWater.value, 0);
      expect(controller.records.value.isEmpty, true);
    });
  });

  group('WorkoutController Tests', () {
    test('Egzersiz eklendiğinde süre, kalori ve ek su ihtiyacı güncellenmelidir', () {
      int reportedExtra = 0;
      final controller = WorkoutController(
        onWorkoutAdded: (extraWater, title) {
          reportedExtra = extraWater;
        },
      );

      controller.addWorkout(
        title: 'Ağırlık Antrenmanı',
        type: WorkoutType.weightLifting,
        durationMinutes: 30,
      );

      expect(controller.totalMinutes.value, 30);
      expect(controller.workouts.value.length, 1);
      expect(reportedExtra, 240); // 30 dk * 8 ml/dk = 240 ml
      expect(controller.totalExtraWater.value, 240);
    });
  });

  group('SusadimApp Widget & Theme Toggle Tests', () {
    testWidgets('Uygulama başarıyla başlatılmalı ve tema değiştirilebilmelidir',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SusadimApp());
      await tester.pumpAndSettle();

      expect(find.text('susadım v1'), findsOneWidget);
      expect(find.text('Su Takibi'), findsOneWidget);
      expect(find.text('Egzersiz'), findsOneWidget);

      // Tema butonunun varlığını ve tıklanabilirliğini doğrula
      final themeToggleFinder = find.byTooltip('Aydınlık Moda Geç');
      expect(themeToggleFinder, findsOneWidget);

      await tester.tap(themeToggleFinder);
      await tester.pumpAndSettle();

      // Tıklandıktan sonra tooltip 'Karanlık Moda Geç' olmalı
      expect(find.byTooltip('Karanlık Moda Geç'), findsOneWidget);
    });
  });
}
