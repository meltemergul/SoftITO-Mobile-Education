import 'package:flutter/material.dart';

class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final conversations = [
      {
        'host': 'Ahmet Yılmaz',
        'car': 'Renault Clio (2023)',
        'lastMessage': 'Merhaba, aracı Sabiha Gökçen Havalimanı terminal çıkışında teslim edebilirim.',
        'time': '14:20',
        'unread': 1,
      },
      {
        'host': 'Mehmet Kaya',
        'car': 'BMW 320i M Sport',
        'lastMessage': 'Teklifinizi onayladım, iyi yolculuklar dilerim.',
        'time': 'Dün',
        'unread': 0,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final unread = (conv['unread'] as int) > 0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            foregroundColor: theme.colorScheme.primary,
            child: Text((conv['host'] as String)[0]),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(conv['host'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(conv['time'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                conv['car'] as String,
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                conv['lastMessage'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: unread ? theme.colorScheme.onSurface : Colors.grey,
                  fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${conv['host']} ile sohbet açılıyor...')),
            );
          },
        );
      },
    );
  }
}
