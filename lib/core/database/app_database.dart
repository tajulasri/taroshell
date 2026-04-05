import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/constants/db_constants.dart';
import 'package:taroshell/features/connections/data/daos/collection_dao.dart';
import 'package:taroshell/features/connections/data/daos/connection_history_dao.dart';
import 'package:taroshell/features/connections/data/daos/server_dao.dart';
import 'package:taroshell/features/keys/data/daos/key_dao.dart';
import 'package:taroshell/features/known_hosts/data/daos/known_host_dao.dart';

part 'app_database.g.dart';

// =============================================================================
// Enums
// =============================================================================

/// Authentication method for SSH connections.
enum AuthType {
  password,
  key,
  keyWithPassphrase,
}

/// SSH key algorithm type.
enum KeyType {
  rsa2048,
  rsa4096,
  ed25519,
}

// =============================================================================
// Tables
// =============================================================================

/// Logical groupings (folders) for organising saved servers.
class ServerCollections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get color => text().withLength(min: 4, max: 9).nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name},
      ];
}

/// Saved SSH server connection profiles.
class Servers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().withLength(min: 1, max: 200)();
  TextColumn get host => text().withLength(min: 1, max: 255)();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get username => text().withLength(min: 1, max: 128)();
  TextColumn get authType =>
      textEnum<AuthType>().withDefault(Constant(AuthType.password.name))();
  TextColumn get encryptedPassword => text().nullable()();
  IntColumn get sshKeyId =>
      integer().nullable().references(SshKeys, #id)();
  IntColumn get collectionId =>
      integer().nullable().references(ServerCollections, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Stored SSH key pairs.
class SshKeys extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().withLength(min: 1, max: 200)();
  TextColumn get keyType => textEnum<KeyType>()();
  TextColumn get publicKey => text()();

  /// The private key is encrypted at rest via AES-256-GCM.
  TextColumn get encryptedPrivateKey => text()();

  TextColumn get fingerprint => text().withLength(max: 128)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {fingerprint},
      ];
}

/// Host key verification records (trust-on-first-use model).
class KnownHosts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text().withLength(min: 1, max: 255)();
  IntColumn get port => integer().withDefault(const Constant(22))();
  TextColumn get keyType => text().withLength(min: 1, max: 64)();
  TextColumn get hostKeyFingerprint => text()();
  DateTimeColumn get firstSeen =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeen =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {host, port, keyType},
      ];
}

/// Audit trail of SSH connection attempts and sessions.
class ConnectionHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serverId =>
      integer().nullable().references(Servers, #id)();
  TextColumn get host => text().withLength(min: 1, max: 255)();
  IntColumn get port => integer()();
  TextColumn get username => text().withLength(min: 1, max: 128)();
  DateTimeColumn get connectedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get disconnectedAt => dateTime().nullable()();
  BoolColumn get wasSuccessful =>
      boolean().withDefault(const Constant(true))();
  TextColumn get errorMessage => text().nullable()();
}

// =============================================================================
// Database
// =============================================================================

@DriftDatabase(
  tables: [
    Servers,
    ServerCollections,
    SshKeys,
    KnownHosts,
    ConnectionHistory,
  ],
  daos: [ServerDao, CollectionDao, KeyDao, KnownHostDao, ConnectionHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(
          executor ??
              driftDatabase(
                name: DbConstants.databaseName,
                native: DriftNativeOptions(
                  shareAcrossIsolates: true,
                  databasePath: _resolveDatabasePath,
                ),
              ),
        );

  @override
  int get schemaVersion => DbConstants.schemaVersion;

  /// Resolves the database file path to `~/.taroshell/taroshell.db.sqlite`.
  ///
  /// Creates the directory if it does not exist, with permissions restricted
  /// to the current user (700).
  static Future<String> _resolveDatabasePath() async {
    final home = Platform.environment['HOME'] ?? '';
    final dir = Directory(p.join(home, AppConstants.appDirectoryName));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
      if (!Platform.isWindows) {
        await Process.run('chmod', ['700', dir.path]);
      }
    }

    return p.join(dir.path, '${DbConstants.databaseName}.sqlite');
  }
}
