import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider(this._authService);

  // Load user từ storage khi app khởi động
  Future<void> loadUserFromStorage() async {
    final token = await _authService.getToken();
    final userJson = await _storage.read(key: 'user');

    if (token != null && userJson != null) {
      try {
        _user = User.fromJson(jsonDecode(userJson));
      } catch (e) {
        await logout();
      }
    }
  }

  // Xử lý chung cho response đăng nhập/đăng ký thành công
  Future<void> _handleAuthSuccess(Map<String, dynamic> authData) async {
    _user = User.fromJson(authData['user']);
    await _storage.write(key: 'user', value: jsonEncode(_user!.toJson()));
    _isLoading = false;
    notifyListeners();
  }

  // Đăng nhập
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      await _handleAuthSuccess(result);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Đăng ký và tự động đăng nhập
  Future<void> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(data);
      await _handleAuthSuccess(result);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      return await _authService.getSettings();
    } catch (e) {
      rethrow;
    }
  }

  // Update settings
  Future<void> updateSettings({
    Map<String, dynamic>? notifications,
    String? language,
    String? theme,
  }) async {
    try {
      await _authService.updateSettings(
        notifications: notifications,
        language: language,
        theme: theme,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ✅ NEW: Update online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_user == null || _user!.role != 'shipper') {
      throw Exception('Chỉ tài xế mới có thể cập nhật trạng thái online');
    }

    try {
      await _authService.updateOnlineStatus(isOnline);
      _user = _user!.copyWith(isOnline: isOnline);
      await _storage.write(key: 'user', value: jsonEncode(_user!.toJson()));
      notifyListeners();
      debugPrint('✅ Online status updated: ${isOnline ? "ONLINE" : "OFFLINE"}');
    } catch (e) {
      debugPrint('❌ Error updating online status: $e');
      rethrow;
    }
  }

  // ============================================
  // FORGOT PASSWORD FLOW
  // ============================================

  /// Step 1: Request OTP for password reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      return await _authService.requestPasswordReset(email);
    } catch (e) {
      debugPrint('❌ Request password reset error: $e');
      rethrow;
    }
  }

  /// Step 2: Verify OTP code
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      return await _authService.verifyOTP(email, otp);
    } catch (e) {
      debugPrint('❌ Verify OTP error: $e');
      rethrow;
    }
  }

  /// Step 3: Reset password with verified OTP
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _authService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      debugPrint('✅ Password reset successful for $email');
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }
}
