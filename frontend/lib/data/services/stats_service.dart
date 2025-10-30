// lib/data/services/stats_service.dart
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class StatsService {
  final ApiService _api;

  StatsService(this._api);

  // Lấy dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _api.get(ApiEndpoints.stats);

      if (response.data['success']) {
        return response.data['data'];
      }

      throw Exception(response.data['message'] ?? 'Không thể lấy thống kê');
    } catch (e) {
      throw Exception('Lỗi lấy thống kê: ${e.toString()}');
    }
  }
}