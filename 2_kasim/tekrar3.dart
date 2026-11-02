// setState() bulunduğu state nesnesinin build() metodunu baştan aşağı tetikler.
//scaffold appbar tabbar ve eğer varsa 20 tane container baştan hesaplanır.

import 'package:flutter/material.dart';
import 'package:go_ router/go_router.dart';

class SepetKontrolu {
  static final SepetKontrolu ornek = SepetKontrolu()._dahili();
  SepetKontrolu._dahili();

  final ValueNotifier<int> _urunSayisi = ValueNotifier<int>(0);

  void sepeteEkle() {
    _urunSayisi.value++;
  }

  void sepetiSifirla() {
    _urunSayisi.value = 0;
  }
}

final GoRouter uygulamaRotalari = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (Buildcontext context, GoRouterState state, Widget child) {
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

class AnaKasaEkrani extends StatefulWidget {
  final Widget ekranGovdesi;
  const AnaKasaEkrani({super.key, required this.ekranGovdesi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Kasa Ekranı')),
      body: ekranGovdesi,
      bottomNavigationBar: BottomNavigationBar(
        selectedIndex: _aktifIndexiBul(context),
        onDestinationSelected: (yeniIndeks) {
          if (yeniIndeks == 0) {
            context.go('/vitrin');
          }
          if (yeniIndeks == 1) {
            context.go('/profil');
          }
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.store), label: 'Vitrin'),
          NavigationDestination(
            icon: ValueListenableBuilder<int>(
              valueListenable: SepetKontrolu.ornek._urunSayisi,
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

  int _aktifIndexiBul(BuildContext context) {
    final String konum = GoRouter.of(context).uri.toString();
    if (konum.startsWith('/profil')) {
      return 1;
    }
    return 0;
  }
}

class VitrinEkrani extends StatelessWidget {
  const VitrinEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Vitrin Ekranı(ValueNotifier)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            SepetKontrolu.ornek.sepeteEkle();
          },
          Icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Sepete Ürün Ekle(+1)'),
        ),
      ),
    );
  }
}

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Profil Ekranı')),
      body: Center(
        child: TextButton(
          onPressed: () {
            SepetKontrolu.ornek.sepetiSifirla();
          },
          child: const Text('Sepeti Temizle'),
        ),
      ),
    );
  }
}
