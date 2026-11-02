import 'package:flutter/material.dart';
// İşlem bilgilerinin tutulduğu BudgetTransaction modelini içe aktarıyorum.
import '../models/budget_transaction.dart';

// Bu ekran yalnızca kendisine gönderilen işlemleri gösterdiği için
// StatefulWidget yerine StatelessWidget kullanıyorum.
class TransactionsScreen extends StatelessWidget {
  // DashboardScreen tarafından gönderilen gelir ve gider listesini tutuyorum.
  final List<BudgetTransaction> transactions;

  // Silinmek istenen işlemi üst ekrana bildirmek için callback tanımlıyorum.
  // ValueChanged<T>, T türünde bir değer alan ve void döndüren fonksiyondur.
  final ValueChanged<BudgetTransaction> onDelete;

  // Ekranın ihtiyaç duyduğu verileri constructor üzerinden alıyorum.
  // required sayesinde bu iki parametrenin gönderilmesi zorunlu oluyor.
  const TransactionsScreen({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  // Ekranın kullanıcı arayüzünü oluşturuyorum.
  @override
  Widget build(BuildContext context) {
    return ListView(
      // Listenin etrafına 20 birim boşluk bırakıyorum.
      padding: const EdgeInsets.all(20),

      // ListView içerisinde gösterilecek widget'ları belirliyorum.
      children: [
        // Ekranın başlığını oluşturuyorum.
        const Text(
          'İşlem Geçmişi',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        // Başlık ile işlem listesi arasına boşluk ekliyorum.
        const SizedBox(height: 16),

        // Eğer işlem listesi boşsa kullanıcıya bilgilendirme mesajı gösteriyorum.
        if (transactions.isEmpty)
          const Center(child: Text('Henüz işlem bulunmuyor.'))
        // İşlem varsa listedeki her bir işlemi ekrana yerleştiriyorum.
        else
          ...transactions.map((item) {
            // Her işlem için ayrı bir Card oluşturuyorum.
            return Card(
              color: Colors.white,

              // Kartın gölgesini kaldırıyorum.
              elevation: 0,

              // Kartların altına 10 birim boşluk bırakıyorum.
              margin: const EdgeInsets.only(bottom: 10),

              child: ListTile(
                // İşlemin gelir veya gider olmasına göre sol tarafta ikon gösteriyorum.
                leading: Icon(
                  item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,

                  // Gelirleri yeşil, giderleri kırmızı renkte gösteriyorum.
                  color: item.isIncome ? Colors.green : Colors.red,
                ),

                // İşlemin adını gösteriyorum.
                title: Text(item.title),

                // İşlemin kategorisini ve tarihini gösteriyorum.
                subtitle: Text(
                  '${item.category} • '
                  '${item.date.day}.${item.date.month}.${item.date.year}',
                ),

                // Kartın sağ tarafında tutar ve işlem menüsü bulunuyor.
                trailing: Row(
                  // Row'un tüm yatay alanı kaplamasını engelliyorum.
                  // Böylece sadece içerisindeki widget'lar kadar yer kaplıyor.
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    // İşlemin tutarını gösteriyorum.
                    Text(
                      // Gelirse +, giderse - işareti ekliyorum.
                      '${item.isIncome ? '+' : '-'}'
                      // Tutarı iki ondalık basamakla gösteriyorum.
                      '₺${item.amount.toStringAsFixed(2)}',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,

                        // Gelir ve gider için farklı renk kullanıyorum.
                        color: item.isIncome ? Colors.green : Colors.red,
                      ),
                    ),

                    // İşlemin yanında üç noktalı seçenek menüsü oluşturuyorum.
                    PopupMenuButton<String>(
                      // Kullanıcı menüden bir seçenek seçtiğinde çalışıyor.
                      onSelected: (value) {
                        // Seçilen seçenek silme ise üst ekrana haber veriyorum.
                        if (value == 'delete') {
                          onDelete(item);
                        }
                      },

                      // Menüde gösterilecek seçenekleri belirliyorum.
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
