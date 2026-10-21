import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../data/price_repository.dart';
import '../data/price_service.dart';
import '../domain/price_info.dart';

final priceServiceProvider = Provider<PriceService>((ref) {
  return PriceService();
});

final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  final service = ref.watch(priceServiceProvider);
  return PriceRepository(service);
});

class LastPriceUpdateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setTime(DateTime time) => state = time;
}

final lastPriceUpdateProvider =
    NotifierProvider<LastPriceUpdateNotifier, DateTime?>(() {
  return LastPriceUpdateNotifier();
});

final pricesProvider = AsyncNotifierProvider<PricesNotifier, List<PriceInfo>>(() {
  return PricesNotifier();
});

class PricesNotifier extends AsyncNotifier<List<PriceInfo>> with WidgetsBindingObserver {
  Timer? _refreshTimer;
  bool _isBackgrounded = false;

  @override
  Future<List<PriceInfo>> build() async {
    // Uygulama yaşam döngüsünü dinlemeye başla
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _stopTimer();
    });

    final repo = ref.watch(priceRepositoryProvider);
    final initialPrices = await repo.getCachedPrices();

    if (initialPrices.isNotEmpty) {
      ref.read(lastPriceUpdateProvider.notifier).setTime(DateTime.now());
    }

    _startTimer();
    return initialPrices;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Uygulama ön plana geldi: zamanlayıcıyı yeniden başlat ve hemen yenile
      _isBackgrounded = false;
      _startTimer();
      refresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      // Uygulama arka plana geçti: kota koruması için zamanlayıcıyı durdur
      _isBackgrounded = true;
      _stopTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    if (_isBackgrounded) return;

    _refreshTimer = Timer.periodic(
      const Duration(seconds: AppConstants.defaultPriceTtlSeconds),
      (_) {
        if (!_isBackgrounded) {
          refresh();
        }
      },
    );
  }

  void _stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Elle veya zamanlayıcıyla fiyatları yenileme
  Future<void> refresh() async {
    final previousPrices = state.value ?? ref.read(priceRepositoryProvider).lastKnownPrices;

    try {
      final repo = ref.read(priceRepositoryProvider);
      final newPrices = await repo.refreshPrices();

      if (newPrices.isNotEmpty) {
        state = AsyncValue.data(newPrices);
        ref.read(lastPriceUpdateProvider.notifier).setTime(DateTime.now());
      }
    } catch (e, st) {
      // Ağ hatasında son bilinen fiyatlar gösterilir, ekran boş kalmaz
      if (previousPrices.isNotEmpty) {
        state = AsyncValue.data(previousPrices);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
