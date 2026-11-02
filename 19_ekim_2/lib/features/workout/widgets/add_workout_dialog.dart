import 'package:flutter/material.dart';
// Flutter'ın Material Design bileşenlerini kullanabilmek için gerekli kütüphaneyi içe aktarıyorum.

import '../../../core/constants/app_colors.dart';
// Uygulama genelinde kullandığım ortak renkleri içe aktarıyorum.

import '../models/workout_model.dart';

// Antrenman türlerini ve su ihtiyacı, kalori hesaplama fonksiyonlarını içeren modeli alıyorum.

/// Yeni antrenman eklemek için açılan alt sayfa (Bottom Sheet).
class AddWorkoutSheet extends StatefulWidget {
  // Antrenman kaydedildiğinde üst ekrana veri göndermek için callback tanımlıyorum.
  // Bu fonksiyon isimlendirilmiş parametreler alıyor.
  final void Function({
    required String title,
    required WorkoutType type,
    required int durationMinutes,
  })
  onSave;

  // onSave fonksiyonunu dışarıdan alıyorum.
  // Böylece antrenman kaydetme işlemini bu widget'ın dışında yönetebiliyorum.
  const AddWorkoutSheet({super.key, required this.onSave});

  // Bottom Sheet'i açmak için kullandığım yardımcı static metot.
  // Böylece bu widget'ı kullanacak ekranlarda tekrar tekrar
  // showModalBottomSheet kodu yazmak zorunda kalmıyorum.
  static Future<void> show(
    BuildContext context, {
    required void Function({
      required String title,
      required WorkoutType type,
      required int durationMinutes,
    })
    onSave,
  }) {
    // Mevcut temanın koyu modda olup olmadığını kontrol ediyorum.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Alt sayfanın arka plan rengini mevcut temaya göre belirliyorum.
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;

    // Bottom Sheet'i ekranda gösteriyorum.
    return showModalBottomSheet(
      context: context,

      // Klavye açıldığında Bottom Sheet'in klavyeye göre
      // yeniden konumlanmasını sağlıyorum.
      isScrollControlled: true,

      // Alt sayfanın arka plan rengini belirliyorum.
      backgroundColor: surfaceColor,

      // Alt sayfanın üst köşelerini yuvarlatıyorum.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      // Bottom Sheet açıldığında gösterilecek widget'ı belirliyorum.
      builder: (context) => AddWorkoutSheet(onSave: onSave),
    );
  }

  // StatefulWidget için State sınıfını oluşturuyorum.
  @override
  State<AddWorkoutSheet> createState() => _AddWorkoutSheetState();
}

// Kullanıcının yaptığı seçimleri ve geçici ekran durumunu burada yönetiyorum.
class _AddWorkoutSheetState extends State<AddWorkoutSheet> {
  // Varsayılan antrenman türünü ağırlık çalışması olarak belirliyorum.
  WorkoutType _selectedType = WorkoutType.weightLifting;

  // Antrenman süresinin başlangıç değerini 30 dakika olarak belirliyorum.
  int _duration = 30;

  // Kullanıcının metin girişi yapması için controller oluşturuyorum.
  final TextEditingController _titleController = TextEditingController();

  // Widget ekrandan kaldırıldığında controller belleğini temizliyorum.
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Bottom Sheet'in kullanıcı arayüzünü oluşturuyorum.
  @override
  Widget build(BuildContext context) {
    // Seçilen antrenman türü ve süreye göre gerekli su miktarını hesaplıyorum.
    final waterNeed = WorkoutModel.calculateWaterNeed(_selectedType, _duration);

    // Seçilen antrenman türü ve süreye göre tahmini kaloriyi hesaplıyorum.
    final calories = WorkoutModel.calculateCalories(_selectedType, _duration);

    return Padding(
      // İçeriğin kenarlara ve klavyeye yapışmasını engelliyorum.
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,

        // Klavye açılırsa klavyenin yüksekliği kadar alt boşluk bırakıyorum.
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),

      child: Column(
        // İçerik kadar yer kaplamasını sağlıyorum.
        // Böylece Bottom Sheet gereksiz yere ekranın tamamını kaplamıyor.
        mainAxisSize: MainAxisSize.min,

        // İçerikleri sola hizalıyorum.
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Başlık ve kapatma butonunu oluşturuyorum.
          _buildHeader(context),

          const SizedBox(height: 16),

          // Antrenman türü seçim alanını oluşturuyorum.
          _buildTypeSelector(context),

          const SizedBox(height: 20),

          // Antrenman süresini ayarlamak için slider ekliyorum.
          _buildDurationSlider(context),

          const SizedBox(height: 16),

          // Seçimlere göre hesaplanan su ve kalori miktarını gösteriyorum.
          _buildPreviewCard(context, waterNeed, calories),

          const SizedBox(height: 20),

          // Antrenmanı kaydetmek için buton oluşturuyorum.
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  // Alt sayfanın başlığını ve kapatma butonunu oluşturuyorum.
  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Başlık ve ikon renklerini temaya göre ayarlıyorum.
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Row(
      // Başlık ile kapatma butonunu iki uca yerleştiriyorum.
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          'Yeni Egzersiz Ekle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        // Alt sayfayı kapatmak için çarpı butonu ekliyorum.
        IconButton(
          icon: Icon(Icons.close, color: subTextColor),

          // Navigator.pop() mevcut Bottom Sheet'i kapatır.
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // Kullanıcının antrenman türünü seçebileceği alanı oluşturuyorum.
  Widget _buildTypeSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;

    final surfaceLight = isDark
        ? AppColors.darkSurfaceLight
        : AppColors.lightSurfaceLight;

    final borderColor = isDark
        ? AppColors.darkSurfaceBorder
        : AppColors.lightSurfaceBorder;

    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Wrap(
      // Aynı satırdaki seçenekler arasında yatay boşluk bırakıyorum.
      spacing: 8,

      // Alt satıra geçilirse satırlar arasında boşluk bırakıyorum.
      runSpacing: 8,

      // WorkoutType enum'undaki bütün antrenman türlerini dolaşıyorum.
      children: WorkoutType.values.map((type) {
        // O anki antrenman türü seçili olan tür mü diye kontrol ediyorum.
        final isSelected = type == _selectedType;

        // Her antrenman türü için ayrı bir seçim butonu oluşturuyorum.
        return ChoiceChip(
          // Kullanıcıya antrenman türünün adını gösteriyorum.
          label: Text(type.label),

          // Seçili olan butonu görsel olarak işaretliyorum.
          selected: isSelected,

          // Kullanıcı bir antrenman türüne dokunduğunda çalışıyorum.
          onSelected: (selected) {
            // Seçim aktif hale getirildiyse seçilen türü güncelliyorum.
            if (selected) {
              setState(() {
                _selectedType = type;
              });
            }
          },

          // Seçili butonun arka plan rengini belirliyorum.
          selectedColor: primaryColor.withAlpha(50),

          // Seçili olmayan butonların arka plan rengini belirliyorum.
          backgroundColor: surfaceLight,

          // Seçenek yazısının rengini ve kalınlığını ayarlıyorum.
          labelStyle: TextStyle(
            color: isSelected ? primaryColor : subTextColor,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),

          // Seçili olma durumuna göre kenarlık rengini değiştiriyorum.
          side: BorderSide(color: isSelected ? primaryColor : borderColor),
        );
      }).toList(),
    );
  }

  // Antrenman süresini belirlemek için slider alanını oluşturuyorum.
  Widget _buildDurationSlider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;

    final borderColor = isDark
        ? AppColors.darkSurfaceBorder
        : AppColors.lightSurfaceBorder;

    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              'Antrenman Süresi',
              style: TextStyle(fontSize: 14, color: subTextColor),
            ),

            // Kullanıcının seçtiği süreyi ekranda gösteriyorum.
            Text(
              '$_duration Dakika',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ),

        // Kullanıcının antrenman süresini kaydırarak seçmesini sağlıyorum.
        Slider(
          // Slider double değer istediği için int değeri double'a çeviriyorum.
          value: _duration.toDouble(),

          // Seçilebilecek minimum süre 10 dakika.
          min: 10,

          // Seçilebilecek maksimum süre 120 dakika.
          max: 120,

          // Slider üzerinde 22 eşit aralık oluşturuyorum.
          divisions: 22,

          activeColor: primaryColor,
          inactiveColor: borderColor,

          // Slider'ın değeri değiştiğinde çalışıyorum.
          onChanged: (val) {
            setState(() {
              // Slider'dan gelen double değeri int'e çeviriyorum.
              _duration = val.toInt();
            });
          },
        ),
      ],
    );
  }

  // Seçilen antrenmana göre hesaplanan su ve kalori miktarını gösteriyorum.
  Widget _buildPreviewCard(BuildContext context, int waterNeed, int calories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.neonCyan : AppColors.lightPrimary;

    final surfaceLight = isDark
        ? AppColors.darkSurfaceLight
        : AppColors.lightSurfaceLight;

    final borderColor = isDark
        ? AppColors.darkSurfaceBorder
        : AppColors.lightSurfaceBorder;

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),

      child: Row(
        // Su ve kalori bilgilerini yatayda dengeli yerleştiriyorum.
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [
          // Tahmini su ihtiyacını gösteriyorum.
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: AppColors.neonCyan,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                '+$waterNeed ml Su',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          // Su ve kalori bilgileri arasına dikey ayraç ekliyorum.
          Container(width: 1, height: 20, color: borderColor),

          // Tahmini kalori miktarını gösteriyorum.
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.neonOrange,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                '~$calories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Antrenmanı kaydetmek için butonu oluşturuyorum.
  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      // Butonun kullanılabilir yatay alanın tamamını kaplamasını sağlıyorum.
      width: double.infinity,

      child: ElevatedButton(
        // Kullanıcı kaydet butonuna bastığında çalışıyorum.
        onPressed: () {
          // StatefulWidget sınıfından gelen onSave callback'ini çağırıyorum.
          // Seçilen antrenman bilgilerini üst ekrana iletiyorum.
          widget.onSave(
            title: _selectedType.label,
            type: _selectedType,
            durationMinutes: _duration,
          );

          // Antrenman kaydedildikten sonra Bottom Sheet'i kapatıyorum.
          Navigator.pop(context);
        },

        child: const Text('Antrenmanı Kaydet & Su Ekle'),
      ),
    );
  }
}
