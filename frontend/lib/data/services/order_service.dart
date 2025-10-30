// frontend/lib/data/services/order_service.dart
// ✅ FINAL: Added category and weight support

import 'api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiService _api;

  OrderService(this._api);

  // Lấy danh sách đơn hàng
  Future<List<Order>> getOrders({String? status}) async {
    try {
      final params = status != null ? {'status': status} : null;
      final response = await _api.get(ApiEndpoints.orders, params: params);

      if (response.data['success']) {
        final List ordersJson = response.data['data']['orders']; 
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      }
      
      throw Exception(response.data['message'] ?? 'Không thể lấy danh sách đơn hàng');
    } catch (e) {
      throw Exception('Lỗi lấy danh sách đơn hàng: ${e.toString()}');
    }
  }

  // Get active orders for shipper
  Future<List<Order>> getActiveOrders() async {
    try {
      final response = await _api.get('${ApiEndpoints.orders}/active');
      if (response.data['success']) {
        final List ordersJson = response.data['data']['orders'];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'Không thể lấy đơn hàng đang thực hiện');
    } catch (e) {
      throw Exception('Lỗi lấy đơn hàng đang thực hiện: ${e.toString()}');
    }
  }

  // Lấy chi tiết đơn hàng
  Future<Order> getOrderById(int id) async {
    try {
      final response = await _api.get('${ApiEndpoints.orders}/$id');

      if (response.data['success']) {
        return Order.fromJson(response.data['data']['order']);
      }
      
      throw Exception(response.data['message'] ?? 'Không tìm thấy đơn hàng');
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết đơn hàng: ${e.toString()}');
    }
  }

  // ✅ FINAL: Create order with distance_km, category, and weight
  Future<Order> createOrder(Map<String, dynamic> data) async {
    try {
      // Ensure all required fields including category and weight
      final payload = {
        'customer_id': data['customer_id'],
        'pickup_address': data['pickup_address'],
        'pickup_lat': data['pickup_lat'],
        'pickup_lng': data['pickup_lng'],
        'delivery_address': data['delivery_address'],
        'delivery_lat': data['delivery_lat'],
        'delivery_lng': data['delivery_lng'],
        'distance_km': data['distance_km'],
        'category': data['category'] ?? 'regular', // ✅ Category
        'weight': data['weight'] ?? 5.0,           // ✅ Weight (required, default 5kg)
        if (data['notes'] != null) 'notes': data['notes'],
      };

      final response = await _api.post(ApiEndpoints.orders, data: payload);

      if (response.data['success']) {
        final orderId = response.data['data']['orderId'];
        return await getOrderById(orderId);
      }
      
      throw Exception(response.data['message'] ?? 'Không thể tạo đơn hàng');
    } catch (e) {
      throw Exception('Lỗi tạo đơn hàng: ${e.toString()}');
    }
  }
  
  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(int orderId, String status, {String? notes, String? photoUrl}) async {
    try {
      final response = await _api.put(
        '${ApiEndpoints.orders}/$orderId/status',
        data: {'status': status, 'notes': notes, if (photoUrl != null) 'photoUrl': photoUrl},
      );

      if (response.statusCode != 200 || !(response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Không thể cập nhật trạng thái');
      }
    } catch (e) {
      throw Exception('Lỗi cập nhật trạng thái: ${e.toString()}');
    }
  }

  // Phân công shipper
  Future<void> assignShipper(int orderId, int shipperId) async {
    try {
      final response = await _api.put(
        '${ApiEndpoints.orders}/$orderId/assign',
        data: {'shipperId': shipperId},
      );

      if (response.statusCode != 200 || !(response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Không thể phân công shipper');
      }
    } catch (e) {
      throw Exception('Lỗi phân công shipper: ${e.toString()}');
    }
  }

  // Upload ảnh xác nhận
  Future<void> uploadProof(int orderId, String base64Image) async {
    try {
      final response = await _api.put(
        '${ApiEndpoints.orders}/$orderId/proof',
        data: {'proof_image_base64': base64Image},
      );

      if (response.statusCode != 200 || !(response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Không thể upload ảnh');
      }
    } catch (e) {
      throw Exception('Lỗi upload ảnh: ${e.toString()}');
    }
  }

  // Cancel order by shipper
  Future<void> cancelOrder(int orderId, String cancelReason) async {
    try {
      final response = await _api.put(
        '${ApiEndpoints.orders}/$orderId/cancel',
        data: {'cancel_reason': cancelReason},
      );

      if (response.statusCode != 200 || !(response.data['success'])) {
        throw Exception(response.data['message'] ?? 'Không thể hủy đơn hàng');
      }
    } catch (e) {
      throw Exception('Lỗi hủy đơn hàng: ${e.toString()}');
    }
  }
}