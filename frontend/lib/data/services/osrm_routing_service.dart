// frontend/lib/data/services/osrm_routing_service.dart
// 🛣️ OSRM ROUTING - FREE ALTERNATIVE TO GOOGLE DIRECTIONS

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class OsrmRoutingService {
  static final Dio _dio = Dio();

  /// Get route using OSRM (OpenStreetMap Routing Machine)
  /// FREE - No API key required!
  static Future<Map<String, dynamic>?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      // OSRM API endpoint (public, free)
      final String url = 
          'https://router.project-osrm.org/route/v1/driving/'
          '$startLng,$startLat;$endLng,$endLat'
          '?overview=full&geometries=polyline';

      debugPrint('🌐 Calling OSRM: $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] == 'Ok' && data['routes'] != null) {
          final route = data['routes'][0];
          final geometry = route['geometry'] as String;
          
          // Decode polyline to LatLng points
          final List<LatLng> points = _decodePolyline(geometry);
          
          // Extract distance & duration
          final double distanceKm = route['distance'] / 1000;
          final int durationMin = (route['duration'] / 60).round();

          debugPrint('✅ OSRM Success: ${points.length} points, $distanceKm km');

          return {
            'points': points,
            'distance': distanceKm,
            'duration': durationMin,
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ OSRM Error: $e');
      return null;
    }
  }

  /// Decode polyline (Google's encoding format)
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
