import 'package:intl/intl.dart';

/// The type of a remote file system entry.
enum SftpEntryType {
  file,
  directory,
  symlink,
}

/// Represents a single entry in a remote SFTP directory listing.
///
/// Immutable value object containing file metadata as returned by
/// the SFTP server. Provides display helpers for formatted sizes,
/// permission strings, and hidden-file detection.
class SftpEntry {
  const SftpEntry({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    this.modifiedAt,
    this.permissions,
    this.owner,
  });

  /// The file or directory name (basename only, no path separators).
  final String name;

  /// The full absolute path on the remote file system.
  final String path;

  /// Whether this entry is a file, directory, or symbolic link.
  final SftpEntryType type;

  /// File size in bytes. Directories typically report 0 or 4096.
  final int size;

  /// Last modification timestamp, if available from the server.
  final DateTime? modifiedAt;

  /// Unix permission bits (e.g. 0755, 0644), if available.
  final int? permissions;

  /// Owner username on the remote system, if available.
  final String? owner;

  // ---------------------------------------------------------------------------
  // Derived properties
  // ---------------------------------------------------------------------------

  /// Whether this entry is a hidden file (name starts with a dot).
  bool get isHidden => name.startsWith('.');

  /// Whether this entry represents a directory.
  bool get isDirectory => type == SftpEntryType.directory;

  /// Whether this entry represents a regular file.
  bool get isFile => type == SftpEntryType.file;

  /// Whether this entry represents a symbolic link.
  bool get isSymlink => type == SftpEntryType.symlink;

  // ---------------------------------------------------------------------------
  // Display helpers
  // ---------------------------------------------------------------------------

  /// File extension without the leading dot, or empty string if none.
  String get extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == name.length - 1) return '';
    return name.substring(dotIndex + 1).toLowerCase();
  }

  /// Returns a human-readable file size string.
  ///
  /// Examples: "1.2 KB", "3.5 MB", "128 B".
  /// Directories return an em-dash to indicate size is not applicable.
  String get formattedSize {
    if (type == SftpEntryType.directory) return '\u2014';
    return _formatBytes(size);
  }

  /// Returns a formatted date string for the modification timestamp.
  ///
  /// Format: "2024-03-15 14:30". Returns an em-dash if no date is available.
  String get formattedModifiedAt {
    if (modifiedAt == null) return '\u2014';
    return DateFormat('yyyy-MM-dd HH:mm').format(modifiedAt!);
  }

  /// Returns a Unix-style permission string (e.g. "rwxr-xr-x").
  ///
  /// Returns an em-dash if permission bits are not available.
  String get formattedPermissions {
    if (permissions == null) return '\u2014';
    return _formatPermissions(permissions!);
  }

  // ---------------------------------------------------------------------------
  // Private formatting utilities
  // ---------------------------------------------------------------------------

  static const int _kibibyte = 1024;
  static const int _mebibyte = 1024 * 1024;
  static const int _gibibyte = 1024 * 1024 * 1024;

  static String _formatBytes(int bytes) {
    if (bytes < _kibibyte) return '$bytes B';
    if (bytes < _mebibyte) {
      return '${(bytes / _kibibyte).toStringAsFixed(1)} KB';
    }
    if (bytes < _gibibyte) {
      return '${(bytes / _mebibyte).toStringAsFixed(1)} MB';
    }
    return '${(bytes / _gibibyte).toStringAsFixed(1)} GB';
  }

  static String _formatPermissions(int mode) {
    final buffer = StringBuffer();
    // Owner
    buffer.write((mode & 0x100) != 0 ? 'r' : '-');
    buffer.write((mode & 0x080) != 0 ? 'w' : '-');
    buffer.write((mode & 0x040) != 0 ? 'x' : '-');
    // Group
    buffer.write((mode & 0x020) != 0 ? 'r' : '-');
    buffer.write((mode & 0x010) != 0 ? 'w' : '-');
    buffer.write((mode & 0x008) != 0 ? 'x' : '-');
    // Others
    buffer.write((mode & 0x004) != 0 ? 'r' : '-');
    buffer.write((mode & 0x002) != 0 ? 'w' : '-');
    buffer.write((mode & 0x001) != 0 ? 'x' : '-');
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SftpEntry && other.path == path && other.type == type;
  }

  @override
  int get hashCode => Object.hash(path, type);

  @override
  String toString() => 'SftpEntry(name: $name, path: $path, type: $type)';
}
