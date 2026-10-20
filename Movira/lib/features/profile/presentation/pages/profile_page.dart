import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/movira_app_icon.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profil Başlığı ve App Icon
        Center(
          child: Column(
            children: [
              const MoviraAppIcon(
                size: 80,
                borderRadius: 20,
                showBorder: true,
                showShadow: true,
              ),
              const SizedBox(height: 12),
              const Text(
                'Mert Demir',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kimlik: user-12345 (Doğrulanmış Üye)',
                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // İstatistikler Kartı
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, '3', 'Kiralama'),
              _buildStatDivider(context),
              _buildStatItem(context, '1', 'Aktif Teklif'),
              _buildStatDivider(context),
              _buildStatItem(context, '4.9', 'Puanım'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Ayarlar & Tercihler Listesi
        Text(
          'Uygulama Tercihleri',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Tema Değiştirme Butonu / Switch
              ValueListenableBuilder<ThemeMode>(
                valueListenable: globalThemeNotifier,
                builder: (context, currentMode, _) {
                  final isDark = currentMode == ThemeMode.dark;
                  return SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Koyu Tema (Bordo / Obsidian)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(isDark ? 'Koyu tema aktif' : 'Açık tema aktif', style: const TextStyle(fontSize: 12)),
                    value: isDark,
                    onChanged: (val) {
                      globalThemeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                    },
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.security, color: theme.colorScheme.primary),
                title: const Text('Gizlilik ve KVKK', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.help_outline, color: theme.colorScheme.primary),
                title: const Text('Yardım ve Destek', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Misafir moduna geçildi.')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
    );
  }
}
