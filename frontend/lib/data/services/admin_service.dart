import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService;

  AdminService(this._apiService);

  /// Get all users with optional filters
  Future<List<User>> getAllUsers({String? role, String? search}) async {
    try {
      final params = <String, dynamic>{};
      if (role != null) params['role'] = role;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _apiService.get('/admin/users', params: params);

      if (response.data['success'] == true) {
        final List<dynamic> usersJson = response.data['data'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Không thể tải danh sách user');
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException in getAllUsers: ${e.message}');
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error in getAllUsers: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Update user status (active/inactive)
  Future<void> updateUserStatus(int userId, bool isActive) async {
    try {
      final response = await _apiService.put(
        '/admin/users/$userId/status',
        data: {'isActive': isActive},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Cập nhật trạng thái thất bại');
      }
      
      debugPrint('✅ User #$userId status updated to $isActive');
    } on DioException catch (e) {
      debugPrint('❌ DioException in updateUserStatus: ${e.message}');
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error in updateUserStatus: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Get online shippers
  Future<List<User>> getOnlineShippers() async {
    try {
      final response = await _apiService.get('/admin/shippers/online');

      if (response.data['success'] == true) {
        final List<dynamic> shippersJson = response.data['data'];
        return shippersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Không thể tải danh sách shipper');
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException in getOnlineShippers: ${e.message}');
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error in getOnlineShippers: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Reassign shipper to order (admin only)
  Future<void> reassignShipper(int orderId, int shipperId) async {
    try {
      final response = await _apiService.put(
        '/orders/$orderId/assign',
        data: {'shipper_id': shipperId}, // ✅ Uses shipper_id for admin reassign
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Phân công shipper thất bại');
      }
      
      debugPrint('✅ Order #$orderId reassigned to Shipper #$shipperId');
    } on DioException catch (e) {
      debugPrint('❌ DioException in reassignShipper: ${e.message}');
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error in reassignShipper: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Update order status (admin only)
  Future<void> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _apiService.put(
        '/orders/$orderId/status',
        data: {'status': status},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Cập nhật trạng thái thất bại');
      }
      
      debugPrint('✅ Order #$orderId status updated to $status');
    } on DioException catch (e) {
      debugPrint('❌ DioException in updateOrderStatus: ${e.message}');
      if (e.response?.data?['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      debugPrint('❌ Error in updateOrderStatus: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
}