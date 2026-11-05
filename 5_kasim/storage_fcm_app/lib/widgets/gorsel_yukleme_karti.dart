import 'dart:io';

import 'package:flutter/material.dart';

class GorselYuklemeKarti extends StatelessWidget {
  final File? secilenDosya;
  final String? yuklenenUrl;
  final double yuklemeOrani;
  final bool yukleniyorMu;
  final VoidCallback onGaleridenSec;
  final VoidCallback onKameradanCek;
  final VoidCallback onBulutaYukle;

  const GorselYuklemeKarti({
    super.key,
    required this.secilenDosya,
    required this.yuklemeOrani,
    required this.yuklenenUrl,
    required this.yukleniyorMu,
    required this.onGaleridenSec,
    required this.onKameradanCek,
    required this.onBulutaYukle,
  });

  @override //sınıf ezmek için
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: Color.fromARGB(255, 41, 185, 41),
                ),
                SizedBox(width: 8),
                Text(
                  'Firebase Medya yükleyici',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 121, 212),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 119, 0, 255),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              alignment: Alignment.center,
              child: secilenDosya != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        secilenDosya!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : yuklenenUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        yuklenenUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey.shade100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Henüz bir görsel seçilmedi',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
            ),
            if (yukleniyorMu) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: yuklemeOrani,
                backgroundColor: Colors.grey.shade200,
                color: const Color.fromARGB(0, 8, 69, 3),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                'Yukleniyor: %${(yuklemeOrani * 100).toStringAsFixed(0)}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: yukleniyorMu ? null : onGaleridenSec,
                    label: const Text('Galeri'),
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: yukleniyorMu ? null : onKameradanCek,
                    label: const Text('Kamera'),
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ],
            ),
            if (secilenDosya != null) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: yukleniyorMu ? null : onBulutaYukle,
                label: const Text('Buluta Yükle'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(0, 213, 141, 46),
                ),
                icon: const Icon(Icons.cloud_upload),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
