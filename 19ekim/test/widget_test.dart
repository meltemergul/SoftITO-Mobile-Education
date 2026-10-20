import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/water_tracker/controller/water_tracker_controller.dart';
import 'package:susadim/features/workout/controller/workout_controller.dart';
import 'package:susadim/main.dart';

void main() {
  group('susadım Birim Testleri', () {
    test('WaterTrackerController su ekleme ve hedef hesaplama testi', () {
      final controller = WaterTrackerController();
      expect(controller.currentAmountMl, 0);
      expect(controller.remainingMl, 2500);

      controller.addWater(500);
      expect(controller.currentAmountMl, 500);
      expect(controller.remainingMl, 2000);
      expect(controller.progressPercentage, 0.2);

      controller.resetDaily();
      expect(controller.currentAmountMl, 0);
      expect(controller.logs.isEmpty, isTrue);
    });

    test('Egzersiz su ihtiyacı hesaplama ve controller senkronizasyonu testi', () {
      final workoutController = WorkoutController();
      final waterController = WaterTrackerController();

      // Kardiyo: 30 dk, 240 kcal -> (30*5) + (240*0.4) = 150 + 96 = 246 ml
      final workout = workoutController.addWorkout(
        title: 'Kardiyo',
        category: 'Kardiyo',
        durationMinutes: 30,
        caloriesBurned: 240,
      );

      expect(workout, isNotNull);
      expect(workout!.recommendedWaterMl, 246);
      expect(workoutController.totalRecommendedWaterMl, 246);

      // Su kontrolcüsüne egzersiz hidrasyonu yansıtılır
      waterController.setExtraWorkoutWater(workoutController.totalRecommendedWaterMl);
      expect(waterController.baseDailyGoalMl, 2500);
      expect(waterController.extraWorkoutWaterMl, 246);
      expect(waterController.dailyGoalMl, 2746);
    });
  });

  group('susadım Widget Testleri', () {
    testWidgets('Uygulama açılır ve su takibi bileşenleri görüntülenir', (WidgetTester tester) async {
      await tester.pumpWidget(const SusadimApp());
      await tester.pumpAndSettle();

      expect(find.text('💧 Su Takibi'), findsOneWidget);
      expect(find.text('Hızlı Su Ekle'), findsOneWidget);
      expect(find.text('+200'), findsOneWidget);
    });

    testWidgets('Hızlı su ekleme butonuna basıldığında su miktarı güncellenir', (WidgetTester tester) async {
      await tester.pumpWidget(const SusadimApp());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.text('+200'));
      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(find.text('+200 ml'), findsOneWidget);
    });

    testWidgets('Egzersiz eklendiğinde hidrasyon bildirimi çıkar ve su hedefi otomatik güncellenir', (WidgetTester tester) async {
      await tester.pumpWidget(const SusadimApp());
      await tester.pumpAndSettle();

      // Egzersiz sekmesine geç
      await tester.tap(find.text('Egzersiz'));
      await tester.pumpAndSettle();

      // Kardiyo egzersizi ekle (+240 kcal, 30 dk)
      await tester.tap(find.text('Kardiyo'));
      await tester.pumpAndSettle(); // SnackBar animasyonunun tamamlanmasını bekle

      // Otomatik hesaplanan ek su ihtiyacı bildirimi doğrulanır
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Gereken ek su: +246 ml'), findsOneWidget);
      expect(find.text('İçtim'), findsOneWidget);

      // 'İçtim' butonuna basarak doğrudan su ekle
      await tester.tap(find.text('İçtim'));
      await tester.pumpAndSettle();

      // Su Takibi sekmesine dön
      await tester.tap(find.text('Su Takibi'));
      await tester.pumpAndSettle();

      // Yeni hedef: 2500 + 246 = 2746 ml ve tüketilen: 246 ml
      expect(find.text('+246 ml egzersiz hidrasyonu'), findsOneWidget);
      expect(find.text('246'), findsOneWidget);
      expect(find.text('/ 2746 ml'), findsOneWidget);
    });
  });
}
