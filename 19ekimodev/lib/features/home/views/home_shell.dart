import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../blood_values/views/blood_values_view.dart';
import '../../donation_centers/views/donation_centers_view.dart';
import '../../donation_statistics/views/donation_statistics_view.dart';
import '../../urgent_requests/views/urgent_requests_view.dart';
import '../controllers/home_controller.dart';

/// 4 modülü alt navigasyonla bağlayan kabuk.
/// IndexedStack sayesinde sekmeler arası geçişte modül durumları korunur.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _controller.currentIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [
              BloodValuesPage(),
              DonationCentersPage(),
              UrgentRequestsPage(),
              DonationStatisticsPage(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: _controller.select,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.bloodtype_outlined),
                selectedIcon: Icon(Icons.bloodtype),
                label: AppStrings.navBloodValues,
              ),
              NavigationDestination(
                icon: Icon(Icons.place_outlined),
                selectedIcon: Icon(Icons.place),
                label: AppStrings.navCenters,
              ),
              NavigationDestination(
                icon: Icon(Icons.emergency_outlined),
                selectedIcon: Icon(Icons.emergency),
                label: AppStrings.navUrgent,
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: AppStrings.navStatistics,
              ),
            ],
          ),
        );
      },
    );
  }
}
