
import 'package:flutter/material.dart';
// Material Design widget'larını, tema sınıflarını ve Flutter'ın temel arayüz bileşenlerini kullanıyorum.

import '../../../core/constants/app_colors.dart';
// Uygulamada ortak kullanılan renkleri tek bir dosyadan alıyorum.

import '../../../core/theme/theme_controller.dart';
// Uygulamanın açık/koyu tema değişimini yöneten controller'ı içe aktarıyorum.

import '../controllers/water_tracker_controller.dart';
// Su ekleme, sıfırlama ve günlük hedef gibi işlemleri yöneten controller'ı alıyorum.

import '../models/water_record_model.dart';
// Su tüketim kayıtlarının modelini içe aktarıyorum.

import '../widgets/quick_water_buttons.dart';
// Hızlı su ekleme butonlarının bulunduğu özel widget'ı alıyorum.

import '../widgets/water_card.dart';
// Su kayıtlarını gösteren özel kart widget'ını içe aktarıyorum.

import '../widgets/water_progress_indicator.dart';
// Günlük su tüketimini ve hedefe ulaşma oranını gösteren widget'ı alıyorum.

/// Su takip ana ekran görünümü.
/// Bu sınıf ekranın görünümünü oluşturur; iş mantığını controller'lara bırakır.
class WaterTrackerView extends StatelessWidget {

  // Su ekleme, kayıtları yönetme ve hedef bilgilerini alma işlemleri için controller.
  final WaterTrackerController controller;

  // Açık ve koyu tema durumunu yönetmek için kullandığım controller.
  final ThemeController themeController;

  // Controller'ları dışarıdan alıyorum.
  // Böylece bu ekran controller nesnelerini kendisi oluşturmak zorunda kalmıyor.
  const WaterTrackerView({
    super.key,
    required this.controller,
    required this.themeController,
  });

  // Ana ekranın widget ağacını oluşturuyorum.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Üst uygulama çubuğunu ayrı bir metotla oluşturuyorum.
      appBar: _buildAppBar(context),

      // Ekranın gövdesini oluşturuyorum.
      body: SingleChildScrollView(
        // İçeriklerin etrafına yatay ve dikey boşluk ekliyorum.
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),

        child: Column(
          // Column içerisindeki widget'ları yatayda ortalıyorum.
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            // Kullanıcıya gösterilecek bildirim alanı.
            _buildNotificationBanner(context),

            const SizedBox(height: 16),

            // Günlük su tüketimi ve hedef göstergesi.
            _buildProgressSection(),

            const SizedBox(height: 20),

            // Antrenman nedeniyle eklenen ekstra su hedefi.
            _buildWorkoutExtraHydrationBanner(context),

            const SizedBox(height: 24),

            // Kullanıcının tek dokunuşla su ekleyebileceği alan.
            _buildQuickAddSection(context),

            const SizedBox(height: 24),

            // Gün içerisinde eklenen su kayıtlarının listesi.
            _buildHistorySection(context),
          ],
        ),
      ),
    );
  }

  // Üst uygulama çubuğunu oluşturuyorum.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      // Sol tarafta logo ve uygulama adını birlikte gösteriyorum.
      title: Row(
        children: [
          // Logonun köşelerini yuvarlatıyorum.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),

            // Projedeki assets klasöründen logo görselini yüklüyorum.
            child: Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          const Text('susadım v1'),
        ],
      ),

      // AppBar'ın sağ tarafındaki butonları belirliyorum.
      actions: [

        // Tema değiştiğinde yalnızca bu alanın yeniden oluşturulmasını sağlıyorum.
        ValueListenableBuilder<ThemeMode>(
          // ThemeController içerisindeki tema durumunu dinliyorum.
          valueListenable: themeController.themeMode,

          // Tema değiştiğinde builder tekrar çalışır.
          builder: (context, mode, _) {

            // Mevcut tema koyu mod mu diye kontrol ediyorum.
            final isDark = mode == ThemeMode.dark;

            return IconButton(
              // Koyu moddaysa aydınlık mod, değilse karanlık mod ikonu gösteriyorum.
              icon: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,

                // İkon rengini mevcut temaya göre değiştiriyorum.
                color: isDark
                    ? AppColors.neonCyan
                    : AppColors.lightPrimary,
              ),

              // Kullanıcı butonun üzerine geldiğinde gösterilecek açıklama.
              tooltip: isDark
                  ? 'Aydınlık Moda Geç'
                  : 'Karanlık Moda Geç',

              // Butona basıldığında controller içerisindeki tema değiştirme
              // fonksiyonunu çalıştırıyorum.
              onPressed: themeController.toggleTheme,
            );
          },
        ),

        // Su tüketimini sıfırlamak için yenileme butonu ekliyorum.
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,

            // İkon rengini mevcut temanın parlaklığına göre belirliyorum.
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),

          tooltip: 'Sıfırla',

          // Tıklanınca su takip controller'ındaki sıfırlama fonksiyonunu çağırıyorum.
          onPressed: controller.resetWater,
        ),
      ],
    );
  }

  // Controller'dan gelen bildirim mesajını gösteren alanı oluşturuyorum.
  Widget _buildNotificationBanner(BuildContext context) {

    // Mevcut temanın koyu modda olup olmadığını kontrol ediyorum.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Temaya göre bildirim alanının ana rengini belirliyorum.
    final primaryColor = isDark
        ? AppColors.neonCyan
        : AppColors.lightPrimary;

    // Temaya göre metin rengini belirliyorum.
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    // Bildirim mesajındaki değişiklikleri dinliyorum.
    // String? kullanılması mesajın null olabileceğini gösteriyor.
    return ValueListenableBuilder<String?>(
      valueListenable: controller.alertMessage,

      builder: (context, message, _) {

        // Mesaj yoksa ekranda boş bir widget gösteriyorum.
        if (message == null) {
          return const SizedBox.shrink();
        }

        return Container(
          // Bildirim alanının altına boşluk bırakıyorum.
          margin: const EdgeInsets.only(bottom: 12),

          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            // Rengin saydamlığını temaya göre ayarlıyorum.
            color: primaryColor.withAlpha(isDark ? 25 : 18),

            borderRadius: BorderRadius.circular(12),

            // Bildirim alanına kenarlık ekliyorum.
            border: Border.all(
              color: primaryColor.withAlpha(isDark ? 90 : 80),
            ),
          ),

          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: primaryColor,
                size: 20,
              ),

              const SizedBox(width: 10),

              // Mesajın kalan yatay alanı kullanmasını sağlıyorum.
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Bildirimi kapatmak için çarpı ikonu ekliyorum.
              GestureDetector(
                // Dokunulduğunda controller'daki bildirim temizleme
                // fonksiyonunu çağırıyorum.
                onTap: controller.clearAlert,

                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Günlük su tüketim göstergesini oluşturuyorum.
  Widget _buildProgressSection() {

    // Anlık su miktarındaki değişiklikleri dinliyorum.
    return ValueListenableBuilder<int>(
      valueListenable: controller.currentWater,

      builder: (context, current, _) {

        // Egzersiz nedeniyle eklenen ekstra hedefi de dinliyorum.
        return ValueListenableBuilder<int>(
          valueListenable: controller.workoutExtraGoal,

          builder: (context, extra, _) {

            // Controller üzerinden toplam günlük hedefi alıyorum.
            final totalGoal = controller.totalDailyGoal;

            // Günlük hedefin ne kadarının tamamlandığını alıyorum.
            final progress = controller.progressRatio;

            // Hesaplanan değerleri gösterge widget'ına gönderiyorum.
            return WaterProgressIndicator(
              currentWater: current,
              totalGoal: totalGoal,
              progress: progress,
            );
          },
        );
      },
    );
  }

  // Egzersiz nedeniyle günlük su hedefine eklenen miktarı gösteriyorum.
  Widget _buildWorkoutExtraHydrationBanner(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Arka plan ve metin renklerini temaya göre belirliyorum.
    final surfaceLight = isDark
        ? AppColors.darkSurfaceLight
        : AppColors.lightSurfaceLight;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    // Ekstra hedef miktarındaki değişiklikleri dinliyorum.
    return ValueListenableBuilder<int>(
      valueListenable: controller.workoutExtraGoal,

      builder: (context, extra, _) {

        // Ekstra hedef yoksa bu alanı hiç göstermiyorum.
        if (extra == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: AppColors.neonOrange.withAlpha(80),
            ),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.neonOrange,
                size: 22,
              ),

              const SizedBox(width: 12),

              // Metinlerin kalan alanı kullanmasını sağlıyorum.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Egzersiz Hidrasyon Desteği',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    // Controller'dan gelen ekstra su miktarını gösteriyorum.
                    Text(
                      'Bugün yapılan antrenmanlar için hedefe +$extra ml su eklendi.',
                      style: TextStyle(
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hızlı su ekleme alanını oluşturuyorum.
  Widget _buildQuickAddSection(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Column(
      // Başlık ve butonları sola hizalıyorum.
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Hızlı Su Ekle',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        // Hızlı su ekleme butonlarını ayrı bir widget olarak kullanıyorum.
        QuickWaterButtons(

          // Kullanıcı bir miktar seçtiğinde callback çalışır.
          // Gelen amount ve label değerlerini controller'a iletiyorum.
          onAdd: (amount, label) {
            controller.addWater(
              amount,
              source: label,
            );
          },
        ),
      ],
    );
  }

  // Günlük su tüketim geçmişini oluşturuyorum.
  Widget _buildHistorySection(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kayıt kartlarının renklerini mevcut temaya göre belirliyorum.
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    final borderColor = isDark
        ? AppColors.darkSurfaceBorder
        : AppColors.lightSurfaceBorder;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final mutedColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Bugünkü Tüketim Kayıtları',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        const SizedBox(height: 12),

        // Su kayıt listesindeki değişiklikleri dinliyorum.
        return ValueListenableBuilder<List<WaterRecordModel>>(
          valueListenable: controller.records,

          builder: (context, list, _) {

            // Henüz hiç su kaydı yoksa bilgilendirme kartı gösteriyorum.
            if (list.isEmpty) {
              return Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(vertical: 24),

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),

                child: Text(
                  'Henüz su kaydı bulunmuyor. Bir bardak suyla başla!',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedColor,
                  ),
                ),
              );
            }

            // Kayıt varsa her birini WaterRecordCard widget'ı ile gösteriyorum.
            return ListView.builder(
              // İç içe ListView kullanıldığı için yüksekliğini içeriğe göre hesaplatıyorum.
              shrinkWrap: true,

              // Dışarıdaki SingleChildScrollView kaydırma işlemini yönetsin diye
              // bu iç listenin kendi kaydırmasını kapatıyorum.
              physics: const NeverScrollableScrollPhysics(),

              // Listede kaç kayıt olduğunu belirliyorum.
              itemCount: list.length,

              // Her kayıt için ekranda gösterilecek kartı oluşturuyorum.
              itemBuilder: (context, index) {
                return WaterRecordCard(
                  record: list[index],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
