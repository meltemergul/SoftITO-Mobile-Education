import 'package:flutter/material.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  bool isBalanceVisible = true;
  String _lastAction = 'Hazır-Butonlara Tıklayabilirsinşz';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //profil online rozeti
          _buildProfileHeader(),
          //cüzdan kartı
          _buildWalletCard(),
          //aksiyon butonları
          _buildQuickActions(),
          //istatisk bölümü
          _buildFlexStatistics(),
          //notification bildirim banner
          _buildNotificationBanner(),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Son İşlem: $_lastAction',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Son işlem bilgisi

  // 1. Profil başlığı
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1F6366F1),
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 32,
                  color: Color(0xFF6366F1),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merhaba, Meltem!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hesabın aktif durumda',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_circle_outlined,
            size: 28,
            color: Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  // 2. Cüzdan kartı
  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
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
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Toplam Bakiye',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Spacer(),
              Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '₺12.450,00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFFBBF7D0), size: 18),
              SizedBox(width: 6),
              Text(
                '%8,5 bu ay',
                style: TextStyle(color: Color(0xFFBBF7D0), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Hızlı işlem butonları
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionItem(
              icon: Icons.add_circle_outline,
              title: 'Para Ekle',
              color: const Color(0xFF6366F1),
              onTap: () {
                setState(() {
                  _lastAction = 'Para Ekle seçildi';
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionItem(
              icon: Icons.send_outlined,
              title: 'Gönder',
              color: const Color(0xFF0D9488),
              onTap: () {
                setState(() {
                  _lastAction = 'Gönder seçildi';
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionItem(
              icon: Icons.receipt_long_outlined,
              title: 'İşlemler',
              color: const Color(0xFFF59E0B),
              onTap: () {
                setState(() {
                  _lastAction = 'İşlemler seçildi';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hızlı işlem butonunun ortak tasarımı
  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. İstatistik bölümü
  Widget _buildFlexStatistics() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İstatistiklerim',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatisticCard(
                  title: 'Gelir',
                  amount: '₺8.500',
                  icon: Icons.arrow_downward,
                  color: const Color(0xFF10B981),
                  background: const Color(0xFFD1FAE5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatisticCard(
                  title: 'Gider',
                  amount: '₺3.250',
                  icon: Icons.arrow_upward,
                  color: const Color(0xFFEF4444),
                  background: const Color(0xFFFEE2E2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // İstatistik kartının ortak tasarımı
  Widget _buildStatisticCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Bildirim banner'ı
  Widget _buildNotificationBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: Color(0xFF4F46E5),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bildirimler',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF312E81),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Hesap hareketlerini takip etmek için '
                  'bildirimlerini kontrol etmeyi unutma.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF4338CA),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Bildirimi kapat',
            onPressed: () {
              setState(() {
                _lastAction = 'Bildirim kontrol edildi';
              });
            },
            icon: const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }
}
