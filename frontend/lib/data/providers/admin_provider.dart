import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;

  AdminProvider(this._adminService);

  // ==================== STATE ====================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<User> _users = [];
  List<User> get users => _users;

  List<User> _onlineShippers = [];
  List<User> get onlineShippers => _onlineShippers;

  // ==================== USER MANAGEMENT ====================

  /// Fetch all users with optional filters
  Future<void> fetchAllUsers({String? role, String? search}) async {
    _setLoading(true);
    _clearError();

    try {
      _users = await _adminService.getAllUsers(role: role, search: search);
      debugPrint('✅ Fetched ${_users.length} users');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Error fetching users: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update user status (active/inactive)
  Future<bool> updateUserStatus(int userId, bool isActive) async {
    _clearError();

    try {
      await _adminService.updateUserStatus(userId, isActive);
      
      // Update local state
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: isActive);
        notifyListeners();
      }
      
      debugPrint('✅ User #$userId status updated locally');
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Error updating user status: $e');
      return false;
    }
  }

  // ==================== SHIPPER MANAGEMENT ====================

  /// Fetch online shippers
  Future<void> fetchOnlineShippers() async {
    _setLoading(true);
    _clearError();

    try {
      _onlineShippers = await _adminService.getOnlineShippers();
      debugPrint('✅ Fetched ${_onlineShippers.length} online shippers');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Error fetching online shippers: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== ORDER INTERVENTION ====================

  /// Reassign order to a different shipper
  Future<bool> reassignOrder(int orderId, int shipperId) async {
    _clearError();

    try {
      await _adminService.reassignShipper(orderId, shipperId);
      debugPrint('✅ Order #$orderId reassigned to Shipper #$shipperId');
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Error reassigning order: $e');
      return false;
    }
  }

  /// Cancel order (admin force cancel)
  Future<bool> cancelOrder(int orderId) async {
    _clearError();

    try {
      await _adminService.updateOrderStatus(orderId, 'cancelled');
      debugPrint('✅ Order #$orderId cancelled by admin');
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Error cancelling order: $e');
      return false;
    }
  }

  /// Update order status (admin action)
  Future<bool> updateOrderStatus(int orderId, String status) async {
    _clearError();

    try {
      await _adminService.updateOrderStatus(orderId, status);
      debugPrint('✅ Order #$orderId status updated to $status');
      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Error updating order status: $e');
      return false;
    }
  }

  // ==================== HELPERS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear all data (useful when logging out)
  void clear() {
    _users = [];
    _onlineShippers = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}