import 'dart:io';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:taroshell/features/sftp/domain/entities/sftp_entry.dart';
import 'package:taroshell/features/sftp/domain/repositories/sftp_repository.dart';

/// SFTP-specific exception for domain-level error handling.
class SftpException implements Exception {
  const SftpException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause != null ? 'SftpException: $message ($cause)' : 'SftpException: $message';
}

/// Implementation of [SftpRepository] backed by dartssh2's [SftpClient].
///
/// Each instance is bound to a single SSH session's SFTP subsystem.
/// The caller is responsible for ensuring the [SSHClient] remains
/// connected for the lifetime of this repository.
class SftpRepositoryImpl implements SftpRepository {
  SftpRepositoryImpl({
    required SSHClient client,
  }) : _client = client;

  final SSHClient _client;

  /// Cached SFTP client to avoid re-opening the subsystem on every call.
  SftpClient? _sftpClient;

  /// Size of read/write chunks during file transfers (64 KB).
  static const int _transferChunkSize = 64 * 1024;

  /// Pseudo-directory names excluded from listings.
  static const Set<String> _pseudoEntries = {'.', '..'};

  // ---------------------------------------------------------------------------
  // SFTP subsystem management
  // ---------------------------------------------------------------------------

  /// Returns the cached [SftpClient], or opens a new SFTP subsystem.
  Future<SftpClient> _getSftpClient() async {
    if (_sftpClient != null) return _sftpClient!;
    try {
      _sftpClient = await _client.sftp();
      return _sftpClient!;
    } catch (e) {
      throw SftpException(
        'Failed to open SFTP subsystem',
        cause: e,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // SftpRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Future<List<SftpEntry>> listDirectory(String path) async {
    final sftp = await _getSftpClient();
    try {
      final items = await sftp.listdir(path);
      return items
          .where((item) => !_pseudoEntries.contains(item.filename))
          .map((item) => _mapToSftpEntry(item, path))
          .toList();
    } catch (e) {
      throw SftpException(
        'Failed to list directory: $path',
        cause: e,
      );
    }
  }

  @override
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    TransferProgressCallback? onProgress,
  }) async {
    final sftp = await _getSftpClient();
    final localFile = File(localPath);

    if (!await localFile.exists()) {
      throw SftpException('Local file does not exist: $localPath');
    }

    final totalBytes = await localFile.length();
    var sentBytes = 0;

    try {
      final remoteFile = await sftp.open(
        remotePath,
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );

      try {
        final inputStream = localFile.openRead();
        await for (final chunk in inputStream) {
          await remoteFile.writeBytes(
            Uint8List.fromList(chunk),
            offset: sentBytes,
          );
          sentBytes += chunk.length;
          onProgress?.call(sentBytes, totalBytes);
        }
      } finally {
        await remoteFile.close();
      }
    } catch (e) {
      if (e is SftpException) rethrow;
      throw SftpException(
        'Failed to upload file to: $remotePath',
        cause: e,
      );
    }
  }

  @override
  Future<void> downloadFile(
    String remotePath,
    String localPath, {
    TransferProgressCallback? onProgress,
  }) async {
    final sftp = await _getSftpClient();

    try {
      final remoteFile = await sftp.open(remotePath);
      try {
        final stat = await remoteFile.stat();
        final totalBytes = stat.size ?? 0;
        var receivedBytes = 0;

        final localFile = File(localPath);
        final sink = localFile.openWrite();

        try {
          final dataStream = remoteFile.read(
            chunkSize: _transferChunkSize,
          );

          await for (final chunk in dataStream) {
            sink.add(chunk);
            receivedBytes += chunk.length;
            onProgress?.call(receivedBytes, totalBytes);
          }
        } finally {
          await sink.flush();
          await sink.close();
        }
      } finally {
        await remoteFile.close();
      }
    } catch (e) {
      if (e is SftpException) rethrow;
      throw SftpException(
        'Failed to download file: $remotePath',
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    final sftp = await _getSftpClient();
    try {
      await sftp.remove(path);
    } catch (e) {
      throw SftpException('Failed to delete file: $path', cause: e);
    }
  }

  @override
  Future<void> deleteDirectory(String path) async {
    final sftp = await _getSftpClient();
    try {
      // Recursively delete contents first
      final items = await sftp.listdir(path);
      for (final item in items) {
        if (_pseudoEntries.contains(item.filename)) continue;
        final itemPath = '$path/${item.filename}';
        final isDir = item.attr.isDirectory;
        if (isDir) {
          await deleteDirectory(itemPath);
        } else {
          await sftp.remove(itemPath);
        }
      }
      await sftp.rmdir(path);
    } catch (e) {
      if (e is SftpException) rethrow;
      throw SftpException(
        'Failed to delete directory: $path',
        cause: e,
      );
    }
  }

  @override
  Future<void> rename(String oldPath, String newPath) async {
    final sftp = await _getSftpClient();
    try {
      await sftp.rename(oldPath, newPath);
    } catch (e) {
      throw SftpException(
        'Failed to rename: $oldPath -> $newPath',
        cause: e,
      );
    }
  }

  @override
  Future<void> createDirectory(String path) async {
    final sftp = await _getSftpClient();
    try {
      await sftp.mkdir(path);
    } catch (e) {
      throw SftpException(
        'Failed to create directory: $path',
        cause: e,
      );
    }
  }

  @override
  Future<void> chmod(String path, int permissions) async {
    final sftp = await _getSftpClient();
    try {
      await sftp.setStat(path, SftpFileAttrs(
        mode: SftpFileMode.value(permissions),
      ));
    } catch (e) {
      throw SftpException(
        'Failed to change permissions on: $path',
        cause: e,
      );
    }
  }

  @override
  Future<String> get homeDirectory async {
    final sftp = await _getSftpClient();
    try {
      return await sftp.absolute('.');
    } catch (e) {
      throw SftpException('Failed to resolve home directory', cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Mapping helpers
  // ---------------------------------------------------------------------------

  /// Maps a dartssh2 [SftpName] to our domain [SftpEntry].
  SftpEntry _mapToSftpEntry(SftpName item, String parentPath) {
    final attrs = item.attr;
    final entryPath = parentPath.endsWith('/')
        ? '$parentPath${item.filename}'
        : '$parentPath/${item.filename}';

    return SftpEntry(
      name: item.filename,
      path: entryPath,
      type: _resolveEntryType(attrs),
      size: attrs.size ?? 0,
      modifiedAt: attrs.modifyTime != null
          ? DateTime.fromMillisecondsSinceEpoch(attrs.modifyTime! * 1000)
          : null,
      permissions: attrs.mode?.value,
      owner: attrs.extended?['owner'],
    );
  }

  /// Determines the [SftpEntryType] from file attributes.
  SftpEntryType _resolveEntryType(SftpFileAttrs attrs) {
    if (attrs.isSymbolicLink) return SftpEntryType.symlink;
    if (attrs.isDirectory) return SftpEntryType.directory;
    return SftpEntryType.file;
  }
}
