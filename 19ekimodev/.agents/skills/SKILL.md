---
name: blood-donation-feature-scaffold
description: CanBağım uygulaması için feature-first mimarisinde kan değerleri, bağış noktaları, acil talepler ve istatistik grafik modüllerini standartlara uygun şekilde üretir.
---

# CanBağım Feature Scaffold (Modüler Özellik İskeleti)

Bu yetenek, CanBağı (Kan Bağışı ve İhtiyaç Takip) uygulamasında yeni bir modül veya ekran geliştirirken Clean UI, medikal veri ayrımı ve reaktif `ValueNotifier` standartlarına tam uyulmasını sağlar.

## Temel Kurallar
1. **Asla Tek Dosyada Toplama:**
   Model (`models/`), Controller (`controllers/`), Alt Bileşenler (`widgets/`) ve Ana Ekran (`views/`) dosyaları mutlaka ayrı ayrı oluşturulmalıdır.
2. **State Yönetimi Standartı:**
   Ağır harici paketler (Bloc, Riverpod vb.) ve sayfa genelini yeniden çizen gereksiz `setState` yasaktır. Ekran durumları `ValueNotifier` ve `ValueListenableBuilder` ile yerel ve hafif tutulacaktır.
3. **Const ve UI Standartları:**
   Tüm statik widget'larda `const` zorunludur. Renkler ve tipografiler doğrudan `AppColors` veya `Theme.of(context)` üzerinden okunmalıdır.
4. **40 Satır Kuralı:**
   40 satırı geçen `build` metotları alt widget'lara parçalanarak `widgets/` dizinine taşınmalıdır.
5. **Tıbbi Eşik ve Aralık Güvenliği:**
   Kan değerleri ile ilgili modellerde referans aralıkları (Hemoglobin, Nabız, Tansiyon vb.) sabit enum/yardımcı sınıflar üzerinden doğrulanmalıdır.

---

## Adım Adım Modül Geliştirme Akışı

### Adım 1: Klasör Yapısının Kurulması
Geliştirilecek modülü `lib/features/<feature_name>` altında aç:

```text
lib/features/<feature_name>/
    controllers/
        <feature_name>_controller.dart
    models/
        <feature_name>_model.dart
    views/
        <feature_name>_view.dart
    widgets/
        <feature_name>_card.dart
```

*Desteklenen Modül İsimleri:*
- `blood_values` (Kan Değerleri Analizi)
- `donation_centers` (Bağış Noktaları ve İstasyonlar)
- `urgent_requests` (Acil Kan Talepleri)
- `donation_statistics` (Aylık Bağış Grafikleri)

---

### Adım 2: Model Dosyasını Oluşturma (`models/`)
Tüm modeller `immutable`, `const` kuruculu, `copyWith`, `fromJson` ve `toJson` metotlarına sahip olmalıdır.

**Örnek:** `lib/features/blood_values/models/blood_metric_model.dart`
```dart
enum MetricStatus { eligible, warning, ineligible }

class BloodMetricModel {
  final String id;
  final String title;
  final double currentValue;
  final double minThreshold;
  final double maxThreshold;
  final String unit;

  const BloodMetricModel({
    required this.id,
    required this.title,
    required this.currentValue,
    required this.minThreshold,
    required this.maxThreshold,
    required this.unit,
  });

  MetricStatus get status {
    if (currentValue >= minThreshold && currentValue <= maxThreshold) {
      return MetricStatus.eligible;
    } else if (currentValue < minThreshold && currentValue >= (minThreshold * 0.9)) {
      return MetricStatus.warning;
    }
    return MetricStatus.ineligible;
  }

  BloodMetricModel copyWith({
    String? id,
    String? title,
    double? currentValue,
    double? minThreshold,
    double? maxThreshold,
    String? unit,
  }) {
    return BloodMetricModel(
      id: id ?? this.id,
      title: title ?? this.title,
      currentValue: currentValue ?? this.currentValue,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      unit: unit ?? this.unit,
    );
  }

  factory BloodMetricModel.fromJson(Map<String, dynamic> json) {
    return BloodMetricModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      minThreshold: (json['minThreshold'] as num?)?.toDouble() ?? 0.0,
      maxThreshold: (json['maxThreshold'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'currentValue': currentValue,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'unit': unit,
    };
  }
}
```

---

### Adım 3: Controller Dosyasını Oluşturma (`controllers/`)
Controller katmanı iş mantığını ve `ValueNotifier` nesnelerini barındırır. Mutlaka bir `dispose()` metodu içermelidir.

**Örnek:** `lib/features/blood_values/controllers/blood_values_controller.dart`
```dart
import 'package:flutter/foundation.dart';
import '../models/blood_metric_model.dart';

class BloodValuesController {
  final ValueNotifier<List<BloodMetricModel>> metrics =
      ValueNotifier<List<BloodMetricModel>>([]);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void loadInitialData() {
    isLoading.value = true;
    metrics.value = const [
      BloodMetricModel(
        id: 'hb',
        title: 'Hemoglobin',
        currentValue: 13.8,
        minThreshold: 12.5,
        maxThreshold: 17.5,
        unit: 'g/dL',
      ),
      BloodMetricModel(
        id: 'weight',
        title: 'Vücut Ağırlığı',
        currentValue: 68.0,
        minThreshold: 50.0,
        maxThreshold: 150.0,
        unit: 'kg',
      ),
    ];
    isLoading.value = false;
  }

  void updateMetricValue(String id, double newValue) {
    metrics.value = [
      for (final item in metrics.value)
        if (item.id == id) item.copyWith(currentValue: newValue) else item,
    ];
  }

  void dispose() {
    metrics.dispose();
    isLoading.dispose();
  }
}
```

---

### Adım 4: Alt Bileşen (Widget) Oluşturma (`widgets/`)
Görsel kartlar, grafikler ve durum rozetleri ayrık `StatelessWidget` sınıfları olarak yazılır.

**Örnek:** `lib/features/blood_values/widgets/blood_metric_card.dart`
```dart
import 'package:flutter/material.dart';
import '../models/blood_metric_model.dart';

class BloodMetricCard extends StatelessWidget {
  final BloodMetricModel metric;

  const BloodMetricCard({
    super.key,
    required this.metric,
  });

  Color _getStatusColor(MetricStatus status) {
    switch (status) {
      case MetricStatus.eligible:
        return const Color(0xFF2EC4B6);
      case MetricStatus.warning:
        return const Color(0xFFFF9F1C);
      case MetricStatus.ineligible:
        return const Color(0xFFE63946);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(metric.status);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hedef: ${metric.minThreshold} - ${metric.maxThreshold} ${metric.unit}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${metric.currentValue} ${metric.unit}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Adım 5: Ekran (View) Dosyasını Oluşturma (`views/`)
Ekran seviyesinde `StatelessWidget` ve `ValueListenableBuilder` kullanılarak controller bağlanır.

**Örnek:** `lib/features/blood_values/views/blood_values_view.dart`
```dart
import 'package:flutter/material.dart';
import '../controllers/blood_values_controller.dart';
import '../models/blood_metric_model.dart';
import '../widgets/blood_metric_card.dart';

class BloodValuesView extends StatelessWidget {
  final BloodValuesController controller;

  const BloodValuesView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağış Uygunluk Değerleri'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<BloodMetricModel>>(
            valueListenable: controller.metrics,
            builder: (context, metrics, _) {
              if (metrics.isEmpty) {
                return const Center(child: Text('Kayıtlı değer bulunamadı.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  return BloodMetricCard(metric: metrics[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## Sayfaya Entegrasyon (Lifecycle Yönetimi)

```dart
import 'package:flutter/material.dart';
import 'features/blood_values/controllers/blood_values_controller.dart';
import 'features/blood_values/views/blood_values_view.dart';

class BloodValuesPage extends StatefulWidget {
  const BloodValuesPage({super.key});

  @override
  State<BloodValuesPage> createState() => _BloodValuesPageState();
}

class _BloodValuesPageState extends State<BloodValuesPage> {
  late final BloodValuesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BloodValuesController()..loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BloodValuesView(controller: _controller);
  }
}
```

---

## Doğrulama ve Test Standartları
Her modül geliştirildikten sonra sırasıyla şu komutlar çalıştırılmalı ve 0 hata elde edilmelidir:

```bash
flutter analyze
flutter test
```