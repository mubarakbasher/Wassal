import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Deep Navy to Electric Blue Gradient
  static const Color primary = Color(0xFF1E3A5F); // Deep Navy
  static const Color primaryDark = Color(0xFF0D2137); // Darker Navy
  static const Color primaryLight = Color(0xFF2E5A8B); // Lighter Navy
  static const Color accent = Color(0xFF00D4FF); // Electric Blue/Cyan
  static const Color accentLight = Color(0xFF7EEAFF); // Light Cyan

  // Gradient Colors for UI elements
  static const Color gradientStart = Color(0xFF1E3A5F); // Deep Navy
  static const Color gradientMiddle = Color(0xFF2E5A8B); // Mid Blue
  static const Color gradientEnd = Color(0xFF00D4FF); // Electric Cyan
  
  // Secondary accent colors
  static const Color secondary = Color(0xFF6C63FF); // Soft Purple
  static const Color secondaryLight = Color(0xFFA5A0FF);
  
  // Status Colors - Vibrant and modern
  static const Color success = Color(0xFF00C853); // Bright Green
  static const Color successLight = Color(0xFFB9F6CA);
  static const Color warning = Color(0xFFFFAB00); // Amber
  static const Color warningLight = Color(0xFFFFE57F);
  static const Color error = Color(0xFFFF5252); // Coral Red
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color info = Color(0xFF00B8D4); // Cyan
  static const Color infoLight = Color(0xFFB2EBF2);

  // Neutral Colors - Clean and modern
  static const Color background = Color(0xFFF8FAFC); // Soft White-Blue
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFF1F5F9); // Slightly gray cards
  static const Color textPrimary = Color(0xFF1E293B); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B); // Slate Gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light Slate
  static const Color divider = Color(0xFFE2E8F0); // Light Gray-Blue
  static const Color border = Color(0xFFCBD5E1); // Border Gray

  // Dark theme variants
  static const Color darkBackground = Color(0xFF0F172A); // Very Dark Blue
  static const Color darkSurface = Color(0xFF1E293B); // Dark Slate
  static const Color darkCard = Color(0xFF334155); // Slate
  
  // Active/Inactive States
  static const Color cardActive = Color(0xFF1E3A5F);
  static const Color cardInactive = Color(0xFFF1F5F9);
  
  // Router Status Colors
  static const Color online = Color(0xFF00C853);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color errorStatus = Color(0xFFFF5252);

  // Voucher Status Colors
  static const Color unused = Color(0xFF00B8D4); // Cyan
  static const Color active = Color(0xFF00C853); // Green
  static const Color expired = Color(0xFF9E9E9E); // Gray
  static const Color sold = Color(0xFFFFAB00); // Amber
  static const Color used = Color(0xFF6C63FF); // Purple

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Glass effect colors
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x1A000000);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // Glass morphism gradient
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
  );

  // Stats card gradients
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8B)],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B8D4), Color(0xFF00D4FF)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFFA5A0FF)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
  );
}
