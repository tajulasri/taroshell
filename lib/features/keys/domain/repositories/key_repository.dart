import 'package:taroshell/features/keys/domain/entities/ssh_key.dart';

/// Abstract interface for SSH key persistence and cryptographic operations.
///
/// Implementations handle storage, retrieval, and secure decryption of
/// SSH key pairs. Private keys are always stored in encrypted form and
/// only decrypted on demand via [decryptPrivateKey].
abstract class KeyRepository {
  /// Watches all stored SSH keys as a reactive stream, ordered newest first.
  Stream<List<SshKeyEntity>> watchAllKeys();

  /// Retrieves a single SSH key by its [id].
  ///
  /// Returns `null` if no key with the given [id] exists.
  Future<SshKeyEntity?> getKeyById(int id);

  /// Persists a new SSH key and returns the auto-generated row ID.
  ///
  /// The [key] entity's [SshKeyEntity.encryptedPrivateKey] must already
  /// be encrypted before calling this method.
  Future<int> addKey(SshKeyEntity key);

  /// Deletes the SSH key with the given [id].
  Future<void> deleteKey(int id);

  /// Decrypts an AES-256-GCM encrypted private key and returns the
  /// plaintext PEM string.
  ///
  /// Throws [ArgumentError] if decryption fails (e.g. tampered data
  /// or invalid encryption key).
  Future<String> decryptPrivateKey(String encryptedKey);
}
