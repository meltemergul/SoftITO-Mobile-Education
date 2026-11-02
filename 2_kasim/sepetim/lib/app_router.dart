import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/ana_kasa.dart';
import 'screens/vitrin.dart';
import 'screens/profil.dart';

final GoRouter uygulamaRotalari = GoRouter(
  initialLocation: '/vitrin',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AnaKasaEkrani(ekranGovdesi: child);
      },
      routes: [
        GoRoute(
          path: '/vitrin',
          builder: (context, state) => const VitrinEkrani(),
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const ProfilEkrani(),
        ),
      ],
    ),
  ],
);
