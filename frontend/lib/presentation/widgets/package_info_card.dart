// lib/presentation/widgets/package_info_card.dart
// ✅ NEW: Reusable widget to display order category and weight

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';

class PackageInfoCard extends StatelessWidget {
  final Order order;
  final bool showDistance;
  final bool showPricing;

  const PackageInfoCard({
    super.key,
    required this.order,
    this.showDistance = true,
    this.showPricing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            order.categoryColor.withAlpha(25),
            order.categoryColor.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: order.categoryColor.withAlpha(51),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: order.categoryColor.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: order.categoryColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: order.categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Thông Tin Gói Hàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category
          _buildInfoRow(
            icon: order.categoryIcon,
            iconColor: order.categoryColor,
            label: 'Loại Hàng',
            value: order.categoryText,
            iconBackgroundColor: order.categoryColor.withAlpha(25),
          ),

          const SizedBox(height: 12),

          // Weight
          _buildInfoRow(
            icon: order.weightIcon,
            iconColor: order.weightColor,
            label: 'Cân Nặng',
            value: '${order.weightText} ${_getWeightLabel(order.weight)}',
            iconBackgroundColor: order.weightColor.withAlpha(25),
          ),

          // Distance (if enabled and available)
          if (showDistance && order.distanceKm != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.social_distance_rounded,
              iconColor: infoBlue,
              label: 'Khoảng Cách',
              value: '${order.distanceKm!.toStringAsFixed(1)} km',
              iconBackgroundColor: infoBlue.withAlpha(25),
            ),
          ],

          // Pricing (if enabled and available)
          if (showPricing && order.hasPricing) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.payments_rounded,
              iconColor: successGreen,
              label: 'Tổng Tiền',
              value: _formatCurrency(order.totalAmount!),
              iconBackgroundColor: successGreen.withAlpha(25),
              isHighlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color iconBackgroundColor,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),

        // Label & Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isHighlight ? 16 : 14,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: isHighlight ? successGreen : textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getWeightLabel(double weight) {
    if (weight <= 5) return '(Nhẹ)';
    if (weight <= 15) return '(Trung bình)';
    if (weight <= 25) return '(Nặng)';
    return '(Rất nặng)';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} triệu đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.${((amount % 1000) ~/ 100).toStringAsFixed(0)} K đ';
    }
    return '${amount.toStringAsFixed(0)} đ';
  }
}