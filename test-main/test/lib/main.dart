import 'package:flutter/material.dart';
import 'screens/01_layout_screen.dart';
import 'screens/02_markets_list_screen.dart';
import 'screens/03_transfer_form_screen.dart';

void main() {
  runApp(const DtmMasteryApp());
}

class DtmMasteryApp extends StatelessWidget {
  const DtmMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DTM Flutter Mastery Studio',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      home: const MainMasteryNavigationHub(),
    );
  }
}

class MainMasteryNavigationHub extends StatefulWidget {
  const MainMasteryNavigationHub({super.key});

  @override
  State<MainMasteryNavigationHub> createState() =>
      _MainMasteryNavigationHubState();
}

class _MainMasteryNavigationHubState extends State<MainMasteryNavigationHub> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LayoutScreen(),
    MarketsListScreen(),
    TransferFormScreen(),
  ];

  final List<String> _titles = const [
    'DTM 1. Bölüm: Layout & Styling',
    'DTM 2. Bölüm: Piyasalar & Listeler',
    'DTM 3. Bölüm: Transfer & Formlar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Bilgi',
            icon: const Icon(Icons.info_outline, color: Color(0xFF6366F1)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('DTM Flutter Mastery'),
                  content: const Text(
                    '14 ve 15 Ekim birleştirilmiş canlı ders projesidir.\n\n'
                    '• Sekme 1: Container, Row, Column, Expanded, Stack\n'
                    '• Sekme 2: GridView.builder, ListView.separated\n'
                    '• Sekme 3: Form Validasyonu, ModalBottomSheet, SnackBar',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 2,
        indicatorColor: const Color(0x266366F1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF6366F1)),
            label: 'Layout',
          ),
          NavigationDestination(
            icon: Icon(Icons.candlestick_chart_outlined),
            selectedIcon: Icon(
              Icons.candlestick_chart,
              color: Color(0xFF6366F1),
            ),
            label: 'Piyasalar',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF6366F1),
            ),
            label: 'Cüzdan/Form',
          ),
        ],
      ),
    );
  }
}
