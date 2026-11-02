import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';

// Günlük su tüketim durumunu dairesel ilerleme grafiği ve istatistiklerle özetleyen ana kart bileşeni.
class WaterProgressCard extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterProgressCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Kartın içindeki boşluk (padding)
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // Sol taraf: Dairesel su ilerleme grafiği ve yüzdelik oran
            _ProgressCircle(controller: controller),
            const SizedBox(width: 24),

            // Sağ taraf: İçilen miktar, toplam hedef, ek egzersiz rozeti ve kalan su bilgisi
            // Expanded: Kalan tüm yatay genişliği kaplasın diye kullandım.
            Expanded(child: _ProgressStats(controller: controller)),
          ],
        ),
      ),
    );
  }
}

// Dairesel ilerleme göstergesi bileşeni (Circular indicator + Yüzde yazısı)
class _ProgressCircle extends StatelessWidget {
  final WaterTrackerController controller;

  const _ProgressCircle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final percent = controller.progressPercentage;
    return SizedBox(
      width: 104,
      height: 104,
      // Neden 'Stack'?
      // Dairesel gösterge ile tam ortasındaki "%75 Hedef" yazısını üst üste bindirmek için Stack kullandım.
      child: Stack(
        fit: StackFit.expand, // Stack içindeki çocukların tam 104x104 alanını kaplamasını sağlar
        children: [
          // Dairesel ilerleme çubuğu
          CircularProgressIndicator(
            value: percent, // 0.0 ile 1.0 arasında doluluk oranı
            strokeWidth: 9, // Çizgi kalınlığı
            backgroundColor: AppColors.surfaceBorder, // Boş kısmın koyu çerçeve rengi
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonWater), // Dolu kısmın neon su mavisi rengi
            strokeCap: StrokeCap.round, // Çizginin başlangıç ve bitiş uçlarının yuvarlak olması için
          ),
          // Halkanın tam merkezine yerleşecek metin grubu
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yüzde hesabı: Örn. 0.75 * 100 = 75%
                Text(
                  '${(percent * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonWater,
                  ),
                ),
                const Text(
                  'Hedef',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sağ taraftaki metriklerin dikey olarak dizildiği bileşen
class _ProgressStats extends StatelessWidget {
  final WaterTrackerController controller;

  const _ProgressStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Küçük başlık
        const Text(
          'Günlük Tüketim',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),

        // Büyük içilen miktar ve yanındaki hedef (örn: 1750 / 2500 ml)
        _GoalRow(controller: controller),

        // Dart'ın 'collection if' ve spread (...) özelliğini kullandım:
        // Eğer egzersizden kaynaklı ekstra bir su ihtiyacı varsa bu rozeti göster, yoksa hiç çizme.
        if (controller.extraWorkoutWaterMl > 0) ...[
          const SizedBox(height: 4),
          _WorkoutHydrationBadge(extraMl: controller.extraWorkoutWaterMl),
        ],
        const SizedBox(height: 8),

        // Kalan miktar veya tebrik mesajı
        _RemainingText(remainingMl: controller.remainingMl),
      ],
    );
  }
}

// İçilen ve hedeflenen su miktarını yan yana hizalayan satır
class _GoalRow extends StatelessWidget {
  final WaterTrackerController controller;

  const _GoalRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      // crossAxisAlignment.baseline ve textBaseline.alphabetic:
      // Büyük fontlu rakam ile küçük fontlu '/ 2500 ml' yazısının alt taban çizgilerini
      // kusursuz bir şekilde aynı hizaya getirmek için kullandım.
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Mevcut içilen miktar (büyük ve belirgin)
        Text(
          '${controller.currentAmountMl}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
        // Hedef miktar ve birim (daha küçük ve ikincil)
        Text(
          '/ ${controller.dailyGoalMl} ml',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// Egzersiz yapıldığında hedef suyun arttığını gösteren şık neon yeşil rozet
class _WorkoutHydrationBadge extends StatelessWidget {
  final int extraMl;

  const _WorkoutHydrationBadge({required this.extraMl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Şimşek / enerji ikonu
        const Icon(Icons.bolt, size: 14, color: AppColors.neonEnergy),
        const SizedBox(width: 4),
        Text(
          '+$extraMl ml egzersiz hidrasyonu',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.neonEnergy,
          ),
        ),
      ],
    );
  }
}

// Hedefin tamamlanıp tamamlanmadığını kontrol edip durum mesajı veren bileşen
class _RemainingText extends StatelessWidget {
  final int remainingMl;

  const _RemainingText({required this.remainingMl});

  @override
  Widget build(BuildContext context) {
    // Ternary operatör (? :) ile hedef tamamlandıysa yeşil tebrik,
    // tamamlanmadıysa kalan mililitreyi gösteriyorum.
    return Text(
      remainingMl == 0
          ? 'Tebrikler! Günlük hedef tamamlandı.'
          : 'Kalan: $remainingMl ml',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: remainingMl == 0 ? AppColors.neonEnergy : AppColors.textSecondary,
      ),
    );
  }
}

