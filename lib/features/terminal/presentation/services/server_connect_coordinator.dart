import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/router/app_router.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/keys/presentation/providers/key_provider.dart';
import 'package:taroshell/features/terminal/domain/services/ssh_service.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';
import 'package:taroshell/features/terminal/presentation/widgets/password_prompt_dialog.dart';

/// Logger for the server connection coordinator.
final _log = AppLogger.ssh;

/// Resolves credentials and starts a connection to [server].
///
/// Drives the full connection flow: credential prompts, key decryption, and
/// handoff to [connectToServer]. Used by both saved-server connects (from
/// the sidebar) and quick-connect ephemeral sessions.
///
/// When [adHocKeyFilePath] is provided, the PEM is read from disk at call
/// time and parsed in-memory — it is never persisted. This supports the
/// quick-connect "Key file" auth option.
///
/// Navigates to [AppRoutes.connections] on success so the user sees the
/// new tab immediately.
Future<void> connectServer(
  BuildContext context,
  WidgetRef ref,
  ServerEntity server, {
  String? adHocKeyFilePath,
}) async {
  _log.i(
    'Initiating connection — server="${server.label}", '
    'authType=${server.authType.name}, '
    'keyId=${server.sshKeyId}, adHocKey=${adHocKeyFilePath != null}',
  );

  String? password;
  SSHKeyPair? keyPair;

  try {
    switch (server.authType) {
      case AuthType.password:
        if (!context.mounted) return;
        password = await PasswordPromptDialog.show(context);
        if (password == null) return;

      case AuthType.key:
        final pem = adHocKeyFilePath != null
            ? await _readPemFile(adHocKeyFilePath)
            : await _decryptStoredKey(ref, server.sshKeyId);
        keyPair = _parseKeyPair(pem);
        // Key is passphrase-protected despite authType being `key` —
        // prompt and retry.
        if (keyPair == null) {
          if (!context.mounted) return;
          final passphrase = await PasswordPromptDialog.show(
            context,
            isPassphrase: true,
          );
          if (passphrase == null) return;
          keyPair = _parseKeyPair(pem, passphrase: passphrase);
        }

      case AuthType.keyWithPassphrase:
        final pem = adHocKeyFilePath != null
            ? await _readPemFile(adHocKeyFilePath)
            : await _decryptStoredKey(ref, server.sshKeyId);
        if (!context.mounted) return;
        final passphrase = await PasswordPromptDialog.show(
          context,
          isPassphrase: true,
        );
        if (passphrase == null) return;
        keyPair = _parseKeyPair(pem, passphrase: passphrase);
    }

    if (!context.mounted) return;

    // Navigate to connections route immediately so the user sees the tab.
    context.go(AppRoutes.connections);

    // Create pending tab and start SSH connection in background.
    // Errors are handled inline in the tab (no snackbar needed).
    connectToServer(
      ref: ref,
      server: server,
      password: password,
      keyPair: keyPair,
      context: context,
    );
  } catch (e, st) {
    // Credential resolution errors (key decryption, parse failures)
    // happen before the pending tab is created, so show a snackbar.
    _log.e('Credential resolution failed for server="${server.label}"', e, st);

    if (context.mounted) {
      final message = switch (e) {
        SshAuthenticationException(:final message) => message,
        _ => 'Failed to resolve credentials: $e',
      };
      _showErrorSnackBar(context, message);
    }
  }
}

/// Reads a PEM private key from disk at [path].
///
/// The file contents are held in memory only for the duration of the SSH
/// handshake and are never persisted to the app database.
Future<String> _readPemFile(String path) async {
  _log.d('Reading ad-hoc PEM key file — path=$path');
  try {
    return await File(path).readAsString();
  } on FileSystemException catch (e) {
    _log.w('Failed to read ad-hoc key file — $e');
    throw SshAuthenticationException(
      'Could not read the selected key file: ${e.message}',
    );
  }
}

/// Decrypts the app-level AES encryption on a stored SSH key and returns
/// the raw PEM string.
Future<String> _decryptStoredKey(WidgetRef ref, int? sshKeyId) async {
  _log.d('Decrypting stored key — keyId=$sshKeyId');

  if (sshKeyId == null) {
    throw const SshAuthenticationException(
      'No SSH key configured for this server.',
    );
  }

  final repository = ref.read(keyRepositoryProvider);
  final keyEntity = await repository.getKeyById(sshKeyId);

  if (keyEntity == null) {
    _log.w('SSH key not found — keyId=$sshKeyId');
    throw const SshAuthenticationException(
      'The configured SSH key was not found.',
    );
  }

  _log.d('Key found — keyId=$sshKeyId, decrypting private key');
  return repository.decryptPrivateKey(keyEntity.encryptedPrivateKey);
}

/// Parses a PEM string into an [SSHKeyPair].
///
/// Returns `null` if the key is passphrase-protected and no [passphrase]
/// was provided (instead of throwing), allowing the caller to prompt the
/// user for a passphrase and retry.
///
/// Throws [SshAuthenticationException] for unrecoverable parse failures.
SSHKeyPair? _parseKeyPair(String pem, {String? passphrase}) {
  _log.d('Parsing key pair — hasPassphrase=${passphrase != null}');
  try {
    final keyPairs = SSHKeyPair.fromPem(pem, passphrase);
    if (keyPairs.isEmpty) {
      _log.e('Key pair parsing returned empty list');
      throw const SshAuthenticationException(
        'Failed to parse the SSH private key.',
      );
    }
    _log.d('Key pair parsed successfully');
    return keyPairs.first;
  } on SSHKeyDecryptError {
    if (passphrase == null) {
      _log.d('Key is passphrase-protected, prompting user');
      return null;
    }
    _log.w('Invalid passphrase provided for key');
    throw const SshAuthenticationException(
      'Invalid passphrase for the SSH private key.',
    );
  }
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
