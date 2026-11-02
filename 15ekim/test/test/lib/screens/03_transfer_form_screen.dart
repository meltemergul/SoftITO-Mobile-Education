import 'package:flutter/material.dart';
import '../models/transation_model.dart';

class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  double _balance = 148950.00;

  final List<TransactionItem> _history = [
    const TransactionItem(
      id: 'tx_init_1',
      title: 'Ahmet Yılmaz',
      category: 'Hızlı Transfer',
      amount: 1500.00,
      date: 'Bugün 11:30',
      isExpense: true,
      icon: Icons.send_rounded,
    ),
  ];

  // Transfer formunu aç
  void _openTransferModal() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Yeni Transfer',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Alıcı bilgilerini ve transfer tutarını gir.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alıcı adı
                      const Text(
                        'Alıcı Adı',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Örn. Ahmet Yılmaz',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Transfer tutarı
                      const Text(
                        'Transfer Tutarı (₺)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: '0,00',
                          prefixIcon: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Güncel bakiye
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Kullanılabilir bakiye: '
                          '₺${_balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF4338CA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transferi gerçekleştir
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final name = nameController.text.trim();

                            // Virgüllü veya noktalı ondalık girişini destekle
                            final rawAmount = amountController.text.trim();

                            final amount = double.tryParse(
                              rawAmount.replaceAll(',', '.'),
                            );

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen alıcı adını gir.'),
                                ),
                              );
                              return;
                            }

                            if (amount == null ||
                                !amount.isFinite ||
                                amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Geçerli bir transfer tutarı gir.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (amount > _balance) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Yetersiz bakiye!'),
                                ),
                              );
                              return;
                            }

                            // Ana ekranın durumunu güncelle
                            setState(() {
                              _balance -= amount;

                              _history.insert(
                                0,
                                TransactionItem(
                                  id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
                                  title: name,
                                  category: 'Hızlı Transfer',
                                  amount: amount,
                                  date: 'Şimdi',
                                  isExpense: true,
                                  icon: Icons.send_rounded,
                                ),
                              );
                            });

                            Navigator.pop(modalContext);

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$name kişisine ₺${amount.toStringAsFixed(2)} '
                                  'tutarında transfer kaydedildi.',
                                ),
                                backgroundColor: const Color(0xFF059669),
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Transfer Yap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      amountController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Para Transferi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 20),
            _buildTransferButton(),
            const SizedBox(height: 28),
            _buildHistoryHeader(),
            const SizedBox(height: 14),
            _buildTransferHistory(),
          ],
        ),
      ),
    );
  }

  // Bakiye kartı
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
              ),
              SizedBox(width: 8),
              Text(
                'Kullanılabilir Bakiye',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '₺${_balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Transfer işlemlerin için hazır.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Transfer butonu
  Widget _buildTransferButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _openTransferModal,
        icon: const Icon(Icons.add),
        label: const Text(
          'Yeni Transfer Oluştur',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // Geçmiş başlığı
  Widget _buildHistoryHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transfer Geçmişi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          '${_history.length} işlem',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      ],
    );
  }

  // Transfer geçmişi listesi
  Widget _buildTransferHistory() {
    if (_history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Henüz transfer yapılmadı.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTransferItem(_history[index]);
      },
    );
  }

  // Tek bir transfer satırı
  Widget _buildTransferItem(TransactionItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${item.category} • ${item.date}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.isExpense ? '-' : '+'}'
            '₺${item.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: item.isExpense
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF059669),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
