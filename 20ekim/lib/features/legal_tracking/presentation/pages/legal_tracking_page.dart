// Girişim360 — Hukuki Süreçler & İş Planı Sayfası (PROJECT.md Bölüm 2.3 & 2.4)
// KVKK, Şirketleşme, Avukat İletişimi ve YZ İş Planı Analizi

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/status_badge.dart';

class LegalTrackingPage extends StatefulWidget {
  const LegalTrackingPage({super.key});

  @override
  State<LegalTrackingPage> createState() => _LegalTrackingPageState();
}

class _LegalTrackingPageState extends State<LegalTrackingPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hukuki Süreçler & İş Planı'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hukuk ve Avukat'),
            Tab(text: 'İş Planı Analizi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. SEKME: HUKUK VE AVUKAT TAKİBİ
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hukuki Uyarı Notu (PROJECT.md Zorunlu İlke)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.legalDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Atanmış Avukat Kartı
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const AppAvatar(
                        name: 'Av. Mehmet Demir',
                        fallbackIcon: Icons.gavel,
                        isVerified: true,
                        size: 50,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Av. Mehmet Demir',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Girişim Hukuku & KVKK Uzmanı (İstanbul Barosu)',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Son İnceleme: 18 Ekim 2026',
                              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Avukat mesajlaşma kanalı açılıyor...')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Hukuki Adımlar ve Belgeler',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _LegalStepCard(
                title: 'Şirket Ana Sözleşmesi',
                status: 'Onaylandı',
                badgeType: 'success',
                dueDate: '12 Ekim 2026',
                description: 'Anonim şirket esas sözleşmesi MERSİS onayı tamamlandı.',
              ),
              _LegalStepCard(
                title: 'KVKK ve Veri İşleme Politikası',
                status: 'Avukat İncelemesinde',
                badgeType: 'warning',
                dueDate: '24 Ekim 2026',
                description: 'Sensör verilerinin toplanması ve bulut aktarım onay metni.',
              ),
              _LegalStepCard(
                title: 'Kurucu Ortaklar Sözleşmesi (Founders Agreement)',
                status: 'Onaylandı',
                badgeType: 'success',
                dueDate: '15 Eylül 2026',
                description: 'Hisse devir kısıtları, vesting ve ayrılma şartları imzalandı.',
              ),
              _LegalStepCard(
                title: 'Marka Tescil Başvurusu (TÜRKPATENT)',
                status: 'Beklemede',
                badgeType: 'neutral',
                dueDate: '10 Kasım 2026',
                description: 'BioLoop marka sınıflandırması ve bülten yayını takibi.',
              ),
            ],
          ),

          // 2. SEKME: İŞ PLANI VE YZ ANALİZİ
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.aiDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Analiz Skor Kartı
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'İş Planı Hazırlık Durumu',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          StatusBadge.demo(label: 'YZ Analizi'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '%78 Tamamlandı',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '9 bölümden 7\'si analiz için uygun.',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Yapay Zekâ iş planı analiz raporu güncelleniyor...')),
                              );
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Yeniden Analiz Et'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Analiz Bulguları ve Öneriler',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _AnalysisCard(
                title: 'Güçlü Alan: Problem ve Çözüm Uyumu',
                severity: 'success',
                description: 'Tarım sulama maliyetleri ve su israfı problemi net saha verileriyle kanıtlanmış.',
              ),
              _AnalysisCard(
                title: 'Eksik Bölüm: 3 Yıllık Nakit Akışı Tablosu',
                severity: 'warning',
                description: 'Abonelik gelir modeli için varsayılan churn (kayıp) oranı tanımlanmamış.',
              ),
              _AnalysisCard(
                title: 'Risk Uyarısı: Rakip Fiyatlandırma Varsayımı',
                severity: 'error',
                description: 'Yerel sensör üreticilerine karşı birim maliyet avantajı varsayımı test edilmelidir.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalStepCard extends StatelessWidget {
  final String title;
  final String status;
  final String badgeType;
  final String dueDate;
  final String description;

  const _LegalStepCard({
    required this.title,
    required this.status,
    required this.badgeType,
    required this.dueDate,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color badgeBg;
    Color badgeFg;
    if (badgeType == 'success') {
      badgeBg = const Color(0xFF064E3B);
      badgeFg = const Color(0xFF6EE7B7);
    } else if (badgeType == 'warning') {
      badgeBg = const Color(0xFF78350F);
      badgeFg = const Color(0xFFFDE68A);
    } else {
      badgeBg = colorScheme.surfaceContainerHighest;
      badgeFg = colorScheme.onSurfaceVariant;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeFg),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Son Tarih: $dueDate',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String severity;
  final String description;

  const _AnalysisCard({
    required this.title,
    required this.severity,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    Color iconColor;

    if (severity == 'success') {
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
    } else if (severity == 'warning') {
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.amber.shade700;
    } else {
      icon = Icons.error_outline;
      iconColor = colorScheme.error;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
