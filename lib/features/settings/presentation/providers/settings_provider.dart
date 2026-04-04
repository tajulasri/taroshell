import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/constants/app_constants.dart';

/// Provider for the terminal font size setting.
///
/// Defaults to [AppConstants.defaultFontSize] and can be adjusted
/// within the range [AppConstants.minFontSize] to [AppConstants.maxFontSize].
final fontSizeProvider = StateProvider<double>(
  (ref) => AppConstants.defaultFontSize,
);

/// Provider for the terminal scrollback buffer size (number of lines).
///
/// Defaults to [AppConstants.defaultScrollbackLines].
final scrollbackLinesProvider = StateProvider<int>(
  (ref) => AppConstants.defaultScrollbackLines,
);

/// Provider for the terminal font family.
///
/// Defaults to [AppConstants.defaultTerminalFontFamily].
final terminalFontFamilyProvider = StateProvider<String>(
  (ref) => AppConstants.defaultTerminalFontFamily,
);

/// Provider controlling whether hidden files are shown in the SFTP browser.
///
/// Defaults to `false` for a cleaner initial view.
final showHiddenFilesProvider = StateProvider<bool>(
  (ref) => false,
);

/// Provider for the default SSH port.
///
/// Defaults to [AppConstants.defaultSshPort].
final defaultSshPortProvider = StateProvider<int>(
  (ref) => AppConstants.defaultSshPort,
);

/// Provider for the connection timeout in seconds.
///
/// Defaults to [AppConstants.connectionTimeoutSeconds].
final connectionTimeoutProvider = StateProvider<int>(
  (ref) => AppConstants.connectionTimeoutSeconds,
);
