import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  final ApiService _api;
  final _storage = const FlutterSecureStorage();

  AuthService(this._api);

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success']) {
        // Lấy object 'data' lồng bên trong
        final authData = response.data['data'] as Map<String, dynamic>;
        
        // Lưu token từ vị trí đúng
        await _storage.write(key: 'token', value: authData['token']);
        
        // Trả về object 'data' để AuthProvider sử dụng
        return authData;
      }
      
      throw Exception(response.data['message'] ?? 'Đăng nhập thất bại');
    } catch (e) {
      // Ném ra lỗi gọn gàng hơn
      if (e is Exception && e.toString().contains('401')) {
        throw Exception('Email hoặc mật khẩu không đúng.');
      }
      throw Exception('Không thể kết nối đến máy chủ.');
    }
  }

  // Đăng ký (cũng được cập nhật để trả về dữ liệu và tự động đăng nhập)
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiEndpoints.register, data: data);

      if (response.data['success']) {
        final authData = response.data['data'] as Map<String, dynamic>;
        await _storage.write(key: 'token', value: authData['token']);
        return authData;
      }
      
      throw Exception(response.data['message'] ?? 'Đăng ký thất bại');
    } catch (e) {
      if (e is Exception && e.toString().contains('409')) {
        throw Exception('Email đã được sử dụng.');
      }
      throw Exception('Đăng ký thất bại.');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
  }

  // Lấy token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
  
  // Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _api.get('/users/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _api.put(
        '/users/profile',
        data: {
          'name': name,
          'phone': phone,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.put(
        '/users/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Get settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _api.get('/users/settings');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Update settings
  Future<Map<String, dynamic>> updateSettings({
    Map<String, dynamic>? notifications,
    String? language,
    String? theme,
  }) async {
    try {
      final response = await _api.put(
        '/users/settings',
        data: {
          if (notifications != null) 'notifications': notifications,
          if (language != null) 'language': language,
          if (theme != null) 'theme': theme,
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ✅ NEW: Update online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    await _api.patch('/auth/online-status', data: {'is_online': isOnline});
  }

  // ============================================
  // FORGOT PASSWORD FLOW
  // ============================================

  /// Step 1: Request OTP for password reset
  /// Sends OTP to user's email
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ OTP sent to $email');
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Không thể gửi mã OTP');
      }
    } catch (e) {
      debugPrint('❌ Request password reset error: $e');
      rethrow;
    }
  }

  /// Step 2: Verify OTP code
  /// Validates the 6-digit OTP entered by user
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ OTP verified for $email');
        return true;
      } else {
        throw Exception(data['message'] ?? 'Mã OTP không đúng');
      }
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      rethrow;
    }
  }

  /// Step 3: Reset password with verified OTP
  /// Updates user's password after OTP verification
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ Password reset successful for $email');
        return;
      } else {
        throw Exception(data['message'] ?? 'Không thể đặt lại mật khẩu');
      }
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }
}
