import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryModel({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<CategoryModel> categories = [
    CategoryModel(
      name: 'Market',
      icon: Icons.shopping_cart,
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
