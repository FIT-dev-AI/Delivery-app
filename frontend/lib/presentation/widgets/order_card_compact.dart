// frontend/lib/presentation/widgets/order_card_compact.dart
// ✅ PERFECT DESIGN 2025 - Grab/Shopee/Uber Standard

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../data/models/order_model.dart';
import '../../core/constants/app_colors.dart';

class OrderCardCompact extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final String heroSuffix;

  const OrderCardCompact({
    super.key,
    required this.order,
    required this.onTap,
    this.heroSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'order_${order.id}$heroSuffix',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22), // ✅ Modern 22px
            boxShadow: [
              // ✅ Double shadow for premium floating effect
              BoxShadow(
                color: Colors.black.withAlpha(64),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              splashColor: primaryOrange.withAlpha(25),
              highlightColor: primaryOrange.withAlpha(13),
              child: Padding(
                padding: const EdgeInsets.all(14), // ✅ Balanced 14px
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 11), // ✅ Golden ratio spacing
                    _buildAddresses(),
                    const SizedBox(height: 11), // ✅ Golden ratio spacing
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ HEADER - Clear hierarchy
  Widget _buildHeader() {
    return Row(
      children: [
        // Gradient badge - Modern
        Container(
          padding: const EdgeInsets.all(9), // ✅ Optimal touch target
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryOrange, accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withAlpha(89),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 19, // ✅ Balanced icon size
          ),
        ),
        const SizedBox(width: 11),
        
        // Order info - Clear typography
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  fontSize: 18, // ✅ Prominent but not oversized
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatTime(order.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11, // ✅ Subtle timestamp
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        _buildStatusBadge(),
      ],
    );
  }

  // ✅ STATUS BADGE - Modern gradient style
  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (order.status) {
      case 'pending':
        bgColor = const Color(0xFFFFF3E0);
        textColor = primaryOrange;
        label = 'Chờ';
        break;
      case 'assigned':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = 'Nhận';
        break;
      case 'picked_up':
        bgColor = const Color(0xFFFFF9C4);
        textColor = const Color(0xFFF57F17);
        label = 'Lấy';
        break;
      case 'in_transit':
        bgColor = const Color(0xFFE1F5FE);
        textColor = const Color(0xFF0277BD);
        label = 'Giao';
        break;
      case 'delivered':
        bgColor = const Color(0xFFE8F5E9);
        textColor = successGreen;
        label = '✓';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        label = '?';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: textColor.withAlpha(89), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ✅ ADDRESSES - Clean 2-line layout
  Widget _buildAddresses() {
    return Container(
      padding: const EdgeInsets.all(11), // ✅ Balanced padding
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          _buildAddressRow(
            icon: Icons.trip_origin,
            iconColor: successGreen,
            label: 'Lấy',
            address: order.pickupAddress,
          ),
          const SizedBox(height: 9), // ✅ Clean separation
          _buildAddressRow(
            icon: Icons.location_on,
            iconColor: errorRed,
            label: 'Giao',
            address: order.deliveryAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    final shortAddress = _smartTruncate(address);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with background
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(32),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 13, color: iconColor),
        ),
        const SizedBox(width: 9),
        
        // Address text - 2 lines
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                shortAddress,
                style: const TextStyle(
                  fontSize: 13, // ✅ Readable
                  color: textDark,
                  fontWeight: FontWeight.w500,
                  height: 1.35, // ✅ Comfortable line height
                  letterSpacing: -0.1,
                ),
                maxLines: 2, // ✅ Show full info
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ SMART TRUNCATE - Show meaningful parts
  String _smartTruncate(String address) {
    String cleaned = address
        .replaceAll('Phường ', '')
        .replaceAll('Quận ', 'Q.')
        .replaceAll('Thành phố ', '')
        .replaceAll('Hồ Chí Minh', 'HCM')
        .replaceAll('Thủ Đức', 'Thủ Đức')
        .replaceAll('Đường ', '');
    
    // Optimal length for 2 lines
    if (cleaned.length <= 45) return cleaned;
    
    final parts = cleaned.split(',');
    if (parts.length >= 2) {
      String result = '${parts[0].trim()}, ${parts[1].trim()}';
      if (result.length <= 45) return result;
      return '${result.substring(0, 42)}...';
    }
    
    return '${cleaned.substring(0, 42)}...';
  }

  // ✅ FOOTER - Inline buttons
  Widget _buildFooter() {
    return Row(
      children: [
        // Customer avatar
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryOrange.withAlpha(38),
                accentOrange.withAlpha(26),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 14,
            color: primaryOrange,
          ),
        ),
        const SizedBox(width: 9),
        
        // Customer name
        Expanded(
          child: Text(
            order.customerName ?? 'Khách hàng',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: textDark,
              fontSize: 14, // ✅ Prominent
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Price badge
        if (order.totalAmount != null && order.totalAmount! > 0) ...[
          const SizedBox(width: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [successGreen, Color(0xFF28A745)],
              ),
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: successGreen.withAlpha(64),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPrice(order.totalAmount!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13, // ✅ Readable
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Call button
        if (order.customerPhone != null) ...[
          const SizedBox(width: 9),
          Container(
            decoration: BoxDecoration(
              color: successGreen,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: successGreen.withAlpha(64),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _makePhoneCall(order.customerPhone!),
                borderRadius: BorderRadius.circular(9),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.phone_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ✅ HELPERS
  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return DateFormat('HH:mm, dd/MM').format(date);
  }

  String _formatPrice(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '${amount.toStringAsFixed(0)}đ';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}