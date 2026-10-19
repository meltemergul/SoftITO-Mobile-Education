import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/donation_centers_controller.dart';
import '../models/donation_center_model.dart';
import '../widgets/center_filter_bar.dart';
import '../widgets/donation_center_card.dart';

class DonationCentersPage extends StatefulWidget {
  const DonationCentersPage({super.key});

  @override
  State<DonationCentersPage> createState() => _DonationCentersPageState();
}

class _DonationCentersPageState extends State<DonationCentersPage> {
  late final DonationCentersController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DonationCentersController()..loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DonationCentersView(controller: _controller);
  }
}

class DonationCentersView extends StatelessWidget {
  final DonationCentersController controller;

  const DonationCentersView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.centersTitle),
        actions: const [ThemeToggleButton()],
      ),
      body: Column(
        children: [
          _FilterSection(controller: controller),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: controller.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ValueListenableBuilder<String?>(
                  valueListenable: controller.errorMessage,
                  builder: (context, error, _) {
                    if (error != null) return Center(child: Text(error));
                    return _CentersList(controller: controller);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final DonationCentersController controller;

  const _FilterSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CenterType?>(
      valueListenable: controller.selectedType,
      builder: (context, type, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: controller.onlyOpen,
          builder: (context, onlyOpen, _) {
            return CenterFilterBar(
              selectedType: type,
              onlyOpen: onlyOpen,
              onTypeSelected: controller.selectType,
              onToggleOpen: controller.toggleOnlyOpen,
            );
          },
        );
      },
    );
  }
}

class _CentersList extends StatelessWidget {
  final DonationCentersController controller;

  const _CentersList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<DonationCenterModel>>(
      valueListenable: controller.visibleCenters,
      builder: (context, centers, _) {
        if (centers.isEmpty) {
          return const Center(
            child: Text('Filtreye uygun bağış noktası bulunamadı.'),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadInitialData,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: centers.length,
            itemBuilder: (context, index) => DonationCenterCard(
              key: ValueKey(centers[index].id),
              center: centers[index],
            ),
          ),
        );
      },
    );
  }
}
