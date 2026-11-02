import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';
import '../models/water_log_model.dart';

// Gün içinde eklenen su kayıtlarını listeleyen bileşen.
class WaterLogList extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterLogList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final logs = controller.logs;

    // Eğer henüz hiç su eklenmediyse, boş ekran yerine kullanıcıya bilgilendirici bir placeholder gösteriyorum
    if (logs.isEmpty) {
      return const _EmptyLogsPlaceholder();
    }

    // Neden 'ListView.separated'?
    // Her bir kayıt arasına `separatorBuilder` ile kolayca boşluk (SizedBox) koyabilmek için tercih ettim.
    return ListView.separated(
      // 'shrinkWrap: true': Listenin ekrandaki tüm yüksekliği zorla kaplamasını engeller,
      // sadece içindeki elemanların toplam yüksekliği kadar yer kaplamasını sağlar.
      shrinkWrap: true,

      // 'physics: const NeverScrollableScrollPhysics()':
      // Bu liste zaten dışarıdaki `SingleChildScrollView` içinde yer alıyor.
      // İç içe iki farklı scroll (kaydırma) mekanizması çakışmasın diye ListView'ın kendi kaydırmasını kapattım.
      physics: const NeverScrollableScrollPhysics(),

      itemCount: logs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8), // Elemanlar arası 8px dikey boşluk
      itemBuilder: (context, index) {
        final log = logs[index];
        return _WaterLogTile(
          log: log,
          // Silme butonuna basıldığında ilgili kaydın ID'si ile silinmesini tetikliyorum
          onDelete: () => controller.removeLog(log.id),
        );
      },
    );
  }
}

// Liste boşken gösterilen şık ve minimal bilgilendirme kutusu
class _EmptyLogsPlaceholder extends StatelessWidget {
  const _EmptyLogsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const Column(
        children: [
          // Soluk damla ikonu
          Icon(Icons.water_drop, color: AppColors.surfaceBorder, size: 40),
          SizedBox(height: 8),
          Text(
            'Henüz su kaydı bulunmuyor.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// Listede tek bir su kaydını (Örn: +250 ml | 14:30 | [X]) gösteren satır kartı
class _WaterLogTile extends StatelessWidget {
  final WaterLog log;
  final VoidCallback onDelete;

  const _WaterLogTile({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
      ),
      child: Row(
        children: [
          // Sol başta neon su damlası
          const Icon(Icons.water_drop, color: AppColors.neonWater, size: 20),
          const SizedBox(width: 12),

          // Eklenen mililitre miktarı
          Text(
            '+${log.amountMl} ml',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),

          // Spacer: Sol taraftaki su miktarı ile sağ taraftaki saat/sil butonunun arasını
          // ekranın elverdiği ölçüde sonuna kadar açar.
          const Spacer(),

          // Kaydın eklendiği saat formatı (Örn: 10:45)
          Text(
            log.formattedTime,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),

          // Kaydı silme butonu
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            onPressed: onDelete,
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

