import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

part 'key_dao.g.dart';

/// Data Access Object for the [SshKeys] table.
///
/// Provides reactive streams and CRUD operations for stored SSH key pairs.
/// All database interactions for SSH keys should flow through this DAO.
@DriftAccessor(tables: [SshKeys])
class KeyDao extends DatabaseAccessor<AppDatabase> with _$KeyDaoMixin {
  KeyDao(super.db);

  /// Watches all SSH keys ordered by creation date (newest first).
  Stream<List<SshKey>> watchAllKeys() {
    return (select(sshKeys)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// Retrieves a single SSH key by its [id].
  ///
  /// Returns `null` if no key with the given [id] exists.
  Future<SshKey?> getKeyById(int id) {
    return (select(sshKeys)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new SSH key record and returns the auto-generated row ID.
  Future<int> insertKey(SshKeysCompanion entry) {
    return into(sshKeys).insert(entry);
  }

  /// Deletes the SSH key with the given [id].
  ///
  /// Returns the number of rows affected (0 or 1).
  Future<int> deleteKey(int id) {
    return (delete(sshKeys)..where((t) => t.id.equals(id))).go();
  }
}
