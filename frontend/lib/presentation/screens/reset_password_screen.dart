// frontend/lib/presentation/screens/reset_password_screen.dart
// ✅ Screen 3: Enter new password

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cherry_toast/cherry_toast.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (password.isEmpty || confirmPassword.isEmpty) {
      CherryToast.warning(
        title: const Text('Vui lòng nhập đầy đủ thông tin'),
      ).show(context);
      return;
    }

    if (password.length < 8) {
      CherryToast.warning(
        title: const Text('Mật khẩu phải có ít nhất 8 ký tự'),
      ).show(context);
      return;
    }

    if (password != confirmPassword) {
      CherryToast.warning(
        title: const Text('Mật khẩu xác nhận không khớp'),
      ).show(context);
      return;
    }

    // Check password strength
    if (!_isStrongPassword(password)) {
      CherryToast.warning(
        title: const Text('Mật khẩu chưa đủ mạnh'),
        description: const Text('Vui lòng xem gợi ý bên dưới'),
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: password,
      );

      if (!mounted) return;

      // Success - show dialog and redirect to login
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: successGreen.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 50,
                  color: successGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Đặt lại mật khẩu thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Vui lòng đăng nhập với mật khẩu mới',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: 'Đăng Nhập',
              icon: Icons.login_rounded,
              onPressed: () {
                Navigator.of(ctx).pop();
                _goToLogin();
              },
              isGradient: true,
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      CherryToast.error(
        title: const Text('Lỗi'),
        description: Text(e.toString().replaceAll('Exception: ', '')),
      ).show(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isStrongPassword(String password) {
    // At least 8 characters
    if (password.length < 8) return false;

    // Has uppercase and lowercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Has number
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    return true;
  }

  void _goToLogin() {
    // Pop all screens and go to login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Prevent back button - must complete or cancel
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textDark,
          title: const Text('Đặt Mật Khẩu Mới'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hủy đặt lại mật khẩu?'),
                    content: const Text('Bạn sẽ quay lại màn hình đăng nhập'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Không'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _goToLogin();
                        },
                        child: const Text('Có'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: successGreen.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 50,
                      color: successGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                const Text(
                  'Tạo mật khẩu mới',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Mật khẩu của bạn phải khác với mật khẩu đã sử dụng trước đó.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    hintText: 'Nhập mật khẩu mới',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: successGreen, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm Password Input
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    hintText: 'Nhập lại mật khẩu mới',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: successGreen, width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _resetPassword(),
                ),

                const SizedBox(height: 30),

                // Reset Button
                CustomButton(
                  text: _isLoading ? 'Đang đặt lại...' : 'Đặt Lại Mật Khẩu',
                  icon: _isLoading ? null : Icons.check_circle_rounded,
                  onPressed: _isLoading ? null : _resetPassword,
                  isGradient: !_isLoading,
                  color: _isLoading ? Colors.grey : successGreen,
                ),

                const SizedBox(height: 20),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: infoBlue.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: infoBlue.withAlpha(76),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: infoBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Yêu cầu mật khẩu',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildRequirement('Tối thiểu 8 ký tự'),
                      _buildRequirement('Có chữ HOA và chữ thường'),
                      _buildRequirement('Có ít nhất 1 chữ số'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}