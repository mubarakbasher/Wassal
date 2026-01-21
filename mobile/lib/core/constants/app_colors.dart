import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Fitness App Style - Pink/Red)
  static const Color primary = Color(0xFFFF4B5C); // Pinkish Red
  static const Color primaryDark = Color(0xFFD63447);
  static const Color primaryLight = Color(0xFFFFB7B2);

  // Accent Colors
  static const Color accent = Color(0xFF000000); // Black for contrast icons
  static const Color accentLight = Color(0xFFE0E0E0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF); // Clean White Background
  static const Color card = Color(0xFFF5F5F5); // Light Gray for inactive cards
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFEEEEEE);

  // Active/Inactive Card Colors
  static const Color cardActive = Color(0xFFFF4B5C);
  static const Color cardInactive = Color(0xFFF5F7FA);
  
  // Router Status Colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color errorStatus = Color(0xFFF44336);

  // Voucher Status Colors
  static const Color unused = Color(0xFF2196F3);
  static const Color active = Color(0xFF4CAF50);
  static const Color expired = Color(0xFF9E9E9E);
  static const Color sold = Color(0xFFFF9800);
}
