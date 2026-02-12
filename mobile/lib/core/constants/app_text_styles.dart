import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headlines - DM Sans for distinctive headings
  static TextStyle headlineLarge = GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headlineMedium = GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle headlineSmall = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Title styles
  static TextStyle titleLarge = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body - Source Sans 3 for readable body text
  static TextStyle bodyLarge = GoogleFonts.sourceSans3(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.sourceSans3(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.sourceSans3(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.sourceSans3(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.sourceSans3(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelSmall = GoogleFonts.sourceSans3(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
  );

  // Button text
  static TextStyle button = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle buttonSmall = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Special styles
  static TextStyle voucherCode = GoogleFonts.jetBrainsMono(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );

  static TextStyle statValue = GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static TextStyle statLabel = GoogleFonts.sourceSans3(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  static TextStyle price = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // Status badges
  static TextStyle badgeText = GoogleFonts.sourceSans3(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
