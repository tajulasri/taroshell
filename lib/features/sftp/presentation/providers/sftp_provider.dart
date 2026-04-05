import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/features/sftp/data/repositories/sftp_repository_impl.dart';
import 'package:taroshell/features/sftp/domain/entities/sftp_entry.dart';
import 'package:taroshell/features/sftp/domain/repositories/sftp_repository.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';

export 'package:taroshell/features/settings/presentation/providers/settings_provider.dart'
    show showHiddenFilesProvider;

// =============================================================================
// Repository provider (keyed by session ID)
// =============================================================================

/// Provides an [SftpRepository] instance for the given [sessionId].
///
/// The repository is lazily created and cached for the lifetime of the
/// session. Returns `null` if the session is not found or has no active
/// SSH client.
final sftpRepositoryProvider =
    Provider.family<SftpRepository?, String>((ref, sessionId) {
  final sessions = ref.watch(activeSessionsProvider);
  final session = sessions.cast<TerminalSession?>().firstWhere(
        (s) => s?.id == sessionId,
        orElse: () => null,
      );

  if (session == null || session.client == null || !session.isConnected) {
    return null;
  }

  return SftpRepositoryImpl(client: session.client!);
});

// =============================================================================
// Path navigation state
// =============================================================================

/// Tracks the current directory path per session.
///
/// Keyed by session ID so that each tab maintains its own navigation state.
final currentPathProvider =
    StateProvider.family<String?, String>((ref, sessionId) => null);

/// Tracks navigation history for backward navigation per session.
final navigationHistoryProvider =
    StateProvider.family<List<String>, String>((ref, sessionId) => []);

/// Tracks forward navigation stack per session.
final forwardHistoryProvider =
    StateProvider.family<List<String>, String>((ref, sessionId) => []);

// =============================================================================
// UI state
// =============================================================================

/// Column used for sorting the file list.
enum SftpSortColumn {
  name,
  size,
  modified,
  permissions,
}

/// The currently active sort column.
final sortColumnProvider =
    StateProvider<SftpSortColumn>((ref) => SftpSortColumn.name);

/// Whether the sort order is ascending.
final sortAscendingProvider = StateProvider<bool>((ref) => true);

/// Set of currently selected file paths.
final selectedEntriesProvider = StateProvider<Set<String>>((ref) => {});

// =============================================================================
// Directory listing
// =============================================================================

/// Asynchronously fetches and caches the directory listing for the
/// current path of the given session.
///
/// Watches [currentPathProvider] so that navigating to a new directory
/// automatically triggers a re-fetch.
final directoryListingProvider =
    FutureProvider.family<List<SftpEntry>, String>((ref, sessionId) async {
  final repository = ref.watch(sftpRepositoryProvider(sessionId));
  if (repository == null) {
    throw const SftpException('No active SFTP connection');
  }

  // Resolve the current path, defaulting to home directory.
  var currentPath = ref.watch(currentPathProvider(sessionId));
  if (currentPath == null) {
    currentPath = await repository.homeDirectory;
    // Use the Future.microtask to schedule the state update after the build.
    Future.microtask(() {
      ref.read(currentPathProvider(sessionId).notifier).state = currentPath;
    });
  }

  final entries = await repository.listDirectory(currentPath);
  return _sortEntries(
    entries,
    ref.watch(sortColumnProvider),
    ref.watch(sortAscendingProvider),
  );
});

/// Sorts entries with directories first, then files, applying the
/// specified column and direction.
List<SftpEntry> _sortEntries(
  List<SftpEntry> entries,
  SftpSortColumn column,
  bool ascending,
) {
  final directories =
      entries.where((e) => e.type == SftpEntryType.directory).toList();
  final files =
      entries.where((e) => e.type != SftpEntryType.directory).toList();

  int Function(SftpEntry, SftpEntry) comparator;
  switch (column) {
    case SftpSortColumn.name:
      comparator =
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case SftpSortColumn.size:
      comparator = (a, b) => a.size.compareTo(b.size);
    case SftpSortColumn.modified:
      comparator = (a, b) {
        final aTime = a.modifiedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.modifiedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      };
    case SftpSortColumn.permissions:
      comparator = (a, b) => (a.permissions ?? 0).compareTo(b.permissions ?? 0);
  }

  if (!ascending) {
    final original = comparator;
    comparator = (a, b) => original(b, a);
  }

  directories.sort(comparator);
  files.sort(comparator);

  return [...directories, ...files];
}

// =============================================================================
// SFTP actions provider
// =============================================================================

/// Provides high-level SFTP operations (upload, download, delete, rename,
/// mkdir, chmod) with proper error handling and state invalidation.
class SftpActions {
  SftpActions({
    required this.ref,
    required this.sessionId,
  });

  final Ref ref;
  final String sessionId;

  SftpRepository? get _repository =>
      ref.read(sftpRepositoryProvider(sessionId));

  /// Navigates into the specified [path], updating history stacks.
  void navigateTo(String path) {
    final currentPath = ref.read(currentPathProvider(sessionId));
    if (currentPath != null) {
      ref.read(navigationHistoryProvider(sessionId).notifier).update(
            (history) => [...history, currentPath],
          );
    }
    ref.read(forwardHistoryProvider(sessionId).notifier).state = [];
    ref.read(currentPathProvider(sessionId).notifier).state = path;
    ref.read(selectedEntriesProvider.notifier).state = {};
  }

  /// Navigates back in the history stack.
  void navigateBack() {
    final history = ref.read(navigationHistoryProvider(sessionId));
    if (history.isEmpty) return;

    final currentPath = ref.read(currentPathProvider(sessionId));
    final previousPath = history.last;

    ref.read(navigationHistoryProvider(sessionId).notifier).update(
          (h) => h.sublist(0, h.length - 1),
        );

    if (currentPath != null) {
      ref.read(forwardHistoryProvider(sessionId).notifier).update(
            (f) => [...f, currentPath],
          );
    }

    ref.read(currentPathProvider(sessionId).notifier).state = previousPath;
    ref.read(selectedEntriesProvider.notifier).state = {};
  }

  /// Navigates forward in the history stack.
  void navigateForward() {
    final forwardStack = ref.read(forwardHistoryProvider(sessionId));
    if (forwardStack.isEmpty) return;

    final currentPath = ref.read(currentPathProvider(sessionId));
    final nextPath = forwardStack.last;

    ref.read(forwardHistoryProvider(sessionId).notifier).update(
          (f) => f.sublist(0, f.length - 1),
        );

    if (currentPath != null) {
      ref.read(navigationHistoryProvider(sessionId).notifier).update(
            (h) => [...h, currentPath],
          );
    }

    ref.read(currentPathProvider(sessionId).notifier).state = nextPath;
    ref.read(selectedEntriesProvider.notifier).state = {};
  }

  /// Navigates to the parent directory.
  void navigateUp() {
    final currentPath = ref.read(currentPathProvider(sessionId));
    if (currentPath == null || currentPath == '/') return;

    final parentPath = currentPath.substring(
      0,
      currentPath.lastIndexOf('/'),
    );
    navigateTo(parentPath.isEmpty ? '/' : parentPath);
  }

  /// Navigates to the user's home directory.
  Future<void> navigateHome() async {
    final repo = _repository;
    if (repo == null) return;

    try {
      final homePath = await repo.homeDirectory;
      navigateTo(homePath);
    } on SftpException {
      // Silently fail -- the UI will reflect the unchanged path.
    }
  }

  /// Refreshes the current directory listing.
  void refresh() {
    ref.invalidate(directoryListingProvider(sessionId));
  }

  /// Uploads a file with progress tracking.
  ///
  /// Returns a [Stream] that yields progress events.
  Future<void> uploadFile(
    String localPath,
    String remotePath, {
    TransferProgressCallback? onProgress,
  }) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.uploadFile(localPath, remotePath, onProgress: onProgress);
    refresh();
  }

  /// Downloads a file with progress tracking.
  Future<void> downloadFile(
    String remotePath,
    String localPath, {
    TransferProgressCallback? onProgress,
  }) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.downloadFile(remotePath, localPath, onProgress: onProgress);
  }

  /// Deletes a file at the given [path].
  Future<void> deleteFile(String path) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.deleteFile(path);
    refresh();
  }

  /// Deletes a directory at the given [path] recursively.
  Future<void> deleteDirectory(String path) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.deleteDirectory(path);
    refresh();
  }

  /// Renames an entry from [oldPath] to [newPath].
  Future<void> rename(String oldPath, String newPath) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.rename(oldPath, newPath);
    refresh();
  }

  /// Creates a new directory at the given [path].
  Future<void> createDirectory(String path) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.createDirectory(path);
    refresh();
  }

  /// Changes permissions on the entry at [path].
  Future<void> chmod(String path, int permissions) async {
    final repo = _repository;
    if (repo == null) {
      throw const SftpException('No active SFTP connection');
    }

    await repo.chmod(path, permissions);
    refresh();
  }
}

/// Provides an [SftpActions] instance keyed by session ID.
final sftpActionsProvider =
    Provider.family<SftpActions, String>((ref, sessionId) {
  return SftpActions(ref: ref, sessionId: sessionId);
});
