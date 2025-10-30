// frontend/lib/presentation/widgets/map_widget.dart
// ✅ KEEP GOOGLE MAPS WIDGET + USE OSRM FOR ROUTING

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/order_model.dart';
import '../../data/services/osrm_routing_service.dart'; // ← NEW
import '../../core/constants/app_colors.dart';

class MapWidget extends StatefulWidget {
  final Order order;
  const MapWidget({super.key, required this.order});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;
  String _routeError = '';
  double? _distanceKm;
  int? _durationMin;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id) {
      _initializeMap();
    }
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoadingRoute = true;
      _routeError = '';
    });

    _setupMarkers();
    await _fetchRoute();
    _fitMapBounds();
  }

  void _setupMarkers() {
    final markers = <Marker>{};

    // 📍 Pickup marker (Green)
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.order.pickupLat, widget.order.pickupLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Lấy hàng',
          snippet: widget.order.pickupAddress,
        ),
      ),
    );

    // 📍 Delivery marker (Red)
    markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(widget.order.deliveryLat, widget.order.deliveryLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Giao hàng',
          snippet: widget.order.deliveryAddress,
        ),
      ),
    );

    // 🚚 Shipper marker (Blue) - Note: shipper location tracking would need to be implemented
    // if (widget.order.status == 'in_transit' && widget.order.shipperLat != null) {
    //   markers.add(
    //     Marker(
    //       markerId: const MarkerId('shipper'),
    //       position: LatLng(widget.order.shipperLat!, widget.order.shipperLng!),
    //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    //       infoWindow: const InfoWindow(title: 'Shipper'),
    //     ),
    //   );
    // }

    setState(() {
      _markers = markers;
    });
  }

  Future<void> _fetchRoute() async {
    try {
      debugPrint('🛣️ Fetching route via OSRM...');
      debugPrint('   Origin: ${widget.order.pickupLat},${widget.order.pickupLng}');
      debugPrint('   Destination: ${widget.order.deliveryLat},${widget.order.deliveryLng}');

      final routeResult = await OsrmRoutingService.getRoute(
        startLat: widget.order.pickupLat,
        startLng: widget.order.pickupLng,
        endLat: widget.order.deliveryLat,
        endLng: widget.order.deliveryLng,
      );

      if (routeResult != null) {
        final routePoints = routeResult['points'] as List<LatLng>;
        
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: primaryOrange,
              width: 5,
              patterns: [
                PatternItem.dash(20),
                PatternItem.gap(10),
              ],
            ),
          };
          _distanceKm = routeResult['distance'] as double?;
          _durationMin = routeResult['duration'] as int?;
          _isLoadingRoute = false;
        });

        debugPrint('✅ Route loaded: ${routePoints.length} points');
        debugPrint('   Distance: $_distanceKm km');
        debugPrint('   Duration: $_durationMin min');
      } else {
        throw Exception('No route found');
      }
    } catch (e) {
      debugPrint('❌ Route error: $e');
      
      // Fallback: straight line
      _drawStraightLineFallback();
      
      setState(() {
        _routeError = 'Đường thẳng (OSRM không khả dụng)';
        _isLoadingRoute = false;
      });
    }
  }

  void _drawStraightLineFallback() {
    debugPrint('📏 Drawing fallback straight line');
    
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('straight_line'),
          points: [
            LatLng(widget.order.pickupLat, widget.order.pickupLng),
            LatLng(widget.order.deliveryLat, widget.order.deliveryLng),
          ],
          color: Colors.grey[600]!,
          width: 3,
          patterns: [PatternItem.dash(10), PatternItem.gap(5)],
        ),
      };
    });
  }

  void _fitMapBounds() {
    if (_mapController == null) return;

    double minLat = widget.order.pickupLat;
    double maxLat = widget.order.pickupLat;
    double minLng = widget.order.pickupLng;
    double maxLng = widget.order.pickupLng;

    if (widget.order.deliveryLat < minLat) minLat = widget.order.deliveryLat;
    if (widget.order.deliveryLat > maxLat) maxLat = widget.order.deliveryLat;
    if (widget.order.deliveryLng < minLng) minLng = widget.order.deliveryLng;
    if (widget.order.deliveryLng > maxLng) maxLng = widget.order.deliveryLng;

    // Note: Shipper location bounds calculation would need to be implemented
    // if (widget.order.shipperLat != null) {
    //   if (widget.order.shipperLat! < minLat) minLat = widget.order.shipperLat!;
    //   if (widget.order.shipperLat! > maxLat) maxLat = widget.order.shipperLat!;
    //   if (widget.order.shipperLng! < minLng) minLng = widget.order.shipperLng!;
    //   if (widget.order.shipperLng! > maxLng) maxLng = widget.order.shipperLng!;
    // }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ VẪN DÙNG GOOGLE MAPS WIDGET
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.order.pickupLat, widget.order.pickupLng),
            zoom: 13,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            _fitMapBounds();
          },
        ),

        // 🔄 Loading indicator
        if (_isLoadingRoute)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Đang tải route...', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),

        // ⚠️ Error indicator
        if (_routeError.isNotEmpty && !_isLoadingRoute)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      _routeError,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 📊 Distance info
        if (_distanceKm != null && _durationMin != null)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.straighten, size: 16, color: primaryOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${_distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: primaryOrange),
                      const SizedBox(width: 4),
                      Text(
                        '$_durationMin phút',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}