// frontend/lib/data/services/navigation_service.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

/// Service để mở Google Maps app cho navigation
/// 
/// Hỗ trợ:
/// - Chỉ đường từ vị trí hiện tại đến destination
/// - Chỉ đường từ origin đến destination
/// - Xem vị trí trên Google Maps (không chỉ đường)
class NavigationService {
  /// Mở Google Maps để chỉ đường từ vị trí hiện tại đến destination
  /// 
  /// Sử dụng cho Shipper khi đang giao hàng
  /// 
  /// Example:
  /// ```dart
  /// await NavigationService.openGoogleMapsNavigation(
  ///   destination: LatLng(10.773496, 106.697807),
  ///   destinationLabel: 'Crescent Mall',
  /// );
  /// ```
  static Future<void> openGoogleMapsNavigation({
    required LatLng destination,
    String? destinationLabel,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🗺️ Mở Google Maps Navigation');
    debugPrint('Destination: ${destination.latitude},${destination.longitude}');
    if (destinationLabel != null) debugPrint('Label: $destinationLabel');

    // URL scheme cho Google Maps navigation
    // Tự động chỉ đường từ vị trí hiện tại → destination
    final String googleMapsUrl = 
        'https://www.google.com/maps/dir/?api=1'
        '&destination=${destination.latitude},${destination.longitude}'
        '&travelmode=driving';
    
    try {
      final Uri uri = Uri.parse(googleMapsUrl);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Mở trong Google Maps app
        );
        
        if (launched) {
          debugPrint('✅ Đã mở Google Maps thành công');
        } else {
          debugPrint('❌ Không thể launch URL');
          throw 'Không thể mở Google Maps';
        }
      } else {
        debugPrint('❌ canLaunchUrl returned false');
        throw 'Không thể mở Google Maps. Vui lòng cài đặt Google Maps.';
      }
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// Mở Google Maps với route từ origin đến destination
  /// 
  /// Sử dụng khi muốn xem route trước khi bắt đầu giao hàng
  /// 
  /// Example:
  /// ```dart
  /// await NavigationService.openGoogleMapsRoute(
  ///   origin: LatLng(10.762622, 106.660172),
  ///   destination: LatLng(10.773496, 106.697807),
  /// );
  /// ```
  static Future<void> openGoogleMapsRoute({
    required LatLng origin,
    required LatLng destination,
    String? originLabel,
    String? destinationLabel,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🗺️ Mở Google Maps Route');
    debugPrint('Origin: ${origin.latitude},${origin.longitude}');
    debugPrint('Destination: ${destination.latitude},${destination.longitude}');
    
    // URL với cả origin và destination
    final String googleMapsUrl = 
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&travelmode=driving';
    
    try {
      final Uri uri = Uri.parse(googleMapsUrl);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          debugPrint('✅ Đã mở Google Maps Route');
        } else {
          throw 'Không thể mở Google Maps';
        }
      } else {
        throw 'Không thể mở Google Maps. Vui lòng cài đặt Google Maps.';
      }
      
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      debugPrint('❌ Exception: $e');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      rethrow;
    }
  }

  /// Mở Google Maps để xem vị trí (không chỉ đường)
  /// 
  /// Sử dụng khi chỉ muốn xem địa điểm trên map
  /// 
  /// Example:
  /// ```dart
  /// await NavigationService.openGoogleMapsLocation(
  ///   location: LatLng(10.762622, 106.660172),
  ///   label: 'Vincom Center',
  /// );
  /// ```
  static Future<void> openGoogleMapsLocation({
    required LatLng location,
    String? label,
  }) async {
    debugPrint('🗺️ Mở Google Maps Location');
    debugPrint('Location: ${location.latitude},${location.longitude}');
    
    final String googleMapsUrl = 
        'https://www.google.com/maps/search/?api=1'
        '&query=${location.latitude},${location.longitude}';
    
    try {
      final Uri uri = Uri.parse(googleMapsUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ Đã mở Google Maps Location');
      } else {
        throw 'Không thể mở Google Maps';
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      rethrow;
    }
  }

  /// Hiển thị dialog lỗi khi không mở được Google Maps
  /// 
  /// Tự động kiểm tra context.mounted trước khi hiển thị
  static void showNavigationError(BuildContext context, String error) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 12),
            Text('Không thể mở Google Maps'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Kiểm tra xem Google Maps app có được cài đặt không
  /// 
  /// Returns: true nếu có thể mở Google Maps
  static Future<bool> isGoogleMapsInstalled() async {
    try {
      final Uri testUri = Uri.parse('https://www.google.com/maps');
      return await canLaunchUrl(testUri);
    } catch (e) {
      debugPrint('❌ Error checking Google Maps: $e');
      return false;
    }
  }
}