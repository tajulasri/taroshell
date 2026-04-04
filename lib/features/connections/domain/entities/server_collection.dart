import 'package:drift/drift.dart';
import 'package:taroshell/core/database/app_database.dart';

/// Clean domain entity representing a logical grouping of servers.
///
/// Decoupled from the Drift data layer to maintain separation of concerns.
/// Use [fromDrift] and [toDriftCompanion] for conversion between layers.
class CollectionEntity {
  final int id;
  final String name;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;

  const CollectionEntity({
    required this.id,
    required this.name,
    this.color,
    required this.sortOrder,
    required this.createdAt,
  });

  /// Creates a [CollectionEntity] from a Drift [ServerCollection] data class.
  factory CollectionEntity.fromDrift(ServerCollection collection) {
    return CollectionEntity(
      id: collection.id,
      name: collection.name,
      color: collection.color,
      sortOrder: collection.sortOrder,
      createdAt: collection.createdAt,
    );
  }

  /// Converts this entity to a [ServerCollectionsCompanion] for insert.
  ServerCollectionsCompanion toDriftInsertCompanion() {
    return ServerCollectionsCompanion.insert(
      name: name,
      color: Value(color),
      sortOrder: Value(sortOrder),
    );
  }

  /// Converts this entity to a [ServerCollectionsCompanion] for update.
  ServerCollectionsCompanion toDriftUpdateCompanion() {
    return ServerCollectionsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Returns a copy of this entity with the given fields replaced.
  CollectionEntity copyWith({
    int? id,
    String? name,
    String? Function()? color,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CollectionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color != null ? color() : this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          sortOrder == other.sortOrder &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, name, color, sortOrder, createdAt);

  @override
  String toString() =>
      'CollectionEntity(id: $id, name: $name, color: $color)';
}
