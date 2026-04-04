import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import 'package:taroshell/core/theme/app_colors.dart';

/// Terminal color schemes for the xterm terminal emulator widget.
///
/// Provides a dark and light [TerminalTheme] with a standard 16-color ANSI
/// palette and search highlight colors that integrate with the overall
/// TaroShell design system.
abstract final class AppTerminalTheme {
  // ===========================================================================
  // Dark terminal theme (Catppuccin Mocha-inspired)
  // ===========================================================================
  static const TerminalTheme dark = TerminalTheme(
    cursor: AppColors.terminalCursorDark,
    selection: AppColors.terminalSelectionDark,
    foreground: Color(0xFFCDD6F4),
    background: AppColors.darkBackground,
    // Standard ANSI colors
    black: Color(0xFF45475A),
    red: Color(0xFFF38BA8),
    green: Color(0xFFA6E3A1),
    yellow: Color(0xFFF9E2AF),
    blue: Color(0xFF89B4FA),
    magenta: Color(0xFFF5C2E7),
    cyan: Color(0xFF94E2D5),
    white: Color(0xFFBAC2DE),
    // Bright ANSI colors
    brightBlack: Color(0xFF585B70),
    brightRed: Color(0xFFF38BA8),
    brightGreen: Color(0xFFA6E3A1),
    brightYellow: Color(0xFFF9E2AF),
    brightBlue: Color(0xFF89B4FA),
    brightMagenta: Color(0xFFF5C2E7),
    brightCyan: Color(0xFF94E2D5),
    brightWhite: Color(0xFFA6ADC8),
    // Search highlights
    searchHitBackground: Color(0xFFF9E2AF),
    searchHitBackgroundCurrent: Color(0xFFA6E3A1),
    searchHitForeground: Color(0xFF1E1E2E),
  );

  // ===========================================================================
  // Light terminal theme (Catppuccin Latte-inspired)
  // ===========================================================================
  static const TerminalTheme light = TerminalTheme(
    cursor: AppColors.terminalCursorLight,
    selection: AppColors.terminalSelectionLight,
    foreground: Color(0xFF4C4F69),
    background: AppColors.lightBackground,
    // Standard ANSI colors
    black: Color(0xFF5C5F77),
    red: Color(0xFFD20F39),
    green: Color(0xFF40A02B),
    yellow: Color(0xFFDF8E1D),
    blue: Color(0xFF1E66F5),
    magenta: Color(0xFFEA76CB),
    cyan: Color(0xFF179299),
    white: Color(0xFFACB0BE),
    // Bright ANSI colors
    brightBlack: Color(0xFF6C6F85),
    brightRed: Color(0xFFD20F39),
    brightGreen: Color(0xFF40A02B),
    brightYellow: Color(0xFFDF8E1D),
    brightBlue: Color(0xFF1E66F5),
    brightMagenta: Color(0xFFEA76CB),
    brightCyan: Color(0xFF179299),
    brightWhite: Color(0xFF4C4F69),
    // Search highlights
    searchHitBackground: Color(0xFFDF8E1D),
    searchHitBackgroundCurrent: Color(0xFF40A02B),
    searchHitForeground: Color(0xFFFFFFFF),
  );
}
