// Girişim360 — Destek Programları ve Teşvikler Sayfası (PROJECT.md Bölüm 2.6)
// TÜBİTAK, KOSGEB, Kuluçka ve Hibe Programları Takibi

import 'package:flutter/material.dart';
import '../../../../core/widgets/status_badge.dart';

class ProgramsPage extends StatelessWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destek ve Teşvikler'),
        actions: [
          StatusBadge.demo(),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Program 1: TÜBİTAK 1507
          _ProgramCard(
            title: 'TÜBİTAK 1507 — KOBİ Ar-Ge Başlangıç Destek Programı',
            provider: 'TÜBİTAK TEYDEB',
            supportType: '%75 Hibe (1.200.000 TL Üst Limit)',
            deadline: '30 Ekim 2026',
            daysLeft: 10,
            isExpired: false,
            eligibilityText: 'KOBİ ölçeğindeki sermaye şirketleri ve teknoloji girişimleri.',
          ),
          const SizedBox(height: 12),

          // Program 2: KOSGEB İleri Girişimci
          _ProgramCard(
            title: 'KOSGEB — İleri Girişimci Destek Programı',
            provider: 'KOSGEB',
            supportType: 'Makine, Teçhizat ve Yazılım Desteği (450.000 TL)',
            deadline: 'Sürekli Açık (Dönemsel Kurul)',
            daysLeft: 45,
            isExpired: false,
            eligibilityText: 'İleri teknoloji veya orta-yüksek teknoloji alanında yeni kurulan şirketler.',
          ),
          const SizedBox(height: 12),

          // Program 3: Süresi Geçmiş Örnek Program (PROJECT.md İlkesi)
          _ProgramCard(
            title: 'BİGG 2026 1. Çağrı — Teknogirişim Sermaye Desteği',
            provider: 'TÜBİTAK BİGG',
            supportType: '900.000 TL Yatırım / Sermaye Desteği',
            deadline: '15 Eylül 2026 (Süresi Doldu)',
            daysLeft: 0,
            isExpired: true,
            eligibilityText: 'Üniversite mezunu veya son sınıf öğrencisi araştırmacılar.',
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final String title;
  final String provider;
  final String supportType;
  final String deadline;
  final int daysLeft;
  final bool isExpired;
  final String eligibilityText;

  const _ProgramCard({
    required this.title,
    required this.provider,
    required this.supportType,
    required this.deadline,
    required this.daysLeft,
    required this.isExpired,
    required this.eligibilityText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: isExpired ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3) : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpired
              ? colorScheme.outlineVariant.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isExpired ? colorScheme.outline : colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isExpired ? colorScheme.surfaceContainerHighest : Colors.amber.shade900.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isExpired ? 'Süresi Geçti' : '$daysLeft Gün Kaldı',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isExpired ? colorScheme.outline : Colors.amber.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isExpired ? colorScheme.outline : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.monetization_on_outlined, size: 16, color: colorScheme.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    supportType,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Uygunluk: $eligibilityText',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Son Başvuru: $deadline',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: colorScheme.outline),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: isExpired
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$title başvuru takibine eklendi.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                  child: Text(isExpired ? 'Başvuru Kapandı' : 'Başvuru Detayı'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
