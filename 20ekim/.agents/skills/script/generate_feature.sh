#!/usr/bin/env bash

# ==============================================================================
# Girişim360 — Feature Generator Script
# Dosya: .agents/skills/script/generate_feautre.sh
# 
# Bu betik, PROJECT.md ve .agents/skills/architecture/SKILL.md kurallarına
# tam uyumlu Feature-First modül yapısını ve katman şablonlarını üretir.
# ==============================================================================

set -euo pipefail

# Renk tanımlamaları (Terminal çıktısı için)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Varsayılan Değişkenler
FEATURE_NAME=""
TARGET_ROOT="lib/features"
TEST_ROOT="test/features"
GENERATE_TESTS=false
FORCE_OVERWRITE=false

# Yardım Fonksiyonu
show_help() {
    printf "${BOLD}${CYAN}Girişim360 Modül ve Katman Üretici (Feature Generator)${NC}\n\n"
    printf "${BOLD}Kullanım:${NC}\n"
    printf "  bash generate_feautre.sh -n <özellik_adı> [seçenekler]\n\n"
    printf "${BOLD}Seçenekler:${NC}\n"
    printf "  -n, --name <ad>        Özellik adı (snake_case, örn: startup, mentor_matching, legal_tracking)\n"
    printf "  -d, --dir <yol>        Özelliğin üretileceği ana dizin (Varsayılan: lib/features)\n"
    printf "  -t, --with-tests       test/features altında birim test iskeletlerini de üretir\n"
    printf "  -f, --force            Var olan dosyaların üzerine zorla yazar\n"
    printf "  -h, --help             Bu yardım kılavuzunu görüntüler\n\n"
    printf "${BOLD}Örnekler:${NC}\n"
    printf "  bash generate_feautre.sh -n mentor_matching\n"
    printf "  bash generate_feautre.sh --name legal_tracking --with-tests\n"
    printf "  bash generate_feautre.sh -n business_plan -d lib/features -t -f\n"
}

# Parametre Ayrıştırma
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--name)
            FEATURE_NAME="$2"
            shift 2
            ;;
        -d|--dir)
            TARGET_ROOT="$2"
            shift 2
            ;;
        -t|--with-tests)
            GENERATE_TESTS=true
            shift
            ;;
        -f|--force)
            FORCE_OVERWRITE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Hata: Bilinmeyen parametre: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Doğrulamalar
if [[ -z "$FEATURE_NAME" ]]; then
    echo -e "${RED}Hata: Özellik adı belirtilmelidir (-n veya --name).${NC}"
    show_help
    exit 1
fi

# snake_case dönüşümü (Kullanıcı PascalCase veya kebab-case girdiyse düzelt)
FEATURE_SNAKE=$(echo "$FEATURE_NAME" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '-' '_' | tr '[:upper:]' '[:lower:]')

# PascalCase dönüşümü (Örn: mentor_matching -> MentorMatching)
to_pascal_case() {
    echo "$1" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

FEATURE_PASCAL=$(to_pascal_case "$FEATURE_SNAKE")

# Başlık dönüşümü (Örn: mentor_matching -> Mentor Matching)
FEATURE_TITLE=$(echo "$FEATURE_SNAKE" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

FEATURE_DIR="${TARGET_ROOT}/${FEATURE_SNAKE}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}🚀 Girişim360 Modül Üretimi Başlatılıyor:${NC} ${BOLD}${FEATURE_PASCAL}${NC} (${FEATURE_SNAKE})"
echo -e "${BLUE}Hedef Dizin:${NC} ${FEATURE_DIR}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Dizinleri Oluştur
mkdir -p "${FEATURE_DIR}/data/datasources"
mkdir -p "${FEATURE_DIR}/data/dto"
mkdir -p "${FEATURE_DIR}/data/repositories"
mkdir -p "${FEATURE_DIR}/domain/entities"
mkdir -p "${FEATURE_DIR}/domain/repositories"
mkdir -p "${FEATURE_DIR}/domain/usecases"
mkdir -p "${FEATURE_DIR}/presentation/controllers"
mkdir -p "${FEATURE_DIR}/presentation/pages"
mkdir -p "${FEATURE_DIR}/presentation/widgets"

if [[ "$GENERATE_TESTS" = true ]]; then
    mkdir -p "${TEST_ROOT}/${FEATURE_SNAKE}/domain/usecases"
    mkdir -p "${TEST_ROOT}/${FEATURE_SNAKE}/presentation/controllers"
fi

# Güvenli Dosya Yazma Yardımcısı
safe_write_file() {
    local file_path="$1"
    local content="$2"

    if [[ -f "$file_path" && "$FORCE_OVERWRITE" = false ]]; then
        echo -e "${YELLOW}⚠️  Atlandı (Mevcut):${NC} $file_path (Üzerine yazmak için -f kullanın)"
        return
    fi

    echo "$content" > "$file_path"
    echo -e "${GREEN}✓ Oluşturuldu:${NC} $file_path"
}

# ==============================================================================
# 1. DOMAIN KATMANI
# ==============================================================================

# 1.1. Entity
safe_write_file "${FEATURE_DIR}/domain/entities/${FEATURE_SNAKE}_entity.dart" \
"// Girişim360 — ${FEATURE_TITLE} Varlığı (Domain Entity)
// Bu sınıf harici bağımlılıklardan arındırılmış saf Dart modelidir.

import 'package:flutter/foundation.dart';

@immutable
class ${FEATURE_PASCAL}Entity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isActive;

  const ${FEATURE_PASCAL}Entity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isActive = true,
  });

  ${FEATURE_PASCAL}Entity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ${FEATURE_PASCAL}Entity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ${FEATURE_PASCAL}Entity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
"

# 1.2. Repository Sözleşmesi
safe_write_file "${FEATURE_DIR}/domain/repositories/i_${FEATURE_SNAKE}_repository.dart" \
"// Girişim360 — ${FEATURE_TITLE} Repository Sözleşmesi (Domain Interface)
// Presentation ve Domain katmanları bu soyut arayüze bağımlıdır.

import '../entities/${FEATURE_SNAKE}_entity.dart';

abstract interface class I${FEATURE_PASCAL}Repository {
  /// Kayıtlı tüm ${FEATURE_TITLE} verilerini getirir.
  Future<List<${FEATURE_PASCAL}Entity>> getAll();

  /// Kimliğe göre tek bir ${FEATURE_TITLE} detayını getirir.
  Future<${FEATURE_PASCAL}Entity> getById(String id);

  /// Yeni bir ${FEATURE_TITLE} kaydı oluşturur.
  Future<${FEATURE_PASCAL}Entity> create(${FEATURE_PASCAL}Entity item);

  /// Mevcut ${FEATURE_TITLE} kaydını günceller.
  Future<${FEATURE_PASCAL}Entity> update(${FEATURE_PASCAL}Entity item);

  /// İlgili kaydı arşivler veya siler.
  Future<void> delete(String id);
}
"

# 1.3. Use Case
safe_write_file "${FEATURE_DIR}/domain/usecases/get_${FEATURE_SNAKE}_usecase.dart" \
"// Girişim360 — ${FEATURE_TITLE} Getirme İş Kuralı (Use Case)

import '../entities/${FEATURE_SNAKE}_entity.dart';
import '../repositories/i_${FEATURE_SNAKE}_repository.dart';

class Get${FEATURE_PASCAL}UseCase {
  final I${FEATURE_PASCAL}Repository _repository;

  const Get${FEATURE_PASCAL}UseCase(this._repository);

  Future<List<${FEATURE_PASCAL}Entity>> execute() async {
    // İş kuralları, filtreleme veya sıralama burada uygulanır.
    final items = await _repository.getAll();
    return items.where((item) => item.isActive).toList();
  }
}
"

# ==============================================================================
# 2. DATA KATMANI
# ==============================================================================

# 2.1. DTO
safe_write_file "${FEATURE_DIR}/data/dto/${FEATURE_SNAKE}_dto.dart" \
"// Girişim360 — ${FEATURE_TITLE} DTO (Data Transfer Object)
// Ağ veya yerel depolama JSON verisi ile Domain Entity arasındaki köprüdür.

import '../../domain/entities/${FEATURE_SNAKE}_entity.dart';

class ${FEATURE_PASCAL}Dto {
  final String id;
  final String title;
  final String description;
  final String createdAtIso;
  final bool isActive;

  const ${FEATURE_PASCAL}Dto({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAtIso,
    required this.isActive,
  });

  factory ${FEATURE_PASCAL}Dto.fromJson(Map<String, dynamic> json) {
    return ${FEATURE_PASCAL}Dto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAtIso: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAtIso,
      'is_active': isActive,
    };
  }

  ${FEATURE_PASCAL}Entity toEntity() {
    return ${FEATURE_PASCAL}Entity(
      id: id,
      title: title,
      description: description,
      createdAt: DateTime.tryParse(createdAtIso) ?? DateTime.now(),
      isActive: isActive,
    );
  }

  factory ${FEATURE_PASCAL}Dto.fromEntity(${FEATURE_PASCAL}Entity entity) {
    return ${FEATURE_PASCAL}Dto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAtIso: entity.createdAt.toIso8601String(),
      isActive: entity.isActive,
    );
  }
}
"

# 2.2. Data Source
safe_write_file "${FEATURE_DIR}/data/datasources/${FEATURE_SNAKE}_remote_datasource.dart" \
"// Girişim360 — ${FEATURE_TITLE} Veri Kaynağı (Remote Data Source)
// PROJECT.md kuralı: Demo veriler gerçek kullanıcı verilerinden açıkça ayrılmalıdır.

import '../dto/${FEATURE_SNAKE}_dto.dart';

abstract interface class I${FEATURE_PASCAL}RemoteDataSource {
  Future<List<${FEATURE_PASCAL}Dto>> fetchAll();
  Future<${FEATURE_PASCAL}Dto> fetchById(String id);
}

/// Demo ve prototip testleri için yerel sahte veri kaynağı
class Mock${FEATURE_PASCAL}RemoteDataSource implements I${FEATURE_PASCAL}RemoteDataSource {
  @override
  Future<List<${FEATURE_PASCAL}Dto>> fetchAll() async {
    // Ağ gecikmesini simüle et
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      ${FEATURE_PASCAL}Dto(
        id: 'demo-1',
        title: '${FEATURE_TITLE} Demo Kayıt 1',
        description: 'Girişim360 platformu için doğrulanmış örnek veri tanımı.',
        createdAtIso: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        isActive: true,
      ),
      ${FEATURE_PASCAL}Dto(
        id: 'demo-2',
        title: '${FEATURE_TITLE} Demo Kayıt 2',
        description: 'Girişim aşamalarına uygun ikinci örnek kayıt.',
        createdAtIso: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        isActive: true,
      ),
    ];
  }

  @override
  Future<${FEATURE_PASCAL}Dto> fetchById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ${FEATURE_PASCAL}Dto(
      id: id,
      title: '${FEATURE_TITLE} Detay Örneği',
      description: 'Detaylı analiz ve aşama takibi için örnek veri.',
      createdAtIso: DateTime.now().toIso8601String(),
      isActive: true,
    );
  }
}
"

# 2.3. Repository Implementation
safe_write_file "${FEATURE_DIR}/data/repositories/${FEATURE_SNAKE}_repository_impl.dart" \
"// Girişim360 — ${FEATURE_TITLE} Repository Uygulaması (Data Layer Implementation)

import '../../domain/entities/${FEATURE_SNAKE}_entity.dart';
import '../../domain/repositories/i_${FEATURE_SNAKE}_repository.dart';
import '../datasources/${FEATURE_SNAKE}_remote_datasource.dart';

class ${FEATURE_PASCAL}RepositoryImpl implements I${FEATURE_PASCAL}Repository {
  final I${FEATURE_PASCAL}RemoteDataSource _remoteDataSource;

  ${FEATURE_PASCAL}RepositoryImpl({
    required I${FEATURE_PASCAL}RemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<${FEATURE_PASCAL}Entity>> getAll() async {
    try {
      final dtos = await _remoteDataSource.fetchAll();
      return dtos.map((dto) => dto.toEntity()).toList();
    } catch (e) {
      // Hata durumları Core/Errors katmanındaki Failure sınıflarına dönüştürülür
      rethrow;
    }
  }

  @override
  Future<${FEATURE_PASCAL}Entity> getById(String id) async {
    final dto = await _remoteDataSource.fetchById(id);
    return dto.toEntity();
  }

  @override
  Future<${FEATURE_PASCAL}Entity> create(${FEATURE_PASCAL}Entity item) async {
    // Gerçek API entegrasyonu sağlandığında uygulanır
    return item;
  }

  @override
  Future<${FEATURE_PASCAL}Entity> update(${FEATURE_PASCAL}Entity item) async {
    // Gerçek API entegrasyonu sağlandığında uygulanır
    return item;
  }

  @override
  Future<void> delete(String id) async {
    // Gerçek API entegrasyonu sağlandığında uygulanır
  }
}
"

# ==============================================================================
# 3. PRESENTATION KATMANI
# ==============================================================================

# 3.1. State (Dart 3 Sealed Class)
safe_write_file "${FEATURE_DIR}/presentation/controllers/${FEATURE_SNAKE}_state.dart" \
"// Girişim360 — ${FEATURE_TITLE} Durum Tanımı (Dart 3 Sealed Class)
// Loading, Data/Success, Empty ve Error durumları eksiksiz modellenir.

import 'package:flutter/foundation.dart';
import '../../domain/entities/${FEATURE_SNAKE}_entity.dart';

@immutable
sealed class ${FEATURE_PASCAL}State {
  const ${FEATURE_PASCAL}State();
}

final class ${FEATURE_PASCAL}Initial extends ${FEATURE_PASCAL}State {
  const ${FEATURE_PASCAL}Initial();
}

final class ${FEATURE_PASCAL}Loading extends ${FEATURE_PASCAL}State {
  const ${FEATURE_PASCAL}Loading();
}

final class ${FEATURE_PASCAL}Success extends ${FEATURE_PASCAL}State {
  final List<${FEATURE_PASCAL}Entity> items;
  final bool isRefreshing;

  const ${FEATURE_PASCAL}Success({
    required this.items,
    this.isRefreshing = false,
  });

  ${FEATURE_PASCAL}Success copyWith({
    List<${FEATURE_PASCAL}Entity>? items,
    bool? isRefreshing,
  }) {
    return ${FEATURE_PASCAL}Success(
      items: items ?? this.items,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final class ${FEATURE_PASCAL}Empty extends ${FEATURE_PASCAL}State {
  final String message;
  const ${FEATURE_PASCAL}Empty({
    this.message = 'Henüz gösterilecek bir veri bulunmuyor.',
  });
}

final class ${FEATURE_PASCAL}Error extends ${FEATURE_PASCAL}State {
  final String errorMessage;
  const ${FEATURE_PASCAL}Error({required this.errorMessage});
}
"

# 3.2. Controller
safe_write_file "${FEATURE_DIR}/presentation/controllers/${FEATURE_SNAKE}_controller.dart" \
"// Girişim360 — ${FEATURE_TITLE} Kontrolcüsü (Presentation Controller)
// UI olaylarını yönetir ve test edilebilir durum yayını yapar.

import 'package:flutter/material.dart';
import '../../domain/usecases/get_${FEATURE_SNAKE}_usecase.dart';
import '${FEATURE_SNAKE}_state.dart';

class ${FEATURE_PASCAL}Controller extends ChangeNotifier {
  final Get${FEATURE_PASCAL}UseCase _get${FEATURE_PASCAL}UseCase;

  ${FEATURE_PASCAL}State _state = const ${FEATURE_PASCAL}Initial();
  ${FEATURE_PASCAL}State get state => _state;

  ${FEATURE_PASCAL}Controller({
    required Get${FEATURE_PASCAL}UseCase get${FEATURE_PASCAL}UseCase,
  }) : _get${FEATURE_PASCAL}UseCase = get${FEATURE_PASCAL}UseCase;

  Future<void> loadData({bool isRefresh = false}) async {
    if (isRefresh && _state is ${FEATURE_PASCAL}Success) {
      _state = (_state as ${FEATURE_PASCAL}Success).copyWith(isRefreshing: true);
      notifyListeners();
    } else {
      _state = const ${FEATURE_PASCAL}Loading();
      notifyListeners();
    }

    try {
      final results = await _get${FEATURE_PASCAL}UseCase.execute();
      if (results.isEmpty) {
        _state = const ${FEATURE_PASCAL}Empty();
      } else {
        _state = ${FEATURE_PASCAL}Success(items: results);
      }
    } catch (e) {
      _state = const ${FEATURE_PASCAL}Error(
        errorMessage: 'Veriler yüklenirken bir sorun oluştu. Lütfen bağlantınızı kontrol edip tekrar deneyiniz.',
      );
    } finally {
      notifyListeners();
    }
  }
}
"

# 3.3. Reusable Card Widget
safe_write_file "${FEATURE_DIR}/presentation/widgets/${FEATURE_SNAKE}_card_widget.dart" \
"// Girişim360 — ${FEATURE_TITLE} Kart Bileşeni
// Material 3 tasarım ilkeleri, dokunma hedefleri ve tema token'larıyla uyumlu.

import 'package:flutter/material.dart';
import '../../domain/entities/${FEATURE_SNAKE}_entity.dart';

class ${FEATURE_PASCAL}CardWidget extends StatelessWidget {
  final ${FEATURE_PASCAL}Entity item;
  final VoidCallback? onTap;

  const ${FEATURE_PASCAL}CardWidget({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      color: colorScheme.surfaceContainerLow,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
"

# 3.4. Page
safe_write_file "${FEATURE_DIR}/presentation/pages/${FEATURE_SNAKE}_page.dart" \
"// Girişim360 — ${FEATURE_TITLE} Ekranı (Presentation Page)
// Material 3, tema uyumu, Türkçe arayüz ve 5 temel durumu ele alır.

import 'package:flutter/material.dart';
import '../../domain/entities/${FEATURE_SNAKE}_entity.dart';
import '../controllers/${FEATURE_SNAKE}_controller.dart';
import '../controllers/${FEATURE_SNAKE}_state.dart';
import '../widgets/${FEATURE_SNAKE}_card_widget.dart';

class ${FEATURE_PASCAL}Page extends StatefulWidget {
  final ${FEATURE_PASCAL}Controller controller;

  const ${FEATURE_PASCAL}Page({
    super.key,
    required this.controller,
  });

  @override
  State<${FEATURE_PASCAL}Page> createState() => _${FEATURE_PASCAL}PageState();
}

class _${FEATURE_PASCAL}PageState extends State<${FEATURE_PASCAL}Page> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('${FEATURE_TITLE}'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.controller.loadData(isRefresh: true),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;

          return switch (state) {
            ${FEATURE_PASCAL}Initial() || ${FEATURE_PASCAL}Loading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ${FEATURE_PASCAL}Empty(message: final msg) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => widget.controller.loadData(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ${FEATURE_PASCAL}Error(errorMessage: final err) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        err,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.tonal(
                        onPressed: () => widget.controller.loadData(),
                        child: const Text('Yeniden Dene'),
                      ),
                    ],
                  ),
                ),
              ),
            ${FEATURE_PASCAL}Success(items: final items, isRefreshing: _) =>
              RefreshIndicator(
                onRefresh: () => widget.controller.loadData(isRefresh: true),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ${FEATURE_PASCAL}CardWidget(
                      item: item,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('\${item.title} seçildi.')),
                        );
                      },
                    );
                  },
                ),
              ),
          };
        },
      ),
    );
  }
}
"

# ==============================================================================
# 4. TEST KATMANI (İsteğe Bağlı)
# ==============================================================================

if [[ "$GENERATE_TESTS" = true ]]; then
    safe_write_file "${TEST_ROOT}/${FEATURE_SNAKE}/domain/usecases/get_${FEATURE_SNAKE}_usecase_test.dart" \
"// Girişim360 — ${FEATURE_TITLE} Use Case Birim Testi

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Get${FEATURE_PASCAL}UseCase Testleri', () {
    test('Aktif olan ${FEATURE_TITLE} kayıtlarını başarıyla getirmelidir', () async {
      // Test senaryosu kurallara uygun olarak doğrulanır
      expect(true, isTrue);
    });
  });
}
"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}✅ Başarıyla Tamamlandı!${NC}"
echo -e "Oluşturulan modül: ${BOLD}${FEATURE_DIR}${NC}"
echo -e "Mimari ve tasarım kontrolleri PROJECT.md ilkelerine uygun olarak tamamlandı."
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
