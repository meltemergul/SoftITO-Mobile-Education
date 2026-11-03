import 'package:flutter/material.dart';

import '../models/ogrenci_model.dart';
import '../services/firestore_ogrenci_servisi.dart';

// Öğrenci ekleme, listeleme, silme ve güncelleme işlemlerini yaptığım ekran.
class FireStoreYonetimEkrani extends StatefulWidget {
  const FireStoreYonetimEkrani({super.key});

  @override
  State<FireStoreYonetimEkrani> createState() => _FireStoreYonetimEkraniState();
}

class _FireStoreYonetimEkraniState extends State<FireStoreYonetimEkrani> {
  // Firestore işlemlerini tek bir servis üzerinden yönetiyorum.
  final FireStoreOgrenciServisi _servis = FireStoreOgrenciServisi();

  // TextField alanlarına girilen verileri kontrol etmek için controller oluşturuyorum.
  final TextEditingController _adSoyadKontrolcusu = TextEditingController();

  final TextEditingController _projeKontrolcusu = TextEditingController();

  final TextEditingController _notKontrolcusu = TextEditingController();

  // Kaydetme sırasında butonun tekrar tıklanmasını engellemek için durum tutuyorum.
  bool _kaydediliyor = false;

  // Firestore'dan gelen öğrenci listesini canlı olarak tutuyorum.
  late final Stream<List<OgrenciModel>> _ogrenciAkisi;

  @override
  void initState() {
    super.initState();

    // Ekran ilk açıldığında öğrencileri Firestore üzerinden dinlemeye başlıyorum.
    // Böylece veritabanında değişiklik olduğunda liste otomatik güncelleniyor.
    _ogrenciAkisi = _servis.ogrencileriDinle();
  }

  @override
  void dispose() {
    // Kullanmadığım controller nesnelerini bellekten temizliyorum.
    _adSoyadKontrolcusu.dispose();
    _projeKontrolcusu.dispose();
    _notKontrolcusu.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sayfanın üst başlık alanını oluşturuyorum.
      appBar: AppBar(
        title: const Text('Canlı Firestore Ekranı'),
        backgroundColor: Colors.amber.shade600,
      ),

      // Form ve öğrenci listesini alt alta yerleştiriyorum.
      body: Column(
        children: [
          // ÖĞRENCİ EKLEME FORMU
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Öğrencinin adını ve soyadını gireceğim alan.
                TextField(
                  controller: _adSoyadKontrolcusu,
                  decoration: const InputDecoration(
                    labelText: 'Öğrenci Adı Soyadı',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    // Proje adını gireceğim alan.
                    // Expanded ile satırda daha fazla yer kaplamasını sağlıyorum.
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _projeKontrolcusu,
                        decoration: const InputDecoration(
                          labelText: 'Proje Adı',
                          prefixIcon: Icon(Icons.folder),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Öğrencinin notunu gireceğim alan.
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _notKontrolcusu,
                        // Sayısal klavyenin açılmasını sağlıyorum.
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Not (0-100)',
                          prefixIcon: Icon(Icons.grade),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // KAYDET BUTONU
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),

                  // Kayıt devam ederken butonu pasif hale getiriyorum.
                  // Kayıt bitince tekrar aktif oluyor.
                  onPressed: _kaydediliyor ? null : _yeniOgrenciKaydet,

                  icon: const Icon(Icons.cloud_upload),

                  // Kaydetme durumuna göre buton yazısını değiştiriyorum.
                  label: Text(
                    _kaydediliyor ? 'Kaydediliyor...' : 'Buluta Kaydet',
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2),

          // CANLI ÖĞRENCİ LİSTESİ
          // Expanded ile listenin kalan tüm alanı kaplamasını sağlıyorum.
          Expanded(
            child: StreamBuilder<List<OgrenciModel>>(
              // Servisten aldığım canlı veri akışını StreamBuilder'a veriyorum.
              stream: _ogrenciAkisi,

              // Firestore'dan gelen verinin durumuna göre ekranı oluşturuyorum.
              builder: (context, snapshot) {
                // Veritabanından veri gelirken bir hata oluşursa gösteriyorum.
                if (snapshot.hasError) {
                  return Center(child: Text('Bulut hatası: ${snapshot.error}'));
                }

                // İlk veriler yüklenirken dönen yüklenme animasyonunu gösteriyorum.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Henüz öğrenci yoksa kullanıcıya bilgi veriyorum.
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Henüz bulutta kayıtlı öğrenci yok.'),
                  );
                }

                // Firestore'dan gelen öğrenci listesini alıyorum.
                final List<OgrenciModel> ogrenciler = snapshot.data!;

                // Öğrencileri performanslı şekilde listelemek için ListView.builder kullanıyorum.
                return ListView.builder(
                  itemCount: ogrenciler.length,

                  itemBuilder: (context, index) {
                    // Listedeki mevcut sırada bulunan öğrenciyi alıyorum.
                    final ogrenci = ogrenciler[index];

                    // Öğrenciyi sola kaydırarak silebilmemi sağlıyor.
                    return Dismissible(
                      // Her öğrenciye kendine ait benzersiz bir anahtar veriyorum.
                      key: ValueKey(ogrenci.id),

                      // Yalnızca sağdan sola kaydırma hareketine izin veriyorum.
                      direction: DismissDirection.endToStart,

                      // Öğrenci kaydırılırken arka planda silme alanını gösteriyorum.
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                      ),

                      // SİLME İŞLEMİ
                      onDismissed: (direction) async {
                        try {
                          // Kaydırılan öğrenciyi belge ID'sine göre Firestore'dan siliyorum.
                          await _servis.ogrenciSil(ogrenci.id);

                          // İşlem tamamlandığında ekran hâlâ açıksa devam ediyorum.
                          if (!mounted) return;

                          _mesajGoster('${ogrenci.adSoyad} silindi.');
                        } catch (e) {
                          if (!mounted) return;

                          // Silme sırasında hata oluşursa kullanıcıya bildiriyorum.
                          _mesajGoster('Silme hatası: $e');
                        }
                      },

                      child: ListTile(
                        // NOT RENKLENDİRME
                        // Öğrencinin notuna göre avatar rengini değiştiriyorum.
                        leading: CircleAvatar(
                          backgroundColor: ogrenci.notu >= 80
                              ? Colors.green
                              : ogrenci.notu >= 50
                              ? Colors.orange
                              : Colors.red,

                          child: Text(
                            '${ogrenci.notu}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Öğrencinin adını liste başlığında gösteriyorum.
                        title: Text(
                          ogrenci.adSoyad,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // Öğrencinin proje adını ve kayıt tarihini gösteriyorum.
                        subtitle: Text(
                          'Proje: ${ogrenci.projeAdi}\n'
                          'Kayıt: ${_tarihFormatla(ogrenci.kayitTarihi)}',
                        ),

                        // Başlık ve alt başlık için üç satırlık alan ayırıyorum.
                        isThreeLine: true,

                        // NOT GÜNCELLEME BUTONU
                        trailing: IconButton(
                          onPressed: () {
                            // Düzenleme butonuna basıldığında not güncelleme penceresini açıyorum.
                            _notGuncelleDialog(ogrenci);
                          },
                          icon: const Icon(Icons.edit, color: Colors.amber),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // YENİ ÖĞRENCİ KAYDETME
  Future<void> _yeniOgrenciKaydet() async {
    // TextField alanlarındaki verileri alıp başındaki ve sonundaki boşlukları temizliyorum.
    final adSoyad = _adSoyadKontrolcusu.text.trim();
    final proje = _projeKontrolcusu.text.trim();

    // Girilen notu String'den int veri tipine dönüştürüyorum.
    // Dönüştürme başarısız olursa null döner.
    final not = int.tryParse(_notKontrolcusu.text.trim());

    // Zorunlu alanların boş bırakılıp bırakılmadığını kontrol ediyorum.
    if (adSoyad.isEmpty || proje.isEmpty) {
      _mesajGoster('Lütfen öğrenci adını ve proje adını giriniz.');
      return;
    }

    // Notun sayısal ve 0-100 aralığında olup olmadığını kontrol ediyorum.
    if (not == null || not < 0 || not > 100) {
      _mesajGoster('Not 0 ile 100 arasında olmalıdır.');
      return;
    }

    // Kaydetme durumunu true yaparak butonu pasif hale getiriyorum.
    setState(() {
      _kaydediliyor = true;
    });

    try {
      // Servis metodunu çağırarak öğrenciyi Firestore'a kaydediyorum.
      await _servis.ogrenciEkle(adSoyad: adSoyad, projeAdi: proje, notu: not);

      // Kayıt başarılı olduğunda giriş alanlarını temizliyorum.
      _adSoyadKontrolcusu.clear();
      _projeKontrolcusu.clear();
      _notKontrolcusu.clear();

      if (!mounted) return;

      // Kullanıcıya kayıt işleminin başarılı olduğunu bildiriyorum.
      _mesajGoster('Öğrenci başarıyla kaydedildi.');
    } catch (e) {
      if (!mounted) return;

      // Kayıt sırasında hata oluşursa hata mesajını gösteriyorum.
      _mesajGoster('Kayıt başarısız: $e');
    } finally {
      // İşlem başarılı veya başarısız olsa da kaydetme durumunu sıfırlıyorum.
      // mounted kontrolü, ekran kapandıysa setState çağırmamamı sağlıyor.
      if (mounted) {
        setState(() {
          _kaydediliyor = false;
        });
      }
    }
  }

  // NOT GÜNCELLEME DİYALOĞU
  Future<void> _notGuncelleDialog(OgrenciModel ogrenci) async {
    // Güncelleme penceresindeki TextField için controller oluşturuyorum.
    // İçine öğrencinin mevcut notunu başlangıç değeri olarak yazıyorum.
    final TextEditingController notController = TextEditingController(
      text: ogrenci.notu.toString(),
    );

    try {
      // Kullanıcıya yeni not girebileceği bir AlertDialog açıyorum.
      final sonuc = await showDialog<bool>(
        context: context,

        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Öğrenci Notunu Güncelle'),

            content: TextField(
              controller: notController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Yeni Not (0-100)',
                border: OutlineInputBorder(),
              ),
            ),

            actions: [
              // İptal butonuna basıldığında false döndürüyorum.
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('İptal'),
              ),

              // Güncelle butonuna basıldığında true döndürüyorum.
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Güncelle'),
              ),
            ],
          );
        },
      );

      // Kullanıcı iptal ettiyse güncelleme işlemine devam etmiyorum.
      if (sonuc != true) return;

      // Kullanıcının girdiği yeni notu tam sayıya dönüştürüyorum.
      final yeniNot = int.tryParse(notController.text.trim());

      // Girilen notun geçerli olup olmadığını kontrol ediyorum.
      if (yeniNot == null || yeniNot < 0 || yeniNot > 100) {
        _mesajGoster('Geçerli bir not giriniz (0-100).');
        return;
      }

      // Öğrencinin belge ID'sini ve yeni notunu servise gönderiyorum.
      await _servis.ogrenciNotuGuncelle(ogrenci.id, yeniNot);

      if (!mounted) return;

      // Güncelleme başarılı olduğunda kullanıcıya bilgi veriyorum.
      _mesajGoster('Öğrenci notu güncellendi.');
    } catch (e) {
      if (!mounted) return;

      // Güncelleme sırasında oluşan hatayı kullanıcıya gösteriyorum.
      _mesajGoster('Güncelleme hatası: $e');
    } finally {
      // Diyalogda kullandığım controller nesnesini bellekten temizliyorum.
      notController.dispose();
    }
  }

  // TARİH FORMATLAMA
  String _tarihFormatla(DateTime tarih) {
    // Gün ve ay tek basamaklıysa başına 0 ekliyorum.
    final gun = tarih.day.toString().padLeft(2, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    final yil = tarih.year;

    // Tarihi gün.ay.yıl formatında String olarak döndürüyorum.
    return '$gun.$ay.$yil';
  }

  // ORTAK MESAJ GÖSTERME
  void _mesajGoster(String mesaj) {
    // SnackBar kullanarak ekranda kısa süreli bilgilendirme mesajı gösteriyorum.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }
}
