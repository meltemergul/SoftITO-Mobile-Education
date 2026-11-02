import 'package:flutter/material.dart';

import 'screens/urun_listesi_ekrani.dart';

void main() {
  runApp(const MiniMagazaApiUygulamasi());
}

class MiniMagazaApiUygulamasi extends StatelessWidget {
  const MiniMagazaApiUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Mağaza Canlı API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const UrunListesiEkrani(),
    );
  }
}
