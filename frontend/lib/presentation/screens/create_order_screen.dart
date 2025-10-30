import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/providers/order_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/pricing_constants.dart';
import '../../core/constants/order_categories.dart'; // ✅ NEW
import '../widgets/custom_button.dart';
import '../widgets/pricing_card.dart';
import '../widgets/category_selector.dart'; // ✅ NEW
import '../widgets/weight_selector.dart'; // ✅ NEW
import 'place_search_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _pickupCtrl = TextEditingController();
  final TextEditingController _deliveryCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  // Location data
  String? _pickupAddress;
  double? _pickupLat;
  double? _pickupLng;

  String? _deliveryAddress;
  double? _deliveryLat;
  double? _deliveryLng;

  // Pricing data
  PricingResult? _pricing;
  bool _isCalculatingPrice = false;

  // ✅ NEW: Selected category
  String _selectedCategory = OrderCategories.defaultCategoryId;
  
  // ✅ NEW: Selected weight (default 5kg)
  double _selectedWeight = 5.0;

  bool _submitting = false;

  // Google Map state
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  static const double _mapPadding = 80.0;

  @override
  void dispose() {
    _pickupCtrl.dispose();
    _deliveryCtrl.dispose();
    _notesCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ============ HELPERS ============

  double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  void _applyPlaceResult({
    required Map<String, dynamic> result,
    required bool isPickup,
  }) {
    final address = (result['address'] ?? result['display_name'] ?? '').toString().trim();
    final lat = _toDouble(result['lat']);
    final lng = _toDouble(result['lng'] ?? result['lon']);

    if (address.isEmpty || lat == null || lng == null) {
      CherryToast.error(
        title: const Text('Lỗi'),
        description: const Text('Không thể lấy địa chỉ/tọa độ. Vui lòng chọn lại.'),
      ).show(context);
      return;
    }

    setState(() {
      if (isPickup) {
        _pickupAddress = address;
        _pickupLat = lat;
        _pickupLng = lng;
        _pickupCtrl.text = address;
      } else {
        _deliveryAddress = address;
        _deliveryLat = lat;
        _deliveryLng = lng;
        _deliveryCtrl.text = address;
      }
    });

    _rebuildMap();
    debugPrint(isPickup
        ? '✅ Pickup saved: $address ($lat,$lng)'
        : '✅ Delivery saved: $address ($lat,$lng)');
  }

  Future<void> _selectLocation({required bool isPickup}) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceSearchScreen(
          title: isPickup ? 'Chọn địa chỉ lấy hàng' : 'Chọn địa chỉ giao hàng',
        ),
      ),
    );

    if (!mounted || result == null) return;
    _applyPlaceResult(result: result, isPickup: isPickup);
  }

  Future<void> _createOrder() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_pickupLat == null || _pickupLng == null || _deliveryLat == null || _deliveryLng == null) {
      CherryToast.error(
        title: const Text('Lỗi'),
        description: const Text('Thiếu tọa độ lấy/giao. Vui lòng chọn lại điểm.'),
      ).show(context);
      return;
    }

    // Check pricing
    if (_pricing == null || !_pricing!.isValid) {
      CherryToast.error(
        title: const Text('Lỗi'),
        description: const Text('Không thể tính giá. Vui lòng thử lại.'),
      ).show(context);
      return;
    }

    final auth = context.read<AuthProvider>();
    final orders = context.read<OrderProvider>();

    if (auth.user == null) {
      CherryToast.error(
        title: const Text('Lỗi'),
        description: const Text('Vui lòng đăng nhập'),
      ).show(context);
      return;
    }

    setState(() => _submitting = true);
    try {
      // ✅ UPDATED: Include category in payload
      await orders.createOrder({
        'customer_id': auth.user!.id,
        'pickup_address': _pickupAddress!,
        'pickup_lat': _pickupLat!,
        'pickup_lng': _pickupLng!,
        'delivery_address': _deliveryAddress!,
        'delivery_lat': _deliveryLat!,
        'delivery_lng': _deliveryLng!,
        'distance_km': _pricing!.distanceKm,
        'category': _selectedCategory, // ✅ NEW: Send category
        'weight': _selectedWeight,     // ✅ NEW: Send weight
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      });

      if (!mounted) return;
      
      // ✅ Show category in success message
      final categoryName = OrderCategories.getNameById(_selectedCategory);
      CherryToast.success(
        title: const Text('Thành công!'),
        description: Text('Đơn hàng $categoryName ${CurrencyFormatter.format(_pricing!.totalAmount)} đã được tạo'),
      ).show(context);
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      if (!mounted) return;
      CherryToast.error(
        title: const Text('Lỗi'),
        description: Text(e.toString()),
      ).show(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool get _canSubmit =>
      _pickupAddress != null && 
      _deliveryAddress != null && 
      _pricing != null && 
      _pricing!.isValid &&
      !_submitting;

  // ============ GOOGLE MAP LOGIC ============

  void _onMapCreated(GoogleMapController c) {
    _mapController = c;
    _rebuildMap();
  }

  Future<void> _rebuildMap() async {
    final hasPickup = _pickupLat != null && _pickupLng != null;
    final hasDelivery = _deliveryLat != null && _deliveryLng != null;

    final Set<Marker> mk = {};
    final Set<Polyline> pl = {};

    if (hasPickup) {
      mk.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(_pickupLat!, _pickupLng!),
        infoWindow: InfoWindow(title: 'Điểm lấy', snippet: _pickupAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (hasDelivery) {
      mk.add(Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(_deliveryLat!, _deliveryLng!),
        infoWindow: InfoWindow(title: 'Điểm giao', snippet: _deliveryAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // Fetch route and calculate pricing
    if (hasPickup && hasDelivery) {
      setState(() => _isCalculatingPrice = true);

      final route = await _fetchOsrmRoute(
        from: LatLng(_pickupLat!, _pickupLng!),
        to: LatLng(_deliveryLat!, _deliveryLng!),
      );

      if (route['points'] != null && route['points'].isNotEmpty) {
        pl.add(Polyline(
          polylineId: const PolylineId('route_preview'),
          width: 5,
          color: primaryOrange,
          points: route['points'],
        ));

        // Calculate pricing from OSRM distance
        final distanceKm = route['distance'] ?? 0.0;
        if (distanceKm > 0) {
          setState(() {
            _pricing = PricingCalculator.calculate(distanceKm);
            _isCalculatingPrice = false;
          });
          
          debugPrint('✅ Pricing calculated: ${_pricing!.distanceKm} km = ${_pricing!.totalAmount} VND');
        } else {
          setState(() {
            _pricing = null;
            _isCalculatingPrice = false;
          });
          debugPrint('⚠️ Distance is 0, cannot calculate pricing');
        }
      } else {
        setState(() {
          _pricing = null;
          _isCalculatingPrice = false;
        });
        debugPrint('⚠️ No route points returned from OSRM');
      }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(mk);
      _polylines.clear();
      _polylines.addAll(pl);
    });

    if (hasPickup && hasDelivery && _mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          math.min(_pickupLat!, _deliveryLat!),
          math.min(_pickupLng!, _deliveryLng!),
        ),
        northeast: LatLng(
          math.max(_pickupLat!, _deliveryLat!),
          math.max(_pickupLng!, _deliveryLng!),
        ),
      );
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, _mapPadding),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchOsrmRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${from.longitude},${from.latitude};'
          '${to.longitude},${to.latitude}'
          '?overview=full&geometries=polyline';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        debugPrint('⚠️ OSRM returned status ${response.statusCode}');
        return {'points': <LatLng>[], 'distance': 0.0};
      }

      final data = jsonDecode(response.body);
      if (data['code'] != 'Ok' || data['routes'] == null || data['routes'].isEmpty) {
        debugPrint('⚠️ OSRM no valid route: ${data['code']}');
        return {'points': <LatLng>[], 'distance': 0.0};
      }

      final route = data['routes'][0];
      final geometry = route['geometry'] as String;
      final distanceMeters = route['distance'] as num;
      final distanceKm = distanceMeters / 1000.0;

      final points = _decodePolyline(geometry);
      debugPrint('✅ OSRM route: ${points.length} points, $distanceKm km');

      return {'points': points, 'distance': distanceKm};
    } catch (e) {
      debugPrint('❌ Error fetching OSRM route: $e');
      return {'points': <LatLng>[], 'distance': 0.0};
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    final points = <LatLng>[];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // ============ UI ============

  @override
  Widget build(BuildContext context) {
    final hasBoth = _pickupLat != null &&
        _pickupLng != null &&
        _deliveryLat != null &&
        _deliveryLng != null;

    return Scaffold(
      appBar: AppBar(
        // Nền trắng đồng bộ với nội dung
        backgroundColor: Colors.white,
        // Màu chữ và icon cam
        foregroundColor: const Color(0xFFF57C00),
        iconTheme: const IconThemeData(
          color: Color(0xFFF57C00),
        ),
        title: const Text(
          'Tạo đơn hàng',
          style: TextStyle(
            color: Color(0xFFF57C00),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // Map preview
              AnimatedCrossFade(
                crossFadeState:
                    hasBoth ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 220),
                firstChild: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 220,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      markers: _markers,
                      polylines: _polylines,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_pickupLat ?? 10.776889, _pickupLng ?? 106.700806),
                        zoom: 12,
                      ),
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),

              const SizedBox(height: 20),

              // PRICING CARD (Real-time preview)
              if (_pricing != null && _pricing!.isValid)
                PricingCard(
                  distanceKm: _pricing!.distanceKm,
                  totalAmount: _pricing!.totalAmount,
                  showBreakdown: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Chi tiết giá'),
                        content: PricingBreakdown(pricing: _pricing!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else if (_isCalculatingPrice)
                const PricingLoadingShimmer()
              else if (hasBoth)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Không thể tính khoảng cách. Vui lòng thử lại.',
                          style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ✅ NEW: CATEGORY SELECTOR
              CategorySelector(
                selectedCategoryId: _selectedCategory,
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategory = categoryId;
                  });
                  debugPrint('✅ Category selected: $categoryId');
                },
                showDescription: true,
              ),

              const SizedBox(height: 24),

              // ✅ NEW: WEIGHT SELECTOR
              WeightSelector(
                weight: _selectedWeight,
                onWeightChanged: (newWeight) {
                  setState(() {
                    _selectedWeight = newWeight;
                  });
                  debugPrint('✅ Weight selected: $newWeight kg');
                },
                showHelperText: true,
              ),

              const SizedBox(height: 24),

              Text('Xác nhận lộ trình',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 14),

              // Pickup field
              _LocationField(
                label: 'Điểm Lấy Hàng',
                controller: _pickupCtrl,
                leading: Icons.circle,
                leadingColor: _pickupAddress == null ? Colors.grey[400]! : Colors.green,
                onTap: () => _selectLocation(isPickup: true),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Vui lòng chọn địa chỉ.' : null,
              ),
              const SizedBox(height: 16),

              // Delivery field
              _LocationField(
                label: 'Điểm Giao Hàng',
                controller: _deliveryCtrl,
                leading: Icons.location_on,
                leadingColor: _deliveryAddress == null ? Colors.grey[400]! : Colors.red,
                onTap: () => _selectLocation(isPickup: false),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Vui lòng chọn địa chỉ.' : null,
              ),
              const SizedBox(height: 20),

              // Notes
              Text('Ghi chú',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú (tùy chọn)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryOrange, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit button with price and category
              CustomButton(
                text: _submitting 
                    ? 'Đang tạo...' 
                    : _pricing != null 
                        ? 'Tạo Đơn - ${CurrencyFormatter.formatCompact(_pricing!.totalAmount)} (${_selectedWeight.toStringAsFixed(1)}kg)'
                        : 'Tạo Đơn Hàng',
                icon: Icons.add_circle_outline,
                isGradient: true,
                onPressed: _canSubmit ? _createOrder : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData leading;
  final Color leadingColor;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const _LocationField({
    required this.label,
    required this.controller,
    required this.leading,
    required this.leadingColor,
    required this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(leading, color: leadingColor, size: 20),
            suffixIcon: const Icon(Icons.search),
            hintText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}