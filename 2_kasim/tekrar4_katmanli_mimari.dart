import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class UrunModel {
  final int id;
  final String baslik;
  final double fiyat;
  final String resimUrl;
  final String kategori;

  const UrunModel({
    required this.id,
    required this.baslik,
    required this.fiyat,
    required this.resimUrl,
    required this.kategori,
  });

  factory UrunModel.fromJson(Map<String, dynamic> json) {
    return UrunModel(
      id: json['id'] as int? ?? 0,
      baslik: json['title'] as String? ?? '',
      fiyat: (json['price'] as num).toDouble(),
      resimUrl: json['image'] as String? ?? 'https://via.placeholder.com/150',
      kategori: json['category'] as String? ?? 'Genel',
    );
  }
}

abstract class UrunServisi {
  Future<List<UrunModel>> urunleriGetir();
}

class CanliApiUrunServisi implements UrunServisi {
  static const String _base_Url = 'https://fakestoreapi.com/products';

  @override
  Future<List<UrunModel>> urunleriGetir() async {
    try {
      final yanit = await http
          .get(Uri.parse(_base_Url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // Zaman aşımı durumunda bir hata fırlat
              throw Exception('İstek zaman aşımına uğradı.');
            },
          );

      if (yanit.statusCode == 200) {
        final List<dynamic> hamListe = json.decode(yanit.body) as List<dynamic>;
        return hamListe
            .map((eleman) => UrunModel.fromJson(eleman as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Ürünleri getirirken bir hata oluştu: ${yanit.statusCode}',
        );
      }
    } catch (e) {
      print('Hata: $e');
      rethrow;
    }
  }
}
