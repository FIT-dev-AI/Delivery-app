// frontend/lib/data/services/location_service.dart (ĐÃ SỬA LỖI & CẬP NHẬT)

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
// Dòng 'google_maps_flutter' đã được xóa vì không cần thiết
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class LocationService {
  final ApiService _api;

  LocationService([ApiService? apiService]) : _api = apiService ?? ApiService();

  /// Lấy vị trí GPS hiện tại của thiết bị.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Vui lòng bật dịch vụ vị trí (GPS).');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền truy cập vị trí đã bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng vào cài đặt để cấp quyền.');
    }

    // ===> SỬA LỖI DEPRECATED Ở ĐÂY <====
    // Sử dụng LocationSettings thay cho desiredAccuracy
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Cập nhật vị trí sau mỗi 10 mét
    );

    return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
  }

  /// Gửi tọa độ của shipper lên server backend.
  Future<void> updateShipperLocation(double latitude, double longitude, {int? orderId}) async {
    try {
      await _api.post(
        '${ApiEndpoints.tracking}/update', 
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'order_id': orderId,
        },
      );
    } catch (e) {
      debugPrint('Lỗi cập nhật vị trí lên server: $e');
      rethrow;
    }
  }
}