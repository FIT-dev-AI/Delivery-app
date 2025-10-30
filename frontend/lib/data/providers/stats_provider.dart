// lib/data/providers/stats_provider.dart
import 'package:flutter/material.dart';
import '../services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _statsService;

  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StatsProvider(this._statsService);

  // ADD this method to process stats by role
  Map<String, dynamic> _processStatsByRole(
    Map<String, dynamic> rawStats,
    bool isShipper,
  ) {
    if (isShipper) {
      // Shipper sees: total, completed (delivered), in_progress, cancelled
      return {
        'totalOrders': rawStats['totalOrders'] ?? 0,
        'completedOrders': rawStats['delivered'] ?? 0, // Đã giao
        'inProgressOrders': rawStats['in_transit'] ?? 0, // Đang giao
        'cancelledOrders': rawStats['cancelled'] ?? 0,
        'revenue': rawStats['revenue'] ?? 0,
        'revenueGrowth': rawStats['revenueGrowth'] ?? 0,
      };
    } else {
      // Customer sees: total, completed (received), in_transit, pending
      return {
        'totalOrders': rawStats['totalOrders'] ?? 0,
        'completedOrders': rawStats['delivered'] ?? 0, // Đã nhận
        'inProgressOrders': rawStats['in_transit'] ?? 0, // Đang vận chuyển
        'pendingOrders': rawStats['pending'] ?? 0, // Đang chờ
        'totalSpent': rawStats['totalSpent'] ?? 0, // For customer
        'revenueGrowth': rawStats['revenueGrowth'] ?? 0,
      };
    }
  }

  // Lấy thống kê từ API
  Future<void> fetchStats([bool isShipper = true]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _statsService.getDashboardStats();
      
      // ✅ Process stats based on role
      _stats = _processStatsByRole(response, isShipper);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh stats
  Future<void> refreshStats([bool isShipper = true]) async {
    await fetchStats(isShipper);
  }
}