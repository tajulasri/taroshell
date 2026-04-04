import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

part 'known_host_dao.g.dart';

/// Data Access Object for the [KnownHosts] table.
///
/// Provides CRUD operations for host key verification records used in
/// Trust-On-First-Use (TOFU) host key checking.
@DriftAccessor(tables: [KnownHosts])
class KnownHostDao extends DatabaseAccessor<AppDatabase>
    with _$KnownHostDaoMixin {
  KnownHostDao(super.db);

  /// Finds all known host records matching the given [host] and [port].
  ///
  /// Typically returns zero or one result per key type. Multiple results
  /// indicate the host has presented different key algorithms over time.
  Future<List<KnownHost>> findByHostPort(String host, int port) {
    return (select(knownHosts)
          ..where(
            (row) => row.host.equals(host) & row.port.equals(port),
          ))
        .get();
  }

  /// Inserts a new known host record and returns the generated row ID.
  Future<int> insertKnownHost(KnownHostsCompanion entry) {
    return into(knownHosts).insert(entry);
  }

  /// Updates the [lastSeen] timestamp to the current time for the record
  /// identified by [id].
  Future<void> updateLastSeen(int id) {
    return (update(knownHosts)..where((row) => row.id.equals(id))).write(
      KnownHostsCompanion(lastSeen: Value(DateTime.now())),
    );
  }

  /// Deletes the known host record identified by [id].
  ///
  /// Returns the number of rows affected (0 or 1).
  Future<int> deleteKnownHost(int id) {
    return (delete(knownHosts)..where((row) => row.id.equals(id))).go();
  }
}
