
import 'package:taroshell/core/database/app_database.dart';

/// Clean domain entity representing a stored SSH key pair.
///
/// Decoupled from the Drift data layer to maintain separation of concerns.
/// Use [fromDrift] for conversion from the data layer and
/// [toDriftInsertCompanion] for persistence operations.
class SshKeyEntity {
  final int id;
  final String label;
  final KeyType keyType;
  final String publicKey;
  final String encryptedPrivateKey;
  final String fingerprint;
  final DateTime createdAt;

  const SshKeyEntity({
    required this.id,
    required this.label,
    required this.keyType,
    required this.publicKey,
    required this.encryptedPrivateKey,
    required this.fingerprint,
    required this.createdAt,
  });

  /// Creates an [SshKeyEntity] from a Drift [SshKey] data class.
  factory SshKeyEntity.fromDrift(SshKey driftKey) {
    return SshKeyEntity(
      id: driftKey.id,
      label: driftKey.label,
      keyType: driftKey.keyType,
      publicKey: driftKey.publicKey,
      encryptedPrivateKey: driftKey.encryptedPrivateKey,
      fingerprint: driftKey.fingerprint,
      createdAt: driftKey.createdAt,
    );
  }

  /// Converts this entity to a [SshKeysCompanion] for Drift insert operations.
  ///
  /// The [id] and [createdAt] fields are omitted to allow the database
  /// to auto-generate them.
  SshKeysCompanion toDriftInsertCompanion() {
    return SshKeysCompanion.insert(
      label: label,
      keyType: keyType,
      publicKey: publicKey,
      encryptedPrivateKey: encryptedPrivateKey,
      fingerprint: fingerprint,
    );
  }

  /// Returns a copy of this entity with the given fields replaced.
  SshKeyEntity copyWith({
    int? id,
    String? label,
    KeyType? keyType,
    String? publicKey,
    String? encryptedPrivateKey,
    String? fingerprint,
    DateTime? createdAt,
  }) {
    return SshKeyEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      keyType: keyType ?? this.keyType,
      publicKey: publicKey ?? this.publicKey,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
      fingerprint: fingerprint ?? this.fingerprint,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns the human-readable display name for the key type.
  String get keyTypeDisplayName {
    switch (keyType) {
      case KeyType.rsa2048:
        return 'RSA 2048';
      case KeyType.rsa4096:
        return 'RSA 4096';
      case KeyType.ed25519:
        return 'Ed25519';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SshKeyEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          keyType == other.keyType &&
          publicKey == other.publicKey &&
          encryptedPrivateKey == other.encryptedPrivateKey &&
          fingerprint == other.fingerprint &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        label,
        keyType,
        publicKey,
        encryptedPrivateKey,
        fingerprint,
        createdAt,
      );

  @override
  String toString() =>
      'SshKeyEntity(id: $id, label: $label, keyType: $keyType)';
}
