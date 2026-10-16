import 'package:flutter/material.dart';
import '../models/budget_transaction.dart';
import 'transaction_form_screen.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<BudgetTransaction> _transactions = [
    BudgetTransaction(
      id: '1',
      title: 'Aylık Maaş',
      category: 'Maaş',
      amount: 35000,
      date: DateTime.now(),
      isIncome: true,
    ),
    BudgetTransaction(
      id: '2',
      title: 'Market Alışverişi',
      category: 'Market',
      amount: 1250,
      date: DateTime.now(),
      isIncome: false,
    ),
    BudgetTransaction(
      id: '3',
      title: 'Elektrik Faturası',
      category: 'Faturalar',
      amount: 650,
      date: DateTime.now(),
      isIncome: false,
    ),
  ];

  double get _totalIncome => _transactions
      .where((item) => item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _totalExpense => _transactions
      .where((item) => !item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get _balance => _totalIncome - _totalExpense;

  String _formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  Future<void> _openTransactionForm() async {
    final result = await Navigator.push<BudgetTransaction>(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );

    if (!mounted || result == null) return;

    setState(() {
      _transactions.insert(0, result);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      TransactionsScreen(
        transactions: _transactions,
        onDelete: _deleteTransaction,
      ),
      const CategoriesScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Budgetly',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _openTransactionForm,
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'İşlemler',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Kategoriler',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildBalanceCard(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatisticCard(
                'Toplam Gelir',
                _totalIncome,
                Icons.trending_up,
                const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatisticCard(
                'Toplam Gider',
                _totalExpense,
                Icons.trending_down,
                const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Son İşlemler',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_transactions.isEmpty)
          const Text('Henüz işlem eklenmedi.')
        else
          ..._transactions.take(5).map(_buildTransactionTile),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Toplam Bakiyem', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            _formatMoney(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gelirlerinden giderlerini çıkar.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatMoney(amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BudgetTransaction item) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isIncome
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFFEE2E2),
          child: Icon(
            item.isIncome ? Icons.add : Icons.remove,
            color: item.isIncome
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
          ),
        ),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item.category),
        trailing: Text(
          '${item.isIncome ? '+' : '-'}'
          '${_formatMoney(item.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item.isIncome
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
          ),
        ),
      ),
    );
  }

  void _deleteTransaction(BudgetTransaction item) {
    setState(() {
      _transactions.removeWhere((transaction) => transaction.id == item.id);
    });
  }
}
