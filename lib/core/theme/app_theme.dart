import 'package:flutter/material.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';

/// Provides fully configured [ThemeData] instances for dark and light modes.
///
/// Design language follows modern terminal applications (Warp, Hyper) with
/// attention to contrast ratios, consistent spacing, and a professional feel.
abstract final class AppTheme {
  // ---------------------------------------------------------------------------
  // Font families
  // ---------------------------------------------------------------------------
  static const String _uiFontFamily = 'Inter';
  static const String terminalFontFamily =
      AppConstants.defaultTerminalFontFamily;

  // ---------------------------------------------------------------------------
  // Shared geometry
  // ---------------------------------------------------------------------------
  static const double _borderRadius = 8.0;
  static const double _inputBorderRadius = 10.0;
  static const double _cardBorderRadius = 12.0;
  static const double _dialogBorderRadius = 16.0;

  static final BorderRadius _borderRadiusGeometry =
      BorderRadius.circular(_borderRadius);
  static final BorderRadius _inputBorderRadiusGeometry =
      BorderRadius.circular(_inputBorderRadius);
  static final BorderRadius _cardBorderRadiusGeometry =
      BorderRadius.circular(_cardBorderRadius);
  static final BorderRadius _dialogBorderRadiusGeometry =
      BorderRadius.circular(_dialogBorderRadius);

  // ===========================================================================
  // Dark theme
  // ===========================================================================
  static final ThemeData dark = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _uiFontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerColor: AppColors.darkDivider,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _uiFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _cardBorderRadiusGeometry,
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: _dialogBorderRadiusGeometry,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _uiFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnBackground,
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide:
              const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(color: AppColors.disconnected, fontSize: 14),
        labelStyle:
            const TextStyle(color: AppColors.darkOnSurface, fontSize: 14),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusGeometry),
          textStyle: const TextStyle(
            fontFamily: _uiFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkOnSurface,
          side: const BorderSide(color: AppColors.darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusGeometry),
          textStyle: const TextStyle(
            fontFamily: _uiFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          textStyle: const TextStyle(
            fontFamily: _uiFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Icon buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.darkOnSurface,
        ),
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.darkOnSurface,
        iconColor: AppColors.darkOnSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        textStyle: const TextStyle(
          color: AppColors.darkOnSurface,
          fontSize: 12,
        ),
      ),

      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.darkBorderMuted),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 0.5,
        space: 0.5,
      ),

      // Popup menu
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadiusGeometry,
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: const TextStyle(color: AppColors.darkOnSurface),
        shape: RoundedRectangleBorder(borderRadius: _borderRadiusGeometry),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab bar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.darkPrimary,
        unselectedLabelColor: AppColors.disconnected,
        indicatorColor: AppColors.darkPrimary,
      ),
    );
  }

  // ===========================================================================
  // Light theme
  // ===========================================================================
  static final ThemeData light = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _uiFontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerColor: AppColors.lightDivider,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _uiFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnSurface,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _cardBorderRadiusGeometry,
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: _dialogBorderRadiusGeometry,
        ),
        titleTextStyle: const TextStyle(
          fontFamily: _uiFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightOnBackground,
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide:
              const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _inputBorderRadiusGeometry,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(
          color: AppColors.lightOnSurfaceSubtle,
          fontSize: 14,
        ),
        labelStyle:
            const TextStyle(color: AppColors.lightOnSurface, fontSize: 14),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusGeometry),
          textStyle: const TextStyle(
            fontFamily: _uiFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightOnSurface,
          side: const BorderSide(color: AppColors.lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusGeometry),
          textStyle: const TextStyle(
            fontFamily: _uiFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          textStyle: const TextStyle(
            fontFamily: _uiFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Icon buttons
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.lightOnSurface,
        ),
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.lightOnSurface,
        iconColor: AppColors.lightOnSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),

      // Tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.lightBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0x14000000), // black at 0.08 alpha
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: AppColors.lightOnSurface,
          fontSize: 12,
        ),
      ),

      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.lightBorderStrong),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 0.5,
        space: 0.5,
      ),

      // Popup menu
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: _borderRadiusGeometry,
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightOnBackground,
        contentTextStyle: const TextStyle(color: AppColors.lightSurface),
        shape: RoundedRectangleBorder(borderRadius: _borderRadiusGeometry),
        behavior: SnackBarBehavior.floating,
      ),

      // Tab bar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.lightPrimary,
        unselectedLabelColor: AppColors.disconnected,
        indicatorColor: AppColors.lightPrimary,
      ),
    );
  }
}
