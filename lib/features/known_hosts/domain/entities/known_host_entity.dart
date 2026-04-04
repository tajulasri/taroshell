/// Domain entity representing a trusted remote host key record.
///
/// Follows the Trust-On-First-Use (TOFU) model: the first time a host is
/// connected to, its key fingerprint is recorded. Subsequent connections
/// verify the fingerprint against this record.
class KnownHostEntity {
  const KnownHostEntity({
    required this.id,
    required this.host,
    required this.port,
    required this.keyType,
    required this.hostKeyFingerprint,
    required this.firstSeen,
    required this.lastSeen,
  });

  /// Database primary key.
  final int id;

  /// Remote host address.
  final String host;

  /// Remote SSH port.
  final int port;

  /// SSH key algorithm type (e.g. "ssh-rsa", "ssh-ed25519").
  final String keyType;

  /// SHA-256 fingerprint of the host public key (hex-encoded with colons).
  final String hostKeyFingerprint;

  /// Timestamp when this host key was first trusted.
  final DateTime firstSeen;

  /// Timestamp of the most recent successful connection to this host.
  final DateTime lastSeen;

  /// Returns a display-friendly host identifier.
  ///
  /// Format: `host:port` (port omitted when default 22).
  String get displayHost {
    const defaultSshPort = 22;
    return port != defaultSshPort ? '$host:$port' : host;
  }
}
