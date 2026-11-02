import 'package:flutter/material.dart';

import 'dart:convert';

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
