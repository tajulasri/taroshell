import 'package:taroshell/features/connections/data/daos/collection_dao.dart';
import 'package:taroshell/features/connections/data/daos/server_dao.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/domain/entities/server_collection.dart';
import 'package:taroshell/features/connections/domain/repositories/connection_repository.dart';

/// Concrete implementation of [ConnectionRepository] backed by Drift DAOs.
///
/// Translates between Drift data classes and clean domain entities,
/// keeping the domain layer free of database concerns.
class ConnectionRepositoryImpl implements ConnectionRepository {
  final ServerDao _serverDao;
  final CollectionDao _collectionDao;

  const ConnectionRepositoryImpl({
    required ServerDao serverDao,
    required CollectionDao collectionDao,
  })  : _serverDao = serverDao,
        _collectionDao = collectionDao;

  // ---------------------------------------------------------------------------
  // Server operations
  // ---------------------------------------------------------------------------

  @override
  Stream<List<ServerEntity>> watchAllServers() {
    return _serverDao
        .watchAllServers()
        .map((rows) => rows.map(ServerEntity.fromDrift).toList());
  }

  @override
  Stream<List<ServerEntity>> watchServersByCollection(int? collectionId) {
    return _serverDao
        .watchServersByCollection(collectionId)
        .map((rows) => rows.map(ServerEntity.fromDrift).toList());
  }

  @override
  Future<ServerEntity?> getServerById(int id) async {
    final server = await _serverDao.getServerById(id);
    return server != null ? ServerEntity.fromDrift(server) : null;
  }

  @override
  Future<int> addServer(ServerEntity server) {
    return _serverDao.insertServer(server.toDriftInsertCompanion());
  }

  @override
  Future<void> updateServer(ServerEntity server) async {
    await _serverDao.updateServer(server.toDriftUpdateCompanion());
  }

  @override
  Future<void> deleteServer(int id) async {
    await _serverDao.deleteServer(id);
  }

  // ---------------------------------------------------------------------------
  // Collection operations
  // ---------------------------------------------------------------------------

  @override
  Stream<List<CollectionEntity>> watchAllCollections() {
    return _collectionDao
        .watchAllCollections()
        .map((rows) => rows.map(CollectionEntity.fromDrift).toList());
  }

  @override
  Future<int> addCollection(CollectionEntity collection) {
    return _collectionDao
        .insertCollection(collection.toDriftInsertCompanion());
  }

  @override
  Future<void> updateCollection(CollectionEntity collection) async {
    await _collectionDao
        .updateCollection(collection.toDriftUpdateCompanion());
  }

  @override
  Future<void> deleteCollection(int id) async {
    await _collectionDao.deleteCollection(id);
  }
}
