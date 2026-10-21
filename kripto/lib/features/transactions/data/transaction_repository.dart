import '../../../core/services/supabase_service.dart';
import '../domain/transaction.dart';

class TransactionRepository {
  Future<List<AppTransaction>> fetchAll() async {
    final client = SupabaseService.client;
    if (client == null) return [];

    final response = await client
        .from('transactions')
        .select()
        .isFilter('deleted_at', null)
        .order('executed_at', ascending: true);

    return (response as List<dynamic>)
        .map((e) => AppTransaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(AppTransaction transaction) async {
    final client = SupabaseService.client;
    if (client == null) throw Exception('Supabase henüz bağlanmadı.');

    await client.from('transactions').insert(transaction.toJson());
  }

  Future<void> softDelete(String id) async {
    final client = SupabaseService.client;
    if (client == null) throw Exception('Supabase henüz bağlanmadı.');

    await client
        .from('transactions')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  Future<void> bulkInsert(List<AppTransaction> transactions) async {
    final client = SupabaseService.client;
    if (client == null) throw Exception('Supabase henüz bağlanmadı.');

    final data = transactions.map((t) => t.toJson()).toList();
    await client.from('transactions').insert(data);
  }
}
