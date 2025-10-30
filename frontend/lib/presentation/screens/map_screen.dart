import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/order_model.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/order_card_compact.dart';
import '../widgets/map_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_widget.dart';
import 'order_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController(
    viewportFraction: 0.84, // ✅ GOLDEN RATIO: 76% card + 8% peek
  );
  final double _carouselHeight = 260.0; // ✅ PERFECT HEIGHT: Safe for all content
  Timer? _refreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
    
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) _loadOrders();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.refreshOrders();
      debugPrint('🗺️ Map Screen: Orders refreshed');
    } catch (e) {
      debugPrint('❌ Map Screen: Error loading orders - $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer2<OrderProvider, AuthProvider>(
      builder: (context, orderProvider, authProvider, child) {
        final user = authProvider.user;
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: primaryOrange),
            ),
          );
        }

        List<Order> pendingOrders = orderProvider.orders
            .where((order) => order.status == 'pending')
            .toList();

        if (user.isShipper && !user.isOnline) {
          pendingOrders = [];
        }

        if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
          return const Scaffold(
            body: LoadingWidget(message: 'Đang tải bản đồ...'),
          );
        }

        return Scaffold(
          appBar: _buildCompactAppBar(user, pendingOrders.length),
          body: Stack(
            children: [
              if (pendingOrders.isNotEmpty)
                MapWidget(order: pendingOrders.first)
              else
                _buildEmptyMapState(user),
              
              if (pendingOrders.isNotEmpty)
                _buildFloatingBadge(pendingOrders.length),
              
              if (pendingOrders.isNotEmpty)
                _buildCompactCarousel(pendingOrders),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildCompactAppBar(user, int orderCount) {
    return AppBar(
      toolbarHeight: 56,
      title: Row(
        children: [
          const Icon(Icons.map_outlined, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Bản Đồ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          if (user.isShipper && user.isOnline && orderCount > 0) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [successGreen, Color(0xFF28A745)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$orderCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5ED),
              Color(0xFFF8F9FA),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      foregroundColor: textDark,
      automaticallyImplyLeading: false,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 22),
          onPressed: () async {
            await _loadOrders();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Đã làm mới'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.grey.withAlpha(51),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBadge(int count) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryOrange, accentOrange],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryOrange.withAlpha(127),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                '$count đơn đang chờ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMapState(user) {
    String title;
    String message;
    IconData icon;
    
    if (user.isShipper && !user.isOnline) {
      title = 'Bạn đang Offline';
      message = 'Bật trạng thái Online ở thanh điều hướng để xem đơn hàng mới.\n\nKhi Offline, bạn chỉ có thể xem các đơn đang thực hiện trong tab "Đơn hàng".';
      icon = Icons.cloud_off_rounded;
    } else if (user.isShipper && user.isOnline) {
      title = 'Chưa có đơn hàng mới';
      message = 'Hiện tại không có đơn hàng nào đang chờ.\n\nBản đồ sẽ tự động cập nhật khi có đơn mới.';
      icon = Icons.map_outlined;
    } else {
      title = 'Không có đơn hàng';
      message = 'Chưa có đơn hàng nào để hiển thị.';
      icon = Icons.inbox_outlined;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: EmptyState(
            title: title,
            message: message,
            icon: icon,
            onAction: user.isShipper && !user.isOnline ? null : () => _loadOrders(),
            actionText: user.isShipper && !user.isOnline ? null : 'Làm mới',
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCarousel(List<Order> pendingOrders) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _carouselHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(51),
            ],
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: pendingOrders.length,
          onPageChanged: (index) {
            debugPrint('🗺️ Switched to order #${pendingOrders[index].id}');
          },
          itemBuilder: (context, index) {
            final order = pendingOrders[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0, // ✅ Slightly wider padding
                vertical: 14.0, // ✅ Balanced vertical
              ),
              child: OrderCardCompact(
                order: order,
                heroSuffix: '_map',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: order),
                    ),
                  ).then((_) => _loadOrders());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}