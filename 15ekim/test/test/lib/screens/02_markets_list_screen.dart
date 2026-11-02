import 'package:flutter/material.dart';
import '../models/asset_model.dart';
import '../models/transation_model.dart';

class MarketsListScreen extends StatefulWidget {
  const MarketsListScreen({super.key});

  static const List<Asset> assets = [
    Asset(
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 67420.00,
      change24h: 4.20,
      balance: 0.4,
    ),
    Asset(
      symbol: 'ETH',
      name: 'Ethereum',
      price: 3500,
      change24h: -1.80,
      balance: 4.20,
    ),
    Asset(
      symbol: 'SOL',
      name: 'Solana',
      price: 200.00,
      change24h: 0.5,
      balance: 85.00,
    ),
  ];

  static const List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Apple Store',
      category: 'Teknoloji',
      amount: 64500,
      date: 'Bugün 14:20',
      isExpense: true,
      icon: Icons.laptop_mac,
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Kodusta Danışmanlık Hakediş',
      category: 'Kurumsal Gelir',
      date: 'Dün 09:00',
      amount: 125000.00,
      isExpense: false,
      icon: Icons.business_center,
    ),
    TransactionItem(
      id: 'tx_3',
      title: 'Market Alışverişi',
      category: 'Market',
      date: 'Dün 12:30',
      amount: 1250,
      isExpense: true,
      icon: Icons.shopping_cart_outlined,
    ),
    TransactionItem(
      id: 'tx_4',
      title: 'Yazılım Ödemesi',
      category: 'Freelance',
      date: '12 Ekim 10:00',
      amount: 8500,
      isExpense: false,
      icon: Icons.code,
    ),
  ];

  @override
  State<MarketsListScreen> createState() => _MarketsGridListScreenState();
}

class _MarketsGridListScreenState extends State<MarketsListScreen> {
  bool _showGrid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Piyasalar ve İşlemler',
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
            _buildMarketHeader(),
            const SizedBox(height: 16),
            _buildMarketGrid(),
            const SizedBox(height: 28),
            _buildTransactionsHeader(),
            const SizedBox(height: 16),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  // 1. Piyasa başlığı
  Widget _buildMarketHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kripto Varlıklar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Varlıklarını ve piyasa değişimlerini incele.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Görünümü değiştir',
          onPressed: () {
            setState(() {
              _showGrid = !_showGrid;
            });
          },
          icon: Icon(
            _showGrid ? Icons.view_list : Icons.grid_view,
            color: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  // 2. Varlıkların grid veya liste görünümü
  Widget _buildMarketGrid() {
    if (!_showGrid) {
      return Column(
        children: [
          for (final asset in MarketsListScreen.assets)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAssetCard(asset),
            ),
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MarketsListScreen.assets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 185,
      ),
      itemBuilder: (context, index) {
        return _buildAssetCard(MarketsListScreen.assets[index]);
      },
    );
  }

  // 3. Tek bir varlık kartı
  Widget _buildAssetCard(Asset asset) {
    final bool isPositive = asset.change24h >= 0;
    final Color changeColor = isPositive
        ? const Color(0xFF059669)
        : const Color(0xFFDC2626);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  asset.symbol.substring(0, 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      asset.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${asset.price.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: changeColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${isPositive ? '+' : ''}'
                  '${asset.change24h.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. İşlem geçmişi başlığı
  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Son İşlemler',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          '${MarketsListScreen.transactions.length} işlem',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  // 5. İşlem listesi
  Widget _buildTransactionList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: MarketsListScreen.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final transaction = MarketsListScreen.transactions[index];

        return _buildTransactionItem(transaction);
      },
    );
  }

  // 6. Tek bir işlem satırı
  Widget _buildTransactionItem(TransactionItem transaction) {
    final bool isExpense = transaction.isExpense;

    final Color amountColor = isExpense
        ? const Color(0xFFDC2626)
        : const Color(0xFF059669);

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
              color: isExpense
                  ? const Color(0xFFFEE2E2)
                  : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(transaction.icon, color: amountColor, size: 23),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
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
                  '${transaction.category} • ${transaction.date}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${isExpense ? '-' : '+'}'
              '\$${transaction.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: amountColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
