// frontend/lib/data/providers/order_provider.dart (ĐÃ SỬA LỖI)

import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService;

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String? _currentFilter;
  Order? _activeOrder; // ✅ NEW

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFilter => _currentFilter;
  Order? get activeOrder => _activeOrder; // ✅ NEW
  bool get hasActiveOrder => _activeOrder != null; // ✅ NEW

  OrderProvider(this._orderService);

  // ✅ NEW: Check active orders for shipper
  Future<void> checkActiveOrders() async {
    try {
      final activeOrders = await _orderService.getActiveOrders();
      _activeOrder = activeOrders.isNotEmpty ? activeOrders.first : null;
      debugPrint('✅ Active order check: ${_activeOrder != null ? "Order #${_activeOrder!.id}" : "None"}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error checking active orders: $e');
    }
  }

  // Lấy danh sách đơn hàng
  Future<void> fetchOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    _currentFilter = status;
    // Chỉ gọi notifyListeners ở đầu và cuối để tránh lỗi
    // notifyListeners();

    try {
      _orders = await _orderService.getOrders(status: status);
      await checkActiveOrders();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy chi tiết đơn hàng
  Future<void> fetchOrderById(int id) async {
    try {
      _selectedOrder = await _orderService.getOrderById(id);
      
      // Cập nhật trong danh sách nếu có
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = _selectedOrder!;
      }
      notifyListeners(); // Cập nhật giao diện chi tiết
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // Tạo đơn hàng mới
  Future<void> createOrder(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(data);
      _orders.insert(0, order);
      _selectedOrder = order;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cập nhật trạng thái
  Future<void> updateOrderStatus(int orderId, String status, {String? notes, String? photoUrl}) async {
    try {
      await _orderService.updateOrderStatus(orderId, status, notes: notes, photoUrl: photoUrl);
      // ===> THAY ĐỔI Ở ĐÂY <====
      // Tải lại cả chi tiết và danh sách
      await fetchOrderById(orderId);
      await refreshOrders(); // Tải lại toàn bộ danh sách
      await checkActiveOrders();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // ✅ UPDATED: Shipper accepts order (self-assign) - uses new /accept endpoint
  Future<void> acceptOrder(int orderId) async {
    try {
      if (hasActiveOrder) {
        throw Exception('Bạn đang có đơn hàng #${_activeOrder!.id} chưa hoàn thành');
      }
      await _orderService.acceptOrder(orderId); // ✅ NEW: Uses /accept endpoint
      // ===> THAY ĐỔI Ở ĐÂY <====
      // Tải lại cả chi tiết và danh sách
      await fetchOrderById(orderId); // Cập nhật màn hình chi tiết
      await refreshOrders();       // Cập nhật màn hình danh sách
      await checkActiveOrders();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Upload ảnh xác nhận
  Future<void> uploadProof(int orderId, String base64Image) async {
    try {
      await _orderService.uploadProof(orderId, base64Image);
      // ===> THAY ĐỔI Ở ĐÂY <====
      // Tải lại cả chi tiết và danh sách
      await fetchOrderById(orderId);
      await refreshOrders();
      await checkActiveOrders();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  // Set selected order
  void setSelectedOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Refresh orders
  Future<void> refreshOrders() async {
    // Không set isLoading = true để việc làm mới diễn ra âm thầm
    try {
      _orders = await _orderService.getOrders(status: _currentFilter);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
  
  // ✅ NEW: Cancel order by shipper
  Future<void> cancelOrder(int orderId, String cancelReason) async {
    try {
      await _orderService.cancelOrder(orderId, cancelReason);
      await fetchOrderById(orderId);
      await refreshOrders();
      await checkActiveOrders();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}