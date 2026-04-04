import 'package:taroshell/features/sftp/domain/entities/sftp_entry.dart';

/// Progress callback signature for file transfer operations.
///
/// [transferred] is the number of bytes sent or received so far.
/// [total] is the total file size in bytes (may be 0 if unknown).
typedef TransferProgressCallback = void Function(int transferred, int total);

/// Abstract interface for SFTP file system operations.
///
/// Implementations are responsible for translating these operations
/// into the underlying SSH/SFTP protocol calls. All paths are absolute
/// remote paths.
abstract class SftpRepository {
  /// Lists all entries in the remote [path] directory.
  ///
  /// Returns a list of [SftpEntry] objects. Excludes the "." and ".."
  /// pseudo-entries. Throws on permission errors or if the path does
  /// not exist.
  Future<List<SftpEntry>> listDirectory(String path);

  /// Uploads a local file to a remote destination.
  ///
  /// [localPath] is the absolute path on the local file system.
  /// [remotePath] is the absolute destination path on the server.
  /// [onProgress] is an optional callback invoked as data is sent.
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    TransferProgressCallback? onProgress,
  });

  /// Downloads a remote file to a local destination.
  ///
  /// [remotePath] is the absolute path on the remote server.
  /// [localPath] is the absolute destination path on the local file system.
  /// [onProgress] is an optional callback invoked as data is received.
  Future<void> downloadFile(
    String remotePath,
    String localPath, {
    TransferProgressCallback? onProgress,
  });

  /// Deletes a single file at the given remote [path].
  Future<void> deleteFile(String path);

  /// Recursively deletes a directory at the given remote [path].
  Future<void> deleteDirectory(String path);

  /// Renames or moves a remote entry from [oldPath] to [newPath].
  Future<void> rename(String oldPath, String newPath);

  /// Creates a new directory at the given remote [path].
  Future<void> createDirectory(String path);

  /// Changes the Unix permissions of the entry at [path].
  ///
  /// [permissions] should be an octal value (e.g. 0755).
  Future<void> chmod(String path, int permissions);

  /// Returns the home directory of the authenticated user.
  Future<String> get homeDirectory;
}
