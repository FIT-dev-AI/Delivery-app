import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/pricing_constants.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/order_provider.dart';
import '../widgets/location_stepper.dart';
import '../widgets/status_badge.dart';
import '../widgets/map_widget.dart';
import '../widgets/pricing_card.dart';
import 'package:cherry_toast/cherry_toast.dart';

class OrderDetailCustomerScreen extends StatefulWidget {
  final Order order;
  const OrderDetailCustomerScreen({super.key, required this.order});

  @override
  State<OrderDetailCustomerScreen> createState() =>
      _OrderDetailCustomerScreenState();
}

class _OrderDetailCustomerScreenState
    extends State<OrderDetailCustomerScreen> {
  late Order _currentOrder;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrder();
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
          // 🗺️ Google Maps (full screen)
          MapWidget(order: _currentOrder),

          // 📱 DraggableScrollableSheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.30, // Slightly larger for pricing
            minChildSize: 0.30,
            maxChildSize: 0.9,
            snap: true,
            snapSizes: const [0.30, 0.5, 0.9],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
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
                    // 🎯 Drag handle - TAP TO EXPAND
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

                    // 📦 Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Order header
                                _buildOrderHeader(),
                                const SizedBox(height: 12),

                                // Progress indicator
                                _buildProgressIndicator(),
                                const SizedBox(height: 12),

                                // ✅ NEW: Pricing section (prominent)
                                if (_currentOrder.hasPricing)
                                  _buildPricingSection(),

                                // Quick action (Call shipper if available)
                                _buildQuickAction(),
                                const SizedBox(height: 16),

                                // Expandable details
                                _buildExpandableDetails(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isCompleted ? successGreen : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 12)
            : Text(
                '$step',
                style: TextStyle(
                  fontSize: 10,
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
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Lấy hàng';
      case 2:
        return 'Đang giao';
      case 3:
        return 'Hoàn thành';
      default:
        return 'Chờ xác nhận';
    }
  }

  // ✅ UPDATED: Use PricingCard widget for consistency
  Widget _buildPricingSection() {
    if (!_currentOrder.hasPricing) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PricingCard(
        distanceKm: _currentOrder.distanceKm!,
        totalAmount: _currentOrder.totalAmount!,
        showBreakdown: true,
        onTap: () {
          final pricing = PricingResult(
            distanceKm: _currentOrder.distanceKm!,
            totalAmount: _currentOrder.totalAmount!,
            shipperAmount: _currentOrder.shipperAmount!,
            appCommission: _currentOrder.appCommission!,
          );
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Chi tiết giá'),
              content: PricingBreakdown(pricing: pricing),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction() {
    // Show call button if shipper assigned and has phone
    if (_currentOrder.shipperId != null &&
        _currentOrder.shipperPhone != null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: _buildCallShipperButton(),
      );
    }

    // Show searching banner if pending
    if (_currentOrder.status == 'pending') {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: _buildSearchingBanner(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCallShipperButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [successGreen, Color(0xFF28A745)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          onTap: () => _makePhoneCall(_currentOrder.shipperPhone!),
          borderRadius: BorderRadius.circular(12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Gọi cho tài xế',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentOrange.withAlpha(51),
            primaryOrange.withAlpha(25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryOrange.withAlpha(76),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đang tìm tài xế',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vui lòng đợi trong giây lát...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Divider(color: Colors.grey[300], height: 1),
        const SizedBox(height: 16),

        // Route section
        _buildSection(
          title: 'Lộ trình',
          icon: Icons.route_rounded,
          child: LocationStepper(order: _currentOrder, isDetailed: true),
        ),
        const SizedBox(height: 16),

        // Shipper info (if assigned)
        if (_currentOrder.shipperId != null)
          _buildSection(
            title: 'Thông tin tài xế',
            icon: Icons.delivery_dining_rounded,
            child: _buildShipperInfo(),
          ),

        // Order notes (if any)
        if (_currentOrder.notes != null && _currentOrder.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSection(
            title: 'Ghi chú',
            icon: Icons.note_rounded,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentOrder.notes!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildShipperInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryOrange.withAlpha(25),
            accentOrange.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryOrange.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: primaryOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentOrder.shipperName ?? 'Tài xế',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                if (_currentOrder.shipperPhone != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentOrder.shipperPhone!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Call button
          if (_currentOrder.shipperPhone != null)
            Container(
              decoration: BoxDecoration(
                color: successGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: successGreen.withAlpha(76),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => _makePhoneCall(_currentOrder.shipperPhone!),
                icon: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                padding: const EdgeInsets.all(10),
              ),
            ),
        ],
      ),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // --- UTILITY ---

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!mounted) return;
        CherryToast.error(
          title: const Text('Không thể gọi điện'),
          description: Text('Số điện thoại: $phoneNumber'),
        ).show(context);
      }
    } catch (e) {
      if (!mounted) return;
      CherryToast.error(
        title: const Text('Lỗi khi gọi điện'),
        description: Text(e.toString()),
      ).show(context);
    }
  }
}