// frontend/lib/presentation/screens/forgot_password_screen.dart
// ✅ Screen 1: Enter email to receive OTP

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cherry_toast/cherry_toast.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();

    // Validation
    if (email.isEmpty) {
      CherryToast.warning(
        title: const Text('Vui lòng nhập email'),
      ).show(context);
      return;
    }

    if (!_isValidEmail(email)) {
      CherryToast.warning(
        title: const Text('Email không hợp lệ'),
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final data = await authProvider.requestPasswordReset(email);

      if (!mounted) return;

      CherryToast.success(
        title: const Text('Đã gửi mã OTP'),
        description: const Text('Vui lòng kiểm tra email của bạn'),
      ).show(context);

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOTPScreen(
            email: email,
            expiresIn: data['expiresIn'] ?? 300,
          ),
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
        title: const Text('Quên Mật Khẩu'),
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
                    color: primaryOrange.withAlpha(38),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 50,
                    color: primaryOrange,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Nhập email của bạn để nhận mã OTP đặt lại mật khẩu. Mã OTP sẽ có hiệu lực trong 5 phút.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Email Input
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'your-email@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
                onSubmitted: (_) => _sendOTP(),
              ),

              const SizedBox(height: 30),

              // Send OTP Button
              CustomButton(
                text: _isLoading ? 'Đang gửi...' : 'Gửi Mã OTP',
                icon: _isLoading ? null : Icons.send_rounded,
                onPressed: _isLoading ? null : _sendOTP,
                isGradient: !_isLoading,
                color: _isLoading ? Colors.grey : null,
              ),

              const SizedBox(height: 20),

              // Info box
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: infoBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lưu ý',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Kiểm tra cả thư mục Spam nếu không thấy email\n'
                            '• Mã OTP có hiệu lực 5 phút\n'
                            '• Có thể yêu cầu gửi lại mã nếu hết hạn',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Back to login
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Quay lại đăng nhập'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}