import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/services/supabase_service.dart';
import '../../features/allocation/presentation/allocation_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  final isConfigured = SupabaseService.isConfigured;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isConfigured && !isAuth ? '/login' : '/dashboard',
    redirect: (context, state) {
      if (!isConfigured) return null;

      final isLoggingIn = state.uri.path == '/login';

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }
      if (isAuth && isLoggingIn) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/allocation',
            builder: (context, state) => const AllocationScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/allocation')) return 1;
    if (location.startsWith('/history')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/allocation');
        break;
      case 2:
        context.push('/add-transaction');
        break;
      case 3:
        context.go('/history');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas.withValues(alpha: 0.95),
                    border: Border(top: BorderSide(color: AppColors.borderCard)),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SizedBox(
              height: 66,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Dashboard',
                    selected: selectedIndex == 0,
                    onTap: () => _onItemTapped(0, context),
                  ),
                  _NavItem(
                    icon: Icons.toll_outlined,
                    activeIcon: Icons.toll_rounded,
                    label: 'Varlıklar',
                    selected: selectedIndex == 1,
                    onTap: () => _onItemTapped(1, context),
                  ),
                  Expanded(
                    child: Center(
                      child: _NavFab(onTap: () => _onItemTapped(2, context)),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.history_rounded,
                    activeIcon: Icons.history_rounded,
                    label: 'Geçmiş',
                    selected: selectedIndex == 3,
                    onTap: () => _onItemTapped(3, context),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Ayarlar',
                    selected: selectedIndex == 4,
                    onTap: () => _onItemTapped(4, context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryBright : AppColors.textSecondary;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(selected ? activeIcon : icon,
                  key: ValueKey(selected), color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                letterSpacing: 0,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavFab extends StatefulWidget {
  final VoidCallback onTap;

  const _NavFab({required this.onTap});

  @override
  State<_NavFab> createState() => _NavFabState();
}

class _NavFabState extends State<_NavFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -8),
      child: Semantics(
        button: true,
        label: 'İşlem Ekle',
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBright,
                borderRadius: AppSpacing.roundedCard,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.add_rounded, color: AppColors.surfaceDim, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
