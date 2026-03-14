import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF1A6B3C);        // deep green
  static const Color primaryLight = Color(0xFF4CAF78);
  static const Color primaryDark = Color(0xFF0D4726);

  // Accent
  static const Color accent = Color(0xFFFFC107);          // amber

  // Neutrals
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F7);

  // Text
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFB0B7C3);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Role badge colors
  static const Map<String, Color> roleBadge = {
    'admin': Color(0xFF7C3AED),
    'committee': Color(0xFF1A6B3C),
    'support_staff': Color(0xFF0EA5E9),
    'member': Color(0xFF6B7280),
  };
}
