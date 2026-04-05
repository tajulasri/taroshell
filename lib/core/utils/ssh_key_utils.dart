import 'dart:convert';
import 'dart:isolate';

import 'package:asn1lib/asn1lib.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:pointycastle/export.dart';

/// Result of an SSH key generation operation.
class SshKeyPair {
  const SshKeyPair({
    required this.publicKeyOpenSsh,
    required this.privateKeyPem,
    required this.fingerprint,
  });

  /// Public key in OpenSSH `ssh-rsa ...` or `ssh-ed25519 ...` format.
  final String publicKeyOpenSsh;

  /// Private key in PEM format.
  final String privateKeyPem;

  /// SHA-256 fingerprint of the public key (hex-encoded with colons).
  final String fingerprint;
}

/// Supported SSH key algorithms for generation.
enum SshKeyAlgorithm {
  rsa2048(2048),
  rsa4096(4096),
  ed25519(256);

  const SshKeyAlgorithm(this.keySize);
  final int keySize;
}

/// Utilities for SSH key generation, parsing, and format conversion.
///
/// Heavy key generation runs in a separate [Isolate] to keep the UI responsive.
abstract final class SshKeyUtils {
  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates an SSH key pair of the requested [algorithm] inside an isolate.
  ///
  /// The optional [comment] is appended to the OpenSSH public key line.
  static Future<SshKeyPair> generateKeyPair({
    required SshKeyAlgorithm algorithm,
    String comment = '',
  }) async {
    return Isolate.run(() => _generateKeyPairSync(
          algorithm: algorithm,
          comment: comment,
        ));
  }

  /// Converts an RSA public key to OpenSSH format (`ssh-rsa <base64> comment`).
  static String rsaPublicKeyToOpenSsh(
    RSAPublicKey publicKey, {
    String comment = '',
  }) {
    final encodedKey = _encodeRsaPublicKey(publicKey);
    final base64Key = base64.encode(encodedKey);
    final suffix = comment.isNotEmpty ? ' $comment' : '';
    return 'ssh-rsa $base64Key$suffix';
  }

  /// Computes the SHA-256 fingerprint of an OpenSSH public key blob.
  static String computeFingerprint(Uint8List publicKeyBlob) {
    final digest = SHA256Digest().process(publicKeyBlob);
    return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
  }

  /// Parses a PEM-encoded RSA private key and returns the [RSAPrivateKey].
  static RSAPrivateKey parseRsaPrivateKeyPem(String pem) {
    final lines = pem
        .split('\n')
        .where((line) =>
            line.isNotEmpty &&
            !line.startsWith('-----BEGIN') &&
            !line.startsWith('-----END'))
        .join();
    final keyBytes = base64.decode(lines);
    final asn1Parser = ASN1Parser(keyBytes);
    final topSeq = asn1Parser.nextObject() as ASN1Sequence;

    final modulus = (topSeq.elements[1] as ASN1Integer).valueAsBigInteger;
    final privateExponent =
        (topSeq.elements[3] as ASN1Integer).valueAsBigInteger;
    final prime1 = (topSeq.elements[4] as ASN1Integer).valueAsBigInteger;
    final prime2 = (topSeq.elements[5] as ASN1Integer).valueAsBigInteger;

    return RSAPrivateKey(modulus, privateExponent, prime1, prime2);
  }

  // ---------------------------------------------------------------------------
  // Private implementation
  // ---------------------------------------------------------------------------

  static SshKeyPair _generateKeyPairSync({
    required SshKeyAlgorithm algorithm,
    required String comment,
  }) {
    switch (algorithm) {
      case SshKeyAlgorithm.rsa2048:
      case SshKeyAlgorithm.rsa4096:
        return _generateRsaKeyPair(
          bitLength: algorithm.keySize,
          comment: comment,
        );
      case SshKeyAlgorithm.ed25519:
        return _generateEd25519KeyPair(comment: comment);
    }
  }

  static SshKeyPair _generateRsaKeyPair({
    required int bitLength,
    required String comment,
  }) {
    final secureRandom = _buildSecureRandom();
    final keyParams = RSAKeyGeneratorParameters(
      BigInt.from(65537),
      bitLength,
      64,
    );
    final generator = RSAKeyGenerator()
      ..init(ParametersWithRandom(keyParams, secureRandom));

    final pair = generator.generateKeyPair();
    final publicKey = pair.publicKey;
    final privateKey = pair.privateKey;

    final publicKeyBlob = _encodeRsaPublicKey(publicKey);
    final openSshPublic = rsaPublicKeyToOpenSsh(publicKey, comment: comment);
    final privatePem = _encodeRsaPrivateKeyPem(privateKey);
    final fingerprint = computeFingerprint(Uint8List.fromList(publicKeyBlob));

    return SshKeyPair(
      publicKeyOpenSsh: openSshPublic,
      privateKeyPem: privatePem,
      fingerprint: fingerprint,
    );
  }

  static SshKeyPair _generateEd25519KeyPair({required String comment}) {
    final signingKey = SigningKey.generate();
    final publicKeyBytes =
        Uint8List.fromList(signingKey.verifyKey.asTypedList);
    final seed = Uint8List.fromList(signingKey.seed.asTypedList);

    // Build OpenSSH public key blob
    final blobBuilder = BytesBuilder();
    writeString(blobBuilder, 'ssh-ed25519');
    writeBytes(blobBuilder, publicKeyBytes);
    final publicKeyBlob = blobBuilder.toBytes();

    final base64Public = base64.encode(publicKeyBlob);
    final suffix = comment.isNotEmpty ? ' $comment' : '';
    final openSshPublic = 'ssh-ed25519 $base64Public$suffix';

    final privatePem = _encodeEd25519PrivateKeyPem(seed, publicKeyBytes);
    final fingerprint =
        computeFingerprint(Uint8List.fromList(publicKeyBlob));

    return SshKeyPair(
      publicKeyOpenSsh: openSshPublic,
      privateKeyPem: privatePem,
      fingerprint: fingerprint,
    );
  }

  // ---------------------------------------------------------------------------
  // Encoding helpers
  // ---------------------------------------------------------------------------

  static List<int> _encodeRsaPublicKey(RSAPublicKey key) {
    final builder = BytesBuilder();
    writeString(builder, 'ssh-rsa');
    writeMpInt(builder, key.publicExponent!);
    writeMpInt(builder, key.modulus!);
    return builder.toBytes();
  }

  static String _encodeRsaPrivateKeyPem(RSAPrivateKey key) {
    final seq = ASN1Sequence()
      ..add(ASN1Integer(BigInt.zero)) // version
      ..add(ASN1Integer(key.modulus!))
      ..add(ASN1Integer(key.publicExponent!))
      ..add(ASN1Integer(key.privateExponent!))
      ..add(ASN1Integer(key.p!))
      ..add(ASN1Integer(key.q!))
      ..add(ASN1Integer(
          key.privateExponent! % (key.p! - BigInt.one))) // d mod (p-1)
      ..add(ASN1Integer(
          key.privateExponent! % (key.q! - BigInt.one))) // d mod (q-1)
      ..add(ASN1Integer(key.q!.modInverse(key.p!))); // q^-1 mod p

    final encoded = base64.encode(seq.encodedBytes);
    return _wrapPem(
      encoded,
      header: 'RSA PRIVATE KEY',
    );
  }

  static String _encodeEd25519PrivateKeyPem(
    Uint8List seed,
    Uint8List publicKey,
  ) {
    final encoded =
        base64.encode(Uint8List.fromList([...seed, ...publicKey]));
    return _wrapPem(
      encoded,
      header: 'OPENSSH PRIVATE KEY',
    );
  }

  /// Wraps a base64-encoded payload in PEM armour with 64-char line wrapping.
  static String _wrapPem(String base64Content, {required String header}) {
    const lineLength = 64;
    final lines = <String>['-----BEGIN $header-----'];
    for (var i = 0; i < base64Content.length; i += lineLength) {
      final end = (i + lineLength < base64Content.length)
          ? i + lineLength
          : base64Content.length;
      lines.add(base64Content.substring(i, end));
    }
    lines.add('-----END $header-----');
    return lines.join('\n');
  }

  /// Writes a length-prefixed UTF-8 string to [builder].
  static void writeString(BytesBuilder builder, String value) {
    final bytes = utf8.encode(value);
    writeBytes(builder, Uint8List.fromList(bytes));
  }

  /// Writes a length-prefixed byte array to [builder].
  static void writeBytes(BytesBuilder builder, Uint8List bytes) {
    final length = ByteData(4)..setUint32(0, bytes.length);
    builder.add(length.buffer.asUint8List());
    builder.add(bytes);
  }

  /// Writes a length-prefixed SSH mpint to [builder].
  static void writeMpInt(BytesBuilder builder, BigInt value) {
    final bytes = bigIntToBytes(value);
    writeBytes(builder, bytes);
  }

  /// Converts a [BigInt] to a big-endian byte array suitable for SSH encoding.
  static Uint8List bigIntToBytes(BigInt value) {
    final hexString = value.toRadixString(16);
    final paddedHex = hexString.length.isOdd ? '0$hexString' : hexString;
    final bytes = <int>[];
    for (var i = 0; i < paddedHex.length; i += 2) {
      bytes.add(int.parse(paddedHex.substring(i, i + 2), radix: 16));
    }
    // SSH mpint requires a leading zero byte if the high bit is set
    if (bytes.isNotEmpty && (bytes[0] & 0x80) != 0) {
      bytes.insert(0, 0);
    }
    return Uint8List.fromList(bytes);
  }

  static SecureRandom _buildSecureRandom() {
    final random = SecureRandom('Fortuna')
      ..seed(KeyParameter(
        Uint8List.fromList(
          List<int>.generate(
            32,
            (_) => DateTime.now().microsecondsSinceEpoch & 0xFF,
          ),
        ),
      ));
    return random;
  }
}
