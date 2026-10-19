import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/date_extension.dart';
import '../../../core/theme/theme_controller.dart';
import '../controllers/donation_statistics_controller.dart';
import '../models/donation_statistics_model.dart';
import '../widgets/blood_group_distribution.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/stat_tile.dart';
import '../widgets/year_comparison_chart.dart';

class DonationStatisticsPage extends StatefulWidget {
  const DonationStatisticsPage({super.key});

  @override
  State<DonationStatisticsPage> createState() => _DonationStatisticsPageState();
}

class _DonationStatisticsPageState extends State<DonationStatisticsPage> {
  late final DonationStatisticsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DonationStatisticsController()..loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DonationStatisticsView(controller: _controller);
  }
}

class DonationStatisticsView extends StatelessWidget {
  final DonationStatisticsController controller;

  const DonationStatisticsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statisticsTitle),
        actions: const [ThemeToggleButton()],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<String?>(
            valueListenable: controller.errorMessage,
            builder: (context, error, _) {
              if (error != null) return Center(child: Text(error));
              return _StatisticsContent(controller: controller);
            },
          );
        },
      ),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  final DonationStatisticsController controller;

  const _StatisticsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MonthlyDonationModel>>(
      valueListenable: controller.monthly,
      builder: (context, monthly, _) {
        if (monthly.isEmpty) {
          return const Center(
            child: Text('Gösterilecek istatistik bulunamadı.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SummaryRow(controller: controller),
            SectionCard(
              title: 'Aylık Bağış Sayıları',
              child: _SelectableBarChart(controller: controller, data: monthly),
            ),
            SectionCard(
              title: 'Yıllık Karşılaştırma',
              child: YearComparisonChart(data: monthly),
            ),
            SectionCard(
              title: 'Kan Grubu Dağılımı',
              child: BloodGroupDistribution(
                shares: controller.groupShares.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final DonationStatisticsController controller;

  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final total = controller.yearTotal;
    final prev = controller.previousYearTotal;
    final change = prev == 0 ? 0.0 : (total - prev) / prev * 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ValueListenableBuilder<int?>(
        valueListenable: controller.selectedMonthIndex,
        builder: (context, index, _) {
          final selected = index == null
              ? null
              : controller.monthly.value[index];
          return Row(
            children: [
              StatTile(
                label: 'Yıllık Toplam',
                value: '$total',
                changePercent: change,
              ),
              StatTile(
                label: selected == null
                    ? 'Seçili Ay'
                    : '${selected.month.shortMonthTr} Bağışı',
                value: selected == null ? '-' : '${selected.count}',
                changePercent: selected?.changePercent,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectableBarChart extends StatelessWidget {
  final DonationStatisticsController controller;
  final List<MonthlyDonationModel> data;

  const _SelectableBarChart({required this.controller, required this.data});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: controller.selectedMonthIndex,
      builder: (context, index, _) => MonthlyBarChart(
        data: data,
        selectedIndex: index,
        onSelect: controller.selectMonth,
      ),
    );
  }
}
