import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'order_detail_customer_screen.dart';
import 'order_detail_shipper_screen.dart';

/// Smart wrapper that routes to appropriate order detail screen based on user role
/// 
/// This screen determines whether to show:
/// - Customer view: OrderDetailCustomerScreen (tracking focused)
/// - Shipper view: OrderDetailShipperScreen (action focused)
class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Show loading while determining user
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: primaryOrange,
          ),
        ),
      );
    }

    // Route to appropriate screen based on role
    if (user.isShipper) {
      return OrderDetailShipperScreen(order: order);
    } else {
      return OrderDetailCustomerScreen(order: order);
    }
  }
}