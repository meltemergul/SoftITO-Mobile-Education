import 'package:flutter/material.dart';

import '../../controllers/sepet_kontrolu.dart';

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Profil Ekranı')),
      body: Center(
        child: TextButton.icon(
          onPressed: () {
            SepetKontrolu.ornek.sepetiSifirla();
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Sepeti Temizle'),
        ),
      ),
    );
  }
}
