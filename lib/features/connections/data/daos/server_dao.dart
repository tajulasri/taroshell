import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

part 'server_dao.g.dart';

/// Data Access Object for the [Servers] table.
///
/// Provides reactive streams and CRUD operations for server connection
/// profiles. All database interactions for the Servers table should flow
/// through this DAO.
@DriftAccessor(tables: [Servers])
class ServerDao extends DatabaseAccessor<AppDatabase> with _$ServerDaoMixin {
  ServerDao(super.db);

  /// Watches all servers ordered by sort order, then by label.
  Stream<List<Server>> watchAllServers() {
    return (select(servers)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.label),
          ]))
        .watch();
  }

  /// Watches servers filtered by [collectionId].
  ///
  /// Pass `null` to retrieve servers that are not assigned to any collection.
  Stream<List<Server>> watchServersByCollection(int? collectionId) {
    return (select(servers)
          ..where((t) => collectionId == null
              ? t.collectionId.isNull()
              : t.collectionId.equals(collectionId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.label),
          ]))
        .watch();
  }

  /// Retrieves a single server by its [id], or `null` if not found.
  Future<Server?> getServerById(int id) {
    return (select(servers)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new server and returns the generated row ID.
  Future<int> insertServer(ServersCompanion companion) {
    return into(servers).insert(companion);
  }

  /// Updates an existing server. Returns `true` if at least one row was updated.
  ///
  /// The [companion] must have its `id` field set to identify the target row.
  Future<bool> updateServer(ServersCompanion companion) async {
    assert(companion.id.present, 'Companion must have an id for update.');

    final rowsAffected =
        await (update(servers)..where((t) => t.id.equals(companion.id.value)))
            .write(companion);
    return rowsAffected > 0;
  }

  /// Deletes a server by [id]. Returns the number of affected rows.
  Future<int> deleteServer(int id) {
    return (delete(servers)..where((t) => t.id.equals(id))).go();
  }

  /// Updates the last-connected timestamp for the given server [id].
  Future<void> updateLastConnected(int id) {
    return (update(servers)..where((t) => t.id.equals(id))).write(
      ServersCompanion(updatedAt: Value(DateTime.now())),
    );
  }
}
