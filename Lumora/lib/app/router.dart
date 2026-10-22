import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/badges/presentation/screens/badges_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/habits/presentation/screens/habit_form_screen.dart';
import '../features/habits/domain/entities/habit_entity.dart';
import 'shell/mobile_blank.dart';
import 'shell/mobile_tab.dart';

/// Oturum durumu için modern Riverpod Notifier
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setAuthenticated(bool value) {
    state = value;
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

/// Riverpod değişikliklerini dinleyen Listenable adaptörü
class RiverpodRouterNotifier extends ChangeNotifier {
  RiverpodRouterNotifier(this.ref) {
    ref.listen<bool>(authStateProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
}

final routerNotifierProvider = Provider<RiverpodRouterNotifier>((ref) {
  return RiverpodRouterNotifier(ref);
});

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/today',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuthenticated = ref.read(authStateProvider);
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/forgot-password';

      // Oturum açılmamışsa ve auth rotasında değilse login'e yönlendir
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // Oturum açılmış ve auth rotasındaysa ana sayfaya yönlendir
      if (isAuthenticated && isAuthRoute) {
        return '/today';
      }

      return null;
    },
    routes: [
      // mobile_blank kabuğu: Giriş Ekranı
      GoRoute(
        path: '/login',
        builder: (context, state) => const MobileBlankShell(
          child: LoginScreen(),
        ),
      ),

      // mobile_blank kabuğu: Şifremi Unuttum Ekranı
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const MobileBlankShell(
          child: ForgotPasswordScreen(),
        ),
      ),

      // Alışkanlık Ekle Ekranı
      GoRoute(
        path: '/habits/new',
        builder: (context, state) => const HabitFormScreen(),
      ),

      // Alışkanlık Düzenle Ekranı
      GoRoute(
        path: '/habits/edit',
        builder: (context, state) {
          final habit = state.extra as HabitEntity?;
          return HabitFormScreen(initialHabit: habit);
        },
      ),

      // mobile_tab kabuğu: 5 Sekmeli Ana Navigasyon
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MobileTabShell(navigationShell: navigationShell);
        },
        branches: [
          // 1. Bugün
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // 2. Takvim
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),

          // 3. İstatistik
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),

          // 4. Rozetler
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/badges',
                builder: (context, state) => const BadgesScreen(),
              ),
            ],
          ),

          // 5. Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
