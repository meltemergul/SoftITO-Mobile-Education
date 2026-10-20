import 'package:flutter/material.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final offers = [
      {
        'id': 'off_101',
        'car': 'Renault Clio 1.0 TCe Touch (2023)',
        'dates': '22 Eki - 25 Eki (3 Gün)',
        'total': '₺4.050',
        'status': 'Beklemede',
        'statusColor': const Color(0xFFF59E0B),
        'role': 'Kiracı Olarak Gönderildi',
        'host': 'Ahmet Yılmaz',
      },
      {
        'id': 'off_102',
        'car': 'BMW 320i M Sport (2024)',
        'dates': '15 Eki - 18 Eki (3 Gün)',
        'total': '₺11.550',
        'status': 'Kabul Edildi',
        'statusColor': const Color(0xFF10B981),
        'role': 'Kiracı Olarak Gönderildi',
        'host': 'Mehmet Kaya',
      },
      {
        'id': 'off_103',
        'car': 'Peugeot 3008 GT (2023)',
        'dates': '10 Eki - 12 Eki (2 Gün)',
        'total': '₺4.500',
        'status': 'Tamamlandı',
        'statusColor': const Color(0xFF3B82F6),
        'role': 'Kiracı Olarak Gönderildi',
        'host': 'Ayşe Demir',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tekliflerim ve Kiralamalarım',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('user-12345', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...offers.map((offer) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.35)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (offer['statusColor'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offer['status'] as String,
                          style: TextStyle(
                            color: offer['statusColor'] as Color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        offer['total'] as String,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer['car'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.date_range, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(offer['dates'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('İlan Sahibi: ${offer['host']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
