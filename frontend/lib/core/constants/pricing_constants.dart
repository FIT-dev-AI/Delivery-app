// frontend/lib/core/constants/pricing_constants.dart
// 💰 PRICING CONFIGURATION & UTILITIES

import 'package:intl/intl.dart';

/// Pricing configuration constants
class PricingConfig {
  // Base rates
  static const double pricePerKm = 10000; // 10,000 VNĐ per km
  static const double shipperCommission = 0.70; // 70% for shipper
  static const double appCommission = 0.30; // 30% for app
  
  // Minimums
  static const double minDistance = 0.5; // km
  static const double minAmount = 5000; // VNĐ
  
  // Display
  static const String currency = '₫';
  static const String currencyFull = 'VNĐ';
}

/// Pricing calculation result
class PricingResult {
  final double distanceKm;
  final double totalAmount;
  final double shipperAmount;
  final double appCommission;

  const PricingResult({
    required this.distanceKm,
    required this.totalAmount,
    required this.shipperAmount,
    required this.appCommission,
  });

  /// Create from distance
  factory PricingResult.fromDistance(double distanceKm) {
    return PricingCalculator.calculate(distanceKm);
  }

  /// Check if pricing is valid
  bool get isValid => totalAmount > 0 && distanceKm > 0;
}

/// Pricing calculator utility
class PricingCalculator {
  /// Calculate pricing from distance
  static PricingResult calculate(double distanceKm) {
    // Apply minimum distance
    final double billableDistance = distanceKm < PricingConfig.minDistance
        ? PricingConfig.minDistance
        : distanceKm;

    // Calculate base amount
    double totalAmount = billableDistance * PricingConfig.pricePerKm;

    // Apply minimum amount
    totalAmount = totalAmount < PricingConfig.minAmount
        ? PricingConfig.minAmount
        : totalAmount;

    // Calculate commission split
    final shipperAmount = (totalAmount * PricingConfig.shipperCommission).round().toDouble();
    final appCommission = (totalAmount * PricingConfig.appCommission).round().toDouble();

    // Adjust total to match sum (handle rounding)
    final adjustedTotal = shipperAmount + appCommission;

    return PricingResult(
      distanceKm: _roundTo2Decimals(distanceKm),
      totalAmount: adjustedTotal,
      shipperAmount: shipperAmount,
      appCommission: appCommission,
    );
  }

  static double _roundTo2Decimals(double value) {
    return (value * 100).round() / 100;
  }
}

/// Currency formatting utilities
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  /// Format amount to Vietnamese currency
  /// Example: 50000 -> "50,000 ₫"
  static String format(double amount, {bool showSymbol = true}) {
    final formatted = _formatter.format(amount.round());
    return showSymbol ? '$formatted ${PricingConfig.currency}' : formatted;
  }

  /// Format amount to compact form
  /// Example: 50000 -> "50k"
  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ${PricingConfig.currency}';
    } else if (amount >= 1000) {
      return '${(amount / 1000).round()}k ${PricingConfig.currency}';
    }
    return '${amount.round()} ${PricingConfig.currency}';
  }

  /// Format distance
  /// Example: 5.5 -> "5.5 km"
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}

/// Pricing display texts
class PricingText {
  static const String distanceLabel = 'Khoảng cách';
  static const String totalLabel = 'Tổng tiền';
  static const String shipperLabel = 'Shipper nhận';
  static const String pricePerKmLabel = 'Giá/km';
  static const String estimatedLabel = 'Ước tính';
  static const String breakdownLabel = 'Chi tiết giá';
}