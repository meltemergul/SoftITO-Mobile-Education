import 'package:flutter/foundation.dart';

import '../../../core/constants/blood_value_ranges.dart';
import '../models/blood_metric_model.dart';

class BloodValuesController {
  final ValueNotifier<List<BloodMetricModel>> metrics =
      ValueNotifier<List<BloodMetricModel>>(const []);
  final ValueNotifier<Gender> gender = ValueNotifier<Gender>(Gender.female);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  bool _isDisposed = false;

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (_isDisposed) return;
      metrics.value = [
        BloodMetricModel.fromRange(
          id: 'hb',
          title: 'Hemoglobin',
          value: 13.8,
          range: BloodValueRanges.hemoglobinFor(gender.value),
        ),
        BloodMetricModel.fromRange(
          id: 'weight',
          title: 'Vücut Ağırlığı',
          value: 68,
          range: BloodValueRanges.weight,
        ),
        BloodMetricModel.fromRange(
          id: 'pulse',
          title: 'Nabız',
          value: 104,
          range: BloodValueRanges.pulse,
        ),
        BloodMetricModel.fromRange(
          id: 'systolic',
          title: 'Büyük Tansiyon',
          value: 122,
          range: BloodValueRanges.systolic,
        ),
        BloodMetricModel.fromRange(
          id: 'diastolic',
          title: 'Küçük Tansiyon',
          value: 78,
          range: BloodValueRanges.diastolic,
        ),
      ];
    } catch (_) {
      if (_isDisposed) return;
      errorMessage.value = 'Değerler yüklenemedi. Lütfen tekrar deneyin.';
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  void setGender(Gender value) {
    gender.value = value;
    final range = BloodValueRanges.hemoglobinFor(value);
    metrics.value = [
      for (final item in metrics.value)
        if (item.id == 'hb')
          item.copyWith(minThreshold: range.min, maxThreshold: range.max)
        else
          item,
    ];
  }

  void updateMetricValue(String id, double newValue) {
    metrics.value = [
      for (final item in metrics.value)
        if (item.id == id) item.copyWith(currentValue: newValue) else item,
    ];
  }

  void dispose() {
    _isDisposed = true;
    metrics.dispose();
    gender.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
