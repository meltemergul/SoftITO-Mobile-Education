import 'package:flutter/material.dart';

class HataliveDogruRow extends StatelessWidget {
  const HataliveDogruRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Row ve Layout Örneği')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hatalı Yapı: a overflowed by ** pixels(sarı siyah şerit)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8.0),
            Container(
              color: Colors.yellow,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.black),
                  const SizedBox(width: 8.0),
                  const Text(
                    'Kısa metin (hata vermez ama uzarsa Render patlar).',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Doğru Yapı:Flexible ve expanded ile sınırlandırılmıştır.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: Colors.green),
          Border: Border.all(color: Colors.black),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bu metin uzun olsa bile taşmaz çünkü Expanded ile sınırlandırılmıştır.',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Expanded widget, Row veya Column içindeki çocuk widget\'ların mevcut alanı paylaşmasını sağlar. Bu sayede taşma (overflow) sorunları önlenir.',
                        style: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
