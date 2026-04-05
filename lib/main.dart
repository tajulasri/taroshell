import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';
import 'package:taroshell/app.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/constants/db_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/core/utils/crypto_utils.dart';

/// Secure storage key under which the AES-256 encryption key is persisted.
const String _encryptionKeyStorageKey = 'taroshell_encryption_key';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---- Window configuration ----
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(
      AppConstants.windowDefaultWidth,
      AppConstants.windowDefaultHeight,
    ),
    minimumSize: Size(
      AppConstants.windowMinWidth,
      AppConstants.windowMinHeight,
    ),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: AppConstants.appName,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // ---- Database initialization ----
  final log = AppLogger.database;
  log.i('Initializing database — name=${DbConstants.databaseName}, schemaVersion=${DbConstants.schemaVersion}');
  final database = AppDatabase();

  // ---- Encryption key bootstrap ----
  log.i('Bootstrapping encryption key');
  final encryptionKey = await _bootstrapEncryptionKey();

  // ---- Launch application ----
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        encryptionKeyProvider.overrideWithValue(encryptionKey),
      ],
      child: const TaroShellApp(),
    ),
  );
}

/// Bootstraps the AES-256 encryption key used for private key storage.
///
/// Uses a two-tier strategy to ensure key consistency across launches:
/// 1. Reads from the file-based store first (always accessible).
/// 2. Falls back to the OS keychain if no file key exists.
/// 3. Generates a new key only when neither store has one.
///
/// After resolving the key, it is persisted to both stores so that
/// switching between keychain and file (e.g. signed vs debug builds)
/// never results in a key mismatch.
Future<String> _bootstrapEncryptionKey() async {
  final fileKey = await _readFileKey();
  final keychainKey = await _readKeychainKey();

  final log = AppLogger.crypto;

  // Prefer the file key — it's always accessible regardless of signing.
  final existingKey = fileKey ?? keychainKey;

  if (existingKey != null) {
    final source = fileKey != null ? 'file' : 'keychain';
    log.i('Encryption key loaded from $source store');
    // Ensure both stores are in sync.
    if (fileKey == null) {
      log.d('Syncing key to file store');
      await _writeFileKey(existingKey);
    }
    if (keychainKey == null) {
      log.d('Syncing key to keychain store');
      await _writeKeychainKey(existingKey);
    }
    return existingKey;
  }

  // No key in either store — generate a fresh one and persist everywhere.
  log.i('No existing key found — generating new encryption key');
  final newKey = CryptoUtils.generateEncryptionKey();
  await _writeFileKey(newKey);
  await _writeKeychainKey(newKey);
  return newKey;
}

// ---------------------------------------------------------------------------
// Keychain helpers
// ---------------------------------------------------------------------------

Future<String?> _readKeychainKey() async {
  try {
    final storage = _createSecureStorage();
    return await storage.read(key: _encryptionKeyStorageKey);
  } on PlatformException {
    return null;
  }
}

Future<void> _writeKeychainKey(String key) async {
  try {
    final storage = _createSecureStorage();
    await storage.write(key: _encryptionKeyStorageKey, value: key);
  } on PlatformException {
    // Keychain unavailable — silently skip.
  }
}

// ---------------------------------------------------------------------------
// File-based key helpers
// ---------------------------------------------------------------------------

File get _keyFile {
  final home = Platform.environment['HOME'] ?? '';
  return File(p.join(home, AppConstants.appDirectoryName, '.encryption_key'));
}

Future<String?> _readFileKey() async {
  final file = _keyFile;
  if (await file.exists()) {
    final content = (await file.readAsString()).trim();
    if (content.isNotEmpty) return content;
  }
  return null;
}

Future<void> _writeFileKey(String key) async {
  final file = _keyFile;
  final dir = file.parent;

  if (!await dir.exists()) {
    await dir.create(recursive: true);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['700', dir.path]);
    }
  }

  await file.writeAsString(key);

  if (!Platform.isWindows) {
    await Process.run('chmod', ['600', file.path]);
  }
}

/// Creates a [FlutterSecureStorage] with platform-appropriate options.
FlutterSecureStorage _createSecureStorage() {
  if (Platform.isMacOS) {
    return const FlutterSecureStorage(
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.unlocked,
        synchronizable: false,
      ),
    );
  }
  return const FlutterSecureStorage();
}

/// Riverpod provider for the singleton [AppDatabase] instance.
///
/// Overridden in [main] after the database is initialised.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'databaseProvider must be overridden at startup.',
  ),
);

/// Riverpod provider for the base64-encoded AES-256 encryption key.
///
/// Overridden in [main] after the key is retrieved from secure storage.
final encryptionKeyProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'encryptionKeyProvider must be overridden at startup.',
  ),
);
