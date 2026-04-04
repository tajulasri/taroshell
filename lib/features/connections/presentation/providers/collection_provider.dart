import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/features/connections/domain/entities/server_collection.dart';
import 'package:taroshell/features/connections/domain/repositories/connection_repository.dart';
import 'package:taroshell/features/connections/presentation/providers/server_provider.dart';

// =============================================================================
// Collection Stream Providers
// =============================================================================

/// Reactive stream of all collections, ordered by sort order then name.
final allCollectionsProvider = StreamProvider<List<CollectionEntity>>((ref) {
  final log = AppLogger.database;
  log.d('allCollectionsProvider — subscribing to collection stream');
  final repository = ref.watch(connectionRepositoryProvider);
  return repository.watchAllCollections().handleError((Object error, StackTrace st) {
    log.e('allCollectionsProvider — stream error', error, st);
  });
});

// =============================================================================
// Collection Actions
// =============================================================================

/// Provides CRUD operations for collections without exposing the repository
/// directly to widgets.
final collectionActionsProvider = Provider<CollectionActions>((ref) {
  return CollectionActions(ref.watch(connectionRepositoryProvider));
});

/// Encapsulates collection-related write operations.
///
/// Keeps the provider layer thin while providing a clear API surface
/// for the presentation layer.
class CollectionActions {
  final ConnectionRepository _repository;

  const CollectionActions(this._repository);

  /// Adds a new collection and returns the generated row ID.
  Future<int> add(CollectionEntity collection) =>
      _repository.addCollection(collection);

  /// Updates an existing collection.
  Future<void> update(CollectionEntity collection) =>
      _repository.updateCollection(collection);

  /// Deletes a collection by [id].
  Future<void> delete(int id) => _repository.deleteCollection(id);
}
