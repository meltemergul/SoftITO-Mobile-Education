// Girişim360 — Ana Navigasyon İskeleti (PROJECT.md Bölüm 4)
// Material 3 NavigationBar, Tema Değiştirici ve Modüler Sayfa Geçişi

import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/legal_tracking/presentation/pages/legal_tracking_page.dart';
import '../../features/mentor_matching/presentation/pages/mentor_matching_page.dart';
import '../../features/programs/presentation/pages/programs_page.dart';
import '../../features/startup/presentation/controllers/startup_controller.dart';
import '../../features/startup/presentation/pages/startup_detail_page.dart';

class MainNavScaffold extends StatefulWidget {
  final ThemeController themeController;
  final StartupController startupController;

  const MainNavScaffold({
    super.key,
    required this.themeController,
    required this.startupController,
  });

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  int _currentIndex = 0;

  void _onNavigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.themeController.isDarkMode;

    final pages = [
      DashboardPage(
        startupController: widget.startupController,
        onNavigateToStartup: () => _onNavigateTo(1),
        onNavigateToMentors: () => _onNavigateTo(2),
        onNavigateToLegal: () => _onNavigateTo(3),
        onNavigateToPrograms: () => _onNavigateTo(4),
      ),
      StartupDetailPage(controller: widget.startupController),
      const MentorMatchingPage(),
      const LegalTrackingPage(),
      const ProgramsPage(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.rocket_launch_outlined,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('Girişim360'),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: isDark ? 'Aydınlık Temaya Geç' : 'Karanlık Temaya Geç',
                  icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                  onPressed: () => widget.themeController.toggleTheme(),
                ),
                IconButton(
                  tooltip: 'Bildirimler',
                  icon: const Badge(
                    label: Text('3'),
                    child: Icon(Icons.notifications_none_outlined),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('3 adet yeni bildiriminiz bulunmaktadır.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavigateTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined),
            selectedIcon: Icon(Icons.business_center),
            label: 'Girişim',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake),
            label: 'Mentorluk',
          ),
          NavigationDestination(
            icon: Icon(Icons.gavel_outlined),
            selectedIcon: Icon(Icons.gavel),
            label: 'Hukuk',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard),
            label: 'Destekler',
          ),
        ],
      ),
    );
  }
}
