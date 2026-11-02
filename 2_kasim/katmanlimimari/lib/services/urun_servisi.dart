import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/urun.dart';

import 'package:flutter/material.dart';

import '../services/i_urun_servisi.dart';

class CanliApiUrunServisi implements IUrunServisi {
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
