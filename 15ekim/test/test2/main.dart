import 'package:flutter/material.dart';

void main() {
  runApp(const DtmMasterApp());
}

class DtmMasterApp extends StatelessWidget {
  const DtmMasterApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "DTM Flutter Sınıfı",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
      ),
      home: const LiveCanvasScreen(),
    );
  }
}

class LiveCanvasScreen extends StatelessWidget {
  const LiveCanvasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FaFC),
      appBar: AppBar(
        title: const Text(
          "DTM Canlı Arayüz",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(child: Text("Buaya Canlı Arayüz Gelecek")),
    );
  }
}
