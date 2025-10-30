import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../data/models/order_model.dart';
import '../../core/constants/app_colors.dart';
import 'status_badge.dart';
import 'location_stepper.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final String heroSuffix;

  const OrderCard({
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
               BoxShadow(
                 color: Colors.black.withAlpha(15),
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
               splashColor: primaryOrange.withAlpha(25),
               highlightColor: primaryOrange.withAlpha(13),
              child: Padding(
                padding: const EdgeInsets.all(12), // ✅ REDUCED from 16
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildModernHeader(context),
                    const SizedBox(height: 10), // ✅ REDUCED from 16
                    
                    // NO container wrapper - just the stepper
                    LocationStepper(order: order, isDetailed: false),
                    
                    const SizedBox(height: 10), // ✅ REDUCED from 16
                    _buildCompactFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Row(
      children: [
        // Modern icon badge - SMALLER
        Container(
          padding: const EdgeInsets.all(8), // ✅ REDUCED from 10
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryOrange, accentOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40FF6F00),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 18, // ✅ REDUCED from 20
          ),
        ),
        const SizedBox(width: 10), // ✅ REDUCED from 12
        
        // Order info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đơn hàng #${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  fontSize: 16, // ✅ REDUCED from 17
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3), // ✅ REDUCED from 4
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusBadge(order: order),
      ],
    );
  }

  // ✅ NEW: Simplified footer
  Widget _buildCompactFooter(BuildContext context) {
    return Row(
      children: [
        // Customer avatar - SMALLER
        Container(
          padding: const EdgeInsets.all(6), // ✅ REDUCED from 8
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
            size: 16, // ✅ REDUCED from 18
            color: primaryOrange,
          ),
        ),
        const SizedBox(width: 10),
        
        // Customer name - BIGGER font
        Expanded(
          child: Text(
            order.customerName ?? 'Khách hàng',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: textDark,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        // Call button - Compact
        if (order.customerPhone != null) ...[
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [successGreen, Color(0xFF28A745)],
              ),
              borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8), // ✅ REDUCED from 10
                  child: const Icon(
                    Icons.phone_rounded,
                    size: 16, // ✅ REDUCED from 18
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}