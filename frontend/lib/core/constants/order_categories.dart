// lib/core/constants/order_categories.dart
// ✅ NEW: Order categories configuration

import 'package:flutter/material.dart';

/// Represents a single order category
class OrderCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String emoji;

  const OrderCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}

/// All available order categories
class OrderCategories {
  // Prevent instantiation
  OrderCategories._();

  /// List of all categories
  static const List<OrderCategory> all = [
    OrderCategory(
      id: 'regular',
      name: 'Hàng thường',
      description: 'Hàng hóa thông thường, không đặc biệt',
      icon: Icons.inventory_2,
      color: Colors.grey,
      emoji: '📦',
    ),
    OrderCategory(
      id: 'food',
      name: 'Đồ ăn/Thức uống',
      description: 'Thực phẩm, đồ ăn nhanh, đồ uống',
      icon: Icons.restaurant,
      color: Colors.orange,
      emoji: '🍕',
    ),
    OrderCategory(
      id: 'frozen',
      name: 'Đồ đông lạnh',
      description: 'Thực phẩm đông lạnh, cần bảo quản lạnh',
      icon: Icons.ac_unit,
      color: Colors.blue,
      emoji: '🧊',
    ),
    OrderCategory(
      id: 'valuable',
      name: 'Hàng giá trị cao',
      description: 'Trang sức, điện tử đắt tiền, cần cẩn thận',
      icon: Icons.diamond,
      color: Colors.purple,
      emoji: '💎',
    ),
    OrderCategory(
      id: 'electronics',
      name: 'Linh kiện điện tử',
      description: 'Linh kiện máy tính, phụ kiện điện tử',
      icon: Icons.devices,
      color: Colors.indigo,
      emoji: '🔧',
    ),
    OrderCategory(
      id: 'fashion',
      name: 'Thời trang',
      description: 'Quần áo, giày dép, phụ kiện thời trang',
      icon: Icons.checkroom,
      color: Colors.pink,
      emoji: '👗',
    ),
    OrderCategory(
      id: 'documents',
      name: 'Sách/Tài liệu',
      description: 'Sách vở, giấy tờ, tài liệu quan trọng',
      icon: Icons.description,
      color: Colors.brown,
      emoji: '📚',
    ),
    OrderCategory(
      id: 'fragile',
      name: 'Đồ dễ vỡ',
      description: 'Đồ thủy tinh, gốm sứ, cần xử lý cẩn thận',
      icon: Icons.warning_amber_rounded,
      color: Colors.amber,
      emoji: '🍶',
    ),
    OrderCategory(
      id: 'medical',
      name: 'Y tế/Dược phẩm',
      description: 'Thuốc men, thiết bị y tế, dược phẩm',
      icon: Icons.medical_services,
      color: Colors.red,
      emoji: '🏥',
    ),
    OrderCategory(
      id: 'gift',
      name: 'Quà tặng',
      description: 'Quà sinh nhật, quà kỷ niệm, quà tặng',
      icon: Icons.card_giftcard,
      color: Colors.green,
      emoji: '🎁',
    ),
  ];

  /// Default category
  static const String defaultCategoryId = 'regular';

  /// Get category by ID
  static OrderCategory? getById(String id) {
    try {
      return all.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get category name by ID
  static String getNameById(String id) {
    final category = getById(id);
    return category?.name ?? 'Hàng thường';
  }

  /// Get category icon by ID
  static IconData getIconById(String id) {
    final category = getById(id);
    return category?.icon ?? Icons.inventory_2;
  }

  /// Get category color by ID
  static Color getColorById(String id) {
    final category = getById(id);
    return category?.color ?? Colors.grey;
  }

  /// Get category emoji by ID
  static String getEmojiById(String id) {
    final category = getById(id);
    return category?.emoji ?? '📦';
  }

  /// Get category description by ID
  static String getDescriptionById(String id) {
    final category = getById(id);
    return category?.description ?? 'Hàng hóa thông thường';
  }

  /// Check if category ID is valid
  static bool isValidId(String id) {
    return all.any((cat) => cat.id == id);
  }

  /// Get all category IDs
  static List<String> get allIds => all.map((cat) => cat.id).toList();

  /// Get all category names
  static List<String> get allNames => all.map((cat) => cat.name).toList();
}