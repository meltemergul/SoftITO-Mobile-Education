import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/badges_remote_data_source.dart';
import '../../data/repositories/badges_repository_impl.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_level_entity.dart';
import '../../domain/repositories/badges_repository.dart';

final badgesRemoteDataSourceProvider = Provider<BadgesRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BadgesRemoteDataSourceImpl(apiClient);
});

final badgesRepositoryProvider = Provider<BadgesRepository>((ref) {
  final remote = ref.watch(badgesRemoteDataSourceProvider);
  return BadgesRepositoryImpl(remote);
});

@immutable
class BadgesState {
  const BadgesState({
    this.selectedCategory = 'all',
    this.badges = const [],
    this.level,
    this.isLoading = false,
    this.errorMessage,
    this.dismissedAchievementIds = const {},
  });

  final String selectedCategory; // 'all', 'streak', 'sport', 'mind'
  final List<BadgeEntity> badges;
  final UserLevelEntity? level;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> dismissedAchievementIds;

  /// Kategoriye göre filtrelenmiş rozetler
  List<BadgeEntity> get filteredBadges {
    if (selectedCategory == 'all') {
      return badges;
    }
    return badges.where((b) => b.category == selectedCategory).toList();
  }

  /// Açılmış olan rozetler
  List<BadgeEntity> get unlockedBadges =>
      badges.where((b) => b.isUnlocked).toList();

  /// Henüz açılmamış / devam eden rozetler
  List<BadgeEntity> get lockedBadges =>
      badges.where((b) => !b.isUnlocked).toList();

  /// Henüz görülüp kapatılmamış en yeni başarım (tebrik kutusu için)
  BadgeEntity? get latestNewAchievement {
    final unlocked = unlockedBadges
        .where((b) => !dismissedAchievementIds.contains(b.id))
        .toList();
    if (unlocked.isEmpty) return null;

    // unlock date'e göre en yenisi
    unlocked.sort((a, b) => (b.unlockedAt ?? '').compareTo(a.unlockedAt ?? ''));
    return unlocked.first;
  }

  /// "Sonraki Büyük Eşik" için en yakın rozet
  BadgeEntity? get nextThresholdBadge {
    final locked = lockedBadges;
    if (locked.isEmpty) return null;

    // İlerleme yüzdesi en yüksek olana göre sırala
    final sorted = [...locked]..sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    return sorted.first;
  }

  BadgesState copyWith({
    String? selectedCategory,
    List<BadgeEntity>? badges,
    UserLevelEntity? level,
    bool? isLoading,
    String? errorMessage,
    Set<String>? dismissedAchievementIds,
  }) {
    return BadgesState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      badges: badges ?? this.badges,
      level: level ?? this.level,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dismissedAchievementIds:
          dismissedAchievementIds ?? this.dismissedAchievementIds,
    );
  }
}

class BadgesNotifier extends Notifier<BadgesState> {
  late final BadgesRepository _repository;

  @override
  BadgesState build() {
    _repository = ref.watch(badgesRepositoryProvider);
    return const BadgesState();
  }

  Future<void> loadData() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final results = await Future.wait([
        _repository.getBadges(),
        _repository.getLevel(),
      ]);

      final badges = results[0] as List<BadgeEntity>;
      final level = results[1] as UserLevelEntity;

      state = state.copyWith(
        badges: badges,
        level: level,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Rozet ve seviye verileri yüklenemedi.',
      );
    }
  }

  void selectCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
  }

  void dismissNewAchievement(String badgeId) {
    final updatedDismissed = {...state.dismissedAchievementIds, badgeId};
    state = state.copyWith(dismissedAchievementIds: updatedDismissed);
  }
}

final badgesNotifierProvider =
    NotifierProvider<BadgesNotifier, BadgesState>(BadgesNotifier.new);
