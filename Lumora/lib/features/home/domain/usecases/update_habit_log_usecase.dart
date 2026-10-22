import '../repositories/today_repository.dart';

class UpdateHabitLogUseCase {
  UpdateHabitLogUseCase(this._repository);

  final TodayRepository _repository;

  Future<void> call({
    required String habitId,
    required String date,
    double? amount,
    double? delta,
  }) {
    return _repository.updateLog(
      habitId,
      date,
      amount: amount,
      delta: delta,
    );
  }
}
