import 'package:flutter/material.dart';

//kategoriler için model oluşturuldu. Bu model, kategori adını, simgesini ve rengini içerir. Ayrıca, önceden tanımlanmış kategorilerin bir listesini sağlar.
class CategoryModel {
  final String name; //string türünde kategori adı
  final IconData icon; //icon için IconData türü kullanıldı
  final Color color; //renk için Color türü kullanıldı

  const CategoryModel({
    required this.name,
    required this.icon, //zorunlu alanlar
    required this.color,
  });

  static const List<CategoryModel> categories = [
    // Önceden tanımlanmış kategoriler listesi
    CategoryModel(
      name: 'Market',
      icon: Icons.shopping_cart, // Market kategorisi için icon
      color: Color(0xFF10B981),
    ),
    CategoryModel(
      name: 'Ulaşım',
      icon: Icons.directions_bus,
      color: Color(0xFF3B82F6),
    ),
    CategoryModel(
      name: 'Faturalar',
      icon: Icons.receipt_long,
      color: Color(0xFFF59E0B),
    ),
    CategoryModel(
      name: 'Alışveriş',
      icon: Icons.shopping_bag,
      color: Color(0xFFEC4899),
    ),
    CategoryModel(
      name: 'Maaş',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF6366F1),
    ),
    CategoryModel(
      name: 'Diğer',
      icon: Icons.category,
      color: Color(0xFF64748B),
    ),
  ];
}
