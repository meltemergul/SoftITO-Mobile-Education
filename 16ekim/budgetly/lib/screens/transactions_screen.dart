import 'package:flutter/material.dart';
import '../models/budget_transaction.dart';

class TransactionsScreen extends StatelessWidget {
  final List<BudgetTransaction> transactions;
  final ValueChanged<BudgetTransaction> onDelete;

  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'İşlem Geçmişi',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          const Center(child: Text('Henüz işlem bulunmuyor.'))
        else
          ...transactions.map((item) {
            return Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Icon(
                  item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: item.isIncome ? Colors.green : Colors.red,
                ),
                title: Text(item.title),
                subtitle: Text(
                  '${item.category} • '
                  '${item.date.day}.${item.date.month}.${item.date.year}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item.isIncome ? '+' : '-'}'
                      '₺${item.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: item.isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          onDelete(item);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'delete', child: Text('Sil')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
