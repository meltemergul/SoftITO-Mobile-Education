import 'package:flutter/material.dart';

import '../models/ogrenci_model.dart';
import '../services/firestore_ogrenci_servisi.dart';

class FireStoreYonetimEkrani extends StatefulWidget {
  const FireStoreYonetimEkrani({super.key});

  @override
  State<FireStoreYonetimEkrani> createState() => _FireStoreYonetimEkraniState();
}

class _FireStoreYonetimEkraniState extends State<FireStoreYonetimEkrani> {
  // Firestore servis nesnesi
  final FireStoreOgrenciServisi _servis = FireStoreOgrenciServisi();

  // TextField kontrolcüleri
  final TextEditingController _adSoyadKontrolcusu = TextEditingController();

  final TextEditingController _projeKontrolcusu = TextEditingController();

  final TextEditingController _notKontrolcusu = TextEditingController();

  // Kaydetme işleminin durumunu tutar.
  bool _kaydediliyor = false;

  // Canlı öğrenci akışı
  late final Stream<List<OgrenciModel>> _ogrenciAkisi;

  @override
  void initState() {
    super.initState();

    // Sayfa açıldığında Firestore dinlenmeye başlanır.
    _ogrenciAkisi = _servis.ogrencileriDinle();
  }

  @override
  void dispose() {
    _adSoyadKontrolcusu.dispose();
    _projeKontrolcusu.dispose();
    _notKontrolcusu.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canlı Firestore Ekranı'),
        backgroundColor: Colors.amber.shade600,
      ),

      body: Column(
        children: [
          // ÖĞRENCİ EKLEME FORMU
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
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
                    // Proje adı alanı
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

                    // Not alanı
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _notKontrolcusu,
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

                  onPressed: _kaydediliyor ? null : _yeniOgrenciKaydet,

                  icon: const Icon(Icons.cloud_upload),

                  label: Text(
                    _kaydediliyor ? 'Kaydediliyor...' : 'Buluta Kaydet',
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2),

          // CANLI ÖĞRENCİ LİSTESİ
          Expanded(
            child: StreamBuilder<List<OgrenciModel>>(
              stream: _ogrenciAkisi,

              builder: (context, snapshot) {
                // Hata kontrolü
                if (snapshot.hasError) {
                  return Center(child: Text('Bulut hatası: ${snapshot.error}'));
                }

                // Yüklenme kontrolü
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Boş liste kontrolü
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Henüz bulutta kayıtlı öğrenci yok.'),
                  );
                }

                final List<OgrenciModel> ogrenciler = snapshot.data!;

                return ListView.builder(
                  itemCount: ogrenciler.length,

                  itemBuilder: (context, index) {
                    // O anki öğrenciyi alıyoruz.
                    final ogrenci = ogrenciler[index];

                    return Dismissible(
                      key: ValueKey(ogrenci.id),

                      direction: DismissDirection.endToStart,

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
                          await _servis.ogrenciSil(ogrenci.id);

                          if (!mounted) return;

                          _mesajGoster('${ogrenci.adSoyad} silindi.');
                        } catch (e) {
                          if (!mounted) return;

                          _mesajGoster('Silme hatası: $e');
                        }
                      },

                      child: ListTile(
                        // NOT RENKLENDİRME
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

                        // ÖĞRENCİ ADI
                        title: Text(
                          ogrenci.adSoyad,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // PROJE VE TARİH
                        subtitle: Text(
                          'Proje: ${ogrenci.projeAdi}\n'
                          'Kayıt: ${_tarihFormatla(ogrenci.kayitTarihi)}',
                        ),

                        isThreeLine: true,

                        // NOT GÜNCELLEME BUTONU
                        trailing: IconButton(
                          onPressed: () {
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
    final adSoyad = _adSoyadKontrolcusu.text.trim();

    final proje = _projeKontrolcusu.text.trim();

    final not = int.tryParse(_notKontrolcusu.text.trim());

    // Boş alan kontrolü
    if (adSoyad.isEmpty || proje.isEmpty) {
      _mesajGoster('Lütfen öğrenci adını ve proje adını giriniz.');
      return;
    }

    // Not kontrolü
    if (not == null || not < 0 || not > 100) {
      _mesajGoster('Not 0 ile 100 arasında olmalıdır.');
      return;
    }

    setState(() {
      _kaydediliyor = true;
    });

    try {
      await _servis.ogrenciEkle(adSoyad: adSoyad, projeAdi: proje, notu: not);

      _adSoyadKontrolcusu.clear();
      _projeKontrolcusu.clear();
      _notKontrolcusu.clear();

      if (!mounted) return;

      _mesajGoster('Öğrenci başarıyla kaydedildi.');
    } catch (e) {
      if (!mounted) return;

      _mesajGoster('Kayıt başarısız: $e');
    } finally {
      if (mounted) {
        setState(() {
          _kaydediliyor = false;
        });
      }
    }
  }

  // NOT GÜNCELLEME DİYALOĞU
  Future<void> _notGuncelleDialog(OgrenciModel ogrenci) async {
    final TextEditingController notController = TextEditingController(
      text: ogrenci.notu.toString(),
    );

    try {
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
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('İptal'),
              ),

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

      // Kullanıcı iptal ettiyse işlem yapılmaz.
      if (sonuc != true) return;

      final yeniNot = int.tryParse(notController.text.trim());

      if (yeniNot == null || yeniNot < 0 || yeniNot > 100) {
        _mesajGoster('Geçerli bir not giriniz (0-100).');
        return;
      }

      await _servis.ogrenciNotuGuncelle(ogrenci.id, yeniNot);

      if (!mounted) return;

      _mesajGoster('Öğrenci notu güncellendi.');
    } catch (e) {
      if (!mounted) return;

      _mesajGoster('Güncelleme hatası: $e');
    } finally {
      notController.dispose();
    }
  }

  // TARİH FORMATLAMA
  String _tarihFormatla(DateTime tarih) {
    final gun = tarih.day.toString().padLeft(2, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    final yil = tarih.year;

    return '$gun.$ay.$yil';
  }

  // ORTAK MESAJ GÖSTERME
  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }
}
