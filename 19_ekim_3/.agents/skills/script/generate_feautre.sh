#!/usr/bin/env bash
# ==============================================================================
# SUSADIM - FEATURE SCAFFOLD GENERATOR
# project.md ve SKILL.md mimari kurallarına uygun modüler klasör ve kod üretici.
#
# Kurallar:
# 1. Feature-based ayrım: controllers/, models/, view/, widgets/
# 2. Reaktif State: ValueNotifier & ValueListenableBuilder (harici paket yok)
# 3. UI Standartları: const kurucular, build metodları <= 40 satır
# 4. Model Standartları: Immutable, copyWith, fromJson, toJson
# 5. Test Desteği: test/features/<feature_name>/ birim test iskeleti
# ==============================================================================

set -euo pipefail

# Renk tanımları
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Argüman kontrolü
FEATURE_NAME="${1:-}"

if [ -z "$FEATURE_NAME" ]; then
  echo -e "${YELLOW}Kullanım:${NC} $0 <feature_name>"
  echo -e "Örnek: $0 water_tracker"
  echo -e "Örnek: $0 workout"
  echo -n "Lütfen oluşturulacak feature adını girin (snake_case): "
  read -r FEATURE_NAME
fi

# Geçerlilik kontrolü (yalnızca küçük harf ve alt çizgi)
if [[ ! "$FEATURE_NAME" =~ ^[a-z0-9_]+$ ]]; then
  echo -e "${RED}Hata:${NC} Feature adı sadece küçük harf, rakam ve alt çizgi (_) içermelidir (örn: water_tracker)"
  exit 1
fi

# snake_case -> PascalCase dönüşümü
PASCAL_NAME=$(echo "$FEATURE_NAME" | awk -F '_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1' OFS='')

# Klasör yolları
TARGET_DIR="lib/features/${FEATURE_NAME}"
TEST_DIR="test/features/${FEATURE_NAME}"

CONTROLLER_DIR="${TARGET_DIR}/controllers"
MODEL_DIR="${TARGET_DIR}/models"
VIEW_DIR="${TARGET_DIR}/view"
WIDGET_DIR="${TARGET_DIR}/widgets"

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}Susadım Modüler Feature Üreticisi Başlatılıyor:${NC} ${GREEN}${FEATURE_NAME}${NC} (${PASCAL_NAME})"
echo -e "${CYAN}================================================================${NC}"

# Klasörleri oluştur
mkdir -p "$CONTROLLER_DIR" "$MODEL_DIR" "$VIEW_DIR" "$WIDGET_DIR" "$TEST_DIR"
echo -e "  [+] Klasörler hazırlandı: ${TARGET_DIR}"

# 1. MODEL DOSYASI
MODEL_FILE="${MODEL_DIR}/${FEATURE_NAME}_model.dart"
cat <<EOF > "$MODEL_FILE"
import 'package:flutter/foundation.dart';

/// ${PASCAL_NAME} değişmez (immutable) veri modeli
@immutable
class ${PASCAL_NAME}Model {
  final String id;
  final String title;
  final int value;
  final bool isActive;
  final DateTime updatedAt;

  const ${PASCAL_NAME}Model({
    required this.id,
    required this.title,
    required this.value,
    required this.isActive,
    required this.updatedAt,
  });

  factory ${PASCAL_NAME}Model.initial() {
    return ${PASCAL_NAME}Model(
      id: '',
      title: 'Varsayılan ${PASCAL_NAME}',
      value: 0,
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  ${PASCAL_NAME}Model copyWith({
    String? id,
    String? title,
    int? value,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return ${PASCAL_NAME}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      value: json['value'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'isActive': isActive,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
EOF
echo -e "  [+] Model oluşturuldu: ${MODEL_FILE}"

# 2. CONTROLLER DOSYASI
CONTROLLER_FILE="${CONTROLLER_DIR}/${FEATURE_NAME}_controller.dart"
cat <<EOF > "$CONTROLLER_FILE"
import 'package:flutter/foundation.dart';
import '../models/${FEATURE_NAME}_model.dart';

/// ${PASCAL_NAME} reaktif durum yöneticisi (ValueNotifier tabanlı)
class ${PASCAL_NAME}Controller {
  final ValueNotifier<${PASCAL_NAME}Model> state =
      ValueNotifier<${PASCAL_NAME}Model>(${PASCAL_NAME}Model.initial());

  /// Değeri artır
  void increment(int amount) {
    if (amount <= 0) return;
    final current = state.value;
    state.value = current.copyWith(
      value: current.value + amount,
      updatedAt: DateTime.now(),
    );
  }

  /// Aktiflik durumunu değiştir
  void toggleActive() {
    final current = state.value;
    state.value = current.copyWith(
      isActive: !current.isActive,
      updatedAt: DateTime.now(),
    );
  }

  /// Sıfırla
  void reset() {
    state.value = ${PASCAL_NAME}Model.initial();
  }

  /// Bellek sızıntısını önlemek için dinleyicileri serbest bırak
  void dispose() {
    state.dispose();
  }
}
EOF
echo -e "  [+] Controller oluşturuldu: ${CONTROLLER_FILE}"

# 3. WIDGET DOSYASI
WIDGET_FILE="${WIDGET_DIR}/${FEATURE_NAME}_card.dart"
cat <<EOF > "$WIDGET_FILE"
import 'package:flutter/material.dart';
import '../models/${FEATURE_NAME}_model.dart';

/// ${PASCAL_NAME} modüler alt kart bileşeni (<= 40 satır)
class ${PASCAL_NAME}Card extends StatelessWidget {
  final ${PASCAL_NAME}Model model;
  final VoidCallback onToggle;

  const ${PASCAL_NAME}Card({
    super.key,
    required this.model,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.fitness_center_rounded, color: theme.colorScheme.primary),
        ),
        title: Text(model.title, style: theme.textTheme.titleMedium),
        subtitle: Text('Değer: \${model.value}', style: theme.textTheme.bodyMedium),
        trailing: IconButton(
          icon: Icon(
            model.isActive ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: model.isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
EOF
echo -e "  [+] Alt Widget oluşturuldu: ${WIDGET_FILE}"

# 4. VIEW DOSYASI
VIEW_FILE="${VIEW_DIR}/${FEATURE_NAME}_view.dart"
cat <<EOF > "$VIEW_FILE"
import 'package:flutter/material.dart';
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../models/${FEATURE_NAME}_model.dart';
import '../widgets/${FEATURE_NAME}_card.dart';

/// ${PASCAL_NAME} ana ekranı (StatelessWidget - Clean UI)
class ${PASCAL_NAME}View extends StatelessWidget {
  final ${PASCAL_NAME}Controller controller;

  const ${PASCAL_NAME}View({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_NAME}'),
        actions: [
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.reset,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<${PASCAL_NAME}Model>(
          valueListenable: controller.state,
          builder: (context, model, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ${PASCAL_NAME}Card(
                    model: model,
                    onToggle: controller.toggleActive,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => controller.increment(10),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Değer Ekle (+10)'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
EOF
echo -e "  [+] View oluşturuldu: ${VIEW_FILE}"

# 5. TEST DOSYASI
TEST_FILE="${TEST_DIR}/${FEATURE_NAME}_controller_test.dart"
cat <<EOF > "$TEST_FILE"
import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/${FEATURE_NAME}/controllers/${FEATURE_NAME}_controller.dart';

void main() {
  group('${PASCAL_NAME}Controller Testleri', () {
    late ${PASCAL_NAME}Controller controller;

    setUp(() {
      controller = ${PASCAL_NAME}Controller();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Başlangıç durumu varsayılan değerlerle açılmalıdır', () {
      expect(controller.state.value.value, 0);
      expect(controller.state.value.isActive, true);
    });

    test('increment metodu değeri reaktif olarak artırmalıdır', () {
      controller.increment(15);
      expect(controller.state.value.value, 15);
    });

    test('toggleActive metodu aktiflik durumunu tersine çevirmelidir', () {
      controller.toggleActive();
      expect(controller.state.value.isActive, false);
      controller.toggleActive();
      expect(controller.state.value.isActive, true);
    });
  });
}
EOF
echo -e "  [+] Birim Test oluşturuldu: ${TEST_FILE}"

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}✓ Feature başarıyla üretildi!${NC}"
echo -e "Sonraki Adımlar:"
echo -e "  1. 'flutter analyze' ile statik kod analizini yap (0 uyarı, 0 hata şart)."
echo -e "  2. 'flutter test' ile birim testlerini çalıştır."
echo -e "${GREEN}================================================================${NC}"
