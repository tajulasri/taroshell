import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/domain/entities/server_collection.dart';

/// Abstract interface defining all connection management operations.
///
/// This contract decouples the presentation layer from the data layer,
/// following the Dependency Inversion Principle. Implementations handle
/// the actual database interactions through DAOs.
abstract class ConnectionRepository {
  // ---------------------------------------------------------------------------
  // Server operations
  // ---------------------------------------------------------------------------

  /// Watches all servers as a reactive stream of domain entities.
  Stream<List<ServerEntity>> watchAllServers();

  /// Watches servers filtered by [collectionId].
  ///
  /// Pass `null` to retrieve servers not assigned to any collection.
  Stream<List<ServerEntity>> watchServersByCollection(int? collectionId);

  /// Retrieves a single server by [id], or `null` if not found.
  Future<ServerEntity?> getServerById(int id);

  /// Adds a new server and returns the generated row ID.
  Future<int> addServer(ServerEntity server);

  /// Updates an existing server.
  Future<void> updateServer(ServerEntity server);

  /// Deletes a server by [id].
  Future<void> deleteServer(int id);

  // ---------------------------------------------------------------------------
  // Collection operations
  // ---------------------------------------------------------------------------

  /// Watches all collections as a reactive stream of domain entities.
  Stream<List<CollectionEntity>> watchAllCollections();

  /// Adds a new collection and returns the generated row ID.
  Future<int> addCollection(CollectionEntity collection);

  /// Updates an existing collection.
  Future<void> updateCollection(CollectionEntity collection);

  /// Deletes a collection by [id].
  Future<void> deleteCollection(int id);
}
