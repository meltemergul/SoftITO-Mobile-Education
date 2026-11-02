import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../controller/water_tracker_controller.dart';

// Kullanıcının sık kullandığı su miktarlarını (+200ml, +330ml vb.)
// tek tıkla hızlıca ekleyebilmesini sağlayan buton grubu.
class QuickWaterButtons extends StatelessWidget {
  final WaterTrackerController controller;

  const QuickWaterButtons({super.key, required this.controller});

  // Hızlı butonlar için önceden belirlediğim hazır su miktarları (ml cinsinden):
  // 200: 1 standart su bardağı
  // 330: Küçük kutu / küçük cam şişe
  // 500: Yarım litrelik standart pet şişe
  // 1000: 1 litrelik spor matarası
  static const List<int> _amounts = [200, 330, 500, 1000];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bölüm başlığı
        const Text(
          'Hızlı Su Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Butonları yatayda yan yana dizmek için Row kullandım
        Row(
          // '_amounts.map(...).toList()' yapısını kullandım:
          // Her bir int değeri alıp tek tek `_QuickAddButton` widget'ına dönüştürüyor.
          children: _amounts.map((amount) {
            // Neden 'Expanded'?
            // Ekran genişliği ne olursa olsun 4 butonun da eşit genişlikte yan yana sığmasını sağlıyorum.
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0), // Butonlar arası boşluk
                child: _QuickAddButton(
                  amount: amount,
                  // Butona basıldığında controller üzerindeki `addWater` metodunu tetikliyorum
                  onTap: () => controller.addWater(amount),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Tek bir hızlı su butonunun tasarımını temsil eden alt widget.
// Kodu temiz tutmak ve tekrarı önlemek için ayrı bir bileşene ayırdım.
class _QuickAddButton extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // InkWell: Kullanıcı butona dokunduğunda modern bir dokunma/tıklama dalgası (ripple effect) verir.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Tıklama dalgasının kutunun yuvarlak köşelerinden taşmasını önlüyorum
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface, // Obsidian kart rengi
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Column(
          // mainAxisSize.min: Sütunun dikeyde gereksiz uzamasını engeller, içeriği kadar yer kaplar
          mainAxisSize: MainAxisSize.min,
          children: [
            // Damla ikonu
            const Icon(
              Icons.water_drop_outlined,
              color: AppColors.neonWater,
              size: 22,
            ),
            const SizedBox(height: 6),

            // Eklenen miktar (Örn: +200)
            Text(
              '+$amount',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            // Birim yazısı (ml)
            const Text(
              'ml',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

