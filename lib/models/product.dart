import 'package:flutter/material.dart';

class Product {
  final dynamic id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final List<String> availableSizes;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.stock = 10,
    this.availableSizes = const ['S', 'M', 'L', 'XL', '2XL'],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? 'ไม่มีชื่อ',
      price: double.tryParse((json['price'] ?? 0).toString()) ?? 0,
      imageUrl: json['image_url'] ?? 'https://picsum.photos/400/500',
      category: json['category'] ?? 'เสื้อ',
      stock: int.tryParse((json['stock'] ?? 0).toString()) ?? 0,
      availableSizes: const ['S', 'M', 'L', 'XL', '2XL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
    };
  }
}

final List<String> categories = [
  'เสื้อ',
  'กระโปรง',
  'กางเกง',
  'เครื่องประดับ',
  'รองเท้า',
  'ถุงเท้า',
  'กระเป๋า'
];
