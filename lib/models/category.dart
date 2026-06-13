import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String iconName; // Maps to Material Design Icon name
  final Color color;
  final double? budgetLimit;

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.budgetLimit,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    Color? color,
    double? budgetLimit,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconName': iconName,
    'color': color.value,
    'budgetLimit': budgetLimit,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    iconName: json['iconName'],
    color: Color(json['color']),
    budgetLimit: json['budgetLimit']?.toDouble(),
  );

  // Helper to map string to IconData
  IconData get iconData {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'coffee':
        return Icons.coffee;
      case 'payments':
        return Icons.payments;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }
}
