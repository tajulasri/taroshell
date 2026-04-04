import 'package:taroshell/core/utils/crypto_utils.dart';
import 'package:taroshell/features/keys/data/daos/key_dao.dart';
import 'package:taroshell/features/keys/domain/entities/ssh_key.dart';
import 'package:taroshell/features/keys/domain/repositories/key_repository.dart';

/// Concrete implementation of [KeyRepository] backed by Drift and AES-256-GCM.
///
/// Delegates database operations to [KeyDao] and uses [CryptoUtils] with
/// the application's encryption key for private key decryption.
class KeyRepositoryImpl implements KeyRepository {
  const KeyRepositoryImpl({
    required KeyDao keyDao,
    required String encryptionKey,
  })  : _keyDao = keyDao,
        _encryptionKey = encryptionKey;

  final KeyDao _keyDao;

  /// Base64-encoded AES-256 key used for encrypting/decrypting private keys.
  final String _encryptionKey;

  @override
  Stream<List<SshKeyEntity>> watchAllKeys() {
    return _keyDao.watchAllKeys().map(
          (keys) => keys.map(SshKeyEntity.fromDrift).toList(),
        );
  }

  @override
  Future<SshKeyEntity?> getKeyById(int id) async {
    final driftKey = await _keyDao.getKeyById(id);
    if (driftKey == null) return null;
    return SshKeyEntity.fromDrift(driftKey);
  }

  @override
  Future<int> addKey(SshKeyEntity key) {
    return _keyDao.insertKey(key.toDriftInsertCompanion());
  }

  @override
  Future<void> deleteKey(int id) async {
    await _keyDao.deleteKey(id);
  }

  @override
  Future<String> decryptPrivateKey(String encryptedKey) async {
    return CryptoUtils.decrypt(
      ciphertext: encryptedKey,
      key: _encryptionKey,
    );
  }
}
