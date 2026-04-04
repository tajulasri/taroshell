import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

part 'collection_dao.g.dart';

/// Data Access Object for the [ServerCollections] table.
///
/// Provides reactive streams and CRUD operations for server collection
/// (folder) management. All database interactions for the ServerCollections
/// table should flow through this DAO.
@DriftAccessor(tables: [ServerCollections])
class CollectionDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionDaoMixin {
  CollectionDao(super.db);

  /// Watches all collections ordered by sort order, then by name.
  Stream<List<ServerCollection>> watchAllCollections() {
    return (select(serverCollections)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  /// Retrieves a single collection by its [id], or `null` if not found.
  Future<ServerCollection?> getCollectionById(int id) {
    return (select(serverCollections)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new collection and returns the generated row ID.
  Future<int> insertCollection(ServerCollectionsCompanion companion) {
    return into(serverCollections).insert(companion);
  }

  /// Updates an existing collection.
  /// Returns `true` if exactly one row was updated.
  Future<bool> updateCollection(ServerCollectionsCompanion companion) {
    return (update(serverCollections)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion)
        .then((rows) => rows > 0);
  }

  /// Deletes a collection by [id]. Returns the number of affected rows.
  Future<int> deleteCollection(int id) {
    return (delete(serverCollections)..where((t) => t.id.equals(id))).go();
  }

  /// Reorders collections by assigning sequential sort order values
  /// matching the position in [orderedIds].
  Future<void> reorderCollections(List<int> orderedIds) async {
    await transaction(() async {
      for (var index = 0; index < orderedIds.length; index++) {
        await (update(serverCollections)
              ..where((t) => t.id.equals(orderedIds[index])))
            .write(
          ServerCollectionsCompanion(
            sortOrder: Value(index),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }
}
