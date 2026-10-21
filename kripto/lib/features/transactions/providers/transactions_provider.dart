import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/csv_service.dart';
import '../data/transaction_repository.dart';
import '../domain/csv_parser.dart';
import '../domain/transaction.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final csvServiceProvider = Provider<CsvService>((ref) {
  return CsvService();
});

final csvParserProvider = Provider<CsvParser>((ref) {
  return CsvParser();
});

final transactionsProvider = AsyncNotifierProvider<TransactionsNotifier, List<AppTransaction>>(() {
  return TransactionsNotifier();
});

class TransactionsNotifier extends AsyncNotifier<List<AppTransaction>> {
  final List<AppTransaction> _localFallback = [];

  @override
  Future<List<AppTransaction>> build() async {
    final repo = ref.watch(transactionRepositoryProvider);
    try {
      final remote = await repo.fetchAll();
      if (remote.isNotEmpty) return remote;
    } catch (_) {
      // Çevrimdışı / demo
    }
    return _localFallback;
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    final repo = ref.read(transactionRepositoryProvider);
    try {
      await repo.add(transaction);
    } catch (_) {
      // Çevrimdışı / demo modunda yerel hafızaya kaydet
      _localFallback.add(transaction);
    }
    ref.invalidateSelf();
  }

  Future<void> bulkInsertTransactions(List<AppTransaction> list) async {
    final repo = ref.read(transactionRepositoryProvider);
    try {
      await repo.bulkInsert(list);
    } catch (_) {
      _localFallback.addAll(list);
    }
    ref.invalidateSelf();
  }

  Future<void> softDeleteTransaction(String id) async {
    final repo = ref.read(transactionRepositoryProvider);
    try {
      await repo.softDelete(id);
    } catch (_) {
      _localFallback.removeWhere((t) => t.id == id);
    }
    ref.invalidateSelf();
  }
}
