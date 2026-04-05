/// Shared formatting utilities for human-readable display values.
abstract final class FormatUtils {
  static const int _kibibyte = 1024;
  static const int _mebibyte = 1024 * 1024;
  static const int _gibibyte = 1024 * 1024 * 1024;

  /// Formats [bytes] into a human-readable size string.
  ///
  /// Examples: "128 B", "1.2 KB", "3.5 MB", "2.1 GB".
  static String formatBytes(int bytes) {
    if (bytes < _kibibyte) return '$bytes B';
    if (bytes < _mebibyte) {
      return '${(bytes / _kibibyte).toStringAsFixed(1)} KB';
    }
    if (bytes < _gibibyte) {
      return '${(bytes / _mebibyte).toStringAsFixed(1)} MB';
    }
    return '${(bytes / _gibibyte).toStringAsFixed(1)} GB';
  }

  /// Formats [bytesPerSecond] into a human-readable transfer speed string.
  ///
  /// Examples: "512 B/s", "1.5 KB/s", "10.2 MB/s".
  static String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < _kibibyte) {
      return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    }
    if (bytesPerSecond < _mebibyte) {
      return '${(bytesPerSecond / _kibibyte).toStringAsFixed(1)} KB/s';
    }
    if (bytesPerSecond < _gibibyte) {
      return '${(bytesPerSecond / _mebibyte).toStringAsFixed(1)} MB/s';
    }
    return '${(bytesPerSecond / _gibibyte).toStringAsFixed(1)} GB/s';
  }
}
