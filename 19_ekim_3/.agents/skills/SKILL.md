---
name: flutter-feature-scaffold
description: Flutter projelerinde feature bazlı kod yazmak için gerekli klasör yapısını oluşturur. ValueNotifier state mimarisini, UI ayrımını ve birim test iskeletini standartlara uygun olarak üretir.
---

# Flutter Feature Scaffold (Modüler Ekran İskeleti)

Bu yetenek, **susadım** projesinde yeni bir ekran ya da işlev modülü açarken Clean UI, modülerlik ve reaktif durum (`ValueNotifier`) kurallarına tam uyulmasını garanti altına alır.

## İlgili Dosya ve Referans Bağlantıları
- **Durum Akış Referansı:** [references/state_flow.md](file:///Users/d1-1/Desktop/19_ekim_3/.agents/skills/references/state_flow.md)
- **Örnek Ekran Kodu:** [examples/sample_screen.dart](file:///Users/d1-1/Desktop/19_ekim_3/.agents/skills/examples/sample_screen.dart)
- **Otomasyon Scripti:** [script/generate_feautre.sh](file:///Users/d1-1/Desktop/19_ekim_3/.agents/skills/script/generate_feautre.sh)

---

## Temel Kurallar

1. **Asla Tek Dosyada Toplama:**
   - UI (`view/<feature_name>_view.dart`), Controller (`controllers/<feature_name>_controller.dart`), Model (`models/<feature_name>_model.dart`) ve Alt Bileşenler (`widgets/<feature_name>_card.dart`) mutlaka ayrı klasör ve dosyalarda açılmalıdır.
2. **Reaktif State Yönetimi:**
   - Harici ağır state paketleri (`Provider`, `Riverpod`, `Bloc`, `GetX`) yasaktır.
   - Flutter'ın yerel ve hafif çekirdek yapısı olan `ValueNotifier` ve `ValueListenableBuilder` kullanılır.
   - Sayfa düzeyinde ağır `setState` kesinlikle kullanılmaz.
3. **Const Zorunluluğu ve Build Kuralı:**
   - Mümkün olan tüm widget'larda `const` kurucular zorunludur.
   - Hiçbir `build` metodu 40 satırı geçemez. 40 satırı aşan yapılar alt widget olarak parçalanmalıdır.
4. **0 Hata & 0 Uyarı Şartı:**
   - Kod değişikliklerinin ardından `flutter analyze` 0 hata ve 0 uyarı vermeli, birim testler `flutter test` ile doğrulanmalıdır.

---

## Adım Adım Uygulama Akışı

### Adım 1: Klasör Yapısını Oluşturma
Hedeflenen modül adını (örn: `water_tracker` veya `workout`), `lib/features/<feature_name>/` altına kur:

```text
lib/features/<feature_name>/
├── controllers/
│   └── <feature_name>_controller.dart
├── models/
│   └── <feature_name>_model.dart
├── view/
│   └── <feature_name>_view.dart
└── widgets/
    └── <feature_name>_card.dart
```

> **İpucu:** Bu yapıyı otomatik üretmek için [generate_feautre.sh](file:///Users/d1-1/Desktop/19_ekim_3/.agents/skills/script/generate_feautre.sh) scriptini çalıştırabilirsiniz:
> ```bash
> ./.agents/skills/script/generate_feautre.sh <feature_name>
> ```

---

### Adım 2: Model Dosyasını Oluşturma
`models/<feature_name>_model.dart` dosyasını `copyWith`, `fromJson`, `toJson` metotlarını içerecek şekilde `@immutable` olarak tanımla:

```dart
import 'package:flutter/foundation.dart';

@immutable
class WaterTrackerModel {
  final int currentWater;
  final int dailyGoalWater;

  const WaterTrackerModel({
    required this.currentWater,
    required this.dailyGoalWater,
  });

  factory WaterTrackerModel.initial() {
    return const WaterTrackerModel(
      currentWater: 0,
      dailyGoalWater: 2000,
    );
  }

  WaterTrackerModel copyWith({
    int? currentWater,
    int? dailyGoalWater,
  }) {
    return WaterTrackerModel(
      currentWater: currentWater ?? this.currentWater,
      dailyGoalWater: dailyGoalWater ?? this.dailyGoalWater,
    );
  }

  factory WaterTrackerModel.fromJson(Map<String, dynamic> json) {
    return WaterTrackerModel(
      currentWater: json['currentWater'] as int? ?? 0,
      dailyGoalWater: json['dailyGoalWater'] as int? ?? 2000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentWater': currentWater,
      'dailyGoalWater': dailyGoalWater,
    };
  }
}
```

---

### Adım 3: Controller Dosyasını Yaz
`controllers/<feature_name>_controller.dart` içinde iş mantığını ve `ValueNotifier` tanımlarını oluştur:

```dart
import 'package:flutter/foundation.dart';
import '../models/<feature_name>_model.dart';

class WaterTrackerController {
  final ValueNotifier<WaterTrackerModel> state =
      ValueNotifier<WaterTrackerModel>(WaterTrackerModel.initial());

  void addWater(int amount) {
    if (amount <= 0) return;
    final current = state.value;
    state.value = current.copyWith(
      currentWater: current.currentWater + amount,
    );
  }

  void resetWater() {
    final current = state.value;
    state.value = current.copyWith(currentWater: 0);
  }

  void dispose() {
    state.dispose();
  }
}
```

---

### Adım 4: Modüler Widget Bileşenini Oluşturma
`widgets/<feature_name>_card.dart` dosyasında `StatelessWidget` kullanarak 40 satırı geçmeyen, yeniden kullanılabilir görsel kartı oluştur:

```dart
import 'package:flutter/material.dart';
import '../models/<feature_name>_model.dart';

class WaterTrackerCard extends StatelessWidget {
  final WaterTrackerModel model;

  const WaterTrackerCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.water_drop, color: theme.colorScheme.primary, size: 36),
            const SizedBox(height: 8),
            Text(
              '${model.currentWater} / ${model.dailyGoalWater} ml',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Adım 5: View Dosyasını Oluşturma
`view/<feature_name>_view.dart` dosyasında `StatelessWidget` ve `ValueListenableBuilder` kullanarak reaktif ekranı kur:

```dart
import 'package:flutter/material.dart';
import '../controllers/<feature_name>_controller.dart';
import '../models/<feature_name>_model.dart';
import '../widgets/<feature_name>_card.dart';

class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('susadım - Su Takibi'),
      ),
      body: ValueListenableBuilder<WaterTrackerModel>(
        valueListenable: controller.state,
        builder: (context, model, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WaterTrackerCard(model: model),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => controller.addWater(250),
                  child: const Text('250 ml Ekle'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

## Clean Architecture ve Kalite Standartları
- **Separation of Concerns:** Model veriyi, Controller mantığı, View ve Widget sadece arayüzü yönetir.
- **Testability:** Controller saf Dart nesnesi olduğu için `flutter test` ile `BuildContext` gerektirmeden bağımsız test edilebilir.
- **Reusability:** Alt widget'lar parametrik çalışır; uygulamanın başka ekranlarında da kullanılabilir.

---

## Sık Sorulan Sorular (SSS)

### Soru: Neden Bloc veya Riverpod yerine ValueNotifier kullanıyoruz?
**Cevap:** Proje ilkelerimiz gereği harici bağımlılıkları minimumda tutmak, ikili paket çakışmalarını önlemek ve Flutter'ın yerel mimarisinin sunduğu yüksek performans ile sıfır ek maliyetten yararlanmak için `ValueNotifier` tercih edilmiştir.

### Soru: Bir build metodunun 40 satırı geçmesi durumunda ne yapılmalı?
**Cevap:** İlgili arayüz bloğu mantıksal parçalara ayrılarak `widgets/` klasörü altına `StatelessWidget` ve `const` kurucu ile yeni bir dosya olarak taşınmalıdır.
