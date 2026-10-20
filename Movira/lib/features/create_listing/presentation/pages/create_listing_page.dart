import 'package:flutter/material.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedClass = 'Ekonomik';
  String _selectedTransmission = 'Otomatik';
  String _selectedFuel = 'Benzin';

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni Araç İlanı Oluştur',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aracınızı sisteme ekleyerek dakikalar içinde kiraya verin.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Fotoğraf Yükleme Alanı
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.35), width: 1.5),
            ),
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fotoğraf seçici açılıyor... (Maks 10 fotoğraf)')),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 8),
                  const Text('Araç Fotoğrafları Yükleyin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  const Text('Kapak fotoğrafı için en az 1 görsel seçiniz', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Form Alanları
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'İlan Başlığı',
              hintText: 'Örn: 2023 Renault Clio Touch — Tertemiz',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 14),

          DropdownButtonFormField<String>(
            initialValue: _selectedClass,
            decoration: const InputDecoration(
              labelText: 'Araç Sınıfı',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: ['Ekonomik', 'Konfor', 'SUV / 4x4', 'Premium', 'Minibüs']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedClass = val);
            },
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedTransmission,
                  decoration: const InputDecoration(
                    labelText: 'Vites',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Otomatik', 'Manuel']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTransmission = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedFuel,
                  decoration: const InputDecoration(
                    labelText: 'Yakıt',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Benzin', 'Dizel', 'Hibrit', 'Elektrik']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFuel = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Günlük Kiralama Bedeli (₺)',
              hintText: '1350',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('İlanınız taslak olarak kaydedildi ve onaya gönderildi!'),
                ),
              );
            },
            icon: const Icon(Icons.publish),
            label: const Text('İlanı Yayına Al', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
