import 'package:flutter/foundation.dart';

import '../models/donation_statistics_model.dart';

class DonationStatisticsController {
  final ValueNotifier<List<MonthlyDonationModel>> monthly =
      ValueNotifier<List<MonthlyDonationModel>>(const []);
  final ValueNotifier<List<BloodGroupShareModel>> groupShares =
      ValueNotifier<List<BloodGroupShareModel>>(const []);
  final ValueNotifier<int?> selectedMonthIndex = ValueNotifier<int?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  bool _isDisposed = false;

  static const List<int> _current = [
    1820,
    1640,
    1910,
    2050,
    2240,
    1980,
    1760,
    1690,
    2120,
    2380,
    2290,
    2510,
  ];
  static const List<int> _previous = [
    1700,
    1580,
    1750,
    1890,
    2010,
    1920,
    1810,
    1600,
    1980,
    2150,
    2200,
    2300,
  ];

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (_isDisposed) return;
      monthly.value = [
        for (var i = 0; i < 12; i++)
          MonthlyDonationModel(
            month: DateTime(2026, i + 1),
            count: _current[i],
            previousYearCount: _previous[i],
          ),
      ];
      groupShares.value = const [
        BloodGroupShareModel(group: 'A+', percent: 34),
        BloodGroupShareModel(group: '0+', percent: 29),
        BloodGroupShareModel(group: 'B+', percent: 15),
        BloodGroupShareModel(group: 'AB+', percent: 7),
        BloodGroupShareModel(group: 'A-', percent: 6),
        BloodGroupShareModel(group: '0-', percent: 5),
        BloodGroupShareModel(group: 'B-', percent: 3),
        BloodGroupShareModel(group: 'AB-', percent: 1),
      ];
      selectedMonthIndex.value = monthly.value.length - 1;
    } catch (_) {
      if (_isDisposed) return;
      errorMessage.value = 'İstatistikler yüklenemedi.';
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  void selectMonth(int index) => selectedMonthIndex.value = index;

  int get yearTotal => monthly.value.fold(0, (sum, m) => sum + m.count);

  int get previousYearTotal =>
      monthly.value.fold(0, (sum, m) => sum + m.previousYearCount);

  void dispose() {
    _isDisposed = true;
    monthly.dispose();
    groupShares.dispose();
    selectedMonthIndex.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
