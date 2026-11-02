import 'package:flutter/material.dart';

// Gelir ve gider işlemlerinin veri yapısını tanımlayan model sınıfını içe aktarıyoruz.
import '../models/budget_transaction.dart';

// Kategorilerin ve işlemlerin yönetildiği diğer ekranları içe aktarıyoruz.
import 'transaction_form_screen.dart';
import 'transactions_screen.dart';
import 'categories_screen.dart';

// Uygulamanın ana sayfasını oluşturuyoruz.
// StatefulWidget kullanıyoruz çünkü bu ekranda değişen veriler ve sayfa seçimi bulunuyor.
class DashboardScreen extends StatefulWidget {
  // Constructor (kurucu metot).
  // super.key ile üst sınıfın key parametresini almasını sağlıyoruz.
  const DashboardScreen({super.key});

  // StatefulWidget'ın kendisine ait State nesnesini oluşturuyoruz.
  // createState metodu ekranın değişebilen verilerini yönetecek sınıfı döndürür.
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// DashboardScreen ekranının değişebilen verilerini ve işlemlerini yönetiyoruz.
class _DashboardScreenState extends State<DashboardScreen> {
  // Alt menüde hangi sayfanın seçili olduğunu tutuyoruz.
  // 0: Ana Sayfa, 1: İşlemler, 2: Kategoriler.
  // Değişebileceği için int olarak tanımlayıp başta 0 değerini veriyoruz.
  int _selectedIndex = 0;

  // Bütçe işlemlerini tutacağımız listeyi oluşturuyoruz.
  // BudgetTransaction modelinden nesneler saklıyoruz.
  // Şimdilik uygulama açıldığında örnek verilerle dolduruyoruz.
  final List<BudgetTransaction> _transactions = [
    // Örnek maaş geliri oluşturuyoruz.
    BudgetTransaction(
      id: '1',
      title: 'Aylık Maaş',
      category: 'Maaş',
      amount: 35000,
      date: DateTime.now(),
      isIncome: true,
    ),

    // Örnek market gideri oluşturuyoruz.
    BudgetTransaction(
      id: '2',
      title: 'Market Alışverişi',
      category: 'Market',
      amount: 1250,
      date: DateTime.now(),
      isIncome: false,
    ),

    // Örnek elektrik faturası gideri oluşturuyoruz.
    BudgetTransaction(
      id: '3',
      title: 'Elektrik Faturası',
      category: 'Faturalar',
      amount: 650,
      date: DateTime.now(),
      isIncome: false,
    ),
  ];

  // Getter kullanarak toplam gelir miktarını hesaplıyoruz.
  // where ile yalnızca gelir olan işlemleri filtreliyoruz.
  // isIncome true olan işlemleri alıyoruz.
  // fold ile filtrelenen işlemlerin tutarlarını toplayıp tek bir sonuç elde ediyoruz.
  // 0.0 başlangıç değeridir. sum toplamı, item ise listedeki mevcut işlemi temsil eder.
  double get _totalIncome => _transactions
      .where((item) => item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  // Toplam gider miktarını hesaplıyoruz.
  // ! işareti bool değerinin tersini alır.
  // !item.isIncome ile yalnızca gelir olmayan yani gider işlemlerini seçiyoruz.
  // fold ile gider tutarlarını topluyoruz.
  double get _totalExpense => _transactions
      .where((item) => !item.isIncome)
      .fold(0.0, (sum, item) => sum + item.amount);

  // Toplam bakiyeyi hesaplıyoruz.
  // Gelirlerden giderleri çıkararak kalan miktarı buluyoruz.
  // Getter sayesinde bu değeri her çağırdığımızda güncel liste üzerinden hesaplıyoruz.
  double get _balance => _totalIncome - _totalExpense;

  // Para miktarlarını ekranda istediğimiz formatta göstermek için metot oluşturuyoruz.
  // toStringAsFixed(2) sayının virgülden sonra iki basamak göstermesini sağlar.
  String _formatMoney(double amount) {
    return '₺${amount.toStringAsFixed(2)}';
  }

  // Yeni gelir veya gider eklemek için işlem formu ekranını açıyoruz.
  // async kullanıyoruz çünkü Navigator.push işleminin sonucunu bekleyeceğiz.
  Future<void> _openTransactionForm() async {
    // Navigator.push ile yeni bir sayfaya geçiyoruz.
    // Kullanıcı formu tamamladığında BudgetTransaction türünde bir sonuç dönebilir.
    // await ile form ekranından gelecek sonucu bekliyoruz.
    final result = await Navigator.push<BudgetTransaction>(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );

    // mounted, widget'ın hâlâ ekranda ve aktif olup olmadığını kontrol eder.
    // result == null ise kullanıcı herhangi bir işlem oluşturmadan geri dönmüştür.
    // Bu durumlardan biri varsa metottan çıkıyoruz.
    if (!mounted || result == null) return;

    // setState ile listedeki değişikliği Flutter'a bildiriyoruz.
    // Böylece ekran yeniden oluşturulur ve yeni işlem görünür.
    setState(() {
      // Yeni eklenen işlemi listenin en başına yerleştiriyoruz.
      // Böylece en son eklenen işlem ilk sırada görünür.
      _transactions.insert(0, result);
    });
  }

  // Widget'ın ekranda nasıl görüneceğini belirleyen build metodunu override ediyoruz.
  @override
  Widget build(BuildContext context) {
    // Uygulamadaki üç sayfayı bir liste içerisinde tutuyoruz.
    // Seçili olan sayfayı _selectedIndex ile belirleyeceğiz.
    final pages = [
      // 0. sırada ana sayfa bulunuyor.
      _buildDashboard(),

      // 1. sırada tüm işlemlerin listelendiği ekran bulunuyor.
      // İşlem listesini ve silme metodunu parametre olarak gönderiyoruz.
      TransactionsScreen(
        transactions: _transactions,
        onDelete: _deleteTransaction,
      ),

      // 2. sırada kategorilerin gösterildiği ekran bulunuyor.
      // const kullanarak sabit widget oluşturuyoruz.
      const CategoriesScreen(),
    ];

    // Scaffold ile sayfanın temel görsel yapısını oluşturuyoruz.
    return Scaffold(
      // Ana sayfanın arka plan rengini belirliyoruz.
      backgroundColor: const Color(0xFFF8FAFC),

      // AppBar ile sayfanın üst menüsünü oluşturuyoruz.
      appBar: AppBar(
        title: const Text(
          'Budgetly',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // AppBar arka planını beyaz yapıyoruz.
        backgroundColor: Colors.white,

        // Başlık ve ikonların rengini belirliyoruz.
        foregroundColor: const Color(0xFF1E293B),

        // AppBar altındaki gölgeyi kaldırıyoruz.
        elevation: 0,
      ),

      // Seçili olan sayfayı ekranda gösteriyoruz.
      // _selectedIndex 0, 1 veya 2 değerini alabilir.
      body: pages[_selectedIndex],

      // Sadece ana sayfadayken (+) butonunu gösteriyoruz.
      // Diğer sayfalarda FloatingActionButton görünmez.
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              // Butona basıldığında yeni işlem ekleme formunu açıyoruz.
              onPressed: _openTransactionForm,

              // Butonun arka plan rengini belirliyoruz.
              backgroundColor: const Color(0xFF6366F1),

              // Buton içerisindeki ikonun rengini beyaz yapıyoruz.
              foregroundColor: Colors.white,

              // Butonun içerisine ekleme ikonu yerleştiriyoruz.
              child: const Icon(Icons.add),
            )
          : null,

      // Sayfanın alt kısmında gezinme menüsü oluşturuyoruz.
      bottomNavigationBar: NavigationBar(
        // Hangi menü öğesinin seçili olduğunu belirtiyoruz.
        selectedIndex: _selectedIndex,

        // Kullanıcı alt menüden başka bir sayfaya bastığında çalışır.
        // index, kullanıcının seçtiği menünün sırasını temsil eder.
        onDestinationSelected: (index) {
          // Seçilen sayfanın index değerini güncelliyoruz.
          // setState sayesinde seçilen sayfa ekranda gösterilir.
          setState(() => _selectedIndex = index);
        },

        // Alt menüde gösterilecek sayfaları tanımlıyoruz.
        destinations: const [
          // Ana sayfa menü öğesi.
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),

          // İşlemler menü öğesi.
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'İşlemler',
          ),

          // Kategoriler menü öğesi.
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Kategoriler',
          ),
        ],
      ),
    );
  }

  // Ana sayfanın içerik tasarımını oluşturan yardımcı metodu yazıyoruz.
  // Widget döndürür çünkü ekranda gösterilecek bir arayüz oluşturuyoruz.
  Widget _buildDashboard() {
    // ListView ile ana sayfa içeriğinin dikey olarak kaydırılmasını sağlıyoruz.
    return ListView(
      // Listenin çevresine 20 piksel boşluk bırakıyoruz.
      padding: const EdgeInsets.all(20),

      children: [
        // Toplam bakiyeyi gösteren kartı ekliyoruz.
        _buildBalanceCard(),

        // Bakiye kartı ile istatistik kartları arasına boşluk bırakıyoruz.
        const SizedBox(height: 20),

        // Gelir ve gider kartlarını yan yana göstermek için Row kullanıyoruz.
        Row(
          children: [
            // Expanded ile gelir kartının mevcut alanın yarısını kaplamasını sağlıyoruz.
            Expanded(
              child: _buildStatisticCard(
                'Toplam Gelir',
                _totalIncome,
                Icons.trending_up,
                const Color(0xFF059669),
              ),
            ),

            // İki istatistik kartı arasına 12 piksel boşluk bırakıyoruz.
            const SizedBox(width: 12),

            // Gider kartını oluşturuyoruz.
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

        // İstatistik kartları ile son işlemler başlığı arasına boşluk ekliyoruz.
        const SizedBox(height: 28),

        // Son işlemler bölümünün başlığını oluşturuyoruz.
        const Text(
          'Son İşlemler',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        // Başlık ile işlem listesi arasına boşluk ekliyoruz.
        const SizedBox(height: 12),

        // Eğer işlem listesi boşsa kullanıcıya bilgilendirme mesajı gösteriyoruz.
        if (_transactions.isEmpty)
          const Text('Henüz işlem eklenmedi.')
        // Liste boş değilse son 5 işlemi ekranda gösteriyoruz.
        else
          ..._transactions.take(5).map(_buildTransactionTile),
        // take(5) listenin ilk 5 elemanını alır.
        // map her elemanı _buildTransactionTile metoduna göndererek widget oluşturur.
        // ... (spread operator) oluşturulan widget listesini children içerisine ekler.
      ],
    );
  }

  // Toplam bakiyeyi gösteren kartın tasarımını oluşturuyoruz.
  Widget _buildBalanceCard() {
    // Container ile bakiye kartının dış görünümünü oluşturuyoruz.
    return Container(
      padding: const EdgeInsets.all(24),

      // Kartın arka planına iki renkli geçiş efekti ekliyoruz.
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
        ),

        // Kartın köşelerini 24 piksel yuvarlatıyoruz.
        borderRadius: BorderRadius.circular(24),
      ),

      // Kart içerisindeki elemanları dikey olarak sıralıyoruz.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bakiye başlığını gösteriyoruz.
          const Text('Toplam Bakiyem', style: TextStyle(color: Colors.white70)),

          const SizedBox(height: 12),

          // Hesaplanan toplam bakiyeyi para formatında gösteriyoruz.
          Text(
            _formatMoney(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Kullanıcıya bakiyenin nasıl hesaplandığını açıklıyoruz.
          const Text(
            'Gelirlerinden giderlerini çıkar.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Gelir ve gider bilgilerini göstermek için ortak bir kart tasarımı oluşturuyoruz.
  // Parametreler sayesinde aynı metodu hem gelir hem gider için kullanabiliyoruz.
  Widget _buildStatisticCard(
    String title, // Kartın başlığını alıyoruz.
    double amount, // Gösterilecek para miktarını alıyoruz.
    IconData icon, // Kartta gösterilecek ikonu alıyoruz.
    Color color, // İkonun rengini alıyoruz.
  ) {
    return Container(
      // Kartın içerisindeki elemanlarla kenarlar arasında boşluk bırakıyoruz.
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),

      // Kartın içeriğini dikey olarak sıralıyoruz.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parametre olarak gelen ikonu ve rengi gösteriyoruz.
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 12),

          // Kartın başlığını ekranda gösteriyoruz.
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 6),

          // Para miktarının kartın genişliğine sığmasını sağlıyoruz.
          // FittedBox gerekirse yazıyı küçülterek taşmayı engeller.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              // Gelen amount değerini para formatına dönüştürüyoruz.
              _formatMoney(amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Her bir bütçe işlemini liste içerisinde gösterecek tasarımı oluşturuyoruz.
  // Parametre olarak bir BudgetTransaction nesnesi alıyoruz.
  Widget _buildTransactionTile(BudgetTransaction item) {
    // Card ile işlem bilgilerini bir kart içerisinde gösteriyoruz.
    return Card(
      color: Colors.white,

      // Kartın gölgesini kaldırıyoruz.
      elevation: 0,

      // Kartın alt kısmına 10 piksel boşluk bırakıyoruz.
      margin: const EdgeInsets.only(bottom: 10),

      // ListTile ile ikon, başlık, açıklama ve tutarı aynı satırda gösteriyoruz.
      child: ListTile(
        // İşlemin gelir veya gider olmasına göre dairesel ikon oluşturuyoruz.
        leading: CircleAvatar(
          // Gelir işlemlerinde açık yeşil, gider işlemlerinde açık kırmızı arka plan kullanıyoruz.
          backgroundColor: item.isIncome
              ? const Color(0xFFD1FAE5)
              : const Color(0xFFFEE2E2),

          child: Icon(
            // Gelirse artı, giderse eksi ikonu gösteriyoruz.
            item.isIncome ? Icons.add : Icons.remove,

            // İkonun rengini gelir veya gider durumuna göre belirliyoruz.
            color: item.isIncome
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
          ),
        ),

        // İşlemin başlığını gösteriyoruz.
        // maxLines ile tek satırda gösterilmesini sağlıyoruz.
        // Metin uzun olursa ellipsis ile sonuna üç nokta ekliyoruz.
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),

        // İşlemin hangi kategoriye ait olduğunu gösteriyoruz.
        subtitle: Text(item.category),

        // İşlem tutarını kartın sağ tarafında gösteriyoruz.
        trailing: Text(
          // Gelir ise +, gider ise - işareti ekliyoruz.
          // Ardından işlem tutarını para formatında gösteriyoruz.
          '${item.isIncome ? '+' : '-'}'
          '${_formatMoney(item.amount)}',

          style: TextStyle(
            fontWeight: FontWeight.bold,

            // Gelirleri yeşil, giderleri kırmızı renkte gösteriyoruz.
            color: item.isIncome
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
          ),
        ),
      ),
    );
  }

  // Seçilen bütçe işlemini listeden silmek için metot oluşturuyoruz.
  // Parametre olarak silinmek istenen işlemi alıyoruz.
  void _deleteTransaction(BudgetTransaction item) {
    // setState ile yapılan değişikliğin ekrana yansımasını sağlıyoruz.
    setState(() {
      // removeWhere ile listedeki koşula uyan elemanları siliyoruz.
      // İşlemin id değeri gönderilen işlemin id değeriyle aynıysa siliniyor.
      // Böylece yalnızca seçilen işlem listeden kaldırılıyor.
      _transactions.removeWhere((transaction) => transaction.id == item.id);
    });
  }
}
