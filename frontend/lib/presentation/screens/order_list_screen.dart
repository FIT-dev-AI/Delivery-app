// frontend/lib/presentation/screens/order_list_screen.dart
// ✅ UPDATED: Added online/offline logic for shipper

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/order_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/order_card.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart';
import 'notification_settings_screen.dart';

class OrderListScreen extends StatefulWidget {
  final bool isMainScreen;

  const OrderListScreen({
    super.key,
    this.isMainScreen = true,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab configuration
  final List<Map<String, dynamic>> _tabs = [
    {
      'title': 'Đang diễn ra',
      'statuses': ['pending', 'assigned', 'picked_up', 'in_transit'],
    },
    {
      'title': 'Lịch sử',
      'statuses': ['delivered', 'cancelled'],
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    Future.microtask(() => _loadInitialData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    // Backend will automatically filter by role and online status
    await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: primaryOrange),
        ),
      );
    }

    // Simple layout for Shipper (non-main screen)
    if (!widget.isMainScreen) {
      return _buildShipperOrderScreen(user);
    }

    // Modern layout for Customer (main screen)
    return _buildCustomerMainScreen(user);
  }

  // ==================== CUSTOMER MAIN SCREEN ====================

  Widget _buildCustomerMainScreen(user) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: primaryGradient,
                ),
                child: FlexibleSpaceBar(
                  background: _buildHeaderContent(user),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withAlpha(178),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: _tabs.map((tab) => Tab(text: tab['title'])).toList(),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((tab) {
            return _OrderTabPage(
              statuses: List<String>.from(tab['statuses']),
              emptyTitle: tab['title'] == 'Đang diễn ra'
                  ? 'Không có đơn đang chạy'
                  : 'Lịch sử trống',
              isCustomer: user.isCustomer,
            );
          }).toList(),
        ),
      ),
      floatingActionButton: user.isCustomer
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const CreateOrderScreen(),
                      ),
                    )
                    .then((_) => _loadInitialData());
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo đơn'),
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildHeaderContent(user) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 50, // Space for TabBar
        left: 16,
        right: 16,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.myOrders,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Xin chào, ${user.name}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(229),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SHIPPER ORDER SCREEN ====================

  Widget _buildShipperOrderScreen(user) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đơn Hàng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Xin chào, ${user.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const _OrderTabPage(
        // Show all statuses for shipper (backend filters based on online status)
        statuses: [
          'pending',
          'assigned',
          'picked_up',
          'in_transit',
          'delivered',
          'cancelled'
        ],
        emptyTitle: 'Chưa có đơn hàng',
        isCustomer: false,
      ),
    );
  }
}

// ==================== ORDER TAB PAGE ====================

class _OrderTabPage extends StatefulWidget {
  final List<String> statuses;
  final String emptyTitle;
  final bool isCustomer;

  const _OrderTabPage({
    required this.statuses,
    required this.emptyTitle,
    required this.isCustomer,
  });

  @override
  State<_OrderTabPage> createState() => _OrderTabPageState();
}

class _OrderTabPageState extends State<_OrderTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _onRefresh() async {
    if (!mounted) return;
    // Backend automatically filters by role and online status
    await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // ✅ NEW: Listen to both OrderProvider AND AuthProvider
    return Consumer2<OrderProvider, AuthProvider>(
      builder: (context, orderProvider, authProvider, child) {
        final user = authProvider.user;

        // Step 1: Filter by tab status (frontend filtering)
        List<dynamic> filteredOrders = orderProvider.orders
            .where((order) => widget.statuses.contains(order.status))
            .toList();

        // ✅ Step 2: Additional filter for OFFLINE shipper (immediate UI feedback)
        // Backend already filters, but this provides instant feedback on toggle
        if (user != null && user.isShipper && !user.isOnline) {
          // Offline shipper: Only show orders assigned to them (no pending orders)
          filteredOrders = filteredOrders.where((order) {
            return order.shipperId == user.id &&
                   ['assigned', 'picked_up', 'in_transit'].contains(order.status);
          }).toList();
          
          debugPrint('🔴 OFFLINE Shipper Filter: ${filteredOrders.length} active orders');
        } else if (user != null && user.isShipper && user.isOnline) {
          debugPrint('🟢 ONLINE Shipper: ${filteredOrders.length} orders (including pending)');
        }

        // Loading state
        if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
          return const LoadingWidget(message: 'Đang tải...');
        }

        // Empty state
        if (filteredOrders.isEmpty) {
          return _buildEmptyState(orderProvider.isLoading, user);
        }

        // Order list
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: primaryOrange,
          child: ListView.builder(
            key: PageStorageKey<String>('tab_${widget.statuses.join('_')}'),
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: OrderCard(
                  order: order,
                  heroSuffix: '_list_tab',
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(order: order),
                          ),
                        )
                        .then((_) => _onRefresh());
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ UPDATED: Custom empty state for offline shipper
  Widget _buildEmptyState(bool isLoading, user) {
    if (isLoading) {
      return const LoadingWidget(message: 'Đang tải...');
    }

    // ✅ Determine empty state message based on user status
    String emptyTitle = widget.emptyTitle;
    String emptyMessage = 'Hiện tại không có đơn hàng nào ở trạng thái này.';
    IconData emptyIcon = Icons.inbox_outlined;
    
    // Special message for OFFLINE shipper
    if (user != null && user.isShipper && !user.isOnline) {
      emptyTitle = 'Bạn đang Offline';
      emptyMessage = 'Bật trạng thái Online ở thanh điều hướng phía trên để nhận đơn hàng mới.\n\nKhi Offline, bạn chỉ có thể xem các đơn đang thực hiện.';
      emptyIcon = Icons.cloud_off_rounded;
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: primaryOrange,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: EmptyState(
                  title: emptyTitle,
                  message: emptyMessage,
                  icon: emptyIcon,
                  onAction: widget.isCustomer &&
                          widget.emptyTitle == 'Không có đơn đang chạy'
                      ? () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateOrderScreen(),
                                ),
                              )
                              .then((_) => _onRefresh());
                        }
                      : null,
                  actionText: widget.isCustomer &&
                          widget.emptyTitle == 'Không có đơn đang chạy'
                      ? 'Tạo đơn hàng'
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}