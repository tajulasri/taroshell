/// Utility for formatting [DateTime] values as human-readable relative strings.
///
/// Pure function with no external dependencies.
abstract final class TimeUtils {
  /// Formats [dateTime] as a relative time string (e.g. "just now", "2m ago").
  ///
  /// The output uses abbreviated units for compact display:
  /// - < 60 seconds: "just now"
  /// - < 60 minutes: "Xm ago"
  /// - < 24 hours: "Xh ago"
  /// - < 7 days: "Xd ago"
  /// - < 30 days: "Xw ago"
  /// - >= 30 days: "Xmo ago"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) return 'just now';

    final seconds = difference.inSeconds;
    if (seconds < 60) return 'just now';

    final minutes = difference.inMinutes;
    if (minutes < 60) return '${minutes}m ago';

    final hours = difference.inHours;
    if (hours < 24) return '${hours}h ago';

    final days = difference.inDays;
    if (days < 7) return '${days}d ago';
    if (days < 30) return '${days ~/ 7}w ago';

    return '${days ~/ 30}mo ago';
  }
}
