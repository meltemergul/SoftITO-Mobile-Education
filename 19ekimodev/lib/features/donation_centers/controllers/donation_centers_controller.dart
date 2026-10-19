import 'package:flutter/foundation.dart';

import '../models/donation_center_model.dart';

class DonationCentersController {
  DonationCentersController() {
    centers.addListener(_applyFilter);
    selectedType.addListener(_applyFilter);
    onlyOpen.addListener(_applyFilter);
  }

  final ValueNotifier<List<DonationCenterModel>> centers =
      ValueNotifier<List<DonationCenterModel>>(const []);
  final ValueNotifier<List<DonationCenterModel>> visibleCenters =
      ValueNotifier<List<DonationCenterModel>>(const []);
  final ValueNotifier<CenterType?> selectedType = ValueNotifier<CenterType?>(
    null,
  );
  final ValueNotifier<bool> onlyOpen = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  bool _isDisposed = false;

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (_isDisposed) return;
      centers.value = const [
        DonationCenterModel(
          id: 'c1',
          name: 'Kızılay Kızılay Meydanı Bağış Merkezi',
          address: 'Çankaya, Ankara',
          type: CenterType.kizilay,
          workingHours: '09:00 - 18:00',
          distanceKm: 1.2,
          occupancy: 0.35,
          isOpen: true,
        ),
        DonationCenterModel(
          id: 'c2',
          name: 'Kızılay Seyyar Kan Alma Otobüsü',
          address: 'ODTÜ Kampüsü, Ankara',
          type: CenterType.mobile,
          workingHours: '10:00 - 16:00',
          distanceKm: 3.8,
          occupancy: 0.72,
          isOpen: true,
        ),
        DonationCenterModel(
          id: 'c3',
          name: 'Ankara Şehir Hastanesi Kan Merkezi',
          address: 'Bilkent, Ankara',
          type: CenterType.hospital,
          workingHours: '08:00 - 17:00',
          distanceKm: 6.4,
          occupancy: 0.9,
          isOpen: true,
        ),
        DonationCenterModel(
          id: 'c4',
          name: 'Hacettepe Üniversitesi Kan Bankası',
          address: 'Sıhhiye, Ankara',
          type: CenterType.hospital,
          workingHours: '08:30 - 16:30',
          distanceKm: 2.5,
          occupancy: 0.15,
          isOpen: false,
        ),
      ];
    } catch (_) {
      if (_isDisposed) return;
      errorMessage.value = 'Bağış noktaları yüklenemedi.';
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  void selectType(CenterType? type) => selectedType.value = type;

  void toggleOnlyOpen() => onlyOpen.value = !onlyOpen.value;

  void _applyFilter() {
    final type = selectedType.value;
    final result =
        centers.value
            .where((c) => type == null || c.type == type)
            .where((c) => !onlyOpen.value || c.isOpen)
            .toList()
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    visibleCenters.value = result;
  }

  void dispose() {
    _isDisposed = true;
    centers.removeListener(_applyFilter);
    selectedType.removeListener(_applyFilter);
    onlyOpen.removeListener(_applyFilter);
    centers.dispose();
    visibleCenters.dispose();
    selectedType.dispose();
    onlyOpen.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
