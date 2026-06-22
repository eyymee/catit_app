import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // Headline — Plus Jakarta Sans
  static TextStyle headlineLg({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        height: 1.25,
        letterSpacing: -0.02 * 32,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineLgMobile({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineMd({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
      );

  // Body — Inter
  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyMd({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.onSurface,
      );

  // Label — Inter
  static TextStyle labelMd({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle labelSm({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.onSurface,
      );
}
