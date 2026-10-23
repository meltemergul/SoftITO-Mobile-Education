import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/core/theme/app_theme.dart';
import 'package:lumora/features/badges/data/models/badge_model.dart';
import 'package:lumora/features/badges/data/models/user_level_model.dart';
import 'package:lumora/features/badges/domain/entities/badge_entity.dart';
import 'package:lumora/features/badges/domain/entities/user_level_entity.dart';
import 'package:lumora/features/badges/domain/repositories/badges_repository.dart';
import 'package:lumora/features/badges/presentation/providers/badges_notifier.dart';
import 'package:lumora/features/badges/presentation/screens/badges_screen.dart';
import 'package:lumora/features/badges/presentation/widgets/badge_category_filter.dart';
import 'package:lumora/features/badges/presentation/widgets/badge_item_card.dart';
import 'package:lumora/features/badges/presentation/widgets/new_achievement_banner.dart';
import 'package:lumora/features/badges/presentation/widgets/next_threshold_card.dart';
import 'package:lumora/features/badges/presentation/widgets/user_level_card.dart';

class MockBadgesRepository implements BadgesRepository {
  bool shouldFail = false;

  UserLevelEntity mockLevel = const UserLevelEntity(
    level: 7,
    title: 'Alışkanlık Mimarı',
    totalXp: 2450,
    currentLevelXp: 2450,
    nextLevelXp: 3000,
    progressPercent: 70,
  );

  List<BadgeEntity> mockBadges = const [
    BadgeEntity(
      id: 'first_step',
      name: 'İlk Adım',
      description: 'İlk alışkanlığını başarıyla tamamla.',
      category: 'streak',
      icon: 'flag_circle',
      xpReward: 25,
      targetValue: 1,
      unit: 'tamamlama',
      isUnlocked: true,
      unlockedAt: '2026-10-01',
      progress: 1,
      maxProgress: 1,
      progressPercent: 100,
    ),
    BadgeEntity(
      id: 'streak_7',
      name: '7 Gün Zincir',
      description: 'Bir alışkanlıkta kesintisiz 7 günlük zincir oluştur.',
      category: 'streak',
      icon: 'local_fire_department',
      xpReward: 50,
      targetValue: 7,
      unit: 'gün',
      isUnlocked: true,
      unlockedAt: '2026-10-07',
      progress: 7,
      maxProgress: 7,
      progressPercent: 100,
    ),
    BadgeEntity(
      id: 'streak_14',
      name: '14 Gün Demir İrade',
      description: 'Bir alışkanlıkta 14 günlük kesintisiz seri yakala.',
      category: 'streak',
      icon: 'shield',
      xpReward: 100,
      targetValue: 14,
      unit: 'gün',
      isUnlocked: true,
      unlockedAt: '2026-10-14',
      progress: 14,
      maxProgress: 14,
      progressPercent: 100,
    ),
    BadgeEntity(
      id: 'water_spring',
      name: 'Su Pınarı',
      description: 'Su içme hedefini 10 gün boyunca eksiksiz yerine getir.',
      category: 'sport',
      icon: 'water_drop',
      xpReward: 75,
      targetValue: 10,
      unit: 'gün',
      isUnlocked: false,
      unlockedAt: null,
      progress: 7,
      maxProgress: 10,
      progressPercent: 70,
    ),
    BadgeEntity(
      id: 'marathon_spirit',
      name: 'Maraton Ruhu',
      description: 'Spor ve egzersiz alışkanlıklarında 21 kez hedefe ulaş.',
      category: 'sport',
      icon: 'directions_run',
      xpReward: 150,
      targetValue: 21,
      unit: 'gün',
      isUnlocked: false,
      unlockedAt: null,
      progress: 14,
      maxProgress: 21,
      progressPercent: 67,
    ),
    BadgeEntity(
      id: 'zen_mind',
      name: 'Zen Zihin',
      description: 'Zihin veya meditasyon alışkanlıklarını 15 kez tamamla.',
      category: 'mind',
      icon: 'self_improvement',
      xpReward: 100,
      targetValue: 15,
      unit: 'seans',
      isUnlocked: false,
      unlockedAt: null,
      progress: 5,
      maxProgress: 15,
      progressPercent: 33,
    ),
  ];

  @override
  Future<List<BadgeEntity>> getBadges() async {
    if (shouldFail) throw Exception('API Error');
    return mockBadges;
  }

  @override
  Future<UserLevelEntity> getLevel() async {
    if (shouldFail) throw Exception('API Error');
    return mockLevel;
  }
}

void main() {
  group('Badges Models Tests', () {
    test('BadgeModel fromJson and toEntity serialization', () {
      final json = {
        'id': 'streak_7',
        'name': '7 Gün Zincir',
        'description': 'Bir alışkanlıkta kesintisiz 7 günlük zincir oluştur.',
        'category': 'streak',
        'icon': 'local_fire_department',
        'xpReward': 50,
        'targetValue': 7,
        'unit': 'gün',
        'isUnlocked': true,
        'unlockedAt': '2026-10-07',
        'progress': 7,
        'maxProgress': 7,
        'progressPercent': 100,
      };

      final model = BadgeModel.fromJson(json);
      expect(model.id, 'streak_7');
      expect(model.name, '7 Gün Zincir');
      expect(model.xpReward, 50);
      expect(model.isUnlocked, true);
      expect(model.progressPercent, 100);

      final entity = model.toEntity();
      expect(entity.id, 'streak_7');
      expect(entity.unlockedAt, '2026-10-07');
    });

    test('UserLevelModel fromJson and toEntity serialization', () {
      final json = {
        'level': 7,
        'title': 'Alışkanlık Mimarı',
        'totalXp': 2450,
        'currentLevelXp': 2450,
        'nextLevelXp': 3000,
        'progressPercent': 70,
      };

      final model = UserLevelModel.fromJson(json);
      expect(model.level, 7);
      expect(model.title, 'Alışkanlık Mimarı');
      expect(model.totalXp, 2450);

      final entity = model.toEntity();
      expect(entity.level, 7);
      expect(entity.progressPercent, 70);
    });
  });

  group('BadgesNotifier Unit Tests', () {
    test('Initial state is uninitialized with empty badges', () {
      final container = ProviderContainer(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(MockBadgesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(badgesNotifierProvider);
      expect(state.isLoading, false);
      expect(state.badges, isEmpty);
      expect(state.level, isNull);
      expect(state.selectedCategory, 'all');
    });

    test('loadData loads badges and level successfully', () async {
      final mockRepo = MockBadgesRepository();
      final container = ProviderContainer(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(badgesNotifierProvider.notifier).loadData();
      final state = container.read(badgesNotifierProvider);

      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.badges.length, 6);
      expect(state.level?.level, 7);
      expect(state.level?.title, 'Alışkanlık Mimarı');
      expect(state.unlockedBadges.length, 3);
      expect(state.lockedBadges.length, 3);
      expect(state.latestNewAchievement?.id, 'streak_14'); // en son açılan tarih: 2026-10-14
    });

    test('Category filter correctly filters badges', () async {
      final container = ProviderContainer(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(MockBadgesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(badgesNotifierProvider.notifier);
      await notifier.loadData();

      // 'streak' filtresi
      notifier.selectCategory('streak');
      expect(container.read(badgesNotifierProvider).filteredBadges.length, 3);

      // 'sport' filtresi
      notifier.selectCategory('sport');
      expect(container.read(badgesNotifierProvider).filteredBadges.length, 2);

      // 'mind' filtresi
      notifier.selectCategory('mind');
      expect(container.read(badgesNotifierProvider).filteredBadges.length, 1);

      // 'all' filtresi
      notifier.selectCategory('all');
      expect(container.read(badgesNotifierProvider).filteredBadges.length, 6);
    });

    test('dismissNewAchievement hides the achievement from latestNewAchievement', () async {
      final container = ProviderContainer(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(MockBadgesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(badgesNotifierProvider.notifier);
      await notifier.loadData();

      expect(container.read(badgesNotifierProvider).latestNewAchievement?.id, 'streak_14');

      notifier.dismissNewAchievement('streak_14');
      // streak_14 kapatılınca sıradaki en yeni açılan (streak_7: 2026-10-07) gelmeli
      expect(container.read(badgesNotifierProvider).latestNewAchievement?.id, 'streak_7');

      notifier.dismissNewAchievement('streak_7');
      notifier.dismissNewAchievement('first_step');
      expect(container.read(badgesNotifierProvider).latestNewAchievement, isNull);
    });

    test('nextThresholdBadge picks the locked badge with highest progress percentage', () async {
      final container = ProviderContainer(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(MockBadgesRepository()),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(badgesNotifierProvider.notifier);
      await notifier.loadData();

      final next = container.read(badgesNotifierProvider).nextThresholdBadge;
      // water_spring %70, marathon_spirit %67, zen_mind %33 => water_spring kazanır
      expect(next?.id, 'water_spring');
    });

    test('Error handling in loadData sets errorMessage', () async {
      final mockRepo = MockBadgesRepository()..shouldFail = true;
      final container = ProviderContainer(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(badgesNotifierProvider.notifier).loadData();
      final state = container.read(badgesNotifierProvider);

      expect(state.isLoading, false);
      expect(state.errorMessage, isNotNull);
      expect(state.badges, isEmpty);
    });
  });

  group('BadgesScreen UI & Widget Tests', () {
    Widget buildTestScreen(MockBadgesRepository repo) {
      return ProviderScope(
        overrides: [
          badgesRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const BadgesScreen(),
        ),
      );
    }

    testWidgets('Renders all primary sections and widgets on BadgesScreen', (tester) async {
      final mockRepo = MockBadgesRepository();
      await tester.pumpWidget(buildTestScreen(mockRepo));
      await tester.pumpAndSettle();

      // Başlık
      expect(find.text('Rozetler & Seviye'), findsOneWidget);

      // Kullanıcı Seviyesi Kalkanı
      expect(find.byType(UserLevelCard), findsOneWidget);
      expect(find.text('Seviye 7: Alışkanlık Mimarı'), findsOneWidget);
      expect(find.text('Toplam 2.450 XP'), findsOneWidget);

      // Yeni Başarım Kartı
      expect(find.byType(NewAchievementBanner), findsOneWidget);
      expect(find.text('Yeni Başarım Açıldı! 🎉'), findsOneWidget);
      expect(find.text('14 Gün Demir İrade'), findsWidgets);

      // Sonraki Büyük Eşik
      expect(find.byType(NextThresholdCard), findsOneWidget);
      expect(find.text('Sonraki Büyük Eşik'), findsOneWidget);
      expect(find.text('Su Pınarı'), findsWidgets);

      // Kategori Filtresi
      expect(find.byType(BadgeCategoryFilter), findsOneWidget);
      expect(find.text('Tümü'), findsOneWidget);
      expect(find.text('Zincirler'), findsOneWidget);
      expect(find.text('Spor & Sağlık'), findsOneWidget);
      expect(find.text('Zihin'), findsOneWidget);

      // Rozet kartları
      expect(find.byType(BadgeItemCard), findsWidgets);
      expect(find.text('7 Gün Zincir'), findsOneWidget);
    });

    testWidgets('Tapping category filter updates visible badges in the grid', (tester) async {
      final mockRepo = MockBadgesRepository();
      await tester.pumpWidget(buildTestScreen(mockRepo));
      await tester.pumpAndSettle();

      // Başlangıçta tüm rozetler görünür (6 adet)
      expect(find.byType(BadgeItemCard), findsNWidgets(6));

      // 'Zihin' filtresine tıkla
      await tester.tap(find.text('Zihin'));
      await tester.pumpAndSettle();

      // Sadece 1 adet Zihin rozeti (Zen Zihin) görünmeli
      expect(find.byType(BadgeItemCard), findsNWidgets(1));
      expect(find.text('Zen Zihin'), findsOneWidget);
      expect(find.text('7 Gün Zincir'), findsNothing);

      // 'Tümü'ne geri dön
      await tester.tap(find.text('Tümü'));
      await tester.pumpAndSettle();
      expect(find.byType(BadgeItemCard), findsNWidgets(6));
    });

    testWidgets('Dismissing NewAchievementBanner removes the banner from screen', (tester) async {
      final mockRepo = MockBadgesRepository();
      await tester.pumpWidget(buildTestScreen(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(NewAchievementBanner), findsOneWidget);

      // Kapatma butonuna tıkla
      await tester.tap(find.byTooltip('Kapat'));
      await tester.pumpAndSettle();

      // Banner'da sıradaki veya kapatılmış durum kontrolü
      // (Test senaryosunda 3 açık rozet olduğu için sonraki rozet veya kapalı durum)
      expect(find.text('14 Gün Demir İrade'), findsOneWidget); // Sadece ızgarada kalır
    });

    testWidgets('Tapping a badge card opens bottom sheet with details', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = MockBadgesRepository();
      await tester.pumpWidget(buildTestScreen(mockRepo));
      await tester.pumpAndSettle();

      // '7 Gün Zincir' rozet kartına dokun
      await tester.tap(find.text('7 Gün Zincir'));
      await tester.pumpAndSettle();

      // Alt sayfa detayları açılmalı
      expect(find.text('Kazanıldı ✓'), findsOneWidget);
      expect(find.text('+50 XP'), findsWidgets);
      expect(find.text('Kapat'), findsOneWidget);

      // Kapat düğmesine basarak alt sayfayı kapat
      await tester.tap(find.text('Kapat'));
      await tester.pumpAndSettle();

      expect(find.text('Kazanıldı ✓'), findsNothing);
    });
  });
}
