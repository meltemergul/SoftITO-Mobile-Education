import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

/// mobile_tab kabuğu: 5 ana sekme (Bugün, Takvim, İstatistik, Rozetler, Profil) için
/// üst çubuk ve alt navigasyon çubuğunu sağlar.
class MobileTabShell extends StatelessWidget {
  const MobileTabShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          onDestinationSelected: _onItemTapped,
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
