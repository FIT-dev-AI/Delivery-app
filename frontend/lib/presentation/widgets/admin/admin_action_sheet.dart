import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/providers/order_provider.dart';

class AdminActionSheet extends StatelessWidget {
  final Order order;

  const AdminActionSheet({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(76),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Hành động Admin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Chọn hành động can thiệp vào đơn hàng',
              style: TextStyle(
                fontSize: 14,
                color: textLight,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildActionTile(
            context,
            icon: Icons.person_add_alt_1,
            iconColor: primaryOrange,
            title: 'Phân công lại Shipper',
            subtitle: 'Chọn shipper khác để giao đơn hàng này',
            onTap: () async {
              final result = await _showReassignSheet(context);
              if (result != null && context.mounted) {
                Navigator.pop(context, result);
              }
            },
          ),
          _buildActionTile(
            context,
            icon: Icons.cancel_outlined,
            iconColor: errorRed,
            title: 'Hủy đơn hàng',
            subtitle: 'Hủy đơn hàng này (không thể hoàn tác)',
            onTap: () async {
              final result = await _confirmCancelOrder(context);
              if (result != null && context.mounted) {
                Navigator.pop(context, result);
              }
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.withAlpha(25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đóng',
                  style: TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textLight.withAlpha(128)),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showReassignSheet(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );

    await adminProvider.fetchOnlineShippers();

    if (!context.mounted) return null;
    Navigator.pop(context);

    if (adminProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.errorMessage!),
          backgroundColor: errorRed,
        ),
      );
      return null;
    }

    if (adminProvider.onlineShippers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Không có shipper nào đang online'),
          backgroundColor: warningOrange,
        ),
      );
      return null;
    }

    if (!context.mounted) return null;
    
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShipperSelectionSheet(
        order: order,
        shippers: adminProvider.onlineShippers,
      ),
    );
  }

  Future<Map<String, dynamic>?> _confirmCancelOrder(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Hủy đơn hàng'),
        content: Text(
          'Bạn có chắc chắn muốn hủy đơn hàng #${order.id}?\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hủy đơn hàng',
              style: TextStyle(
                color: errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return null;

    return await _executeCancelOrder(context);
  }

  Future<Map<String, dynamic>?> _executeCancelOrder(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );

    final success = await adminProvider.cancelOrder(order.id);

    if (!context.mounted) return null;
    Navigator.pop(context);

    if (success) {
      await orderProvider.fetchOrderById(order.id);
      return {
        'success': true,
        'message': 'Đã hủy đơn hàng #${order.id}',
        'action': 'cancel',
      };
    } else {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: errorRed,
        ),
      );
      return null;
    }
  }
}

class _ShipperSelectionSheet extends StatelessWidget {
  final Order order;
  final List<User> shippers;

  const _ShipperSelectionSheet({
    required this.order,
    required this.shippers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(76),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Chọn Shipper',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${shippers.length} shipper đang online',
              style: const TextStyle(
                fontSize: 14,
                color: textLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: shippers.length,
              itemBuilder: (context, index) {
                final shipper = shippers[index];
                return _buildShipperTile(context, shipper);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildShipperTile(BuildContext context, User shipper) {
    return InkWell(
      onTap: () => _confirmReassign(context, shipper),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryOrange.withAlpha(25),
              child: const Icon(
                Icons.delivery_dining,
                color: primaryOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shipper.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 13,
                          color: successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textLight.withAlpha(128)),
          ],
        ),
      ),
    );
  }

  void _confirmReassign(BuildContext context, User shipper) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận phân công'),
        content: Text(
          'Phân công đơn hàng #${order.id} cho shipper ${shipper.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await _executeReassign(context, shipper);
              if (result != null && context.mounted) {
                Navigator.pop(context, result);
              }
            },
            child: const Text(
              'Xác nhận',
              style: TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _executeReassign(BuildContext context, User shipper) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: primaryOrange),
      ),
    );

    final success = await adminProvider.reassignOrder(order.id, shipper.id);

    if (!context.mounted) return null;
    Navigator.pop(context); // Close loading

    if (success) {
      await orderProvider.fetchOrderById(order.id);
      
      // Return result thay vì show SnackBar ở đây
      return {
        'success': true,
        'message': 'Đã phân công cho ${shipper.name}',
        'action': 'reassign',
        'shipperName': shipper.name,
      };
    } else {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.errorMessage ?? 'Có lỗi xảy ra'),
          backgroundColor: errorRed,
        ),
      );
      return null;
    }
  }
}