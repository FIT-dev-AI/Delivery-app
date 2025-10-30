// frontend/lib/data/services/nominatim_service.dart
// 🔍 FREE ALTERNATIVE TO GOOGLE PLACES API

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NominatimService {
  static final Dio _dio = Dio();
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Search places - FREE alternative to Google Places Autocomplete
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final searchQuery = '$query, Ho Chi Minh City, Vietnam';
      
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': searchQuery,
          'format': 'json',
          'addressdetails': 1,
          'limit': 5,
          'countrycodes': 'vn',
        },
        options: Options(
          headers: {
            'User-Agent': 'DeliveryApp/1.0',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data;
        
        debugPrint('🔍 Nominatim: Found ${results.length} results for "$query"');

        return results.map((result) {
          return {
            'place_id': result['place_id'].toString(),
            'display_name': result['display_name'] as String,
            'lat': double.parse(result['lat']),
            'lng': double.parse(result['lon']),
            'address': result['address'] as Map<String, dynamic>?,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Nominatim error: $e');
      return [];
    }
  }

  /// Reverse geocoding - Get address from coordinates
  static Future<Map<String, dynamic>?> reverseGeocode({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'DeliveryApp/1.0',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'display_name': data['display_name'] as String,
          'address': data['address'] as Map<String, dynamic>,
        };
      }

      return null;
    } catch (e) {
      debugPrint('❌ Reverse geocoding error: $e');
      return null;
    }
  }

  /// Format address nicely
  static String formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '';

    List<String> parts = [];

    if (address['house_number'] != null) parts.add(address['house_number']);
    if (address['road'] != null) parts.add(address['road']);
    if (address['suburb'] != null) parts.add(address['suburb']);
    if (address['city'] != null) {
      parts.add(address['city']);
    } else if (address['town'] != null) {
      parts.add(address['town']);
    }

    return parts.join(', ');
  }
}
