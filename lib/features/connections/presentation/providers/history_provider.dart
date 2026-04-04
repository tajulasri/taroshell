import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/features/connections/data/daos/connection_history_dao.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';

// =============================================================================
// History Stream Provider
// =============================================================================

/// Maximum number of recent history entries displayed in the sidebar panel.
const int _recentHistoryLimit = 15;

/// Reactive stream of recent **successful** connection history entries.
///
/// Filters out failed connection attempts so the quick-connect list only
/// shows servers the user has successfully connected to before.
final recentHistoryProvider =
    StreamProvider<List<ConnectionHistoryData>>((ref) {
  final log = AppLogger.database;
  log.d('recentHistoryProvider — subscribing to history stream');

  final historyDao = ref.watch(connectionHistoryDaoProvider);
  return historyDao
      .watchRecentHistory(limit: _recentHistoryLimit)
      .map((entries) => entries.where((e) => e.wasSuccessful).toList())
      .handleError((Object error, StackTrace st) {
    log.e('recentHistoryProvider — stream error', error, st);
  });
});

// =============================================================================
// History Actions
// =============================================================================

/// Provides write operations for connection history management.
final historyActionsProvider = Provider<HistoryActions>((ref) {
  return HistoryActions(ref.watch(connectionHistoryDaoProvider));
});

/// Encapsulates history-related write operations.
class HistoryActions {
  final ConnectionHistoryDao _dao;

  const HistoryActions(this._dao);

  /// Deletes all connection history entries older than 90 days.
  Future<int> clearOld() {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    return _dao.deleteOlderThan(cutoff);
  }
}
