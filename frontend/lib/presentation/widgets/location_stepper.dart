import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';
import '../../core/constants/app_colors.dart';

class LocationStepper extends StatelessWidget {
  final Order order;
  final bool isDetailed;

  const LocationStepper({
    super.key,
    required this.order,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon column - NO extra containers
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: successGreen.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.circle,
                color: successGreen,
                size: 10,
              ),
            ),
            Container(
              width: 2,
              height: isDetailed ? 50 : 35, // ✅ REDUCED from 45
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    successGreen.withAlpha(102),
                    errorRed.withAlpha(102),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: errorRed.withAlpha(38),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: errorRed,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Address column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAddressBlock(
                label: 'Điểm lấy',
                address: order.pickupAddress,
                color: successGreen,
                icon: Icons.inventory_2_outlined,
              ),
              SizedBox(height: isDetailed ? 12 : 8), // ✅ REDUCED
              _buildAddressBlock(
                label: 'Điểm giao',
                address: order.deliveryAddress,
                color: errorRed,
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressBlock({
    required String label,
    required String address,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(31),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withAlpha(76), width: 0.5),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4), // ✅ REDUCED from 6
        
        // Address - BIGGER font
        Text(
          address,
          style: const TextStyle(
            fontSize: 14,
            color: textDark,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          maxLines: isDetailed ? 3 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}