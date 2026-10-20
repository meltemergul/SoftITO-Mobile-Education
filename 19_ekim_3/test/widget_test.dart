import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/water_tracker/controllers/water_tracker_controller.dart';
import 'package:susadim/features/workout/controllers/workout_controller.dart';
import 'package:susadim/features/workout/models/workout_model.dart';
import 'package:susadim/main.dart';

void main() {
  testWidgets('Uygulama başlatma ve su takip başlığı testi', (WidgetTester tester) async {
    await tester.pumpWidget(const SusadimApp());
    expect(find.text('susadım - Su Takibi'), findsOneWidget);
    expect(find.text('Hızlı Su Ekle'), findsOneWidget);
  });

  group('WaterTrackerController Birim Testleri', () {
    late WaterTrackerController controller;

    setUp(() {
      controller = WaterTrackerController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Başlangıçta su miktarı 0 olmalıdır', () {
      expect(controller.state.value.currentWaterMl, 0);
      expect(controller.state.value.baseGoalMl, 2000);
    });

    test('addWater reaktif olarak su miktarını artırmalıdır', () {
      controller.addWater(250);
      expect(controller.state.value.currentWaterMl, 250);
      expect(controller.state.value.remainingMl, 1750);
    });

    test('addWorkoutExtra ek su ihtiyacını hedefe eklemelidir', () {
      controller.addWorkoutExtra(500);
      expect(controller.state.value.workoutExtraMl, 500);
      expect(controller.state.value.totalGoalMl, 2500);
    });

    test('resetWater sayacı sıfırlamalıdır', () {
      controller.addWater(500);
      controller.resetWater();
      expect(controller.state.value.currentWaterMl, 0);
    });
  });

  group('WorkoutController ve Dinamik Su Hesaplama Testleri', () {
    late WorkoutController workoutController;

    setUp(() {
      workoutController = WorkoutController();
    });

    tearDown(() {
      workoutController.dispose();
    });

    test('addWorkout egzersiz eklemeli ve ek su ihtiyacı hesaplamalıdır', () {
      // 30 dk kardiyo -> 30 * 14 = 420 ml su
      workoutController.addWorkout(WorkoutType.cardio, 30);
      final state = workoutController.state.value;
      expect(state.workouts.length, 1);
      expect(state.workouts.first.calculatedExtraWaterMl, 420);
      expect(state.totalExtraWaterMl, 420);
    });
  });
}
