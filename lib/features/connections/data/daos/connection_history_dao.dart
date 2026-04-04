import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

part 'connection_history_dao.g.dart';

/// Data Access Object for the [ConnectionHistory] table.
///
/// Provides insertion, update, reactive watching, and cleanup operations
/// for the connection audit trail. All database interactions for the
/// ConnectionHistory table should flow through this DAO.
@DriftAccessor(tables: [ConnectionHistory])
class ConnectionHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$ConnectionHistoryDaoMixin {
  ConnectionHistoryDao(super.db);

  /// Inserts a new connection history entry and returns the generated row ID.
  Future<int> insertHistory(ConnectionHistoryCompanion companion) {
    return into(connectionHistory).insert(companion);
  }

  /// Updates an existing history entry to record disconnection details.
  ///
  /// Sets the [disconnectedAt] timestamp and an optional [reason] for
  /// the entry identified by [id].
  Future<void> updateDisconnected(
    int id,
    DateTime disconnectedAt,
    String? reason,
  ) async {
    await (update(connectionHistory)..where((t) => t.id.equals(id))).write(
      ConnectionHistoryCompanion(
        disconnectedAt: Value(disconnectedAt),
        errorMessage: Value(reason),
      ),
    );
  }

  /// Watches recent connection history entries as a reactive stream.
  ///
  /// Returns entries ordered by [connectedAt] descending, limited to [limit].
  Stream<List<ConnectionHistoryData>> watchRecentHistory({int limit = 50}) {
    return (select(connectionHistory)
          ..orderBy([(t) => OrderingTerm.desc(t.connectedAt)])
          ..limit(limit))
        .watch();
  }

  /// Deletes connection history entries older than [cutoff].
  ///
  /// Returns the number of deleted rows. Useful for periodic cleanup
  /// to prevent unbounded database growth.
  Future<int> deleteOlderThan(DateTime cutoff) {
    return (delete(connectionHistory)
          ..where((t) => t.connectedAt.isSmallerThanValue(cutoff)))
        .go();
  }
}
