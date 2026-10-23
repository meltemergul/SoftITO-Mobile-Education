import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/stats_remote_data_source.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';

final statsRemoteDataSourceProvider = Provider<StatsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StatsRemoteDataSourceImpl(apiClient);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final remote = ref.watch(statsRemoteDataSourceProvider);
  return StatsRepositoryImpl(remote);
});

@immutable
class StatsState {
  const StatsState({
    this.range = 'weekly',
    this.stats,
    this.isLoading = false,
    this.errorMessage,
  });

  final String range;
  final StatsEntity? stats;
  final bool isLoading;
  final String? errorMessage;

  StatsState copyWith({
    String? range,
    StatsEntity? stats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StatsState(
      range: range ?? this.range,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class StatsNotifier extends Notifier<StatsState> {
  late final StatsRepository _repository;

  @override
  StatsState build() {
    _repository = ref.watch(statsRepositoryProvider);
    return const StatsState();
  }

  Future<void> loadStats({String? range, bool force = false}) async {
    final targetRange = range ?? state.range;

    state = state.copyWith(
      range: targetRange,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final data = await _repository.getStats(range: targetRange);
      state = state.copyWith(
        stats: data,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'İstatistikler yüklenemedi.',
      );
    }
  }

  Future<void> changeRange(String newRange) async {
    if (state.range == newRange && state.stats != null) return;
    await loadStats(range: newRange);
  }
}

final statsNotifierProvider =
    NotifierProvider<StatsNotifier, StatsState>(StatsNotifier.new);
