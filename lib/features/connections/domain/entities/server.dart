import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

/// Clean domain entity representing an SSH server connection profile.
///
/// Decoupled from the Drift data layer to maintain separation of concerns.
/// Use [fromDrift] and [toDriftCompanion] for conversion between layers.
class ServerEntity {
  final int id;
  final String label;
  final String host;
  final int port;
  final String username;
  final AuthType authType;
  final int? sshKeyId;
  final int? collectionId;
  final int sortOrder;
  final bool isFavorite;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServerEntity({
    required this.id,
    required this.label,
    required this.host,
    required this.port,
    required this.username,
    required this.authType,
    this.sshKeyId,
    this.collectionId,
    required this.sortOrder,
    required this.isFavorite,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [ServerEntity] from a Drift [Server] data class.
  factory ServerEntity.fromDrift(Server server) {
    return ServerEntity(
      id: server.id,
      label: server.label,
      host: server.host,
      port: server.port,
      username: server.username,
      authType: server.authType,
      sshKeyId: server.sshKeyId,
      collectionId: server.collectionId,
      sortOrder: server.sortOrder,
      isFavorite: server.isFavorite,
      notes: server.notes,
      createdAt: server.createdAt,
      updatedAt: server.updatedAt,
    );
  }

  /// Converts this entity to a [ServersCompanion] for Drift insert operations.
  ServersCompanion toDriftInsertCompanion() {
    return ServersCompanion.insert(
      label: label,
      host: host,
      port: Value(port),
      username: username,
      authType: Value(authType),
      sshKeyId: Value(sshKeyId),
      collectionId: Value(collectionId),
      sortOrder: Value(sortOrder),
      isFavorite: Value(isFavorite),
      notes: Value(notes),
    );
  }

  /// Converts this entity to a [ServersCompanion] for Drift update operations.
  ServersCompanion toDriftUpdateCompanion() {
    return ServersCompanion(
      id: Value(id),
      label: Value(label),
      host: Value(host),
      port: Value(port),
      username: Value(username),
      authType: Value(authType),
      sshKeyId: Value(sshKeyId),
      collectionId: Value(collectionId),
      sortOrder: Value(sortOrder),
      isFavorite: Value(isFavorite),
      notes: Value(notes),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Returns a copy of this entity with the given fields replaced.
  ServerEntity copyWith({
    int? id,
    String? label,
    String? host,
    int? port,
    String? username,
    AuthType? authType,
    int? Function()? sshKeyId,
    int? Function()? collectionId,
    int? sortOrder,
    bool? isFavorite,
    String? Function()? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServerEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      sshKeyId: sshKeyId != null ? sshKeyId() : this.sshKeyId,
      collectionId: collectionId != null ? collectionId() : this.collectionId,
      sortOrder: sortOrder ?? this.sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes != null ? notes() : this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          host == other.host &&
          port == other.port &&
          username == other.username &&
          authType == other.authType &&
          sshKeyId == other.sshKeyId &&
          collectionId == other.collectionId &&
          sortOrder == other.sortOrder &&
          isFavorite == other.isFavorite &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        label,
        host,
        port,
        username,
        authType,
        sshKeyId,
        collectionId,
        sortOrder,
        isFavorite,
        notes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'ServerEntity(id: $id, label: $label, host: $host, port: $port)';
}
