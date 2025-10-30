import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/quick_action_button.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'notification_settings_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'main_navigation_screen.dart';
import 'stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authProvider.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _navigateToOrders(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user == null) return;

    // Navigate to MainNavigationScreen and select appropriate tab
    if (user.isShipper) {
      // Shipper: Navigate to tab index 1 (Đơn hàng)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 1),
        ),
        (route) => false, // Clear all routes
      );
    } else {
      // Customer: Navigate to tab index 0 (Đơn hàng - main screen)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(initialIndex: 0),
        ),
        (route) => false, // Clear all routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Lỗi tải thông tin người dùng"),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern Compact Header
          _buildModernHeader(user),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // User Info Card with Avatar
              _buildUserInfoCard(user),

              const SizedBox(height: 16),

              // Quick Actions Row
              _buildQuickActions(context, user),

              const SizedBox(height: 24),

              // Account Settings Section
              _buildSectionHeader('Tài khoản'),
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu của bạn',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                subtitle: 'Quản lý thông báo',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // About & Legal Section
              _buildSectionHeader('Thông tin'),
              _buildSettingsTile(
                context,
                icon: Icons.info_outline,
                title: 'Về ứng dụng',
                subtitle: 'Phiên bản & Thông tin',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.description_outlined,
                title: 'Điều khoản sử dụng',
                subtitle: 'Chính sách & Điều khoản',
                onTap: () {
                  // Navigate to Help screen as placeholder for Terms
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutButton(context),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildModernHeader(user) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: const Text(
          'Hồ Sơ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: primaryGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white.withAlpha(51),
                  child: Icon(
                    user.isShipper ? Icons.delivery_dining : Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50), // Space for title
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Large Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: primaryOrange.withAlpha(25),
                child: Icon(
                  user.isShipper ? Icons.delivery_dining : Icons.person,
                  size: 45,
                  color: primaryOrange,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.isShipper ? 'Tài Xế' : 'Khách Hàng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const Divider(height: 32),

              // Contact Info
              _buildInfoRow(Icons.email_outlined, user.email),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.phone_outlined,
                user.phone ?? 'Chưa cập nhật',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Đơn hàng Button - Navigate to bottom nav tab
          QuickActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Đơn hàng',
            onTap: () => _navigateToOrders(context),
          ),
          const SizedBox(width: 12),

          // Thống kê Button
          QuickActionButton(
            icon: Icons.bar_chart_outlined,
            label: 'Thống kê',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StatsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),

          // Trợ giúp Button
          QuickActionButton(
            icon: Icons.help_outline,
            label: 'Trợ giúp',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => _logout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: errorRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: textLight),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryOrange,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryOrange.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryOrange, size: 24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: textLight,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: textLight),
          onTap: onTap,
        ),
      ),
    );
  }
}