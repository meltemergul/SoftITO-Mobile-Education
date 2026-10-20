import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../core/widgets/movira_app_icon.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/create_listing/presentation/pages/create_listing_page.dart';
import '../../features/offers/presentation/pages/offers_page.dart';
import '../../features/messaging/presentation/pages/messaging_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Movira Ana Gezinme İskeleti (Main Navigation Shell)
/// Ortak AppBar (Logo, Tema Değiştirici, Oturum Bildirimi) ve Material 3 NavigationBar içerir.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ExplorePage(),
    CreateListingPage(),
    OffersPage(),
    MessagingPage(),
    ProfilePage(),
  ];

  final List<String> _titles = const [
    'Movira Araç Keşfi',
    'İlan Oluştur',
    'Tekliflerim ve Kiralamalar',
    'Mesajlar',
    'Profilim',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        leadingWidth: 54,
        leading: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: Center(
            child: MoviraAppIcon(
              size: 36,
              borderRadius: 9,
              showBorder: true,
              showShadow: true,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'MOVIRA',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'KİRALAMA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              _titles[_currentIndex],
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Tema Modu Değiştirme Butonu (ValueNotifier<ThemeMode>)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: globalThemeNotifier,
            builder: (context, currentMode, _) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: isDark ? Colors.amber : null,
                ),
                onPressed: () {
                  globalThemeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          // Oturum Göstergesi Çipi (user-12345)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ActionChip(
              avatar: const Icon(Icons.person, size: 14),
              label: const Text('user-12345', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              backgroundColor: theme.colorScheme.surface,
              onPressed: () {
                setState(() => _currentIndex = 4); // Profile git
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Keşfet',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'İlan Ver',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Teklifler',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Mesajlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
