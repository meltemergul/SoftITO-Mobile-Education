// Girişim360 — Mentor Eşleşmesi Sayfası (PROJECT.md Bölüm 2.2)
// Sektör ve aşama bazlı uyum puanı ve görüşme planlama

import 'package:flutter/material.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/status_badge.dart';

class MentorMatchingPage extends StatefulWidget {
  const MentorMatchingPage({super.key});

  @override
  State<MentorMatchingPage> createState() => _MentorMatchingPageState();
}

class _MentorMatchingPageState extends State<MentorMatchingPage> {
  String _selectedSector = 'Tümü';

  final List<String> _sectors = ['Tümü', 'AgriTech', 'FinTech', 'Biyoteknoloji', 'Yapay Zekâ'];

  final List<Map<String, dynamic>> _mentors = [
    {
      'id': 'mentor-1',
      'name': 'Dr. Selin Aksoy',
      'title': 'AgriTech & Girişim Danışmanı',
      'experience': '12 yıl deneyim • Eski Kuluçka Direktörü',
      'matchScore': 94,
      'sector': 'AgriTech',
      'availableDate': '24 Ekim 2026, 14:00',
      'isVerified': true,
      'isDemo': true,
    },
    {
      'id': 'mentor-2',
      'name': 'Caner Yılmaz',
      'title': 'Büyüme & Pazara Çıkış Mentoru',
      'experience': '8 yıl deneyim • 3 Başarılı Exit',
      'matchScore': 88,
      'sector': 'FinTech',
      'availableDate': '26 Ekim 2026, 16:30',
      'isVerified': true,
      'isDemo': true,
    },
    {
      'id': 'mentor-3',
      'name': 'Av. Zeynep Erdem',
      'title': 'Fikrî Mülkiyet & Patent Stratejisti',
      'experience': '15 yıl deneyim • Marka & Patent Vekili',
      'matchScore': 82,
      'sector': 'Biyoteknoloji',
      'availableDate': '28 Ekim 2026, 11:00',
      'isVerified': true,
      'isDemo': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filteredMentors = _selectedSector == 'Tümü'
        ? _mentors
        : _mentors.where((m) => m['sector'] == _selectedSector).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Eşleşmesi'),
        actions: [
          StatusBadge.demo(),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bilgilendirme Notu (PROJECT.md kuralı: Kriterler ve ağırlıklar)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Uyum puanı sektör uyumu (%35), girişim aşaması (%30) ve uzmanlık ihtiyacına (%35) göre hesaplanmaktadır.',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sektör Filtresi
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sectors.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final sector = _sectors[index];
                final isSelected = sector == _selectedSector;
                return ChoiceChip(
                  label: Text(sector),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedSector = sector),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Mentor Kartları Listesi
          ...filteredMentors.map((mentor) {
            final matchScore = mentor['matchScore'] as int;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppAvatar(
                          name: mentor['name'] as String,
                          size: 48,
                          isVerified: mentor['isVerified'] as bool,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mentor['name'] as String,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mentor['title'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mentor['experience'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '%$matchScore Uyum',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.event_available, size: 16, color: colorScheme.outline),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  mentor['availableDate'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${mentor['name']} için görüşme talebi iletildi.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Talep Gönder'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
