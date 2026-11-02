import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';
import '../widget/quick_water_buttons.dart';
import '../widget/water_log_list.dart';
import '../widget/water_progress_card.dart';

// Su takibi ana ekranını temsil eden görünüm (View) katmanı.
// StatefulWidget yapıp her yerde `setState` çağırmak yerine, durumu Controller'a devrettim.
// 'ListenableBuilder' sayesinde controller'daki veriler değiştiğinde (notifyListeners çağrıldığında)
// ekran otomatik ve verimli bir şekilde kendini yeniler.
class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder: Controller nesnesindeki değişiklikleri dinler
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // SingleChildScrollView: Ekran küçük cihazlarda taştığında (RenderFlex overflow hatası almamak için)
        // sayfanın dikeyde rahatça kaydırılabilmesini sağlıyorum.
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bölüm: Günlük su ilerlemesini ve dairesel grafiği gösteren kart
              WaterProgressCard(controller: controller),
              const SizedBox(height: 24),

              // 2. Bölüm: Tek tıkla +200ml, +500ml gibi su ekleyen butonlar
              QuickWaterButtons(controller: controller),
              const SizedBox(height: 28),

              // 3. Bölüm: Bugünkü kayıtlar başlığı ve 'Sıfırla' butonu
              _LogSectionHeader(onReset: controller.resetDaily),
              const SizedBox(height: 12),

              // 4. Bölüm: Eklenen su kayıtlarının listesi
              WaterLogList(controller: controller),
            ],
          ),
        );
      },
    );
  }
}

// Sadece bu dosyaya özel, "Bugünkü Kayıtlar" başlığını ve sıfırlama butonunu tutan alt widget.
// Dosya dışına açmama gerek olmadığı için başına alt tire (_) koyarak private yaptım.
class _LogSectionHeader extends StatelessWidget {
  final VoidCallback onReset;

  const _LogSectionHeader({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bugünkü Kayıtlar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        // Tüm su kayıtlarını sıfırlamak için kırmızı renkli buton
        TextButton(
          onPressed: onReset,
          child: const Text(
            'Sıfırla',
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

