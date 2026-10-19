#!/usr/bin/env bash
#
# CanBağım Feature Scaffold Script
# ---------------------------------
# SKILL.md "Adım Adım Modül Geliştirme Akışı" bölümünü otomatikleştirir.
# lib/features/<feature_name>/ altında controllers/, models/, views/, widgets/
# klasörlerini ve standartlara uygun başlangıç dosyalarını üretir.
#
# Kullanım:
#   .agents/skills/script/generate_feature.sh <feature_name> [seçenekler]
#
# Seçenekler:
#   --root <dizin>     Flutter proje kökü (varsayılan: mevcut dizin)
#   --force            Var olan dosyaların üzerine yaz
#   --dry-run          Hiçbir dosya yazmadan yapılacakları listele
#   --allow-custom     Desteklenen liste dışındaki snake_case isimlere izin ver
#   -h, --help         Yardımı göster
#
# Desteklenen modüller (SKILL.md):
#   blood_values | donation_centers | urgent_requests | donation_statistics
#
# Örnek:
#   .agents/skills/script/generate_feature.sh donation_centers
#   .agents/skills/script/generate_feature.sh urgent_requests --dry-run
#
# macOS varsayılan bash 3.2 ile uyumludur (associative array kullanılmaz).

set -euo pipefail

# ---------------------------------------------------------------------------
# Yardımcılar
# ---------------------------------------------------------------------------

readonly SUPPORTED_FEATURES="blood_values donation_centers urgent_requests donation_statistics"

if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'; C_RESET=$'\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_RESET=''
fi

info()  { printf '%s[i]%s %s\n' "$C_BLUE" "$C_RESET" "$1"; }
ok()    { printf '%s[✓]%s %s\n' "$C_GREEN" "$C_RESET" "$1"; }
warn()  { printf '%s[!]%s %s\n' "$C_YELLOW" "$C_RESET" "$1"; }
fail()  { printf '%s[✗]%s %s\n' "$C_RED" "$C_RESET" "$1" >&2; exit 1; }

usage() {
  sed -n '3,25p' "$0" | sed 's/^# \{0,1\}//'
}

# snake_case -> PascalCase (blood_values -> BloodValues)
to_pascal() {
  echo "$1" | awk -F'_' '{
    out = "";
    for (i = 1; i <= NF; i++) {
      out = out toupper(substr($i, 1, 1)) substr($i, 2);
    }
    print out;
  }'
}

# Modül adına göre Türkçe ekran başlığı
feature_title() {
  case "$1" in
    blood_values)        echo "Bağış Uygunluk Değerleri" ;;
    donation_centers)    echo "Bağış Noktaları" ;;
    urgent_requests)     echo "Acil Kan Talepleri" ;;
    donation_statistics) echo "Aylık Bağış İstatistikleri" ;;
    *)                   to_pascal "$1" ;;
  esac
}

# Modül adına göre boş durum mesajı
feature_empty_message() {
  case "$1" in
    blood_values)        echo "Kayıtlı değer bulunamadı." ;;
    donation_centers)    echo "Yakınınızda bağış noktası bulunamadı." ;;
    urgent_requests)     echo "Aktif acil talep bulunamadı." ;;
    donation_statistics) echo "Gösterilecek istatistik bulunamadı." ;;
    *)                   echo "Kayıt bulunamadı." ;;
  esac
}

# Şablonu yer tutucularla doldurup hedef dosyaya yazar.
# stdin: şablon içeriği
write_template() {
  local target="$1"
  local rel="${target#"$ROOT"/}"

  if [[ -f "$target" && "$FORCE" -eq 0 ]]; then
    warn "Atlandı (zaten var, --force ile üzerine yazılabilir): $rel"
    cat > /dev/null
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "[dry-run] Oluşturulacak: $rel"
    cat > /dev/null
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  sed \
    -e "s|__SNAKE__|${FEATURE}|g" \
    -e "s|__PASCAL__|${PASCAL}|g" \
    -e "s|__TITLE__|${TITLE}|g" \
    -e "s|__EMPTY__|${EMPTY_MSG}|g" \
    -e "s|__PACKAGE__|${PACKAGE_NAME}|g" \
    > "$target"
  ok "Oluşturuldu: $rel"
}

# ---------------------------------------------------------------------------
# Argüman ayrıştırma
# ---------------------------------------------------------------------------

FEATURE=""
ROOT="$(pwd)"
FORCE=0
DRY_RUN=0
ALLOW_CUSTOM=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)         [[ $# -ge 2 ]] || fail "--root bir dizin bekliyor."; ROOT="$2"; shift 2 ;;
    --force)        FORCE=1; shift ;;
    --dry-run)      DRY_RUN=1; shift ;;
    --allow-custom) ALLOW_CUSTOM=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    -*)             fail "Bilinmeyen seçenek: $1 (yardım için --help)" ;;
    *)
      [[ -z "$FEATURE" ]] || fail "Yalnızca bir modül adı verilebilir."
      FEATURE="$1"; shift ;;
  esac
done

[[ -n "$FEATURE" ]] || { usage; echo; fail "Modül adı belirtilmedi."; }

# ---------------------------------------------------------------------------
# Doğrulamalar
# ---------------------------------------------------------------------------

[[ "$FEATURE" =~ ^[a-z][a-z0-9]*(_[a-z0-9]+)*$ ]] \
  || fail "Modül adı snake_case olmalı (ör. blood_values): '$FEATURE'"

if [[ " $SUPPORTED_FEATURES " != *" $FEATURE "* && "$ALLOW_CUSTOM" -eq 0 ]]; then
  fail "Desteklenmeyen modül: '$FEATURE'. Desteklenenler: $SUPPORTED_FEATURES (özel isim için --allow-custom)"
fi

[[ -d "$ROOT" ]] || fail "Proje kökü bulunamadı: $ROOT"
ROOT="$(cd "$ROOT" && pwd)"

PACKAGE_NAME=""
if [[ -f "$ROOT/pubspec.yaml" ]]; then
  PACKAGE_NAME="$(awk -F': *' '/^name:/ { print $2; exit }' "$ROOT/pubspec.yaml" | tr -d '[:space:]')"
else
  warn "pubspec.yaml bulunamadı; widget testi üretilmeyecek. (--root ile Flutter proje kökünü verin)"
fi

PASCAL="$(to_pascal "$FEATURE")"
TITLE="$(feature_title "$FEATURE")"
EMPTY_MSG="$(feature_empty_message "$FEATURE")"
FEATURE_DIR="$ROOT/lib/features/$FEATURE"

info "Modül: $FEATURE  →  sınıf öneki: $PASCAL"
info "Hedef: ${FEATURE_DIR#"$ROOT"/}"

# ---------------------------------------------------------------------------
# Ortak sabit: lib/core/constants/app_colors.dart (yalnızca yoksa)
# ---------------------------------------------------------------------------

APP_COLORS="$ROOT/lib/core/constants/app_colors.dart"
if [[ ! -f "$APP_COLORS" ]]; then
  write_template "$APP_COLORS" <<'EOF'
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Karanlık tema (derin gece medikal paleti)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF151A23);
  static const Color darkPrimary = Color(0xFFE63946);

  // Aydınlık tema (klinik hijyenik palet)
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightPrimary = Color(0xFFD90429);
  static const Color medicalBlue = Color(0xFF0077B6);

  // Tıbbi durum ve aciliyet tonları
  static const Color eligible = Color(0xFF2EC4B6);
  static const Color warning = Color(0xFFFF9F1C);
  static const Color ineligible = Color(0xFFE63946);
  static const Color critical = Color(0xFFFF4D6D);
  static const Color info = Color(0xFF48CAE4);
}
EOF
fi

# ---------------------------------------------------------------------------
# Adım 2: Model
# ---------------------------------------------------------------------------

write_template "$FEATURE_DIR/models/${FEATURE}_model.dart" <<'EOF'
class __PASCAL__Model {
  final String id;
  final String title;
  final String description;

  const __PASCAL__Model({
    required this.id,
    required this.title,
    required this.description,
  });

  __PASCAL__Model copyWith({
    String? id,
    String? title,
    String? description,
  }) {
    return __PASCAL__Model(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  factory __PASCAL__Model.fromJson(Map<String, dynamic> json) {
    return __PASCAL__Model(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
EOF

# ---------------------------------------------------------------------------
# Adım 3: Controller
# ---------------------------------------------------------------------------

write_template "$FEATURE_DIR/controllers/${FEATURE}_controller.dart" <<'EOF'
import 'package:flutter/foundation.dart';

import '../models/__SNAKE___model.dart';

class __PASCAL__Controller {
  final ValueNotifier<List<__PASCAL__Model>> items =
      ValueNotifier<List<__PASCAL__Model>>(const []);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  bool _isDisposed = false;

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      // TODO(__SNAKE__): Servis/repository çağrısı bağlandığında değiştirin.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (_isDisposed) return;
      items.value = const [
        __PASCAL__Model(
          id: '__SNAKE___001',
          title: 'Örnek Kayıt',
          description: 'Başlangıç verisi',
        ),
      ];
    } catch (_) {
      if (_isDisposed) return;
      errorMessage.value = 'Veriler yüklenemedi. Lütfen tekrar deneyin.';
    } finally {
      if (!_isDisposed) isLoading.value = false;
    }
  }

  void updateItem(__PASCAL__Model updated) {
    items.value = [
      for (final item in items.value)
        if (item.id == updated.id) updated else item,
    ];
  }

  void dispose() {
    _isDisposed = true;
    items.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
EOF

# ---------------------------------------------------------------------------
# Adım 4: Widget
# ---------------------------------------------------------------------------

write_template "$FEATURE_DIR/widgets/${FEATURE}_card.dart" <<'EOF'
import 'package:flutter/material.dart';

import '../models/__SNAKE___model.dart';

class __PASCAL__Card extends StatelessWidget {
  final __PASCAL__Model item;
  final VoidCallback? onTap;

  const __PASCAL__Card({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: theme.colorScheme.primary.withAlpha(77),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(item.description, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
EOF

# ---------------------------------------------------------------------------
# Adım 5: View + Sayfa Entegrasyonu (Lifecycle)
# ---------------------------------------------------------------------------

write_template "$FEATURE_DIR/views/${FEATURE}_view.dart" <<'EOF'
import 'package:flutter/material.dart';

import '../controllers/__SNAKE___controller.dart';
import '../models/__SNAKE___model.dart';
import '../widgets/__SNAKE___card.dart';

class __PASCAL__Page extends StatefulWidget {
  const __PASCAL__Page({super.key});

  @override
  State<__PASCAL__Page> createState() => ___PASCAL__PageState();
}

class ___PASCAL__PageState extends State<__PASCAL__Page> {
  late final __PASCAL__Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = __PASCAL__Controller()..loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return __PASCAL__View(controller: _controller);
  }
}

class __PASCAL__View extends StatelessWidget {
  final __PASCAL__Controller controller;

  const __PASCAL__View({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('__TITLE__'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<String?>(
            valueListenable: controller.errorMessage,
            builder: (context, error, _) {
              if (error != null) {
                return Center(child: Text(error));
              }

              return _ItemList(controller: controller);
            },
          );
        },
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final __PASCAL__Controller controller;

  const _ItemList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<__PASCAL__Model>>(
      valueListenable: controller.items,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return const Center(child: Text('__EMPTY__'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return __PASCAL__Card(key: ValueKey(item.id), item: item);
          },
        );
      },
    );
  }
}
EOF

# ---------------------------------------------------------------------------
# Doğrulama ve Test Standartları: başlangıç widget testi
# ---------------------------------------------------------------------------

if [[ -n "$PACKAGE_NAME" ]]; then
  write_template "$ROOT/test/features/$FEATURE/${FEATURE}_view_test.dart" <<'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:__PACKAGE__/features/__SNAKE__/models/__SNAKE___model.dart';
import 'package:__PACKAGE__/features/__SNAKE__/views/__SNAKE___view.dart';

void main() {
  group('__PASCAL__Model', () {
    test('toJson / fromJson simetrik olmalı', () {
      const model = __PASCAL__Model(id: '1', title: 'Başlık', description: 'Açıklama');
      final decoded = __PASCAL__Model.fromJson(model.toJson());

      expect(decoded.id, model.id);
      expect(decoded.title, model.title);
      expect(decoded.description, model.description);
    });
  });

  testWidgets('__PASCAL__Page yüklenip listeyi göstermeli', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: __PASCAL__Page()));

    expect(find.text('__TITLE__'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Örnek Kayıt'), findsOneWidget);
  });
}
EOF
fi

# ---------------------------------------------------------------------------
# Özet
# ---------------------------------------------------------------------------

echo
if [[ "$DRY_RUN" -eq 1 ]]; then
  info "Dry-run tamamlandı; hiçbir dosya yazılmadı."
else
  ok "'$FEATURE' modülü iskeleti hazır."
  echo
  echo "Sonraki adımlar (SKILL.md → Doğrulama ve Test Standartları):"
  echo "  1. Modeli modüle özgü alanlarla genişletin (tıbbi eşikler için core/constants/blood_value_ranges.dart)."
  echo "  2. build metotlarını 40 satırın altında tutun; gerekirse widgets/ altına bölün."
  echo "  3. Şimdi \`flutter analyze\` ile kontrol edebilirsin."
  echo "  4. Ardından \`flutter test\` çalıştırın."
fi
