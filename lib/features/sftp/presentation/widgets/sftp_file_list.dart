import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/sftp/domain/entities/sftp_entry.dart';
import 'package:taroshell/features/sftp/presentation/providers/sftp_provider.dart';

// =============================================================================
// Callbacks
// =============================================================================

/// Callback when a directory is double-clicked to navigate into.
typedef OnDirectoryOpen = void Function(SftpEntry entry);

/// Callback when a context-menu action is selected for an entry.
typedef OnContextAction = void Function(SftpContextAction action, SftpEntry entry);

/// Callback when a column header is tapped to change sort order.
typedef OnSortChanged = void Function(SftpSortColumn column);

/// Available context-menu actions for file entries.
enum SftpContextAction {
  download,
  rename,
  delete,
  chmod,
  copyPath,
}

// =============================================================================
// File list widget
// =============================================================================

/// Displays a sortable, selectable list of SFTP file entries.
///
/// Supports:
/// - Sortable column headers (name, size, modified, permissions)
/// - Double-click on directories to navigate in
/// - Click to select, Shift-click for range, Ctrl/Cmd-click for multi-select
/// - Right-click context menu
/// - File type icons based on extension
class SftpFileList extends StatefulWidget {
  const SftpFileList({
    super.key,
    required this.entries,
    required this.showHidden,
    required this.selectedPaths,
    required this.sortColumn,
    required this.sortAscending,
    required this.onDirectoryOpen,
    required this.onContextAction,
    required this.onSortChanged,
    required this.onSelectionChanged,
  });

  final List<SftpEntry> entries;
  final bool showHidden;
  final Set<String> selectedPaths;
  final SftpSortColumn sortColumn;
  final bool sortAscending;
  final OnDirectoryOpen onDirectoryOpen;
  final OnContextAction onContextAction;
  final OnSortChanged onSortChanged;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  State<SftpFileList> createState() => _SftpFileListState();
}

class _SftpFileListState extends State<SftpFileList> {
  /// Index of the last clicked entry for shift-select range calculation.
  int? _lastClickedIndex;

  /// Filtered entries (hidden files excluded when toggle is off).
  List<SftpEntry> get _visibleEntries {
    if (widget.showHidden) return widget.entries;
    return widget.entries.where((e) => !e.isHidden).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entries = _visibleEntries;

    return Column(
      children: [
        _buildHeader(isDark, theme),
        Expanded(
          child: entries.isEmpty
              ? _buildEmptyState(isDark, theme)
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _buildRow(entries[index], index, isDark, theme),
                ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Column header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(bool isDark, ThemeData theme) {
    final headerColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface)
        .withValues(alpha: 0.6);
    final borderColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Container(
      height: _kHeaderHeight,
      decoration: BoxDecoration(
        color: headerColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Icon column (fixed width, no sort)
          const SizedBox(width: _kIconColumnWidth),
          // Name column
          Expanded(
            flex: _kNameFlex,
            child: _buildHeaderCell(
              label: 'Name',
              column: SftpSortColumn.name,
              textColor: textColor,
              theme: theme,
            ),
          ),
          // Size column
          SizedBox(
            width: _kSizeColumnWidth,
            child: _buildHeaderCell(
              label: 'Size',
              column: SftpSortColumn.size,
              textColor: textColor,
              theme: theme,
              alignment: Alignment.centerRight,
            ),
          ),
          // Modified column
          SizedBox(
            width: _kModifiedColumnWidth,
            child: _buildHeaderCell(
              label: 'Modified',
              column: SftpSortColumn.modified,
              textColor: textColor,
              theme: theme,
            ),
          ),
          // Permissions column
          SizedBox(
            width: _kPermissionsColumnWidth,
            child: _buildHeaderCell(
              label: 'Permissions',
              column: SftpSortColumn.permissions,
              textColor: textColor,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell({
    required String label,
    required SftpSortColumn column,
    required Color textColor,
    required ThemeData theme,
    Alignment alignment = Alignment.centerLeft,
  }) {
    final isActive = widget.sortColumn == column;
    final activeColor = theme.brightness == Brightness.dark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    return InkWell(
      onTap: () => widget.onSortChanged(column),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? activeColor : textColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                widget.sortAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 12,
                color: activeColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // File row
  // ---------------------------------------------------------------------------

  Widget _buildRow(
    SftpEntry entry,
    int index,
    bool isDark,
    ThemeData theme,
  ) {
    final isSelected = widget.selectedPaths.contains(entry.path);
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final selectedColor = (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
        .withValues(alpha: 0.15);
    final hoverColor = (isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface)
        .withValues(alpha: 0.04);

    return GestureDetector(
      onDoubleTap: entry.isDirectory ? () => widget.onDirectoryOpen(entry) : null,
      onSecondaryTapUp: (details) =>
          _showContextMenu(context, details.globalPosition, entry),
      child: InkWell(
        onTap: () => _handleTap(index, entry),
        hoverColor: hoverColor,
        child: Container(
          height: _kRowHeight,
          color: isSelected ? selectedColor : null,
          child: Row(
            children: [
              // File type icon
              SizedBox(
                width: _kIconColumnWidth,
                child: Center(
                  child: Icon(
                    _resolveIcon(entry),
                    size: _kFileIconSize,
                    color: _resolveIconColor(entry, isDark),
                  ),
                ),
              ),
              // Name
              Expanded(
                flex: _kNameFlex,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    entry.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: entry.isHidden
                          ? textColor.withValues(alpha: 0.5)
                          : textColor,
                      fontWeight:
                          entry.isDirectory ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // Size
              SizedBox(
                width: _kSizeColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    entry.formattedSize,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              // Modified
              SizedBox(
                width: _kModifiedColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    entry.formattedModifiedAt,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              // Permissions
              SizedBox(
                width: _kPermissionsColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    entry.formattedPermissions,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textColor.withValues(alpha: 0.6),
                      fontFamily: AppConstants.defaultTerminalFontFamily,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(bool isDark, ThemeData theme) {
    final color = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.3)
        : AppColors.lightOnSurface.withValues(alpha: 0.3);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            'This directory is empty',
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Selection handling
  // ---------------------------------------------------------------------------

  void _handleTap(int index, SftpEntry entry) {
    final isShiftHeld = HardwareKeyboard.instance.logicalKeysPressed
        .any((key) =>
            key == LogicalKeyboardKey.shiftLeft ||
            key == LogicalKeyboardKey.shiftRight);

    final isCtrlOrCmdHeld = HardwareKeyboard.instance.logicalKeysPressed
        .any((key) =>
            key == LogicalKeyboardKey.controlLeft ||
            key == LogicalKeyboardKey.controlRight ||
            key == LogicalKeyboardKey.metaLeft ||
            key == LogicalKeyboardKey.metaRight);

    final entries = _visibleEntries;
    var newSelection = Set<String>.from(widget.selectedPaths);

    if (isShiftHeld && _lastClickedIndex != null) {
      // Range selection
      final start =
          _lastClickedIndex! < index ? _lastClickedIndex! : index;
      final end =
          _lastClickedIndex! > index ? _lastClickedIndex! : index;
      for (var i = start; i <= end; i++) {
        newSelection.add(entries[i].path);
      }
    } else if (isCtrlOrCmdHeld) {
      // Toggle selection
      if (newSelection.contains(entry.path)) {
        newSelection.remove(entry.path);
      } else {
        newSelection.add(entry.path);
      }
    } else {
      // Single selection
      newSelection = {entry.path};
    }

    _lastClickedIndex = index;
    widget.onSelectionChanged(newSelection);
  }

  // ---------------------------------------------------------------------------
  // Context menu
  // ---------------------------------------------------------------------------

  Future<void> _showContextMenu(
    BuildContext context,
    Offset position,
    SftpEntry entry,
  ) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final menuColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final action = await showMenu<SftpContextAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      color: menuColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      items: [
        if (entry.isFile)
          const PopupMenuItem(
            value: SftpContextAction.download,
            child: _ContextMenuItem(
              icon: Icons.download_outlined,
              label: 'Download',
            ),
          ),
        const PopupMenuItem(
          value: SftpContextAction.rename,
          child: _ContextMenuItem(
            icon: Icons.drive_file_rename_outline,
            label: 'Rename',
          ),
        ),
        const PopupMenuItem(
          value: SftpContextAction.chmod,
          child: _ContextMenuItem(
            icon: Icons.lock_outline,
            label: 'Change Permissions',
          ),
        ),
        const PopupMenuItem(
          value: SftpContextAction.copyPath,
          child: _ContextMenuItem(
            icon: Icons.copy_outlined,
            label: 'Copy Path',
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: SftpContextAction.delete,
          child: _ContextMenuItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            isDestructive: true,
          ),
        ),
      ],
    );

    if (action != null) {
      widget.onContextAction(action, entry);
    }
  }

  // ---------------------------------------------------------------------------
  // Icon resolution
  // ---------------------------------------------------------------------------

  IconData _resolveIcon(SftpEntry entry) {
    if (entry.isDirectory) return Icons.folder;
    if (entry.isSymlink) return Icons.link;

    return switch (entry.extension) {
      'txt' || 'log' || 'md' || 'csv' => Icons.description_outlined,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'svg' || 'bmp' || 'webp' =>
        Icons.image_outlined,
      'mp4' || 'avi' || 'mov' || 'mkv' || 'wmv' => Icons.movie_outlined,
      'mp3' || 'wav' || 'flac' || 'aac' || 'ogg' => Icons.audio_file_outlined,
      'zip' || 'tar' || 'gz' || 'bz2' || 'xz' || '7z' || 'rar' =>
        Icons.archive_outlined,
      'dart' || 'py' || 'js' || 'ts' || 'go' || 'rs' || 'java' || 'c' ||
      'cpp' || 'h' || 'rb' || 'php' || 'swift' || 'kt' =>
        Icons.code_outlined,
      'html' || 'css' || 'scss' || 'xml' || 'json' || 'yaml' || 'yml' ||
      'toml' =>
        Icons.code_outlined,
      'sh' || 'bash' || 'zsh' || 'fish' => Icons.terminal,
      'pdf' => Icons.picture_as_pdf_outlined,
      'doc' || 'docx' || 'odt' => Icons.article_outlined,
      'xls' || 'xlsx' || 'ods' => Icons.table_chart_outlined,
      'ppt' || 'pptx' || 'odp' => Icons.slideshow_outlined,
      'conf' || 'cfg' || 'ini' || 'env' => Icons.settings_outlined,
      'key' || 'pem' || 'crt' || 'cer' => Icons.vpn_key_outlined,
      'db' || 'sqlite' || 'sql' => Icons.storage_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }

  Color _resolveIconColor(SftpEntry entry, bool isDark) {
    if (entry.isDirectory) {
      return isDark ? AppColors.darkAccent : AppColors.lightAccent;
    }
    if (entry.isSymlink) {
      return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    }

    return switch (entry.extension) {
      'jpg' || 'jpeg' || 'png' || 'gif' || 'svg' || 'bmp' || 'webp' =>
        AppColors.warning,
      'zip' || 'tar' || 'gz' || 'bz2' || 'xz' || '7z' || 'rar' =>
        isDark ? AppColors.darkPrimaryVariant : AppColors.lightPrimaryVariant,
      'dart' || 'py' || 'js' || 'ts' || 'go' || 'rs' || 'java' || 'c' ||
      'cpp' || 'h' || 'rb' || 'php' || 'swift' || 'kt' =>
        AppColors.connected,
      'sh' || 'bash' || 'zsh' || 'fish' => AppColors.connected,
      'key' || 'pem' || 'crt' || 'cer' => AppColors.error,
      _ => isDark
          ? AppColors.darkOnSurface.withValues(alpha: 0.5)
          : AppColors.lightOnSurface.withValues(alpha: 0.5),
    };
  }

  // ---------------------------------------------------------------------------
  // Layout constants
  // ---------------------------------------------------------------------------

  static const double _kHeaderHeight = 32;
  static const double _kRowHeight = 30;
  static const double _kIconColumnWidth = 36;
  static const double _kSizeColumnWidth = 90;
  static const double _kModifiedColumnWidth = 140;
  static const double _kPermissionsColumnWidth = 110;
  static const double _kFileIconSize = 16;
  static const int _kNameFlex = 3;
}

// =============================================================================
// Context menu item widget
// =============================================================================

class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : null;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}
