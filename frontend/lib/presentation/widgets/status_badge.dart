import 'package:flutter/material.dart';
import '../../data/models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final Order order;

  const StatusBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: order.statusColor.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: order.statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            order.statusIcon,
            size: 16,
            color: order.statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            order.statusText,
            style: TextStyle(
              color: order.statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
