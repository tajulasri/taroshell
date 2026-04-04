import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/features/connections/data/daos/collection_dao.dart';
import 'package:taroshell/features/connections/data/daos/server_dao.dart';
import 'package:taroshell/features/connections/data/repositories/connection_repository_impl.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/domain/repositories/connection_repository.dart';
import 'package:taroshell/main.dart';

// =============================================================================
// DAO Providers
// =============================================================================

/// Provides the [ServerDao] singleton scoped to the application database.
final serverDaoProvider = Provider<ServerDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ServerDao(db);
});

/// Provides the [CollectionDao] singleton scoped to the application database.
final collectionDaoProvider = Provider<CollectionDao>((ref) {
  final db = ref.watch(databaseProvider);
  return CollectionDao(db);
});

// =============================================================================
// Repository Provider
// =============================================================================

/// Provides the [ConnectionRepository] backed by Drift DAOs.
///
/// This is the single point of access for all server and collection
/// data operations in the presentation layer.
final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  return ConnectionRepositoryImpl(
    serverDao: ref.watch(serverDaoProvider),
    collectionDao: ref.watch(collectionDaoProvider),
  );
});

// =============================================================================
// Server Stream Providers
// =============================================================================

/// Reactive stream of all servers, ordered by sort order then label.
final allServersProvider = StreamProvider<List<ServerEntity>>((ref) {
  final repository = ref.watch(connectionRepositoryProvider);
  return repository.watchAllServers();
});

/// Reactive stream of servers filtered by collection ID.
///
/// Pass `null` to retrieve ungrouped servers (not in any collection).
final serversByCollectionProvider =
    StreamProvider.family<List<ServerEntity>, int?>((ref, collectionId) {
  final repository = ref.watch(connectionRepositoryProvider);
  return repository.watchServersByCollection(collectionId);
});

// =============================================================================
// Server Actions
// =============================================================================

/// Provides CRUD operations for servers without exposing the repository
/// directly to widgets.
final serverActionsProvider = Provider<ServerActions>((ref) {
  return ServerActions(ref.watch(connectionRepositoryProvider));
});

/// Encapsulates server-related write operations.
///
/// Keeps the provider layer thin while providing a clear API surface
/// for the presentation layer.
class ServerActions {
  final ConnectionRepository _repository;

  const ServerActions(this._repository);

  /// Adds a new server and returns the generated row ID.
  Future<int> add(ServerEntity server) => _repository.addServer(server);

  /// Updates an existing server.
  Future<void> update(ServerEntity server) => _repository.updateServer(server);

  /// Deletes a server by [id].
  Future<void> delete(int id) => _repository.deleteServer(id);

  /// Retrieves a server by [id], or `null` if not found.
  Future<ServerEntity?> getById(int id) => _repository.getServerById(id);

  /// Creates a duplicate of the given [server] with a modified label.
  Future<int> duplicate(ServerEntity server) {
    final copy = server.copyWith(
      id: 0,
      label: '${server.label} (copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _repository.addServer(copy);
  }
}
