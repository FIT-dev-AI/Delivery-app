// frontend/lib/core/constants/api_constants.dart
// 🔧 FINAL VERSION - NO GOOGLE API KEYS NEEDED FOR ROUTING/SEARCH

class ApiConstants {
  static const String _localIP = '192.168.1.4';
  static const String baseUrl = 'http://$_localIP:3000/api';
  static const String socketUrl = 'http://$_localIP:3000';
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String orders = '/orders';
  static const String tracking = '/tracking';
  static const String stats = '/stats/dashboard';
}

// Note: Google Maps API key is only needed for the Maps UI (free for mobile apps)
// Routing uses OSRM (free) and Place search uses Nominatim (free)