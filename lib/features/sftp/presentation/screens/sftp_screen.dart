import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/sftp/data/repositories/sftp_repository_impl.dart';
import 'package:taroshell/features/sftp/domain/entities/sftp_entry.dart';
import 'package:taroshell/features/sftp/presentation/providers/sftp_provider.dart';
import 'package:taroshell/features/sftp/presentation/widgets/sftp_breadcrumb.dart';
import 'package:taroshell/features/sftp/presentation/widgets/sftp_file_list.dart';
import 'package:taroshell/features/sftp/presentation/widgets/sftp_transfer_dialog.dart';

/// The SFTP file browser panel.
///
/// Provides a full-featured remote file browser with:
/// - Breadcrumb path navigation
/// - Toolbar with back/forward/up/home/refresh/hidden toggle/new folder/upload
/// - Sortable file list with context menus
/// - Transfer progress dialogs
class SftpScreen extends ConsumerStatefulWidget {
  const SftpScreen({
    super.key,
    required this.sessionId,
  });

  /// The active terminal session ID this SFTP browser is bound to.
  final String sessionId;

  @override
  ConsumerState<SftpScreen> createState() => _SftpScreenState();
}

class _SftpScreenState extends ConsumerState<SftpScreen> {
  /// Whether a transfer cancellation has been requested.
  bool _transferCancelled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final listing = ref.watch(directoryListingProvider(widget.sessionId));
    final currentPath =
        ref.watch(currentPathProvider(widget.sessionId)) ?? '/';
    final showHidden = ref.watch(showHiddenFilesProvider);
    final sortColumn = ref.watch(sortColumnProvider);
    final sortAscending = ref.watch(sortAscendingProvider);
    final selectedPaths = ref.watch(selectedEntriesProvider);
    final history = ref.watch(navigationHistoryProvider(widget.sessionId));
    final forwardStack =
        ref.watch(forwardHistoryProvider(widget.sessionId));

    return Column(
      children: [
        // Breadcrumb navigation
        SftpBreadcrumb(
          currentPath: currentPath,
          onNavigate: (path) =>
              ref.read(sftpActionsProvider(widget.sessionId)).navigateTo(path),
          onHome: () =>
              ref.read(sftpActionsProvider(widget.sessionId)).navigateHome(),
        ),

        // Toolbar
        _buildToolbar(
          isDark: isDark,
          theme: theme,
          showHidden: showHidden,
          canGoBack: history.isNotEmpty,
          canGoForward: forwardStack.isNotEmpty,
          currentPath: currentPath,
        ),

        // File list / loading / error
        Expanded(
          child: listing.when(
            data: (entries) => SftpFileList(
              entries: entries,
              showHidden: showHidden,
              selectedPaths: selectedPaths,
              sortColumn: sortColumn,
              sortAscending: sortAscending,
              onDirectoryOpen: (entry) => ref
                  .read(sftpActionsProvider(widget.sessionId))
                  .navigateTo(entry.path),
              onContextAction: _handleContextAction,
              onSortChanged: _handleSortChanged,
              onSelectionChanged: (selection) => ref
                  .read(selectedEntriesProvider.notifier)
                  .state = selection,
            ),
            loading: () => _buildLoadingState(isDark),
            error: (error, _) => _buildErrorState(error, isDark, theme),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Toolbar
  // ---------------------------------------------------------------------------

  Widget _buildToolbar({
    required bool isDark,
    required ThemeData theme,
    required bool showHidden,
    required bool canGoBack,
    required bool canGoForward,
    required String currentPath,
  }) {
    final actions = ref.read(sftpActionsProvider(widget.sessionId));
    final borderColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final disabledColor = (isDark
            ? AppColors.darkOnSurface
            : AppColors.lightOnSurface)
        .withValues(alpha: 0.2);
    final enabledColor = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.7)
        : AppColors.lightOnSurface.withValues(alpha: 0.7);
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    return Container(
      height: _kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back
          _buildToolbarButton(
            icon: Icons.arrow_back,
            tooltip: 'Back',
            enabled: canGoBack,
            color: canGoBack ? enabledColor : disabledColor,
            onTap: canGoBack ? actions.navigateBack : null,
          ),
          // Forward
          _buildToolbarButton(
            icon: Icons.arrow_forward,
            tooltip: 'Forward',
            enabled: canGoForward,
            color: canGoForward ? enabledColor : disabledColor,
            onTap: canGoForward ? actions.navigateForward : null,
          ),
          // Up
          _buildToolbarButton(
            icon: Icons.arrow_upward,
            tooltip: 'Parent Directory',
            enabled: currentPath != '/',
            color: currentPath != '/' ? enabledColor : disabledColor,
            onTap: currentPath != '/' ? actions.navigateUp : null,
          ),
          // Home
          _buildToolbarButton(
            icon: Icons.home_outlined,
            tooltip: 'Home Directory',
            enabled: true,
            color: enabledColor,
            onTap: actions.navigateHome,
          ),

          const SizedBox(width: 4),
          _buildToolbarDivider(isDark),
          const SizedBox(width: 4),

          // Refresh
          _buildToolbarButton(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            enabled: true,
            color: enabledColor,
            onTap: actions.refresh,
          ),
          // Show hidden
          _buildToolbarButton(
            icon: showHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            tooltip: showHidden ? 'Hide Hidden Files' : 'Show Hidden Files',
            enabled: true,
            color: showHidden ? accentColor : enabledColor,
            onTap: () => ref.read(showHiddenFilesProvider.notifier).state =
                !showHidden,
          ),

          const SizedBox(width: 4),
          _buildToolbarDivider(isDark),
          const SizedBox(width: 4),

          // New folder
          _buildToolbarButton(
            icon: Icons.create_new_folder_outlined,
            tooltip: 'New Folder',
            enabled: true,
            color: enabledColor,
            onTap: () => _showNewFolderDialog(currentPath),
          ),
          // Upload
          _buildToolbarButton(
            icon: Icons.upload_file_outlined,
            tooltip: 'Upload File',
            enabled: true,
            color: enabledColor,
            onTap: () => _handleUpload(currentPath),
          ),

          const Spacer(),

          // Path display
          Text(
            currentPath,
            style: theme.textTheme.bodySmall?.copyWith(
              color: (isDark
                      ? AppColors.darkOnSurface
                      : AppColors.lightOnSurface)
                  .withValues(alpha: 0.4),
              fontSize: 10,
              fontFamily: 'JetBrainsMono',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kToolbarButtonRadius),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: _kToolbarIconSize, color: color),
        ),
      ),
    );
  }

  Widget _buildToolbarDivider(bool isDark) {
    return Container(
      width: 1,
      height: 16,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }

  // ---------------------------------------------------------------------------
  // Loading and error states
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: SizedBox(
        width: _kLoadingIndicatorSize,
        height: _kLoadingIndicatorSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, bool isDark, ThemeData theme) {
    final message = error is SftpException ? error.message : error.toString();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load directory',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: (isDark
                        ? AppColors.darkOnSurface
                        : AppColors.lightOnSurface)
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref
                  .read(sftpActionsProvider(widget.sessionId))
                  .refresh(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sort handling
  // ---------------------------------------------------------------------------

  void _handleSortChanged(SftpSortColumn column) {
    final currentColumn = ref.read(sortColumnProvider);
    if (currentColumn == column) {
      ref.read(sortAscendingProvider.notifier).state =
          !ref.read(sortAscendingProvider);
    } else {
      ref.read(sortColumnProvider.notifier).state = column;
      ref.read(sortAscendingProvider.notifier).state = true;
    }
    ref.invalidate(directoryListingProvider(widget.sessionId));
  }

  // ---------------------------------------------------------------------------
  // Context action handling
  // ---------------------------------------------------------------------------

  Future<void> _handleContextAction(
    SftpContextAction action,
    SftpEntry entry,
  ) async {
    final actions = ref.read(sftpActionsProvider(widget.sessionId));

    switch (action) {
      case SftpContextAction.download:
        await _handleDownload(entry);

      case SftpContextAction.rename:
        await _showRenameDialog(entry);

      case SftpContextAction.delete:
        await _showDeleteConfirmation(entry, actions);

      case SftpContextAction.chmod:
        await _showChmodDialog(entry, actions);

      case SftpContextAction.copyPath:
        await Clipboard.setData(ClipboardData(text: entry.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Path copied to clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
    }
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _showNewFolderDialog(String currentPath) async {
    final controller = TextEditingController();
    final actions = ref.read(sftpActionsProvider(widget.sessionId));

    final folderName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder name',
            hintText: 'Enter folder name',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (folderName != null && folderName.trim().isNotEmpty) {
      try {
        final newPath = currentPath.endsWith('/')
            ? '$currentPath${folderName.trim()}'
            : '$currentPath/${folderName.trim()}';
        await actions.createDirectory(newPath);
      } on SftpException catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to create folder: ${e.message}');
        }
      }
    }
  }

  Future<void> _showRenameDialog(SftpEntry entry) async {
    final controller = TextEditingController(text: entry.name);
    final actions = ref.read(sftpActionsProvider(widget.sessionId));

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New name',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newName != null &&
        newName.trim().isNotEmpty &&
        newName.trim() != entry.name) {
      try {
        final parentPath =
            entry.path.substring(0, entry.path.lastIndexOf('/'));
        final newPath = parentPath.isEmpty
            ? '/${newName.trim()}'
            : '$parentPath/${newName.trim()}';
        await actions.rename(entry.path, newPath);
      } on SftpException catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to rename: ${e.message}');
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    SftpEntry entry,
    SftpActions actions,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          'Are you sure you want to delete "${entry.name}"? '
          '${entry.isDirectory ? 'This will delete all contents recursively.' : 'This action cannot be undone.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (entry.isDirectory) {
          await actions.deleteDirectory(entry.path);
        } else {
          await actions.deleteFile(entry.path);
        }
      } on SftpException catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to delete: ${e.message}');
        }
      }
    }
  }

  Future<void> _showChmodDialog(
    SftpEntry entry,
    SftpActions actions,
  ) async {
    final controller = TextEditingController(
      text: entry.permissions != null
          ? entry.permissions!.toRadixString(8).padLeft(3, '0')
          : '',
    );

    final permissionStr = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Permissions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${entry.name}'),
            const SizedBox(height: 4),
            Text(
              'Current: ${entry.formattedPermissions}',
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Octal permissions',
                hintText: '755',
                helperText: 'Enter 3-digit octal value (e.g. 644, 755)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-7]')),
                LengthLimitingTextInputFormatter(3),
              ],
              onSubmitted: (value) =>
                  Navigator.of(dialogContext).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (permissionStr != null && permissionStr.length == 3) {
      try {
        final permissions = int.parse(permissionStr, radix: 8);
        await actions.chmod(entry.path, permissions);
      } on FormatException {
        if (mounted) {
          _showErrorSnackBar('Invalid permission value');
        }
      } on SftpException catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to change permissions: ${e.message}');
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // File transfers
  // ---------------------------------------------------------------------------

  Future<void> _handleUpload(String currentPath) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final localPath = file.path!;
    final remotePath = currentPath.endsWith('/')
        ? '$currentPath${file.name}'
        : '$currentPath/${file.name}';

    final dialogKey = GlobalKey<SftpTransferDialogState>();
    _transferCancelled = false;

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SftpTransferDialog(
        key: dialogKey,
        fileName: file.name,
        isUpload: true,
        onCancel: () => _transferCancelled = true,
      ),
    );

    try {
      await ref.read(sftpActionsProvider(widget.sessionId)).uploadFile(
        localPath,
        remotePath,
        onProgress: (sent, total) {
          if (_transferCancelled) return;
          dialogKey.currentState?.updateProgress(sent, total);
        },
      );
    } on SftpException catch (e) {
      if (mounted && !_transferCancelled) {
        Navigator.of(context).pop(); // Close progress dialog
        _showErrorSnackBar('Upload failed: ${e.message}');
      }
    }
  }

  Future<void> _handleDownload(SftpEntry entry) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save As',
      fileName: entry.name,
    );
    if (outputPath == null) return;

    final dialogKey = GlobalKey<SftpTransferDialogState>();
    _transferCancelled = false;

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SftpTransferDialog(
        key: dialogKey,
        fileName: entry.name,
        isUpload: false,
        onCancel: () => _transferCancelled = true,
      ),
    );

    try {
      await ref.read(sftpActionsProvider(widget.sessionId)).downloadFile(
        entry.path,
        outputPath,
        onProgress: (received, total) {
          if (_transferCancelled) return;
          dialogKey.currentState?.updateProgress(received, total);
        },
      );
    } on SftpException catch (e) {
      if (mounted && !_transferCancelled) {
        Navigator.of(context).pop(); // Close progress dialog
        _showErrorSnackBar('Download failed: ${e.message}');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layout constants
  // ---------------------------------------------------------------------------

  static const double _kToolbarHeight = 36;
  static const double _kToolbarIconSize = 16;
  static const double _kToolbarButtonRadius = 4;
  static const double _kLoadingIndicatorSize = 32;
}
