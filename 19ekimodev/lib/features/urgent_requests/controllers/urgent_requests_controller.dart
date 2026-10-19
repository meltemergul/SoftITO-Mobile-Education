import 'package:flutter/foundation.dart';

import '../models/urgent_request_model.dart';

class UrgentRequestsController {
  UrgentRequestsController() {
    requests.addListener(_applyFilter);
    selectedGroup.addListener(_applyFilter);
  }

  final ValueNotifier<List<UrgentRequestModel>> requests =
      ValueNotifier<List<UrgentRequestModel>>(const []);
  final ValueNotifier<List<UrgentRequestModel>> filteredRequests =
      ValueNotifier<List<UrgentRequestModel>>(const []);
  final ValueNotifier<BloodGroup?> selectedGroup = ValueNotifier<BloodGroup?>(
    null,
  );
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  bool _isDisposed = false;

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      // Servis katmanı bağlandığında bu gecikme repository çağrısıyla değiştirilir.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (_isDisposed) return;
      requests.value = const [
        UrgentRequestModel(
          id: 'req_001',
          hospitalName: 'Ankara Şehir Hastanesi',
          city: 'Ankara',
          bloodGroup: BloodGroup.zeroNeg,
          unitsNeeded: 4,
          respondedDonors: 1,
          urgency: UrgencyLevel.critical,
        ),
        UrgentRequestModel(
          id: 'req_002',
          hospitalName: 'Cerrahpaşa Tıp Fakültesi',
          city: 'İstanbul',
          bloodGroup: BloodGroup.aPos,
          unitsNeeded: 2,
          respondedDonors: 0,
          urgency: UrgencyLevel.high,
        ),
        UrgentRequestModel(
          id: 'req_003',
          hospitalName: 'Ege Üniversitesi Hastanesi',
          city: 'İzmir',
          bloodGroup: BloodGroup.abPos,
          unitsNeeded: 3,
          respondedDonors: 3,
          urgency: UrgencyLevel.normal,
        ),
      ];
    } catch (_) {
      if (_isDisposed) return;
      errorMessage.value = 'Acil talepler yüklenemedi. Lütfen tekrar deneyin.';
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  void selectGroup(BloodGroup? group) {
    selectedGroup.value = group;
  }

  void respondToRequest(String id) {
    requests.value = [
      for (final item in requests.value)
        if (item.id == id && !item.isFulfilled)
          item.copyWith(respondedDonors: item.respondedDonors + 1)
        else
          item,
    ];
  }

  void _applyFilter() {
    final group = selectedGroup.value;
    final sorted = [...requests.value]
      ..sort((a, b) => a.urgency.index.compareTo(b.urgency.index));
    filteredRequests.value = group == null
        ? sorted
        : sorted.where((item) => item.bloodGroup == group).toList();
  }

  void dispose() {
    _isDisposed = true;
    requests.removeListener(_applyFilter);
    selectedGroup.removeListener(_applyFilter);
    requests.dispose();
    filteredRequests.dispose();
    selectedGroup.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
