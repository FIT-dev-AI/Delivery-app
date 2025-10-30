// frontend/lib/core/constants/app_colors.dart
// ✅ UPDATED: Added warningOrange for offline warning banner

import 'package:flutter/material.dart';

// ==================== PRIMARY COLORS ====================
// Cam Gradient Hiện Đại (2025 Design Trend)
const Color primaryOrange = Color(0xFFFF6B35); // Cam chính
const Color secondaryOrange = Color(0xFFFF8C42); // Cam phụ
const Color accentOrange = Color(0xFFFFA94D); // Cam accent

// ==================== STATUS COLORS ====================
const Color successGreen = Color(0xFF4CAF50); // Xanh lá - Success
const Color warningYellow = Color(0xFFFFB84D); // Vàng - Warning (general)
const Color warningOrange = Color(0xFFFFA726); // ✅ NEW: Cam - Warning (offline/critical)
const Color errorRed = Color(0xFFF44336); // Đỏ - Error
const Color infoBlue = Color(0xFF2196F3); // Xanh dương - Info

// ==================== BACKGROUND & SURFACE ====================
const Color backgroundColor = Color(0xFFF8F9FA); // Nền app
const Color cardBackground = Color(0xFFFFFFFF); // Nền card
const Color surfaceColor = Color(0xFFFAFAFA); // Bề mặt

// ==================== TEXT COLORS ====================
const Color textDark = Color(0xFF2C3E50); // Text chính
const Color textLight = Color(0xFF7F8C8D); // Text phụ
const Color textHint = Color(0xFFBDC3C7); // Text hint/placeholder

// ==================== GRADIENT STYLES ====================
// Primary gradient - Dùng cho buttons, headers
const LinearGradient primaryGradient = LinearGradient(
  colors: [primaryOrange, secondaryOrange],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Card gradient - Dùng cho cards, containers
const LinearGradient cardGradient = LinearGradient(
  colors: [Color(0xFFFFF5F0), Color(0xFFFFFFFF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Success gradient - Dùng cho success states
const LinearGradient successGradient = LinearGradient(
  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Warning gradient - Dùng cho warning states
const LinearGradient warningGradient = LinearGradient(
  colors: [Color(0xFFFFA726), Color(0xFFFFB74D)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Error gradient - Dùng cho error states
const LinearGradient errorGradient = LinearGradient(
  colors: [Color(0xFFF44336), Color(0xFFE57373)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ==================== SHIPPER STATUS COLORS ====================
// Dùng cho online/offline indicators
const Color onlineGreen = Color(0xFF4CAF50); // Online status
const Color offlineGrey = Color(0xFF9E9E9E); // Offline status

// ==================== SHADOW COLORS ====================
// Dùng cho shadows và elevations
Color lightShadow = Colors.black.withAlpha(13); // 5% opacity
Color mediumShadow = Colors.black.withAlpha(25); // 10% opacity
Color darkShadow = Colors.black.withAlpha(51); // 20% opacity

// ==================== OVERLAY COLORS ====================
// Dùng cho overlays, backdrops
Color lightOverlay = Colors.black.withAlpha(76); // 30% opacity
Color mediumOverlay = Colors.black.withAlpha(127); // 50% opacity
Color darkOverlay = Colors.black.withAlpha(178); // 70% opacity

// ==================== HELPER FUNCTIONS ====================
// Convert opacity (0.0-1.0) to alpha (0-255)
int opacityToAlpha(double opacity) {
  return (opacity * 255).round().clamp(0, 255);
}

// Create color with specific opacity
Color colorWithOpacity(Color color, double opacity) {
  return color.withAlpha(opacityToAlpha(opacity));
}