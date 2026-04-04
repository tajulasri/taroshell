import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:taroshell/core/utils/app_logger.dart';

/// AES-256-GCM encryption utilities for securing private keys at rest.
///
/// Each encryption call generates a fresh random IV (96-bit) which is prepended
/// to the ciphertext. The authentication tag (128-bit) is appended by the GCM
/// implementation and verified on decryption.
///
/// Wire format: `[IV 12 bytes][ciphertext + tag]`
abstract final class CryptoUtils {
  static final _log = AppLogger.crypto;
  static const int _ivLengthBytes = 12;
  static const int _keyLengthBytes = 32; // 256-bit
  static const int _tagLengthBits = 128;

  /// Encrypts [plaintext] using AES-256-GCM with the given base64-encoded [key].
  ///
  /// Returns a base64-encoded string containing `IV || ciphertext || tag`.
  static String encrypt({
    required String plaintext,
    required String key,
  }) {
    _log.d('Encrypting data — inputLength=${plaintext.length}');
    final keyBytes = base64.decode(key);
    _validateKeyLength(keyBytes);

    final iv = _generateSecureRandomBytes(_ivLengthBytes);
    final plaintextBytes = utf8.encode(plaintext);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(keyBytes),
          _tagLengthBits,
          iv,
          Uint8List(0),
        ),
      );

    final outputBuffer = Uint8List(cipher.getOutputSize(plaintextBytes.length));
    final bytesWritten =
        cipher.processBytes(plaintextBytes, 0, plaintextBytes.length, outputBuffer, 0);
    final finalBytes = cipher.doFinal(outputBuffer, bytesWritten);
    final actualLength = bytesWritten + finalBytes;

    // Trim to actual written length — getOutputSize may over-allocate.
    final ciphertext = Uint8List.sublistView(outputBuffer, 0, actualLength);

    // Prepend IV to ciphertext+tag
    final combined = Uint8List(_ivLengthBytes + ciphertext.length)
      ..setAll(0, iv)
      ..setAll(_ivLengthBytes, ciphertext);

    _log.d('Encryption complete — outputLength=${combined.length}');
    return base64.encode(combined);
  }

  /// Decrypts a base64-encoded [ciphertext] that was produced by [encrypt].
  ///
  /// Throws [ArgumentError] if the key is invalid or decryption fails
  /// (e.g. tampered data).
  static String decrypt({
    required String ciphertext,
    required String key,
  }) {
    _log.d('Decrypting data — ciphertextLength=${ciphertext.length}');
    final keyBytes = base64.decode(key);
    _validateKeyLength(keyBytes);

    final combined = base64.decode(ciphertext);
    if (combined.length < _ivLengthBytes) {
      throw ArgumentError('Ciphertext is too short to contain a valid IV.');
    }

    final iv = Uint8List.sublistView(combined, 0, _ivLengthBytes);
    final encrypted = Uint8List.sublistView(combined, _ivLengthBytes);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(keyBytes),
          _tagLengthBits,
          iv,
          Uint8List(0),
        ),
      );

    final outputBuffer = Uint8List(cipher.getOutputSize(encrypted.length));
    final bytesWritten =
        cipher.processBytes(encrypted, 0, encrypted.length, outputBuffer, 0);
    final finalBytes = cipher.doFinal(outputBuffer, bytesWritten);
    final actualLength = bytesWritten + finalBytes;

    final result = utf8.decode(Uint8List.sublistView(outputBuffer, 0, actualLength));
    _log.d('Decryption complete — outputLength=${result.length}');
    return result;
  }

  /// Generates a cryptographically secure random 256-bit key, returned as
  /// a base64-encoded string suitable for storage in secure storage.
  static String generateEncryptionKey() {
    final keyBytes = _generateSecureRandomBytes(_keyLengthBytes);
    return base64.encode(keyBytes);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static Uint8List _generateSecureRandomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  static void _validateKeyLength(Uint8List keyBytes) {
    if (keyBytes.length != _keyLengthBytes) {
      throw ArgumentError(
        'Encryption key must be $_keyLengthBytes bytes '
        '(got ${keyBytes.length}).',
      );
    }
  }
}
