import 'package:flutter/material.dart';

// Oluşturacağımız gelir veya gider işleminin veri yapısını kullanmak için model sınıfını içe aktarıyoruz.
import '../models/budget_transaction.dart';

// İşlem eklerken kullanıcının seçebileceği kategorileri kullanmak için kategori modelini içe aktarıyoruz.
import '../models/category_model.dart';

// Yeni gelir veya gider işlemi eklemek için form ekranımızı oluşturuyoruz.
// StatefulWidget kullanıyoruz çünkü form içerisindeki alanların değerleri değişebiliyor.
class TransactionFormScreen extends StatefulWidget {
  // Constructor (kurucu metot).
  // super.key ile üst sınıfın key parametresini almasını sağlıyoruz.
  const TransactionFormScreen({super.key});

  // StatefulWidget için değişebilen verileri yönetecek State sınıfını oluşturuyoruz.
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

// Form ekranının state ve işlemlerini yönettiğimiz sınıfı oluşturuyoruz.
class _TransactionFormScreenState extends State<TransactionFormScreen> {
  // Formun durumunu kontrol edebilmek ve doğrulama işlemlerini yapabilmek için GlobalKey oluşturuyoruz.
  // validate() metodunu kullanarak form içerisindeki alanların doğru doldurulup doldurulmadığını kontrol edeceğiz.
  final _formKey = GlobalKey<FormState>();

  // İşlem adının yazıldığı TextFormField alanını kontrol etmek için controller oluşturuyoruz.
  // Kullanıcının girdiği metne erişmemizi sağlar.
  final _titleController = TextEditingController();

  // İşlem tutarının yazıldığı alanı kontrol etmek için ikinci bir controller oluşturuyoruz.
  final _amountController = TextEditingController();

  // İşlemin gelir mi gider mi olduğunu tutuyoruz.
  // Başlangıçta false vererek varsayılan olarak gider seçili olmasını sağlıyoruz.
  bool _isIncome = false;

  // Kullanıcının seçtiği kategoriyi tutuyoruz.
  // String? kullanmamızın sebebi başlangıçta henüz kategori seçilmemiş olmasıdır.
  String? _selectedCategory;

  // İşlem tarihini tutuyoruz.
  // Başlangıç değeri olarak o anki tarihi alıyoruz.
  DateTime _selectedDate = DateTime.now();

  // Kullanıcının gelir veya gider seçimine göre gösterilecek kategorileri filtreliyoruz.
  // Getter sayesinde bu listeye erişildiğinde güncel kategori seçimine göre hesaplama yapılır.
  List<CategoryModel> get _availableCategories => CategoryModel.categories
      .where(
        (category) => _isIncome
            // Gelir seçildiyse yalnızca Maaş ve Diğer kategorilerini gösteriyoruz.
            ? category.name == 'Maaş' || category.name == 'Diğer'
            // Gider seçildiyse Maaş kategorisi dışındaki kategorileri gösteriyoruz.
            : category.name != 'Maaş',
      )
      // where sonucunda elde ettiğimiz filtrelenmiş listeyi List olarak oluşturuyoruz.
      .toList();

  // Widget ekrandan kaldırıldığında çalışır.
  // Oluşturduğumuz controller nesnelerini artık kullanmayacağımız için hafızadan temizliyoruz.
  @override
  void dispose() {
    // İşlem adı alanının controller nesnesini temizliyoruz.
    _titleController.dispose();

    // İşlem tutarı alanının controller nesnesini temizliyoruz.
    _amountController.dispose();

    // Üst sınıfın dispose metodunu da çağırıyoruz.
    super.dispose();
  }

  // Kullanıcının işlem tarihini seçebilmesi için tarih seçici açan metodu oluşturuyoruz.
  // async kullanıyoruz çünkü tarih seçimi Future döndürür ve sonucu beklememiz gerekir.
  Future<void> _pickDate() async {
    // Flutter'ın hazır tarih seçme penceresini açıyoruz.
    final date = await showDatePicker(
      // Tarih seçicinin hangi ekranın üzerinde açılacağını belirtiyoruz.
      context: context,

      // Tarih seçici ilk açıldığında mevcut seçili tarihi gösteriyoruz.
      initialDate: _selectedDate,

      // Kullanıcının seçebileceği en eski tarihi belirliyoruz.
      firstDate: DateTime(2020),

      // Gelecekteki tarihlerin seçilmesini engelliyoruz.
      lastDate: DateTime.now(),
    );

    // Kullanıcı bir tarih seçtiyse ve iptal etmediyse işlem yapıyoruz.
    // İptal edilirse date null döner.
    if (date != null) {
      // Seçilen tarihi güncelliyoruz ve ekranın yeniden oluşturulmasını sağlıyoruz.
      setState(() => _selectedDate = date);
    }
  }

  // Kullanıcının doldurduğu form bilgilerini kontrol edip yeni işlem oluşturan metodu yazıyoruz.
  void _saveTransaction() {
    // Form içerisindeki tüm validator metotlarını çalıştırıyoruz.
    // Alanlardan biri hatalıysa validate false döndürür ve return ile metottan çıkıyoruz.
    if (!_formKey.currentState!.validate()) return;

    // Kullanıcının girdiği tutarı double veri tipine dönüştürüyoruz.
    // trim() baştaki ve sondaki boşlukları temizler.
    // replaceAll(',', '.') Türkçe ondalık virgülünü noktaya dönüştürür.
    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    // Formdan gelen bilgilerle yeni bir BudgetTransaction nesnesi oluşturuyoruz.
    final transaction = BudgetTransaction(
      // İşleme benzersiz bir ID oluşturuyoruz.
      // microsecondsSinceEpoch mevcut zamanı mikrosaniye cinsinden verir.
      // toString() ile String veri tipine dönüştürüyoruz.
      id: DateTime.now().microsecondsSinceEpoch.toString(),

      // İşlem adını controller üzerinden alıyoruz ve gereksiz boşlukları temizliyoruz.
      title: _titleController.text.trim(),

      // Kullanıcının seçtiği kategoriyi alıyoruz.
      // ! işareti burada değerin null olmadığını belirtiyoruz.
      category: _selectedCategory!,

      // Kullanıcının girdiği işlem tutarını ekliyoruz.
      amount: amount,

      // Kullanıcının seçtiği tarihi ekliyoruz.
      date: _selectedDate,

      // İşlemin gelir veya gider olduğunu ekliyoruz.
      isIncome: _isIncome,
    );

    // Oluşturduğumuz işlem nesnesini bir önceki ekrana geri gönderiyoruz.
    // DashboardScreen bu sonucu alarak işlem listesine ekleyecek.
    Navigator.pop(context, transaction);
  }

  // Form ekranının arayüzünü oluşturuyoruz.
  @override
  Widget build(BuildContext context) {
    // Scaffold ile sayfanın temel yapısını oluşturuyoruz.
    return Scaffold(
      // Sayfanın üst kısmında başlık gösteriyoruz.
      appBar: AppBar(title: const Text('Yeni İşlem')),

      // SafeArea ile cihazın çentik ve sistem alanlarına taşmayı önlüyoruz.
      body: SafeArea(
        // Form widget'ı ile içerisindeki alanların doğrulama işlemlerini yönetiyoruz.
        child: Form(
          // Oluşturduğumuz GlobalKey'i forma bağlıyoruz.
          // Böylece formun validate() metoduna dışarıdan erişebiliyoruz.
          key: _formKey,

          // Form alanlarının dikey olarak kaydırılmasını sağlıyoruz.
          child: ListView(
            // Formun çevresine 20 piksel boşluk bırakıyoruz.
            padding: const EdgeInsets.all(20),

            children: [
              // Kullanıcının gelir veya gider seçebilmesi için seçim butonları oluşturuyoruz.
              SegmentedButton<bool>(
                // Seçilebilir iki seçenek tanımlıyoruz.
                segments: const [
                  // Gelir seçeneği.
                  ButtonSegment(
                    value: true,
                    label: Text('Gelir'),
                    icon: Icon(Icons.trending_up),
                  ),

                  // Gider seçeneği.
                  ButtonSegment(
                    value: false,
                    label: Text('Gider'),
                    icon: Icon(Icons.trending_down),
                  ),
                ],

                // Hangi seçeneğin aktif olduğunu belirliyoruz.
                // Set içerisinde mevcut _isIncome değerini tutuyoruz.
                selected: {_isIncome},

                // Kullanıcı seçim yaptığında çalışır.
                // selection, seçilen değeri Set<bool> olarak döndürür.
                onSelectionChanged: (selection) {
                  // Seçilen gelir/gider değerini ve kategoriyi güncelliyoruz.
                  setState(() {
                    // Set içerisindeki ilk seçilen değeri alıyoruz.
                    _isIncome = selection.first;

                    // Gelir/gider değiştiğinde önceki kategori seçimini sıfırlıyoruz.
                    // Çünkü yeni işlem türünde farklı kategoriler gösterilebilir.
                    _selectedCategory = null;
                  });
                },
              ),

              const SizedBox(height: 24),

              // İşlem adı alanının başlığını gösteriyoruz.
              const Text('İşlem adı'),

              const SizedBox(height: 8),

              // Kullanıcının işlem adını gireceği metin alanını oluşturuyoruz.
              TextFormField(
                // Bu alanı _titleController ile kontrol ediyoruz.
                controller: _titleController,

                // Alanın ipucu metnini ve kenarlık tasarımını belirliyoruz.
                decoration: const InputDecoration(
                  hintText: 'Örn. Market alışverişi',
                  border: OutlineInputBorder(),
                ),

                // Kullanıcının girdiği değerin geçerli olup olmadığını kontrol ediyoruz.
                // value null veya boşsa hata mesajı döndürüyoruz.
                // Geçerliyse null döndürerek hata olmadığını belirtiyoruz.
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'İşlem adı zorunludur.'
                    : null,
              ),

              const SizedBox(height: 20),

              // İşlem tutarı alanının başlığını gösteriyoruz.
              const Text('Tutar (₺)'),

              const SizedBox(height: 8),

              // Kullanıcının para miktarını gireceği alanı oluşturuyoruz.
              TextFormField(
                // Tutar alanını _amountController ile kontrol ediyoruz.
                controller: _amountController,

                // Klavyenin sayısal girişe uygun açılmasını sağlıyoruz.
                // decimal: true ile ondalıklı sayı girişine izin veriyoruz.
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                // Tutar alanının ipucu metnini, kenarlığını ve para birimi işaretini belirliyoruz.
                decoration: const InputDecoration(
                  hintText: '0,00',
                  border: OutlineInputBorder(),
                  prefixText: '₺ ',
                ),

                // Girilen tutarın geçerli olup olmadığını kontrol ediyoruz.
                validator: (value) {
                  // Girilen metni sayıya dönüştürmeyi deniyoruz.
                  // tryParse dönüşüm başarısız olursa hata vermek yerine null döndürür.
                  // Virgül kullanılmışsa noktaya çeviriyoruz.
                  final amount = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );

                  // Tutar geçersizse, sonlu değilse veya sıfırdan küçük/eşitse hata veriyoruz.
                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Pozitif ve geçerli bir tutar gir.';
                  }

                  // Kontroller başarılıysa hata olmadığını belirtiyoruz.
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Kategori alanının başlığını gösteriyoruz.
              const Text('Kategori'),

              const SizedBox(height: 8),

              // Kullanıcının listeden kategori seçebilmesi için açılır menü oluşturuyoruz.
              DropdownButtonFormField<String>(
                // Seçili olan kategoriyi dropdown içerisinde gösteriyoruz.
                value: _selectedCategory,

                // Açılır menünün kenarlık tasarımını belirliyoruz.
                decoration: const InputDecoration(border: OutlineInputBorder()),

                // Henüz kategori seçilmediyse gösterilecek metin.
                hint: const Text('Kategori seç'),

                // Filtrelenmiş kategorileri dropdown seçeneklerine dönüştürüyoruz.
                // map ile her CategoryModel nesnesini bir DropdownMenuItem widget'ına çeviriyoruz.
                items: _availableCategories.map((category) {
                  return DropdownMenuItem(
                    // Kullanıcı bu kategoriyi seçtiğinde tutulacak değer.
                    value: category.name,

                    // Kategori ikonunu ve ismini yan yana gösteriyoruz.
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color),
                        const SizedBox(width: 10),
                        Text(category.name),
                      ],
                    ),
                  );

                  // map sonucunu DropdownButtonFormField'ın beklediği listeye dönüştürüyoruz.
                }).toList(),

                // Kullanıcı yeni bir kategori seçtiğinde çalışır.
                onChanged: (value) {
                  // Seçilen kategoriyi güncelliyoruz.
                  setState(() => _selectedCategory = value);
                },

                // Kullanıcının kategori seçip seçmediğini kontrol ediyoruz.
                validator: (value) =>
                    value == null ? 'Kategori seçmelisin.' : null,
              ),

              const SizedBox(height: 20),

              // Kullanıcının işlem tarihini değiştirebilmesi için buton oluşturuyoruz.
              OutlinedButton.icon(
                // Butona basıldığında tarih seçme metodunu çalıştırıyoruz.
                onPressed: _pickDate,

                // Butonun içerisine takvim ikonu ekliyoruz.
                icon: const Icon(Icons.calendar_month),

                // Seçili tarihi gün.ay.yıl formatında gösteriyoruz.
                // ${} ile değişkenleri metin içerisine yerleştiriyoruz.
                label: Text(
                  'Tarih: ${_selectedDate.day}.'
                  '${_selectedDate.month}.'
                  '${_selectedDate.year}',
                ),
              ),

              const SizedBox(height: 28),

              // Kaydet butonunun yüksekliğini belirliyoruz.
              SizedBox(
                height: 54,

                // Kullanıcının formu kaydedebilmesi için buton oluşturuyoruz.
                child: ElevatedButton(
                  // Butona basıldığında form doğrulama ve kayıt metodunu çalıştırıyoruz.
                  onPressed: _saveTransaction,

                  child: const Text('İşlemi Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
