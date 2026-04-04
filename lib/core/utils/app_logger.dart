import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized structured logging utility for TaroShell.
///
/// Provides module-scoped [Logger] instances with consistent configuration.
/// In debug builds, logs are verbose with pretty-printed output.
/// In release builds, only warnings and above are emitted.
final class AppLogger {
  AppLogger._(this._tag, this._logger);

  final String _tag;
  final Logger _logger;

  // ---------------------------------------------------------------------------
  // Module-scoped factory constructors
  // ---------------------------------------------------------------------------

  /// Logger for database open, migration, and error events.
  static final AppLogger database = _create('DB');

  /// Logger for SSH connection lifecycle events.
  static final AppLogger ssh = _create('SSH');

  /// Logger for SFTP file operations.
  static final AppLogger sftp = _create('SFTP');

  /// Logger for encryption/decryption operations.
  static final AppLogger crypto = _create('CRYPTO');

  /// General-purpose fallback logger.
  static final AppLogger general = _create('APP');

  // ---------------------------------------------------------------------------
  // Public logging API
  // ---------------------------------------------------------------------------

  /// Debug-level trace message.
  void d(String message) => _logger.d('[$_tag] $message');

  /// Informational state transition.
  void i(String message) => _logger.i('[$_tag] $message');

  /// Warning — unexpected but recoverable.
  void w(String message) => _logger.w('[$_tag] $message');

  /// Error with optional exception and stack trace.
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e('[$_tag] $message', error: error, stackTrace: stackTrace);

  // ---------------------------------------------------------------------------
  // Internal factory
  // ---------------------------------------------------------------------------

  static AppLogger _create(String tag) {
    final logger = Logger(
      filter: _AppLogFilter(),
      printer: kDebugMode
          ? PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 8,
              lineLength: 80,
              noBoxingByDefault: true,
            )
          : SimplePrinter(),
      level: kDebugMode ? Level.debug : Level.warning,
    );

    return AppLogger._(tag, logger);
  }
}

/// Custom log filter that respects [kDebugMode].
///
/// In debug builds all events at or above the configured level pass through.
/// In release builds only [Level.warning] and above are emitted.
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) return true;
    return event.level.index >= Level.warning.index;
  }
}
