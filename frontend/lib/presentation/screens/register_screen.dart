import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cherry_toast/cherry_toast.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _selectedRole = 'customer';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.register({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
      });

      if (mounted) {
        CherryToast.success(
          title: const Text('Đăng ký thành công!'),
          description: const Text('Vui lòng đăng nhập để tiếp tục'),
        ).show(context);

        // Quay về màn hình đăng nhập
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('Đăng ký thất bại'),
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
              Color(0xFFFFF5F0),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      AppStrings.register,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Họ tên
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.name,
                            hintText: 'Nguyễn Văn A',
                            prefixIcon: Icon(Icons.person_outlined, color: primaryOrange),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ tên';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
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
                        const SizedBox(height: 16),

                        // Số điện thoại
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: AppStrings.phone,
                            hintText: '0123456789',
                            prefixIcon: Icon(Icons.phone_outlined, color: primaryOrange),
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (value.length < 10) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Chọn vai trò
                        const Text(
                          AppStrings.selectRole,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                title: AppStrings.customer,
                                icon: Icons.shopping_bag_outlined,
                                isSelected: _selectedRole == 'customer',
                                onTap: () => setState(() => _selectedRole = 'customer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RoleCard(
                                title: AppStrings.shipper,
                                icon: Icons.delivery_dining,
                                isSelected: _selectedRole == 'shipper',
                                onTap: () => setState(() => _selectedRole = 'shipper'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Mật khẩu
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
                          textInputAction: TextInputAction.next,
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
                        const SizedBox(height: 16),

                        // Xác nhận mật khẩu
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Xác nhận mật khẩu',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outlined, color: primaryOrange),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: textLight,
                              ),
                              onPressed: () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _register(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu';
                            }
                            if (value != _passwordController.text) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Register button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return CustomButton(
                              text: AppStrings.register,
                              icon: Icons.person_add,
                              onPressed: _register,
                              isLoading: authProvider.isLoading,
                              isGradient: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.alreadyHaveAccount,
                              style: TextStyle(color: textLight),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                AppStrings.login,
                                style: TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

// Role Card Widget
class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryOrange.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryOrange : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryOrange.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? primaryOrange : textLight,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryOrange : textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
