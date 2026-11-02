import 'package:flutter/material.dart';

// Su takibi işlemlerini yöneten controller dosyasını içe aktarıyorum.
import '../controllers/water_tracker_controller.dart';

// Su takibine ait verileri bir arada tutan model dosyasını içe aktarıyorum.
import '../models/water_tracker_model.dart';

// Günlük su ilerlemesini gösteren kart widget'ını içe aktarıyorum.
import '../widgets/water_progress_card.dart';

// Hızlı su ekleme butonlarının bulunduğu bölümü içe aktarıyorum.
import '../widgets/water_quick_add_section.dart';

// Su tüketimine ait istatistikleri gösteren grid widget'ını içe aktarıyorum.
import '../widgets/water_stats_grid.dart';

/// Su takibi ana ekranını oluşturuyorum.
/// StatelessWidget kullanıyorum çünkü ekranın kendi içerisinde değişken bir state tutmasına gerek yok.
/// Verilerdeki değişiklikleri controller üzerinden dinliyorum.
class WaterTrackerView extends StatelessWidget {
  // Su takibi işlemlerini gerçekleştiren controller'ı tutuyorum.
  final WaterTrackerController controller;

  // Controller nesnesini dışarıdan alarak ekranın bağımlılığını belirliyorum.
  const WaterTrackerView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Ekranın temel iskeletini Scaffold ile oluşturuyorum.
    return Scaffold(
      // Ekranın üst bölümünde uygulama başlığını ve sıfırlama butonunu gösteriyorum.
      appBar: AppBar(
        title: const Text('susadım - Su Takibi'),

        // AppBar'ın sağ tarafına işlem butonlarını ekliyorum.
        actions: [
          IconButton(
            // Butonun üzerine basıldığında gösterilecek açıklama.
            tooltip: 'Sıfırla',

            // Su takibini sıfırlamak için yenileme ikonu kullanıyorum.
            icon: const Icon(Icons.refresh_rounded),

            // Butona basıldığında controller içerisindeki resetWater fonksiyonunu çağırıyorum.
            onPressed: controller.resetWater,
          ),
        ],
      ),

      // İçeriğin cihazın güvenli ekran alanı içerisinde kalmasını sağlıyorum.
      body: SafeArea(
        // Controller içerisindeki su takip verilerini dinliyorum.
        // Model değiştiğinde ilgili arayüzün otomatik güncellenmesini sağlıyorum.
        child: ValueListenableBuilder<WaterTrackerModel>(
          // Controller'ın state isimli ValueListenable nesnesini dinliyorum.
          valueListenable: controller.state,

          // State değiştiğinde güncel model ile arayüzü yeniden oluşturuyorum.
          builder: (context, model, _) {
            // İçerik ekranın boyutunu aşarsa dikey kaydırma sağlıyorum.
            return SingleChildScrollView(
              // Ekran içeriğinin etrafına 16 birim boşluk bırakıyorum.
              padding: const EdgeInsets.all(16.0),

              // İçerik bileşenlerini dikey olarak sıralıyorum.
              child: Column(
                // Çocuk widget'ların yatay eksende mümkün olduğunca genişlemesini sağlıyorum.
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  // Günlük su tüketimini ve hedefe ulaşma durumunu gösteriyorum.
                  WaterProgressCard(model: model),

                  const SizedBox(height: 16),

                  // Su tüketimine ait istatistikleri gösteriyorum.
                  WaterStatsGrid(model: model),

                  const SizedBox(height: 24),

                  // Kullanıcının hızlıca su ekleyebilmesini sağlıyorum.
                  // Su ekleme işlemini controller'ın addWater fonksiyonuna bağlıyorum.
                  WaterQuickAddSection(onAdd: controller.addWater),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
