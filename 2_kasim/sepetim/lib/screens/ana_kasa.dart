import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/sepet_kontrolu.dart';

class AnaKasaEkrani extends StatelessWidget {
  final Widget ekranGovdesi;
  const AnaKasaEkrani({super.key, required this.ekranGovdesi});

  int _aktifIndexiBul(BuildContext context) {
    final String konum = GoRouterState.of(context).uri.toString();
    if (konum.startsWith('/profil')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Kasa Ekranı')),
      body: ekranGovdesi,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aktifIndexiBul(context),
        onDestinationSelected: (yeniIndeks) {
          if (yeniIndeks == 0) {
            context.go('/vitrin');
          } else if (yeniIndeks == 1) {
            context.go('/profil');
          }
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.store), label: 'Vitrin'),
          NavigationDestination(
            icon: ValueListenableBuilder<int>(
              valueListenable: SepetKontrolu.ornek.urunSayisi,
              builder: (context, sayi, child) {
                return Badge(
                  label: Text('$sayi'),
                  isLabelVisible: sayi > 0,
                  child: const Icon(Icons.person),
                );
              },
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
