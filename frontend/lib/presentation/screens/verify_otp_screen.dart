// frontend/lib/presentation/screens/verify_otp_screen.dart
// ✅ Screen 2: Enter and verify OTP code

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cherry_toast/cherry_toast.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'reset_password_screen.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  final int expiresIn; // seconds

  const VerifyOTPScreen({
    super.key,
    required this.email,
    this.expiresIn = 300,
  });

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _canResend = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = widget.expiresIn;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  String _getOTP() {
    return _controllers.map((c) => c.text).join();
  }

  void _clearOTP() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTP();

    // Validation
    if (otp.length != 6) {
      CherryToast.warning(
        title: const Text('Vui lòng nhập đủ 6 chữ số'),
      ).show(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final verified = await authProvider.verifyOTP(widget.email, otp);

      if (!mounted) return;

      if (verified) {
        CherryToast.success(
          title: const Text('Xác thực thành công'),
        ).show(context);

        // Navigate to reset password screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              otp: otp,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      CherryToast.error(
        title: const Text('Lỗi'),
        description: Text(e.toString().replaceAll('Exception: ', '')),
      ).show(context);

      _clearOTP();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.requestPasswordReset(widget.email);

      if (!mounted) return;

      CherryToast.success(
        title: const Text('Đã gửi lại mã OTP'),
        description: const Text('Vui lòng kiểm tra email'),
      ).show(context);

      _clearOTP();
      _startCountdown();
    } catch (e) {
      if (!mounted) return;

      CherryToast.error(
        title: const Text('Lỗi'),
        description: Text(e.toString().replaceAll('Exception: ', '')),
      ).show(context);
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
        title: const Text('Xác Thực OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: primaryOrange.withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 50,
                  color: primaryOrange,
                ),
              ),

              const SizedBox(height: 30),

              // Title
              const Text(
                'Nhập mã OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Mã OTP đã được gửi đến',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryOrange,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      enabled: !_isLoading,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryOrange, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          // Auto focus next field
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // Last digit entered - auto verify
                            _focusNodes[index].unfocus();
                            _verifyOTP();
                          }
                        } else if (value.isEmpty && index > 0) {
                          // Auto focus previous field on backspace
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Timer / Resend
              if (_remainingSeconds > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Mã hết hạn sau ${_formatTime(_remainingSeconds)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  onPressed: _canResend ? _resendOTP : null,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Gửi lại mã OTP'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryOrange,
                  ),
                ),

              const SizedBox(height: 30),

              // Verify Button
              CustomButton(
                text: _isLoading ? 'Đang xác thực...' : 'Xác Nhận',
                icon: _isLoading ? null : Icons.check_circle_outline_rounded,
                onPressed: _isLoading ? null : _verifyOTP,
                isGradient: !_isLoading,
                color: _isLoading ? Colors.grey : null,
              ),

              const SizedBox(height: 20),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFA726).withAlpha(76),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFFFA726),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Không nhận được mã?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Kiểm tra thư mục Spam\n'
                            '• Đợi ${_formatTime(_remainingSeconds)} để gửi lại\n'
                            '• Đảm bảo email chính xác',
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
            ],
          ),
        ),
      ),
    );
  }
}