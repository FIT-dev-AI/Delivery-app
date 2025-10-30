// frontend/lib/presentation/screens/base_order_detail_screen.dart (ĐÃ SỬA LỖI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/order_provider.dart';
import '../widgets/map_widget.dart';

class BaseOrderDetailScreen extends StatefulWidget {
  final Order initialOrder;
  final Widget Function(Order order, VoidCallback refreshCallback) contentBuilder;
  final Widget? Function(Order order)? actionsBuilder;
  final String appBarTitle;

  const BaseOrderDetailScreen({
    super.key,
    required this.initialOrder,
    required this.contentBuilder,
    this.actionsBuilder,
    required this.appBarTitle,
  });

  @override
  State<BaseOrderDetailScreen> createState() => _BaseOrderDetailScreenState();
}

class _BaseOrderDetailScreenState extends State<BaseOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Đặt đơn hàng ban đầu và fetch dữ liệu mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        orderProvider.setSelectedOrder(widget.initialOrder);
        _refreshOrder();
      }
    });
  }

  Future<void> _refreshOrder() async {
    if (!mounted) return;
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.selectedOrder != null) {
        await orderProvider.fetchOrderById(orderProvider.selectedOrder!.id);
      }
    } catch (e) {
      debugPrint("Failed to refresh order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để lắng nghe sự thay đổi từ OrderProvider
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.selectedOrder ?? widget.initialOrder;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.appBarTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.white,
            foregroundColor: textDark,
            elevation: 0.5,
            surfaceTintColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _refreshOrder,
                tooltip: 'Làm mới',
              ),
            ],
          ),
          body: Stack(
            children: [
              MapWidget(order: order),
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.15,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 15,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshOrder,
                            color: primaryOrange,
                            child: ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              children: [
                                // Truyền hàm _refreshOrder vào contentBuilder
                                widget.contentBuilder(order, _refreshOrder),
                              ],
                            ),
                          ),
                        ),
                        if (widget.actionsBuilder != null && widget.actionsBuilder!(order) != null)
                          _buildStickyActionBar(widget.actionsBuilder!(order)!),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyActionBar(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(child: child),
    );
  }
}