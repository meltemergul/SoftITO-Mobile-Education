import 'package:flutter/material.dart';

import 'app_router.dart';

void main() {
  runApp(const AnaUygulama());
}

class AnaUygulama extends StatelessWidget {
  const AnaUygulama({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sepet Uygulaması',
      debugShowCheckedModeBanner: false,
      routerConfig: uygulamaRotalari,
    );
  }
}
