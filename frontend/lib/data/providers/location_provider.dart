// frontend/lib/data/providers/location_provider.dart
// 📍 LOCATION STATE MANAGEMENT

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import 'dart:async';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  
  LatLng? _currentLocation;
  bool _isTracking = false;
  StreamSubscription<Position>? _locationSubscription;

  LocationProvider(this._locationService);

  LatLng? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;

  /// Get current location once
  Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
      return _currentLocation;
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Start tracking location (for shippers during delivery)
  Future<void> startTracking(int orderId) async {
    if (_isTracking) return;

    _isTracking = true;
    notifyListeners();

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (position) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        notifyListeners();

        // Update location to server
        _locationService.updateShipperLocation(
          position.latitude,
          position.longitude,
          orderId: orderId,
        );
      },
      onError: (error) {
        debugPrint('❌ Location tracking error: $error');
        stopTracking();
      },
    );
  }

  /// Stop tracking
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}