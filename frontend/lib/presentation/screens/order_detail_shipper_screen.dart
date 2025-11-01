// frontend/lib/presentation/screens/order_detail_shipper_screen.dart
// ✅ UPDATED: Added online/offline logic for shipper

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/pricing_constants.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/order_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/services/image_picker_service.dart';
import '../../data/services/navigation_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/package_info_card.dart'; // ✅ NEW: Import Package Info Card
import '../widgets/admin/admin_action_sheet.dart'; // ✅ NEW: Admin actions
import '../widgets/location_stepper.dart';
import '../widgets/status_badge.dart';
import '../widgets/map_widget.dart';
import 'package:cherry_toast/cherry_toast.dart';

class OrderDetailShipperScreen extends StatefulWidget {
  final Order order;
  const OrderDetailShipperScreen({super.key, required this.order});

  @override
  State<OrderDetailShipperScreen> createState() => _OrderDetailShipperScreenState();
}

class _OrderDetailShipperScreenState extends State<OrderDetailShipperScreen> {
  late Order _currentOrder;
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isNavigating = false;
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrder();
      _checkActiveOrders();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }
  
  Future<void> _refreshOrder() async {
    if (!mounted) return;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchOrderById(_currentOrder.id);
    if (mounted && orderProvider.selectedOrder != null) {
      setState(() {
        _currentOrder = orderProvider.selectedOrder!;
      });
    }
  }

  Future<void> _checkActiveOrders() async {
    if (!mounted) return;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.checkActiveOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
        actions: [
          IconButton(
            onPressed: _refreshOrder,
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.refresh_rounded, color: textDark),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MapWidget(order: _currentOrder),

          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.28,
            minChildSize: 0.28,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.28, 0.5, 0.9],
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _sheetController.animateTo(
                          0.5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildOrderHeader(),
                                const SizedBox(height: 10),

                                _buildProgressIndicator(),
                                const SizedBox(height: 10),

                                // ✅ NEW: Package Info Card (Category + Weight)
                                PackageInfoCard(
                                  order: _currentOrder,
                                  showDistance: true,
                                  showPricing: false, // Earnings card shows pricing for shipper
                                ),

                                if (_currentOrder.hasPricing && _currentOrder.shipperId != null)
                                  _buildEarningsSection(),

                                // ✅ NEW: Admin Actions (if admin user)
                                _buildAdminActionsSection(),

                                // ✅ NEW: Warning banner for offline shipper viewing pending order
                                _buildOfflineWarningBanner(),

                                _buildQuickActions(),
                                const SizedBox(height: 12),

                                // Cancel button (only for assigned status)
                                if (_currentOrder.status == 'assigned' && _currentOrder.shipperId != null)
                                  _buildCancelButton(),

                                _buildExpandableDetails(),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildStickyActionBar(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildOrderHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn hàng #${_currentOrder.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(_currentOrder.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        StatusBadge(order: _currentOrder),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final currentStep = _getCurrentStep();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryOrange.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildStepDot(1, currentStep >= 1),
          Expanded(child: _buildStepLine(currentStep >= 2)),
          _buildStepDot(2, currentStep >= 2),
          Expanded(child: _buildStepLine(currentStep >= 3)),
          _buildStepDot(3, currentStep >= 3),
          const SizedBox(width: 8),
          Text(
            _getStepLabel(currentStep),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, bool isCompleted) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isCompleted ? successGreen : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 11)
            : Text(
                '$step',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isCompleted ? successGreen : Colors.grey[300],
    );
  }

  int _getCurrentStep() {
    switch (_currentOrder.status) {
      case 'pending':
        return 0;
      case 'assigned':
        return 1;
      case 'picked_up':
      case 'in_transit':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 1:
        return 'Lấy hàng';
      case 2:
        return 'Giao hàng';
      case 3:
        return 'Hoàn thành';
      default:
        return 'Chờ xác nhận';
    }
  }

  Widget _buildEarningsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            successGreen.withAlpha(31),
            const Color(0xFF28A745).withAlpha(15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: successGreen.withAlpha(76),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: infoBlue.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.straighten, color: infoBlue, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khoảng cách',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatDistance(_currentOrder.distanceKm!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 10),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: successGreen.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_wallet, color: successGreen, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thu nhập của bạn',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(_currentOrder.shipperAmount!),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: successGreen.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: successGreen.withAlpha(76), width: 1),
                ),
                child: const Text(
                  '70%',
                  style: TextStyle(
                    fontSize: 12,
                    color: successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Warning banner for offline shipper viewing pending order
  Widget _buildOfflineWarningBanner() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    // Only show for offline shipper viewing pending order
    if (user == null || !user.isShipper || user.isOnline || _currentOrder.status != 'pending') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726).withAlpha(38), // warningOrange
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFA726).withAlpha(127),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFFA726),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Bạn đang OFFLINE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bật trạng thái Online ở thanh điều hướng để có thể nhận đơn này.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    if (_currentOrder.status == 'pending' || _currentOrder.status == 'delivered') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildNavigationButton()),
          const SizedBox(width: 8),
          if (_currentOrder.customerPhone != null) _buildCallButton(),
        ],
      ),
    );
  }

  Widget _buildNavigationButton() {
    final bool isGoingToPickup = _currentOrder.status == 'assigned';
    final LatLng destination = isGoingToPickup
        ? LatLng(_currentOrder.pickupLat, _currentOrder.pickupLng)
        : LatLng(_currentOrder.deliveryLat, _currentOrder.deliveryLng);
    final String destinationLabel = isGoingToPickup
        ? _currentOrder.pickupAddress
        : _currentOrder.deliveryAddress;

    final gradient = isGoingToPickup
        ? const LinearGradient(
            colors: [Color(0xFFFF6F00), Color(0xFFFF8F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isGoingToPickup ? const Color(0xFFFF6F00) : const Color(0xFF1E88E5)).withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isNavigating ? null : () => _handleNavigationTap(destination, destinationLabel),
          borderRadius: BorderRadius.circular(12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'Chỉ đường',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: successGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: successGreen.withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _makePhoneCall(_currentOrder.customerPhone!),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(Icons.phone_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    // Only show for assigned shipper
    if (user == null || _currentOrder.shipperId != user.id) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCancelDialog(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: errorRed.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorRed.withAlpha(76),
                width: 1.5,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, color: errorRed, size: 20),
                SizedBox(width: 8),
                Text(
                  'Hủy Đơn Hàng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: errorRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey[300], height: 1),
        const SizedBox(height: 16),

        _buildSection(
          title: 'Lộ trình',
          icon: Icons.route_rounded,
          child: LocationStepper(order: _currentOrder, isDetailed: true),
        ),
        const SizedBox(height: 16),

        _buildSection(
          title: 'Thông tin khách hàng',
          icon: Icons.person_rounded,
          child: _buildCustomerInfo(),
        ),
        const SizedBox(height: 16),

        if (_currentOrder.notes != null && _currentOrder.notes!.isNotEmpty)
          _buildSection(
            title: 'Ghi chú',
            icon: Icons.note_rounded,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_currentOrder.notes!, style: const TextStyle(fontSize: 14)),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          child: Icon(Icons.person_rounded, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentOrder.customerName ?? 'Khách hàng',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              if (_currentOrder.customerPhone != null) ...[
                const SizedBox(height: 2),
                Text(
                  _currentOrder.customerPhone!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: textLight, size: 18),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildStickyActionBar() {
    final actionButton = _buildActionButton();
    if (actionButton == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SafeArea(top: false, child: actionButton),
    );
  }

  // ✅ UPDATED: Action button with online status check
  Widget? _buildActionButton() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final orderProvider = Provider.of<OrderProvider>(context);
    if (user == null) return null;

    // ✅ For PENDING orders - check online status
    if (_currentOrder.status == 'pending') {
      final bool isOnline = user.isOnline;
      final bool hasActiveOrder = orderProvider.hasActiveOrder;
      final Order? activeOrder = orderProvider.activeOrder;
      
      // Determine button state
      String buttonText;
      bool isDisabled;
      IconData buttonIcon;
      
      if (!isOnline) {
        // ✅ OFFLINE - Cannot accept
        buttonText = '⚠️ Bật Online để nhận đơn';
        isDisabled = true;
        buttonIcon = Icons.cloud_off_rounded;
        debugPrint('🔴 Accept button DISABLED: Shipper is OFFLINE');
      } else if (hasActiveOrder) {
        // ONLINE but has active order
        buttonText = 'Đang có đơn #${activeOrder!.id} chưa hoàn thành';
        isDisabled = true;
        buttonIcon = Icons.block_rounded;
        debugPrint('⚠️ Accept button DISABLED: Has active order #${activeOrder.id}');
      } else {
        // ONLINE and no active order - Can accept
        buttonText = 'Nhận Đơn Hàng';
        isDisabled = false;
        buttonIcon = Icons.check_circle_outline_rounded;
        debugPrint('✅ Accept button ENABLED: Shipper online, no active orders');
      }
      
      return CustomButton(
        text: buttonText,
        icon: buttonIcon,
        onPressed: isDisabled ? null : () => _acceptOrder(),
        isGradient: !isDisabled,
        color: isDisabled ? Colors.grey : null,
      );
    }

    // For other statuses - check if order belongs to this shipper
    if (_currentOrder.shipperId != user.id) return null;

    if (_currentOrder.status == 'assigned') {
      return CustomButton(
        text: 'Đã Lấy Hàng',
        icon: Icons.photo_camera_rounded,
        onPressed: () => _confirmPickup(),
        isGradient: true,
        color: accentOrange,
      );
    }

    if (_currentOrder.status == 'picked_up') {
      return CustomButton(
        text: 'Bắt Đầu Giao Hàng',
        icon: Icons.local_shipping_rounded,
        onPressed: () => _startDelivery(),
        isGradient: true,
      );
    }

    if (_currentOrder.status == 'in_transit') {
      return CustomButton(
        text: 'Hoàn Thành',
        icon: Icons.check_circle_rounded,
        onPressed: () => _completeDelivery(),
        isGradient: true,
        color: successGreen,
      );
    }

    return null;
  }

  // --- ACTION HANDLERS ---

  Future<void> _showCancelDialog() async {
    String? selectedReason;
    final TextEditingController otherReasonCtrl = TextEditingController();

    final List<String> cancelReasons = [
      'Khách hàng yêu cầu hủy',
      'Không thể đến lấy hàng',
      'Địa chỉ quá xa',
      'Đơn hàng không phù hợp',
      'Lý do khác',
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: errorRed, size: 24),
              SizedBox(width: 8),
              Text('Lý do hủy đơn hàng'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vui lòng chọn lý do hủy đơn hàng:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                ...cancelReasons.map((reason) => InkWell(
                  onTap: () => setState(() => selectedReason = reason),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          selectedReason == reason
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selectedReason == reason ? primaryOrange : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                if (selectedReason == 'Lý do khác') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: otherReasonCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Nhập lý do...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      final reason = selectedReason == 'Lý do khác'
                          ? otherReasonCtrl.text.trim()
                          : selectedReason!;
                      Navigator.pop(context, reason);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorRed,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận hủy'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      _cancelOrder(result);
    }
  }

  Future<void> _cancelOrder(String reason) async {
    if (!mounted) return;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      await orderProvider.cancelOrder(_currentOrder.id, reason);

      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop(); // Close loading

      if (!mounted) return;
      CherryToast.success(
        title: const Text('Đã hủy đơn hàng'),
        description: const Text('Đơn hàng đã được trả về trạng thái chờ'),
      ).show(context);

      await _refreshOrder();
      
      // Navigate back to order list
      nav.pop();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      
      if (!mounted) return;
      CherryToast.error(
        title: const Text('Lỗi'),
        description: Text(e.toString()),
      ).show(context);
    }
  }

  Future<void> _handleNavigationTap(LatLng destination, String label) async {
    setState(() => _isNavigating = true);

    try {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      await NavigationService.openGoogleMapsNavigation(
        destination: destination,
        destinationLabel: label,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (!mounted) return;
      CherryToast.success(
        title: const Text('Đã mở Google Maps'),
        description: Text('Đến: $label'),
      ).show(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      CherryToast.error(title: const Text('Không thể mở Google Maps')).show(context);
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  Future<void> _acceptOrder() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (authProvider.user == null) return;

    // ✅ Double check online status before accepting
    if (!authProvider.user!.isOnline) {
      CherryToast.error(
        title: const Text('Không thể nhận đơn'),
        description: const Text('Bạn phải BẬT ONLINE trước khi nhận đơn'),
      ).show(context);
      return;
    }

    try {
      await orderProvider.acceptOrder(_currentOrder.id); // ✅ FIXED: No shipperId needed
      if (!mounted) return;
      CherryToast.success(
        title: const Text('Đã nhận đơn hàng!'),
        description: const Text('Hãy đến điểm lấy hàng'),
      ).show(context);
      await _refreshOrder();
    } catch (e) {
      if (!mounted) return;
      CherryToast.error(title: Text(e.toString())).show(context);
    }
  }

  Future<void> _confirmPickup() async {
    if (!mounted) return;

    final String? base64Image = await _showImagePickerDialog(
      title: 'Chụp ảnh xác nhận lấy hàng',
      message: 'Chụp ảnh sản phẩm đã nhận',
    );

    if (base64Image == null) return;

    if (!mounted) return;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      await orderProvider.updateOrderStatus(
        _currentOrder.id,
        'picked_up',
        notes: 'Shipper đã lấy hàng',
        photoUrl: base64Image,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      CherryToast.success(title: const Text('Đã xác nhận lấy hàng!')).show(context);

      await _refreshOrder();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      CherryToast.error(title: Text(e.toString())).show(context);
    }
  }

  Future<void> _startDelivery() async {
    if (!mounted) return;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      await orderProvider.updateOrderStatus(
        _currentOrder.id,
        'in_transit',
        notes: 'Shipper bắt đầu giao hàng',
      );

      if (!mounted) return;
      CherryToast.success(title: const Text('Bắt đầu giao hàng!')).show(context);

      await _refreshOrder();
    } catch (e) {
      if (!mounted) return;
      CherryToast.error(title: Text(e.toString())).show(context);
    }
  }

  Future<void> _completeDelivery() async {
    if (!mounted) return;

    final String? base64Image = await _showImagePickerDialog(
      title: 'Chụp ảnh xác nhận giao hàng',
      message: 'Chụp ảnh đơn hàng đã giao',
    );

    if (base64Image == null) return;

    if (!mounted) return;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      // ✅ FIXED: Update status to delivered AND upload proof image
      await orderProvider.updateOrderStatus(
        _currentOrder.id,
        'delivered',
        notes: 'Shipper đã giao hàng',
        photoUrl: base64Image, // ✅ Upload proof image with status update
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      if (!mounted) return;
      CherryToast.success(
        title: const Text('Hoàn thành giao hàng!'),
        description: const Text('Đơn hàng đã được giao thành công'),
      ).show(context);

      await _refreshOrder();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      CherryToast.error(title: Text(e.toString())).show(context);
    }
  }

  Future<String?> _showImagePickerDialog({
    required String title,
    required String message,
  }) async {
    final String? source = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(ctx).pop('camera'),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Chụp Ảnh'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(ctx).pop('gallery'),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Thư Viện'),
          ),
        ],
      ),
    );

    if (source == null) return null;

    if (source == 'camera') {
      return await _imagePickerService.pickImageFromCamera();
    } else {
      return await _imagePickerService.pickImageFromGallery();
    }
  }

  // ✅ NEW: Admin Actions Section
  Widget _buildAdminActionsSection() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Only show for admin users
    if (user == null || !user.isAdmin) {
      return const SizedBox.shrink();
    }

    // Only show for orders that can be modified
    if (_currentOrder.status == 'delivered' || 
        _currentOrder.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9C27B0).withAlpha(25), // Purple
            const Color(0xFF9C27B0).withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9C27B0).withAlpha(76),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Color(0xFF9C27B0),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Hành động Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => AdminActionSheet(order: _currentOrder),
                ).then((_) {
                  // Refresh order after admin action
                  _refreshOrder();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.settings),
              label: const Text(
                'Quản lý đơn hàng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}