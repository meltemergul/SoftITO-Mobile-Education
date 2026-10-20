#!/usr/bin/env bash

# ==============================================================================
# Movira — Modül ve Katman Üretici Betiği (Feature Generator Script)
# Dosya: .agents/skills/scripts/generate_feautre.sh
# 
# Bu betik; PROJECT.md, .agents/skills/architecture/SKILL.md, design/SKILL.md ve
# references/state_flow.md kurallarına tam uyumlu Feature-First modül yapısını,
# katman şablonlarını ve isteğe bağlı test iskeletlerini üretir.
# ==============================================================================

set -euo pipefail

# Terminal Renkleri
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

# Yardım Kılavuzu
show_help() {
    printf "${BOLD}${CYAN}Movira Modül ve Katman Üretici (Feature Generator)${NC}\n\n"
    printf "${BOLD}Kullanım:${NC}\n"
    printf "  bash generate_feautre.sh -n <özellik_adı> [seçenekler]\n\n"
    printf "${BOLD}Seçenekler:${NC}\n"
    printf "  -n, --name <ad>        Özellik adı (snake_case, örn: vehicles, listings, offers, rentals, messaging, reviews, galleries, auth)\n"
    printf "  -d, --dir <yol>        Özelliğin üretileceği ana dizin (Varsayılan: lib/features)\n"
    printf "  -t, --with-tests       test/features altında birim test iskeletlerini de üretir\n"
    printf "  -f, --force            Var olan dosyaların üzerine zorla yazar\n"
    printf "  -h, --help             Bu yardım kılavuzunu görüntüler\n\n"
    printf "${BOLD}Örnekler:${NC}\n"
    printf "  bash .agents/skills/scripts/generate_feautre.sh -n vehicles\n"
    printf "  bash .agents/skills/scripts/generate_feautre.sh --name offers --with-tests\n"
    printf "  bash .agents/skills/scripts/generate_feautre.sh -n rentals -d lib/features -t -f\n"
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
            printf "${RED}Bilinmeyen seçenek: $1${NC}\n"
            show_help
            exit 1
            ;;
    esac
done

# Doğrulama: Özellik adı boş mu?
if [[ -z "$FEATURE_NAME" ]]; then
    printf "${RED}Hata: Lütfen '-n' veya '--name' ile bir özellik adı belirtiniz.${NC}\n"
    show_help
    exit 1
fi

# Doğrulama: snake_case kontrolü
if [[ ! "$FEATURE_NAME" =~ ^[a-z0-9_]+$ ]]; then
    printf "${RED}Hata: Özellik adı küçük harf ve alt tire ile yazılmalıdır (snake_case). Örn: 'rental_offer', 'vehicle_details'${NC}\n"
    exit 1
fi

# İsim Dönüşümleri (snake_case -> PascalCase)
to_pascal_case() {
    echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

PASCAL_NAME=$(to_pascal_case "$FEATURE_NAME")

FEATURE_DIR="$TARGET_ROOT/$FEATURE_NAME"
TEST_FEATURE_DIR="$TEST_ROOT/$FEATURE_NAME"

printf "${CYAN}==> Movira Özellik Modülü Başlatılıyor: ${BOLD}$FEATURE_NAME ($PASCAL_NAME)${NC}\n"
printf "Hedef Dizin: $FEATURE_DIR\n\n"

# Dizin Yapısını Oluşturma
mkdir -p "$FEATURE_DIR/domain/entities"
mkdir -p "$FEATURE_DIR/domain/repositories"
mkdir -p "$FEATURE_DIR/domain/usecases"

mkdir -p "$FEATURE_DIR/data/datasources"
mkdir -p "$FEATURE_DIR/data/models"
mkdir -p "$FEATURE_DIR/data/repositories"

mkdir -p "$FEATURE_DIR/presentation/controllers"
mkdir -p "$FEATURE_DIR/presentation/pages"
mkdir -p "$FEATURE_DIR/presentation/widgets"

# Dosya Kontrol Yardımcısı
check_target_file() {
    local target_file="$1"
    if [[ -f "$target_file" && "$FORCE_OVERWRITE" == false ]]; then
        printf "  ${YELLOW}Zaten var (atlandı):${NC} $target_file\n"
        return 1
    fi
    printf "  ${GREEN}Oluşturuldu:${NC} $target_file\n"
    return 0
}

# ------------------------------------------------------------------------------
# 1. DOMAIN KATMANI
# ------------------------------------------------------------------------------

# 1.1 Entity
TARGET_FILE="$FEATURE_DIR/domain/entities/${FEATURE_NAME}_entity.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import 'package:flutter/foundation.dart';

/// Movira — __PASCAL_NAME__ Varlığı (Domain Katmanı)
/// PROJECT.md ve mimari kurallarına uygun saf Dart nesnesi.
@immutable
class __PASCAL_NAME__Entity {
  final String id;
  final String title;
  final DateTime createdAt;
  final bool isActive;

  const __PASCAL_NAME__Entity({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isActive = true,
  });

  __PASCAL_NAME__Entity copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return __PASCAL_NAME__Entity(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
EOF
fi

# 1.2 Repository Interface
TARGET_FILE="$FEATURE_DIR/domain/repositories/${FEATURE_NAME}_repository.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import '../entities/__FEATURE_NAME___entity.dart';

/// Hata Tanımları (Domain Failure)
sealed class __PASCAL_NAME__Failure {
  final String message;
  const __PASCAL_NAME__Failure(this.message);
}

final class __PASCAL_NAME__NetworkFailure extends __PASCAL_NAME__Failure {
  const __PASCAL_NAME__NetworkFailure([super.message = 'İnternet bağlantınızı kontrol edip tekrar deneyiniz.']);
}

final class __PASCAL_NAME__AuthFailure extends __PASCAL_NAME__Failure {
  const __PASCAL_NAME__AuthFailure([super.message = 'İşleme devam etmek için giriş yapınız (user-12345).']);
}

final class __PASCAL_NAME__ValidationFailure extends __PASCAL_NAME__Failure {
  const __PASCAL_NAME__ValidationFailure(super.message);
}

final class __PASCAL_NAME__ServerFailure extends __PASCAL_NAME__Failure {
  const __PASCAL_NAME__ServerFailure([super.message = 'Sunucu işlemi gerçekleştiremedi. Lütfen daha sonra tekrar deneyiniz.']);
}

/// Fonksiyonel Result Sarmalayıcısı
sealed class __PASCAL_NAME__Result<S, E extends __PASCAL_NAME__Failure> {
  const __PASCAL_NAME__Result();
}

final class __PASCAL_NAME__Success<S, E extends __PASCAL_NAME__Failure> extends __PASCAL_NAME__Result<S, E> {
  final S data;
  const __PASCAL_NAME__Success(this.data);
}

final class __PASCAL_NAME__Error<S, E extends __PASCAL_NAME__Failure> extends __PASCAL_NAME__Result<S, E> {
  final E failure;
  const __PASCAL_NAME__Error(this.failure);
}

/// Movira — __PASCAL_NAME__ Repository Sözleşmesi
abstract interface class __PASCAL_NAME__Repository {
  Future<__PASCAL_NAME__Result<List<__PASCAL_NAME__Entity>, __PASCAL_NAME__Failure>> get__PASCAL_NAME__List();
  Future<__PASCAL_NAME__Result<__PASCAL_NAME__Entity, __PASCAL_NAME__Failure>> get__PASCAL_NAME__ById(String id);
}
EOF
fi

# 1.3 Use Case
TARGET_FILE="$FEATURE_DIR/domain/usecases/get_${FEATURE_NAME}_list_usecase.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import '../entities/__FEATURE_NAME___entity.dart';
import '../repositories/__FEATURE_NAME___repository.dart';

/// Movira — __PASCAL_NAME__ Listesi Getirme Use Case
class Get__PASCAL_NAME__ListUseCase {
  final __PASCAL_NAME__Repository _repository;

  const Get__PASCAL_NAME__ListUseCase(this._repository);

  Future<__PASCAL_NAME__Result<List<__PASCAL_NAME__Entity>, __PASCAL_NAME__Failure>> call() async {
    return _repository.get__PASCAL_NAME__List();
  }
}
EOF
fi

# ------------------------------------------------------------------------------
# 2. DATA KATMANI
# ------------------------------------------------------------------------------

# 2.1 Model (DTO)
TARGET_FILE="$FEATURE_DIR/data/models/${FEATURE_NAME}_model.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import '../../domain/entities/__FEATURE_NAME___entity.dart';

/// Movira — __PASCAL_NAME__ Veri Aktarım Modeli (DTO)
class __PASCAL_NAME__Model extends __PASCAL_NAME__Entity {
  const __PASCAL_NAME__Model({
    required super.id,
    required super.title,
    required super.createdAt,
    super.isActive = true,
  });

  factory __PASCAL_NAME__Model.fromJson(Map<String, dynamic> json) {
    return __PASCAL_NAME__Model(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  __PASCAL_NAME__Entity toEntity() => this;
}
EOF
fi

# 2.2 Data Source Interface & Mock/Demo Implementation
TARGET_FILE="$FEATURE_DIR/data/datasources/${FEATURE_NAME}_remote_data_source.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import '../models/__FEATURE_NAME___model.dart';

/// Veri Kaynağı Arayüzü
abstract interface class __PASCAL_NAME__RemoteDataSource {
  Future<List<__PASCAL_NAME__Model>> fetch__PASCAL_NAME__List();
  Future<__PASCAL_NAME__Model> fetch__PASCAL_NAME__ById(String id);
}

/// Demo / Mock Veri Kaynağı Gerçeklemesi
/// (PROJECT.md: Gerçek backend entegrasyonu seçilene kadar varsayılan demo verisi)
class __PASCAL_NAME__RemoteDataSourceImpl implements __PASCAL_NAME__RemoteDataSource {
  @override
  Future<List<__PASCAL_NAME__Model>> fetch__PASCAL_NAME__List() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      __PASCAL_NAME__Model(
        id: '1',
        title: 'Movira __PASCAL_NAME__ Kaydı #1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
      ),
      __PASCAL_NAME__Model(
        id: '2',
        title: 'Movira __PASCAL_NAME__ Kaydı #2',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
      ),
    ];
  }

  @override
  Future<__PASCAL_NAME__Model> fetch__PASCAL_NAME__ById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return __PASCAL_NAME__Model(
      id: id,
      title: 'Movira __PASCAL_NAME__ Detayı ($id)',
      createdAt: DateTime.now(),
      isActive: true,
    );
  }
}
EOF
fi

# 2.3 Repository Implementation
TARGET_FILE="$FEATURE_DIR/data/repositories/${FEATURE_NAME}_repository_impl.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import '../../domain/entities/__FEATURE_NAME___entity.dart';
import '../../domain/repositories/__FEATURE_NAME___repository.dart';
import '../datasources/__FEATURE_NAME___remote_data_source.dart';

/// Movira — __PASCAL_NAME__ Repository Gerçeklemesi
class __PASCAL_NAME__RepositoryImpl implements __PASCAL_NAME__Repository {
  final __PASCAL_NAME__RemoteDataSource _remoteDataSource;

  const __PASCAL_NAME__RepositoryImpl(this._remoteDataSource);

  @override
  Future<__PASCAL_NAME__Result<List<__PASCAL_NAME__Entity>, __PASCAL_NAME__Failure>> get__PASCAL_NAME__List() async {
    try {
      final models = await _remoteDataSource.fetch__PASCAL_NAME__List();
      final entities = models.map((m) => m.toEntity()).toList();
      return __PASCAL_NAME__Success(entities);
    } catch (e) {
      return const __PASCAL_NAME__Error(__PASCAL_NAME__NetworkFailure('Veriler yüklenirken bağlantı hatası oluştu.'));
    }
  }

  @override
  Future<__PASCAL_NAME__Result<__PASCAL_NAME__Entity, __PASCAL_NAME__Failure>> get__PASCAL_NAME__ById(String id) async {
    try {
      final model = await _remoteDataSource.fetch__PASCAL_NAME__ById(id);
      return __PASCAL_NAME__Success(model.toEntity());
    } catch (e) {
      return const __PASCAL_NAME__Error(__PASCAL_NAME__ServerFailure('Kayıt bulunamadı veya sunucu hatası.'));
    }
  }
}
EOF
fi

# ------------------------------------------------------------------------------
# 3. PRESENTATION KATMANI
# ------------------------------------------------------------------------------

# 3.1 State
TARGET_FILE="$FEATURE_DIR/presentation/controllers/${FEATURE_NAME}_state.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import '../../domain/entities/__FEATURE_NAME___entity.dart';

/// Movira — __PASCAL_NAME__ UI Durumları (Dart 3 Sealed Class)
sealed class __PASCAL_NAME__State {
  const __PASCAL_NAME__State();
}

final class __PASCAL_NAME__Initial extends __PASCAL_NAME__State {
  const __PASCAL_NAME__Initial();
}

final class __PASCAL_NAME__Loading extends __PASCAL_NAME__State {
  const __PASCAL_NAME__Loading();
}

final class __PASCAL_NAME__Success extends __PASCAL_NAME__State {
  final List<__PASCAL_NAME__Entity> items;
  const __PASCAL_NAME__Success(this.items);
}

final class __PASCAL_NAME__Empty extends __PASCAL_NAME__State {
  final String message;
  const __PASCAL_NAME__Empty([this.message = 'Henüz kayıtlı veri bulunmuyor.']);
}

final class __PASCAL_NAME__Error extends __PASCAL_NAME__State {
  final String message;
  final bool canRetry;
  const __PASCAL_NAME__Error({required this.message, this.canRetry = true});
}
EOF
fi

# 3.2 Controller
TARGET_FILE="$FEATURE_DIR/presentation/controllers/${FEATURE_NAME}_controller.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import 'package:flutter/foundation.dart';
import '../../domain/repositories/__FEATURE_NAME___repository.dart';
import '../../domain/usecases/get___FEATURE_NAME___list_usecase.dart';
import '__FEATURE_NAME___state.dart';

/// Movira — __PASCAL_NAME__ Controller (ValueNotifier Tabanlı)
class __PASCAL_NAME__Controller extends ValueNotifier<__PASCAL_NAME__State> {
  final Get__PASCAL_NAME__ListUseCase _getListUseCase;

  __PASCAL_NAME__Controller({required Get__PASCAL_NAME__ListUseCase getListUseCase})
      : _getListUseCase = getListUseCase,
        super(const __PASCAL_NAME__Initial());

  Future<void> loadItems() async {
    value = const __PASCAL_NAME__Loading();

    final result = await _getListUseCase();

    switch (result) {
      case __PASCAL_NAME__Success(data: final items):
        if (items.isEmpty) {
          value = const __PASCAL_NAME__Empty();
        } else {
          value = __PASCAL_NAME__Success(items);
        }
      case __PASCAL_NAME__Error(failure: final failure):
        value = __PASCAL_NAME__Error(message: failure.message);
    }
  }

  void retry() => loadItems();
}
EOF
fi

# 3.3 Card Widget
TARGET_FILE="$FEATURE_DIR/presentation/widgets/${FEATURE_NAME}_card.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import 'package:flutter/material.dart';
import '../../domain/entities/__FEATURE_NAME___entity.dart';

/// Movira — __PASCAL_NAME__ Kart Bileşeni (Material 3)
class __PASCAL_NAME__Card extends StatelessWidget {
  final __PASCAL_NAME__Entity item;
  final VoidCallback? onTap;

  const __PASCAL_NAME__Card({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.directions_car_outlined),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Tarih: ${item.createdAt.day}.${item.createdAt.month}.${item.createdAt.year}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
EOF
fi

# 3.4 Page View
TARGET_FILE="$FEATURE_DIR/presentation/pages/${FEATURE_NAME}_page.dart"
if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import 'package:flutter/material.dart';
import '../../data/datasources/__FEATURE_NAME___remote_data_source.dart';
import '../../data/repositories/__FEATURE_NAME___repository_impl.dart';
import '../../domain/usecases/get___FEATURE_NAME___list_usecase.dart';
import '../controllers/__FEATURE_NAME___controller.dart';
import '../controllers/__FEATURE_NAME___state.dart';
import '../widgets/__FEATURE_NAME___card.dart';

/// Movira — __PASCAL_NAME__ Sayfası
class __PASCAL_NAME__Page extends StatefulWidget {
  const __PASCAL_NAME__Page({super.key});

  @override
  State<__PASCAL_NAME__Page> createState() => ___PASCAL_NAME__PageState();
}

class ___PASCAL_NAME__PageState extends State<__PASCAL_NAME__Page> {
  late final __PASCAL_NAME__Controller _controller;

  @override
  void initState() {
    super.initState();
    final dataSource = __PASCAL_NAME__RemoteDataSourceImpl();
    final repository = __PASCAL_NAME__RepositoryImpl(dataSource);
    final useCase = Get__PASCAL_NAME__ListUseCase(repository);

    _controller = __PASCAL_NAME__Controller(getListUseCase: useCase);
    _controller.loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('__PASCAL_NAME__ Listesi'),
      ),
      body: ValueListenableBuilder<__PASCAL_NAME__State>(
        valueListenable: _controller,
        builder: (context, state, _) {
          return switch (state) {
            __PASCAL_NAME__Initial() => const SizedBox.shrink(),
            __PASCAL_NAME__Loading() => const Center(child: CircularProgressIndicator()),
            __PASCAL_NAME__Empty(message: final msg) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(msg, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            __PASCAL_NAME__Error(message: final msg, canRetry: final canRetry) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(msg, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      if (canRetry)
                        ElevatedButton.icon(
                          onPressed: _controller.retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yeniden Dene'),
                        ),
                    ],
                  ),
                ),
              ),
            __PASCAL_NAME__Success(items: final items) => RefreshIndicator(
                onRefresh: _controller.loadItems,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return __PASCAL_NAME__Card(
                      item: item,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.title} seçildi.')),
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
EOF
fi

# ------------------------------------------------------------------------------
# 4. İSTEĞE BAĞLI TEST İSKELETİ
# ------------------------------------------------------------------------------
if [[ "$GENERATE_TESTS" == true ]]; then
    printf "\n${CYAN}==> Birim Test İskeletleri Oluşturuluyor...${NC}\n"
    mkdir -p "$TEST_FEATURE_DIR/domain/usecases"
    mkdir -p "$TEST_FEATURE_DIR/presentation/controllers"

    TARGET_FILE="$TEST_FEATURE_DIR/domain/usecases/get_${FEATURE_NAME}_list_usecase_test.dart"
    if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Get__PASCAL_NAME__ListUseCase Testleri', () {
    test('Başarılı durumda veri listesi dönmelidir', () async {
      expect(true, isTrue);
    });
  });
}
EOF
    fi

    TARGET_FILE="$TEST_FEATURE_DIR/presentation/controllers/${FEATURE_NAME}_controller_test.dart"
    if check_target_file "$TARGET_FILE"; then
cat << 'EOF' | sed -e "s/__FEATURE_NAME__/${FEATURE_NAME}/g" -e "s/__PASCAL_NAME__/${PASCAL_NAME}/g" > "$TARGET_FILE"
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('__PASCAL_NAME__Controller Testleri', () {
    test('İlk durum __PASCAL_NAME__Initial olmalıdır', () {
      expect(true, isTrue);
    });
  });
}
EOF
    fi
fi

printf "\n${GREEN}✔ $FEATURE_NAME özelliği başarıyla üretildi!${NC}\n"
printf "Katman dosyaları: $FEATURE_DIR\n"
