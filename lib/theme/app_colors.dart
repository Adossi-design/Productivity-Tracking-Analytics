import 'package:flutter/material.dart';

/// Central brand palette. Use these instead of scattering raw hex literals so
/// the theme can be changed in one place and stays consistent across screens.
class AppColors {
  AppColors._();

  /// Primary brand indigo.
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  /// Semantic accents.
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);
  static const Color accentPurple = Color(0xFF8B5CF6);

  /// Surfaces.
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightScaffold = Color(0xFFF8FAFC);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkScaffold = Color(0xFF1E1E2E);
  static const Color darkCard = Color(0xFF2A2A3E);
  static const Color darkDrawer = Color(0xFF1E1E3A);

  /// Neutral text/border tones.
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  /// Ordered palette used for charts (pie slices, cluster badges).
  static const List<Color> chart = [
    primary,
    success,
    warning,
    danger,
    accentPurple,
    info,
  ];
}
