import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/admin_provider.dart';

class UserAdminCard extends StatelessWidget {
  final User user;

  const UserAdminCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: user.isActive 
              ? Colors.transparent 
              : errorRed.withAlpha(76),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: user.isActive ? textDark : textLight,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Role & Status Row
                  Row(
                    children: [
                      // Role Badge
                      _buildRoleBadge(),
                      const SizedBox(width: 8),

                      // Online Status
                      if (user.isShipper) _buildOnlineIndicator(),
                    ],
                  ),
                ],
              ),
            ),

            // Active/Inactive Switch
            _buildStatusSwitch(context),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getRoleColor().withAlpha(25),
        shape: BoxShape.circle,
        border: Border.all(
          color: user.isActive 
              ? _getRoleColor().withAlpha(76) 
              : Colors.grey.withAlpha(76),
          width: 2,
        ),
      ),
      child: Icon(
        _getRoleIcon(),
        color: user.isActive ? _getRoleColor() : Colors.grey,
        size: 28,
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor().withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRoleColor().withAlpha(76),
          width: 1,
        ),
      ),
      child: Text(
        _getRoleText(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getRoleColor(),
        ),
      ),
    );
  }

  Widget _buildOnlineIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: user.isOnline ? successGreen : Colors.grey,
            shape: BoxShape.circle,
            boxShadow: user.isOnline
                ? [
                    BoxShadow(
                      color: successGreen.withAlpha(76),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          user.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 11,
            color: user.isOnline ? successGreen : textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: user.isActive,
          onChanged: (value) => _handleStatusChange(context, value),
          activeTrackColor: successGreen.withAlpha(76),
          activeThumbColor: successGreen,
          inactiveThumbColor: errorRed,
          inactiveTrackColor: errorRed.withAlpha(76),
        ),
        Text(
          user.isActive ? 'Hoạt động' : 'Khóa',
          style: TextStyle(
            fontSize: 11,
            color: user.isActive ? successGreen : errorRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==================== HELPERS ====================

  IconData _getRoleIcon() {
    switch (user.role) {
      case 'shipper':
        return Icons.delivery_dining_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getRoleText() {
    switch (user.role) {
      case 'shipper':
        return 'Tài Xế';
      case 'admin':
        return 'Admin';
      default:
        return 'Khách Hàng';
    }
  }

  Color _getRoleColor() {
    switch (user.role) {
      case 'shipper':
        return primaryOrange;
      case 'admin':
        return const Color(0xFF9C27B0); // Purple
      default:
        return infoBlue;
    }
  }

  Future<void> _handleStatusChange(BuildContext context, bool newValue) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newValue ? 'Kích hoạt User' : 'Khóa User'),
        content: Text(
          newValue
              ? 'Bạn có chắc muốn kích hoạt user "${user.name}"?'
              : 'Bạn có chắc muốn khóa user "${user.name}"? User sẽ không thể đăng nhập.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              newValue ? 'Kích hoạt' : 'Khóa',
              style: TextStyle(
                color: newValue ? successGreen : errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await adminProvider.updateUserStatus(user.id, newValue);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newValue
                    ? '✅ Đã kích hoạt user "${user.name}"'
                    : '❌ Đã khóa user "${user.name}"',
              ),
              backgroundColor: newValue ? successGreen : warningOrange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminProvider.errorMessage ?? 'Có lỗi xảy ra'),
              backgroundColor: errorRed,
            ),
          );
        }
      }
    }
  }
}