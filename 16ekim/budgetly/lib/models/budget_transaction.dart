class BudgetTransaction {
  //budget sınıfı oluşturuldu
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final bool isIncome;

  const BudgetTransaction({
    //kurucu metot
    required this.id, //zorunlu alanlar
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}
