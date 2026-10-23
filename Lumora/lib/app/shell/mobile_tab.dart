import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../features/home/presentation/providers/today_notifier.dart';
import '../../features/calendar/presentation/providers/calendar_notifier.dart';
import '../../features/statistics/presentation/providers/stats_notifier.dart';
import '../../features/badges/presentation/providers/badges_notifier.dart';

/// mobile_tab kabuğu: 5 ana sekme (Bugün, Takvim, İstatistik, Rozetler, Profil) için
/// üst çubuk ve alt navigasyon çubuğunu sağlar.
class MobileTabShell extends ConsumerWidget {
  const MobileTabShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );

    // Sekmeler arası geçişte veriyi her zaman güncel tut
    switch (index) {
      case 0:
        ref.read(todayNotifierProvider.notifier).loadToday();
        break;
      case 1:
        ref.read(calendarNotifierProvider.notifier).loadCalendar();
        break;
      case 2:
        ref.read(statsNotifierProvider.notifier).loadStats();
        break;
      case 3:
        ref.read(badgesNotifierProvider.notifier).loadData();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(
              color: colors.border,
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onItemTapped(context, ref, index),
          backgroundColor: colors.surface,
          indicatorColor: colors.primary.withValues(alpha: 0.15),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.today_outlined, color: colors.textSecondary),
              selectedIcon: Icon(Icons.today_rounded, color: colors.primaryStrong),
              label: 'Bugün',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: colors.textSecondary),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: colors.primaryStrong),
              label: 'Takvim',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: colors.textSecondary),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: colors.primaryStrong),
              label: 'İstatistik',
            ),
            NavigationDestination(
              icon: Icon(Icons.military_tech_outlined, color: colors.textSecondary),
              selectedIcon: Icon(Icons.military_tech_rounded, color: colors.primaryStrong),
              label: 'Rozetler',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: colors.textSecondary),
              selectedIcon: Icon(Icons.person_rounded, color: colors.primaryStrong),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
