  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:cherry_toast/cherry_toast.dart';
  import '../../data/providers/auth_provider.dart';
  import '../../core/constants/app_colors.dart';
  import '../../core/constants/app_strings.dart';
  import '../widgets/custom_button.dart';
  import 'register_screen.dart';
  import 'main_navigation_screen.dart';
  import 'forgot_password_screen.dart'; 

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _obscurePassword = true;

    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

    Future<void> _login() async {
      if (!_formKey.currentState!.validate()) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          CherryToast.success(
            title: const Text(AppStrings.loginSuccess),
          ).show(context);

          // Chuyển hướng sang MainNavigationScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          CherryToast.error(
            title: const Text('Đăng nhập thất bại'),
            description: Text(e.toString().replaceAll('Exception: ', '')),
          ).show(context);
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFF5F0), // Cam nhạt
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo với gradient cam
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: primaryOrange.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_shipping_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Quản lý giao hàng thông minh',
                        style: TextStyle(
                          fontSize: 16,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email field với icon
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.email,
                          hintText: 'example@email.com',
                          prefixIcon: Icon(Icons.email_outlined, color: primaryOrange),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!value.contains('@')) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password field với toggle visibility
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outlined, color: primaryOrange),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: textLight,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Forgot password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login button với gradient
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return CustomButton(
                            text: AppStrings.login,
                            icon: Icons.login,
                            onPressed: _login,
                            isLoading: authProvider.isLoading,
                            isGradient: true,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'hoặc',
                              style: TextStyle(color: textLight, fontSize: 14),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.dontHaveAccount,
                            style: TextStyle(color: textLight),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              AppStrings.register,
                              style: TextStyle(
                                color: primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Demo accounts info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Tài khoản demo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Khách hàng: customer@test.com / 123456\nShipper: shipper@test.com / 123456',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
