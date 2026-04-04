/// Application-wide constants for Taro Shell.
///
/// All magic numbers and strings are centralized here to maintain
/// a single source of truth across the application.
abstract final class AppConstants {
  // Application metadata
  static const String appName = 'Taro Shell';
  static const String appTitle = 'Taro Shell - SSH Console';
  static const String appVersion = '1.0.0';
  static const String appAuthorEmail = 'espressobyte@gmail.com';
  static const String appCopyright = '\u00a9 2026 espressobyte. All rights reserved.';

  // SSH connection defaults
  static const int defaultSshPort = 22;
  static const int connectionTimeoutSeconds = 30;
  static const int keepAliveIntervalSeconds = 60;

  // Terminal configuration
  static const int defaultScrollbackLines = 10000;
  static const double defaultFontSize = 14.0;
  static const double minFontSize = 10.0;
  static const double maxFontSize = 24.0;
  static const String defaultTerminalFontFamily = 'JetBrainsMono';

  // Layout dimensions
  static const double sidebarWidth = 260.0;
  static const double sidebarMinWidth = 200.0;
  static const double sidebarMaxWidth = 400.0;
  static const double titleBarHeight = 38.0;
  static const double statusBarHeight = 28.0;

  // Window constraints
  static const double windowMinWidth = 900.0;
  static const double windowMinHeight = 600.0;
  static const double windowDefaultWidth = 1280.0;
  static const double windowDefaultHeight = 800.0;

  // Animation durations (milliseconds)
  static const int animationFastMs = 150;
  static const int animationNormalMs = 300;

  // Search debounce
  static const int searchDebounceMs = 300;
}
