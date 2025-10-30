// lib/data/models/order_model.dart
// ✅ UPDATED: Added category and weight fields

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:latlong2/latlong.dart';

class Order {
  final int id;
  final int customerId;
  final int? shipperId;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double deliveryLat;
  final double deliveryLng;
  final String deliveryAddress;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? shipperName;
  final String? shipperPhone;
  final double? shipperLat;
  final double? shipperLng;
  final String? proofImageBase64;
  final String? notes;
  final DateTime createdAt;
  
  // Pricing fields
  final double? distanceKm;
  final double? totalAmount;
  final double? shipperAmount;
  final double? appCommission;

  // ✅ NEW: Category field
  final String category;

  // ✅ NEW: Weight field (kg)
  final double weight;

  Order({
    required this.id,
    required this.customerId,
    this.shipperId,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.deliveryAddress,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.shipperName,
    this.shipperPhone,
    this.shipperLat,
    this.shipperLng,
    this.proofImageBase64,
    this.notes,
    required this.createdAt,
    this.distanceKm,
    this.totalAmount,
    this.shipperAmount,
    this.appCommission,
    this.category = 'regular', // ✅ NEW
    this.weight = 5.0, // ✅ NEW: Default 5kg
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      shipperId: json['shipper_id'],
      pickupLat: double.parse(json['pickup_lat'].toString()),
      pickupLng: double.parse(json['pickup_lng'].toString()),
      pickupAddress: json['pickup_address'],
      deliveryLat: double.parse(json['delivery_lat'].toString()),
      deliveryLng: double.parse(json['delivery_lng'].toString()),
      deliveryAddress: json['delivery_address'],
      status: json['status'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      shipperName: json['shipper_name'],
      shipperPhone: json['shipper_phone'],
      shipperLat: json['shipper_lat'] != null 
          ? double.parse(json['shipper_lat'].toString()) 
          : null,
      shipperLng: json['shipper_lng'] != null 
          ? double.parse(json['shipper_lng'].toString()) 
          : null,
      proofImageBase64: json['proof_image_base64'],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      distanceKm: json['distance_km'] != null 
          ? double.parse(json['distance_km'].toString()) 
          : null,
      totalAmount: json['total_amount'] != null 
          ? double.parse(json['total_amount'].toString()) 
          : null,
      shipperAmount: json['shipper_amount'] != null 
          ? double.parse(json['shipper_amount'].toString()) 
          : null,
      appCommission: json['app_commission'] != null 
          ? double.parse(json['app_commission'].toString()) 
          : null,
      // ✅ NEW: Parse category and weight
      category: json['category'] as String? ?? 'regular',
      weight: json['weight'] != null 
          ? double.parse(json['weight'].toString()) 
          : 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'pickup_address': pickupAddress,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'category': category, // ✅ NEW
      'weight': weight, // ✅ NEW
      if (distanceKm != null) 'distance_km': distanceKm,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (shipperAmount != null) 'shipper_amount': shipperAmount,
      if (appCommission != null) 'app_commission': appCommission,
    };
  }

  // Helper getters
  LatLng get pickupLocation => LatLng(pickupLat, pickupLng);
  LatLng get deliveryLocation => LatLng(deliveryLat, deliveryLng);
  
  // Check if has pricing info
  bool get hasPricing => totalAmount != null && totalAmount! > 0;
  
  // ✅ NEW: Category icon
  IconData get categoryIcon {
    switch (category) {
      case 'food':
        return Icons.restaurant;
      case 'frozen':
        return Icons.ac_unit;
      case 'valuable':
        return Icons.diamond;
      case 'electronics':
        return Icons.devices;
      case 'fashion':
        return Icons.checkroom;
      case 'documents':
        return Icons.description;
      case 'fragile':
        return Icons.warning_amber_rounded;
      case 'medical':
        return Icons.medical_services;
      case 'gift':
        return Icons.card_giftcard;
      case 'regular':
      default:
        return Icons.inventory_2;
    }
  }

  // ✅ NEW: Category text in Vietnamese
  String get categoryText {
    switch (category) {
      case 'food':
        return 'Đồ ăn/Thức uống';
      case 'frozen':
        return 'Đồ đông lạnh';
      case 'valuable':
        return 'Hàng giá trị cao';
      case 'electronics':
        return 'Linh kiện điện tử';
      case 'fashion':
        return 'Thời trang';
      case 'documents':
        return 'Sách/Tài liệu';
      case 'fragile':
        return 'Đồ dễ vỡ';
      case 'medical':
        return 'Y tế/Dược phẩm';
      case 'gift':
        return 'Quà tặng';
      case 'regular':
      default:
        return 'Hàng thường';
    }
  }

  // ✅ NEW: Category color
  Color get categoryColor {
    switch (category) {
      case 'food':
        return Colors.orange;
      case 'frozen':
        return Colors.blue;
      case 'valuable':
        return Colors.purple;
      case 'electronics':
        return Colors.indigo;
      case 'fashion':
        return Colors.pink;
      case 'documents':
        return Colors.brown;
      case 'fragile':
        return Colors.amber;
      case 'medical':
        return Colors.red;
      case 'gift':
        return Colors.green;
      case 'regular':
      default:
        return Colors.grey;
    }
  }

  // ✅ NEW: Weight display text
  String get weightText => '${weight.toStringAsFixed(1)} kg';
  
  // ✅ NEW: Weight icon based on range
  IconData get weightIcon {
    if (weight <= 5) return Icons.shopping_bag;
    if (weight <= 15) return Icons.work;
    return Icons.inbox; // Heavy package
  }

  // ✅ NEW: Weight color based on range
  Color get weightColor {
    if (weight <= 5) return Colors.green;
    if (weight <= 15) return Colors.orange;
    if (weight <= 25) return Colors.deepOrange;
    return Colors.red; // Very heavy
  }
  
  // Status color với gradient cam
  Color get statusColor {
    switch (status) {
      case 'pending':
        return warningYellow;
      case 'assigned':
        return infoBlue;
      case 'picked_up':
        return accentOrange;
      case 'in_transit':
        return primaryOrange;
      case 'delivered':
        return successGreen;
      case 'cancelled':
        return errorRed;
      default:
        return textLight;
    }
  }
  
  // Status text tiếng Việt
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Chờ Xử Lý';
      case 'assigned':
        return 'Đã Phân Công';
      case 'picked_up':
        return 'Đã Lấy Hàng';
      case 'in_transit':
        return 'Đang Giao';
      case 'delivered':
        return 'Đã Giao';
      case 'cancelled':
        return 'Đã Hủy';
      default:
        return status;
    }
  }
  
  // Status icon
  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'assigned':
        return Icons.person_add;
      case 'picked_up':
        return Icons.inventory;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}