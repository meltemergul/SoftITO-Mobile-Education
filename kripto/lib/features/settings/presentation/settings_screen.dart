import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/models/asset.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/domain/transaction.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _refreshSeconds = 60;

  void _showCurrencyPicker(String currentCurrency) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Varsayılan Para Birimi', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              title: Text('Amerikan Doları (USD)'),
              trailing: currentCurrency == 'USD'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(currencyProvider.notifier).setCurrency('USD');
                Navigator.pop(ctx);
              },
            ),
            Divider(height: 1, color: AppColors.borderDivider),
            ListTile(
              title: Text('Türk Lirası (TRY)'),
              trailing: currentCurrency == 'TRY'
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(currencyProvider.notifier).setCurrency('TRY');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRefreshPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Fiyat Yenileme Sıklığı', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.md),
            _buildRefreshOption(30, '30 saniye (Hızlı)'),
            Divider(height: 1, color: AppColors.borderDivider),
            _buildRefreshOption(60, '60 saniye (Önerilen)'),
            Divider(height: 1, color: AppColors.borderDivider),
            _buildRefreshOption(300, '5 dakika (Kota Tasarrufu)'),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshOption(int seconds, String label) {
    return ListTile(
      title: Text(label),
      trailing: _refreshSeconds == seconds ? Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() => _refreshSeconds = seconds);
        ref.read(settingsRepositoryProvider).setRefreshSeconds(seconds);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _handleCsvImport() async {
    final csvService = ref.read(csvServiceProvider);
    final parser = ref.read(csvParserProvider);
    final assets = ref.read(assetsProvider).value ?? Asset.defaultAssets;
    final user = ref.read(currentUserProvider);

    final csvContent = await csvService.pickAndReadCsv();
    if (csvContent == null || !mounted) return;

    final result = parser.parse(csvContent);

    if (result.hasErrors) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface1,
          title: Text('CSV Hataları', style: AppTextStyles.headlineSm.copyWith(color: AppColors.lossText)),
          content: SizedBox(
            width: double.maxFinite,
            height: 220,
            child: ListView.separated(
              itemCount: result.errors.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.borderDivider),
              itemBuilder: (context, i) {
                final err = result.errors[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Satır ${err.rowIndex}: ${err.message}',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.lossText),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Kapat', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
      return;
    }

    // Doğrulama başarılı -> Önizleme ve onay diyaloğu
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text('CSV İçe Aktarma Önizleme', style: AppTextStyles.headlineSm),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${result.validRows.length} adet geçerli işlem bulundu.', style: AppTextStyles.bodyMd),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bu işlemler portföyünüze eklenecektir. Onaylıyor musunuz?',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final List<AppTransaction> newTxs = [];

              for (int i = 0; i < result.validRows.length; i++) {
                final row = result.validRows[i];
                final symbol = row['symbol'].toString();
                final asset = assets.firstWhere(
                  (a) => a.symbol == symbol,
                  orElse: () => Asset(
                    id: symbol.toLowerCase(),
                    symbol: symbol,
                    name: symbol,
                    coingeckoId: symbol.toLowerCase(),
                  ),
                );

                newTxs.add(
                  AppTransaction(
                    id: '${DateTime.now().millisecondsSinceEpoch}-$i',
                    userId: user?.id ?? 'local-user',
                    assetId: asset.id,
                    type: row['type'] == 'BUY' ? TransactionType.buy : TransactionType.sell,
                    quantity: row['quantity'],
                    price: row['price'],
                    priceCurrency: row['price_currency'],
                    fee: row['fee'],
                    executedAt: row['executed_at'],
                    source: TransactionSource.csv,
                    createdAt: DateTime.now().toUtc(),
                  ),
                );
              }

              await ref.read(transactionsProvider.notifier).bulkInsertTransactions(newTxs);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${newTxs.length} işlem başarıyla yüklendi.'),
                    backgroundColor: AppColors.profit,
                  ),
                );
              }
            },
            child: Text('YÜKLE'),
          ),
        ],
      ),
    );
  }

  void _showThemeInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text('Arayüz Teması', style: AppTextStyles.headlineSm),
        content: Text(
          'Chronomind, finansal verilerin okunabilirliğini artıran ve OLED ekranlarda pil tasarrufu sağlayan Obsidian Precision Karanlık Teması ile çalışır.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Rect _getShareOrigin() {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    return const Rect.fromLTWH(0, 0, 300, 300);
  }

  void _showSampleCsvTemplate() {
    const template = 'tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon\n'
        '2026-01-15 10:30,BTC,BUY,0.05,95000,USD,2.5\n'
        '2026-01-16 14:00,ETH,BUY,1.0,3400,USD,1.0\n'
        '2026-01-20 18:30,BTC,SELL,0.02,98000,USD,2.0';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text('CSV Şablonu', style: AppTextStyles.headlineSm),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dosyanız şu formatta olmalıdır:', style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.inputInset,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderCard),
                ),
                child: SelectableText(
                  template,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Kapat', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.file_download_outlined, size: 16),
            label: Text('Şablonu .CSV İndir'),
            onPressed: () async {
              Navigator.pop(ctx);
              final origin = _getShareOrigin();
              await ref.read(csvServiceProvider).exportSampleTemplateCsvFile(sharePositionOrigin: origin);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleCsvExport() async {
    final txList = ref.read(transactionsProvider).value ?? [];
    final assets = ref.read(assetsProvider).value ?? Asset.defaultAssets;
    final origin = _getShareOrigin();

    try {
      final csvService = ref.read(csvServiceProvider);
      if (txList.isEmpty) {
        // İşlem listesi boş olsa bile kullanıcıya hatasız başlık satırlı boş CSV şablonu sunulur
        await csvService.exportSampleTemplateCsvFile(sharePositionOrigin: origin);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıtlı işlem olmadığından CSV başlık şablonu dışa aktarıldı.'),
              backgroundColor: AppColors.profit,
            ),
          );
        }
        return;
      }

      await csvService.exportTransactionsToCsvFile(txList, assets, sharePositionOrigin: origin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${txList.length} işlem .csv dosyası olarak paylaşıldı.'),
            backgroundColor: AppColors.profit,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV dışa aktarma hatası: $e'),
            backgroundColor: AppColors.loss,
          ),
        );
      }
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface1,
        title: Text('Hesabı ve Verileri Sil', style: AppTextStyles.headlineSm.copyWith(color: AppColors.lossText)),
        content: Text(
          'Tüm işlemleriniz, portföy geçmişiniz ve hesap verileriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz.',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authControllerProvider.notifier).signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            child: Text('KALICI OLARAK SİL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMarginMobile),
          children: [
            // Kullanıcı Profili
            if (user != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface1,
                  borderRadius: AppSpacing.roundedCard,
                  border: Border.all(color: AppColors.borderCard),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.email ?? 'Kullanıcı', style: AppTextStyles.headlineSm.copyWith(fontSize: 15)),
                          Text('Supabase Hesabı', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            _buildSection(
              title: 'TERCİHLER',
              children: [
                _buildTile(
                  icon: Icons.currency_exchange,
                  title: 'Varsayılan Para Birimi',
                  subtitle: '$currency cinsinden gösteriliyor',
                  trailing: Text(
                    currency,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  onTap: () => _showCurrencyPicker(currency),
                ),
                _buildTile(
                  icon: Icons.refresh,
                  title: 'Fiyat Yenileme Sıklığı',
                  subtitle: '$_refreshSeconds saniye',
                  onTap: _showRefreshPicker,
                ),
                _buildTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Arayüz Teması',
                  subtitle: 'Obsidian Precision Koyu (OLED Aktif)',
                  trailing: const Text(
                    'Karanlık',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  onTap: _showThemeInfo,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              title: 'CSV & VERİ YÖNETİMİ',
              children: [
                _buildTile(
                  icon: Icons.file_upload_outlined,
                  title: 'CSV İçe Aktar',
                  subtitle: 'Toplu işlem listesi yükle',
                  onTap: _handleCsvImport,
                ),
                _buildTile(
                  icon: Icons.description_outlined,
                  title: 'Örnek CSV Şablonu',
                  subtitle: 'Formatı görüntüle ve .csv olarak indir',
                  onTap: _showSampleCsvTemplate,
                ),
                _buildTile(
                  icon: Icons.file_download_outlined,
                  title: 'Verileri Dışa Aktar',
                  subtitle: 'Tüm işlemleri .csv dosyası olarak dışa aktar',
                  onTap: _handleCsvExport,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              title: 'BİLGİLENDİRME',
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Text(
                    'Uyarı: Chronomind yalnızca portföy takip ve analiz amaçlı bir finansal gösterge panelidir. Hiçbir koşulda yatırım tavsiyesi içermez.',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _buildSection(
              title: 'HESAP',
              children: [
                _buildTile(
                  icon: Icons.logout,
                  title: 'Çıkış Yap',
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                ),
                _buildTile(
                  icon: Icons.delete_forever,
                  title: 'Hesabı ve Tüm Verileri Sil',
                  titleColor: AppColors.lossText,
                  onTap: _confirmDeleteAccount,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryBright.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBright.withValues(alpha: 0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Chronomind Crypto Portfolio',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sürüm 1.0.0 · Pure Dark Obsidian',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelSm),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: AppSpacing.roundedCard,
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.textSecondary, size: 20),
      title: Text(
        title,
        style: AppTextStyles.bodyMd.copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted))
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
      onTap: onTap,
    );
  }
}
