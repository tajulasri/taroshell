import 'package:dartssh2/dartssh2.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:xterm/xterm.dart';

/// The lifecycle status of an SSH terminal session.
enum ConnectionStatus {
  /// SSH handshake is in progress (socket, auth, PTY).
  connecting,

  /// Fully connected with a live terminal.
  connected,

  /// Connection attempt failed; [TerminalSession.errorMessage] has details.
  error,
}

/// Represents an active SSH terminal session.
///
/// Each session holds a reference to the underlying [SSHClient] and an xterm
/// [Terminal] instance that renders the shell output. Sessions are identified
/// by a unique [id] (UUID v4) and track connection metadata for display
/// purposes.
class TerminalSession {
  TerminalSession({
    required this.id,
    required this.serverId,
    required this.label,
    required this.host,
    required this.port,
    required this.username,
    required this.terminal,
    required this.connectedAt,
    this.client,
    this.isConnected = true,
    this.status = ConnectionStatus.connected,
    this.errorMessage,
  });

  /// Unique session identifier (UUID v4).
  final String id;

  /// The database ID of the server profile this session was opened from.
  final int serverId;

  /// Human-readable label for the session tab (typically the server label).
  final String label;

  /// Remote host address.
  final String host;

  /// Remote SSH port.
  final int port;

  /// Username used for authentication.
  final String username;

  /// The xterm terminal emulator instance bound to this session.
  Terminal terminal;

  /// Timestamp when the connection was established.
  final DateTime connectedAt;

  /// The dartssh2 client powering the connection.
  ///
  /// May be `null` after disconnect or while still [ConnectionStatus.connecting].
  SSHClient? client;

  /// The database row ID in the [ConnectionHistory] table.
  ///
  /// Used to update the disconnect timestamp when the session ends.
  int? historyId;

  /// Whether the SSH connection is currently active.
  bool isConnected;

  /// The current lifecycle status of this session.
  ConnectionStatus status;

  /// Human-readable error message when [status] is [ConnectionStatus.error].
  String? errorMessage;

  // ---------------------------------------------------------------------------
  // Display helpers
  // ---------------------------------------------------------------------------

  /// Returns a compact connection string suitable for banners and tooltips.
  ///
  /// Format: `username@host:port` (port omitted when default 22).
  String get connectionString {
    final portSuffix = port != AppConstants.defaultSshPort ? ':$port' : '';
    return '$username@$host$portSuffix';
  }

  /// Returns the elapsed duration since the session was connected.
  Duration get uptime => DateTime.now().difference(connectedAt);

  /// Formats [uptime] as a human-readable string (e.g. "2h 15m 30s").
  String get formattedUptime {
    final duration = uptime;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
