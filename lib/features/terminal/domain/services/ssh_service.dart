import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:uuid/uuid.dart';
import 'package:xterm/xterm.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/known_hosts/data/daos/known_host_dao.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';

// =============================================================================
// SSH-specific exceptions
// =============================================================================

/// Exception thrown when SSH host key verification fails or is rejected.
class HostKeyVerificationException implements Exception {
  const HostKeyVerificationException(this.message);
  final String message;

  @override
  String toString() => 'HostKeyVerificationException: $message';
}

/// Exception thrown when SSH authentication fails.
class SshAuthenticationException implements Exception {
  const SshAuthenticationException(this.message);
  final String message;

  @override
  String toString() => 'SshAuthenticationException: $message';
}

/// Exception thrown when the SSH connection times out or is refused.
class SshConnectionException implements Exception {
  const SshConnectionException(this.message);
  final String message;

  @override
  String toString() => 'SshConnectionException: $message';
}

// =============================================================================
// Internal host key trust status
// =============================================================================

/// Result of checking a host key against stored known hosts.
enum _HostKeyStatus {
  /// Host key is already trusted and matches the stored fingerprint.
  trusted,

  /// First time connecting to this host -- no stored fingerprint.
  newHost,

  /// The host key fingerprint has changed since last connection.
  changed,
}

// =============================================================================
// SSH Service
// =============================================================================

/// Core SSH service responsible for establishing, maintaining, and
/// terminating SSH connections.
///
/// Implements Trust-On-First-Use (TOFU) host key verification, supports
/// both password and key-based authentication, and bridges dartssh2
/// with xterm for terminal emulation.
class SshService {
  SshService({
    required KnownHostDao knownHostDao,
  }) : _knownHostDao = knownHostDao;

  final KnownHostDao _knownHostDao;
  static const _uuid = Uuid();
  static final _log = AppLogger.ssh;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Establishes an SSH connection to the given [server].
  ///
  /// Authentication is resolved based on the server's auth type:
  /// - Password auth: [password] must be provided.
  /// - Key auth: [keyPair] must be provided (already decrypted).
  ///
  /// The [context] is used to display host key verification dialogs when
  /// the host is new or its fingerprint has changed.
  ///
  /// Returns a fully connected [TerminalSession] with a shell channel
  /// already bound to the terminal emulator.
  ///
  /// Throws [SshConnectionException] if the connection cannot be established.
  /// Throws [SshAuthenticationException] if authentication fails.
  /// Throws [HostKeyVerificationException] if the user rejects the host key.
  Future<TerminalSession> connect({
    required ServerEntity server,
    required String? password,
    required SSHKeyPair? keyPair,
    required BuildContext context,
  }) async {
    final authMethod = password != null ? 'password' : 'publicKey';
    _log.i(
      'Connecting to ${server.host}:${server.port} '
      'as ${server.username} (auth=$authMethod)',
    );

    final SSHClient client;

    try {
      final socket = await SSHSocket.connect(
        server.host,
        server.port,
        timeout: const Duration(
          seconds: AppConstants.connectionTimeoutSeconds,
        ),
      );

      client = SSHClient(
        socket,
        username: server.username,
        onPasswordRequest: password != null ? () => password : null,
        identities: keyPair != null ? [keyPair] : [],
        keepAliveInterval: const Duration(
          seconds: AppConstants.keepAliveIntervalSeconds,
        ),
        onVerifyHostKey: (String type, Uint8List hostKeyBytes) async {
          return _verifyHostKey(
            host: server.host,
            port: server.port,
            keyType: type,
            hostKeyBytes: hostKeyBytes,
            context: context,
          );
        },
      );

      // Wait for authentication to complete.
      await client.authenticated;
      _log.i('Connected successfully to ${server.host}:${server.port}');
    } on SSHAuthFailError {
      _log.e('Authentication failed for ${server.host}:${server.port}');
      throw const SshAuthenticationException(
        'Authentication failed. Please verify your credentials.',
      );
    } on SSHAuthAbortError {
      _log.e('Authentication aborted by server at ${server.host}:${server.port}');
      throw const SshAuthenticationException(
        'Authentication was aborted by the server.',
      );
    } on HostKeyVerificationException {
      _log.w('Host key verification rejected for ${server.host}:${server.port}');
      rethrow;
    } catch (e, st) {
      _log.e(
        'Connection failed to ${server.host}:${server.port}',
        e,
        st,
      );
      throw SshConnectionException(
        'Failed to connect to ${server.host}:${server.port} -- $e',
      );
    }

    final terminal = Terminal(
      maxLines: AppConstants.defaultScrollbackLines,
    );

    final session = TerminalSession(
      id: _uuid.v4(),
      serverId: server.id,
      label: server.label,
      host: server.host,
      port: server.port,
      username: server.username,
      terminal: terminal,
      connectedAt: DateTime.now(),
      client: client,
    );

    await _bindTerminal(client, terminal);

    return session;
  }

  /// Gracefully disconnects the given [session].
  ///
  /// Closes the SSH client and marks the session as disconnected.
  Future<void> disconnect(TerminalSession session) async {
    _log.i('Disconnecting session ${session.id} (${session.host}:${session.port})');
    session.isConnected = false;
    session.client?.close();
    session.client = null;
  }

  // ---------------------------------------------------------------------------
  // Host key verification (TOFU)
  // ---------------------------------------------------------------------------

  /// Verifies the host key against stored known hosts.
  ///
  /// The [keyType] is the SSH key algorithm name (e.g. "ssh-rsa",
  /// "ssh-ed25519") and [hostKeyBytes] is the raw public key blob,
  /// both provided by the dartssh2 callback.
  ///
  /// Returns `true` if the key is accepted, `false` otherwise.
  Future<bool> _verifyHostKey({
    required String host,
    required int port,
    required String keyType,
    required Uint8List hostKeyBytes,
    required BuildContext context,
  }) async {
    final fingerprint = _computeHostKeyFingerprint(hostKeyBytes);
    final knownHosts = await _knownHostDao.findByHostPort(host, port);

    final status = _resolveHostKeyStatus(
      knownHosts: knownHosts,
      keyType: keyType,
      fingerprint: fingerprint,
    );

    _log.d('Host key verification — host=$host:$port, type=$keyType, status=$status');

    switch (status) {
      case _HostKeyStatus.trusted:
        final match = knownHosts.firstWhere(
          (kh) =>
              kh.keyType == keyType &&
              kh.hostKeyFingerprint == fingerprint,
        );
        await _knownHostDao.updateLastSeen(match.id);
        return true;

      case _HostKeyStatus.newHost:
        if (!context.mounted) return false;
        final accepted = await _showNewHostDialog(
          context: context,
          host: host,
          port: port,
          keyType: keyType,
          fingerprint: fingerprint,
        );
        if (accepted) {
          await _knownHostDao.insertKnownHost(
            KnownHostsCompanion.insert(
              host: host,
              keyType: keyType,
              hostKeyFingerprint: fingerprint,
              port: Value(port),
            ),
          );
        }
        return accepted;

      case _HostKeyStatus.changed:
        if (!context.mounted) return false;
        final accepted = await _showChangedHostKeyDialog(
          context: context,
          host: host,
          port: port,
          keyType: keyType,
          fingerprint: fingerprint,
        );
        if (accepted) {
          // Replace the stale record with the new fingerprint.
          final stale = knownHosts.firstWhere(
            (kh) => kh.keyType == keyType,
          );
          await _knownHostDao.deleteKnownHost(stale.id);
          await _knownHostDao.insertKnownHost(
            KnownHostsCompanion.insert(
              host: host,
              keyType: keyType,
              hostKeyFingerprint: fingerprint,
              port: Value(port),
            ),
          );
        }
        return accepted;
    }
  }

  /// Determines the trust status of a host key against stored records.
  _HostKeyStatus _resolveHostKeyStatus({
    required List<KnownHost> knownHosts,
    required String keyType,
    required String fingerprint,
  }) {
    final matchingType = knownHosts.where((kh) => kh.keyType == keyType);
    if (matchingType.isEmpty) {
      return _HostKeyStatus.newHost;
    }
    final hasMatch = matchingType.any(
      (kh) => kh.hostKeyFingerprint == fingerprint,
    );
    return hasMatch ? _HostKeyStatus.trusted : _HostKeyStatus.changed;
  }

  /// Computes a hex-encoded SHA-256 fingerprint of the raw host key bytes.
  String _computeHostKeyFingerprint(Uint8List hostKeyBytes) {
    final digest = SHA256Digest().process(hostKeyBytes);
    return digest
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':');
  }

  // ---------------------------------------------------------------------------
  // Terminal binding
  // ---------------------------------------------------------------------------

  /// Opens a shell channel and pipes I/O between the SSH channel and the
  /// xterm [Terminal].
  Future<void> _bindTerminal(SSHClient client, Terminal terminal) async {
    final shell = await client.shell(
      pty: SSHPtyConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
    );

    // SSH stdout -> terminal
    shell.stdout.listen(
      (data) {
        terminal.write(utf8.decode(data, allowMalformed: true));
      },
      onDone: () {
        terminal.write('\r\n[Session ended]');
      },
    );

    // SSH stderr -> terminal
    shell.stderr.listen((data) {
      terminal.write(utf8.decode(data, allowMalformed: true));
    });

    // Terminal input -> SSH stdin
    terminal.onOutput = (data) {
      shell.stdin.add(utf8.encode(data));
    };

    // Terminal resize -> SSH pty resize
    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      shell.resizeTerminal(width, height);
    };
  }

  // ---------------------------------------------------------------------------
  // Host key verification dialogs
  // ---------------------------------------------------------------------------

  /// Shows a confirmation dialog for a new, previously unseen host.
  Future<bool> _showNewHostDialog({
    required BuildContext context,
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Host'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The authenticity of this host has not been established.',
            ),
            const SizedBox(height: 16),
            _buildFingerprintInfo(host, port, keyType, fingerprint),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to continue connecting?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Trust & Connect'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Shows a warning dialog when the host key fingerprint has changed.
  Future<bool> _showChangedHostKeyDialog({
    required BuildContext context,
    required String host,
    required int port,
    required String keyType,
    required String fingerprint,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Text('Host Key Changed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WARNING: The host key for this server has changed. '
              'This could indicate a man-in-the-middle attack, or the '
              'server may have been reinstalled.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildFingerprintInfo(host, port, keyType, fingerprint),
            const SizedBox(height: 16),
            const Text(
              'If you trust this change, you can accept the new key. '
              'Otherwise, cancel to abort the connection.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Accept New Key'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Builds a styled widget displaying host key fingerprint details.
  Widget _buildFingerprintInfo(
    String host,
    int port,
    String keyType,
    String fingerprint,
  ) {
    final hostDisplay =
        port != AppConstants.defaultSshPort ? '$host:$port' : host;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Host', hostDisplay),
          const SizedBox(height: 4),
          _buildInfoRow('Key Type', keyType),
          const SizedBox(height: 4),
          _buildInfoRow('Fingerprint', fingerprint),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontFamily: AppConstants.defaultTerminalFontFamily,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
