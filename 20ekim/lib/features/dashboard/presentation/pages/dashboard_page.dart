// Girişim360 — Dashboard Ana Sayfa (PROJECT.md Bölüm 2.7)
// Girişim aşaması, ilerleme, bekleyen görevler ve dinamik controller entegrasyonu

import 'package:flutter/material.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../startup/presentation/controllers/startup_controller.dart';

class DashboardPage extends StatelessWidget {
  final StartupController startupController;
  final VoidCallback onNavigateToStartup;
  final VoidCallback onNavigateToMentors;
  final VoidCallback onNavigateToLegal;
  final VoidCallback onNavigateToPrograms;

  const DashboardPage({
    super.key,
    required this.startupController,
    required this.onNavigateToStartup,
    required this.onNavigateToMentors,
    required this.onNavigateToLegal,
    required this.onNavigateToPrograms,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: startupController,
      builder: (context, _) {
        final state = startupController.state;

        if (state is StartupLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StartupLoaded) {
          final startup = state.activeStartup;
          final progress = startup.calculatedProgress;
          final currentStage = startup.currentStage;
          final pendingTasks = startup.tasks.where((t) => !t.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hoş Geldiniz & Girişim Özet Kartı
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppAvatar(
                            name: startup.name,
                            size: 46,
                            isVerified: true,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Girişim Paneli 👋',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  startup.name,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    fontSize: 22,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge.demo(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Aşama ve İlerleme Göstergesi
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag_outlined, size: 18, color: colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Aşama ${currentStage.order}/7: ${currentStage.label}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '%${progress.toStringAsFixed(0)} Tamamlandı',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                minHeight: 8,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${startup.tasks.length} Görev • ${startup.tasks.where((t) => t.isCompleted).length} Bitti',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.tonalIcon(
                            onPressed: onNavigateToStartup,
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Aşama Yönetimi'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hızlı Modül Durum Başlığı
              Text(
                '360° Girişim Durumu',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DashboardActionCard(
                      icon: Icons.handshake_outlined,
                      iconColor: Colors.teal,
                      title: 'Mentorluk',
                      badgeText: '%92 Uyum',
                      description: 'Dr. Selin Aksoy ile randevu: 24 Ekim',
                      onTap: onNavigateToMentors,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardActionCard(
                      icon: Icons.gavel_outlined,
                      iconColor: Colors.purple,
                      title: 'Hukuk',
                      badgeText: '3/5 Adım',
                      description: 'KVKK ve ortaklık sözleşmesi incelemede',
                      onTap: onNavigateToLegal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DashboardActionCard(
                      icon: Icons.analytics_outlined,
                      iconColor: Colors.blueAccent,
                      title: 'İş Planı',
                      badgeText: 'YZ Analizi',
                      description: 'Nakit akışı tablosu için öneriler hazır',
                      onTap: onNavigateToStartup,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DashboardActionCard(
                      icon: Icons.card_giftcard_outlined,
                      iconColor: Colors.amber.shade700,
                      title: 'Destekler',
                      badgeText: '2 Aktif',
                      description: 'TÜBİTAK 1507 son başvuru: 10 gün kaldı',
                      onTap: onNavigateToPrograms,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bekleyen Görevler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bekleyen Görevler (${pendingTasks.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: onNavigateToStartup,
                    child: const Text('Tümünü Gör'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (pendingTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      const Text('Tebrikler! Bekleyen göreviniz kalmadı.'),
                    ],
                  ),
                )
              else
                ...pendingTasks.map((task) => _DashboardTaskItem(
                      title: task.title,
                      dueDate: '${task.dueDate.day}.${task.dueDate.month}.${task.dueDate.year}',
                      isMilestone: task.isMilestone,
                      category: task.isMilestone ? 'Kilometre Taşı' : 'Operasyonel Görev',
                      onToggle: () => startupController.toggleTask(task.id),
                    )),
            ],
          );
        }

        return Center(
          child: FilledButton(
            onPressed: () => startupController.loadStartups(),
            child: const Text('Verileri Yenile'),
          ),
        );
      },
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badgeText;
  final String description;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTaskItem extends StatelessWidget {
  final String title;
  final String dueDate;
  final bool isMilestone;
  final String category;
  final VoidCallback onToggle;

  const _DashboardTaskItem({
    required this.title,
    required this.dueDate,
    required this.isMilestone,
    required this.category,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: false,
                onChanged: (_) => onToggle(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$category • Son Tarih: $dueDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isMilestone) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Milestone',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
