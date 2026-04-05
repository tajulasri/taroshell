import 'package:flutter/material.dart';

/// Centralized color palette for TaroShell.
///
/// Provides consistent dark and light theme colors, status indicators,
/// and semantic color accessors. All color values are defined as constants
/// to avoid magic hex values throughout the codebase.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Dark theme palette
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF1E1E2E);
  static const Color darkSurface = Color(0xFF2A2A3C);
  static const Color darkSurfaceVariant = Color(0xFF313147);
  static const Color darkPrimary = Color(0xFF6366F1);
  static const Color darkPrimaryVariant = Color(0xFF818CF8);
  static const Color darkSecondary = Color(0xFFA78BFA);
  static const Color darkAccent = Color(0xFF22D3EE);
  static const Color darkOnBackground = Color(0xFFE2E8F0);
  static const Color darkOnSurface = Color(0xFFCBD5E1);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkBorder = Color(0xFF3F3F5C);
  static const Color darkDivider = Color(0xFF2E2E44);

  // ---------------------------------------------------------------------------
  // Light theme palette
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightPrimaryVariant = Color(0xFF6366F1);
  static const Color lightSecondary = Color(0xFF7C3AED);
  static const Color lightAccent = Color(0xFF0891B2);
  static const Color lightOnBackground = Color(0xFF1E293B);
  static const Color lightOnSurface = Color(0xFF334155);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // ---------------------------------------------------------------------------
  // Status / semantic colors (shared across themes)
  // ---------------------------------------------------------------------------
  static const Color connected = Color(0xFF22C55E);
  static const Color disconnected = Color(0xFF94A3B8);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Pre-computed alpha variants (avoid per-frame withValues calls)
  // ---------------------------------------------------------------------------
  static const Color darkOnSurfaceMuted = Color(0x99CBD5E1); // 0.6 alpha
  static const Color darkOnSurfaceSubtle = Color(0x66CBD5E1); // 0.4 alpha
  static const Color lightOnSurfaceMuted = Color(0x99334155); // 0.6 alpha
  static const Color lightOnSurfaceSubtle = Color(0x66334155); // 0.4 alpha
  static const Color darkSurfaceVariantHalf = Color(0x80313147); // 0.5 alpha
  static const Color darkBorderMuted = Color(0x993F3F5C); // 0.6 alpha
  static const Color lightBorderStrong = Color(0xCCE2E8F0); // 0.8 alpha

  // ---------------------------------------------------------------------------
  // Primary alpha variants
  // ---------------------------------------------------------------------------
  static const Color lightPrimaryAlpha10 = Color(0x1A4F46E5);
  static const Color darkPrimaryAlpha10 = Color(0x1A6366F1);
  static const Color lightPrimaryAlpha60 = Color(0x994F46E5);
  static const Color darkPrimaryAlpha60 = Color(0x996366F1);

  // ---------------------------------------------------------------------------
  // Overlay colors
  // ---------------------------------------------------------------------------
  static const Color overlayLight = Color(0x1F000000); // Colors.black12

  // ---------------------------------------------------------------------------
  // Text on primary surface
  // ---------------------------------------------------------------------------
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Terminal-specific colors
  // ---------------------------------------------------------------------------
  static const Color terminalCursorDark = Color(0xFFE2E8F0);
  static const Color terminalCursorLight = Color(0xFF1E293B);
  static const Color terminalSelectionDark = Color(0x606366F1);
  static const Color terminalSelectionLight = Color(0x604F46E5);
}
