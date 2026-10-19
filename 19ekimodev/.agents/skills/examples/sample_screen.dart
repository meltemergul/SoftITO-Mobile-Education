// Dosya Yolu: lib/features/urgent_requests/views/urgent_requests_view.dart
//
// CanBağım - Acil Kan Talepleri ekranı (örnek View + Page).
// Bu dosya, SKILL.md "Adım 5" ve "Sayfaya Entegrasyon" bölümlerinin
// eksiksiz bir uygulamasıdır. Bağımlı olduğu model, controller ve widget
// dosyaları references/state_flow.md içinde (Bölüm 6) yer alır:
//   - models/urgent_request_model.dart
//   - controllers/urgent_requests_controller.dart
//   - widgets/blood_group_filter_bar.dart
//   - widgets/urgent_request_card.dart
//
// Uyulan kurallar (project.md §4):
//   - Sayfa düzeyinde setState yok; tüm durumlar ValueNotifier ile yönetilir.
//   - Statik widget'larda const zorunlu.
//   - Renk/tipografi yalnızca Theme.of(context) veya AppColors üzerinden.
//   - Hiçbir build metodu 40 satırı geçmez.

import 'package:flutter/material.dart';

import '../controllers/urgent_requests_controller.dart';
import '../models/urgent_request_model.dart';
import '../widgets/blood_group_filter_bar.dart';
import '../widgets/urgent_request_card.dart';

/// Lifecycle sahibi sayfa: controller'ı oluşturur ve dispose eder.
/// StatefulWidget yalnızca yaşam döngüsü için kullanılır; setState çağrılmaz.
class UrgentRequestsPage extends StatefulWidget {
  const UrgentRequestsPage({super.key});

  @override
  State<UrgentRequestsPage> createState() => _UrgentRequestsPageState();
}

class _UrgentRequestsPageState extends State<UrgentRequestsPage> {
  late final UrgentRequestsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UrgentRequestsController()..loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UrgentRequestsView(controller: _controller);
  }
}

/// Saf görünüm katmanı: controller'ı ValueListenableBuilder ile UI'a bağlar.
class UrgentRequestsView extends StatelessWidget {
  final UrgentRequestsController controller;

  const UrgentRequestsView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acil Kan Talepleri'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadInitialData,
          ),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<BloodGroup?>(
            valueListenable: controller.selectedGroup,
            builder: (context, selected, _) {
              return BloodGroupFilterBar(
                selected: selected,
                onSelected: controller.selectGroup,
              );
            },
          ),
          Expanded(child: _UrgentRequestsBody(controller: controller)),
        ],
      ),
    );
  }
}

/// Durum sırası (state_flow.md §3): isLoading → errorMessage → boş → dolu.
class _UrgentRequestsBody extends StatelessWidget {
  final UrgentRequestsController controller;

  const _UrgentRequestsBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<String?>(
          valueListenable: controller.errorMessage,
          builder: (context, error, _) {
            if (error != null) {
              return _ErrorState(
                message: error,
                onRetry: controller.loadInitialData,
              );
            }

            return _UrgentRequestsList(controller: controller);
          },
        );
      },
    );
  }
}

/// Yalnızca filtrelenmiş liste değiştiğinde yeniden çizilen alt ağaç.
class _UrgentRequestsList extends StatelessWidget {
  final UrgentRequestsController controller;

  const _UrgentRequestsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UrgentRequestModel>>(
      valueListenable: controller.filteredRequests,
      builder: (context, requests, _) {
        if (requests.isEmpty) {
          return const Center(
            child: Text('Bu kan grubu için aktif acil talep bulunamadı.'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadInitialData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return UrgentRequestCard(
                key: ValueKey(request.id),
                request: request,
                onRespond: () => controller.respondToRequest(request.id),
              );
            },
          ),
        );
      },
    );
  }
}

/// Hata durumu: renkler Theme.of(context) üzerinden okunur.
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
