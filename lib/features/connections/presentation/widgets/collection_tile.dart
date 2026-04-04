import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/domain/entities/server_collection.dart';
import 'package:taroshell/features/connections/presentation/providers/server_provider.dart';

import 'package:taroshell/features/connections/presentation/widgets/server_card.dart';

/// Context menu actions for a collection tile.
enum _CollectionContextAction {
  rename,
  changeColor,
  delete,
}

/// Available collection color options.
///
/// Stored as hex strings matching the [ServerCollections.color] column format.
abstract final class CollectionColors {
  static const List<_ColorOption> options = [
    _ColorOption(label: 'Blue', hex: '#3B82F6'),
    _ColorOption(label: 'Green', hex: '#22C55E'),
    _ColorOption(label: 'Red', hex: '#EF4444'),
    _ColorOption(label: 'Orange', hex: '#F59E0B'),
    _ColorOption(label: 'Purple', hex: '#A78BFA'),
    _ColorOption(label: 'Teal', hex: '#14B8A6'),
    _ColorOption(label: 'Pink', hex: '#EC4899'),
    _ColorOption(label: 'Gray', hex: '#94A3B8'),
  ];
}

class _ColorOption {
  final String label;
  final String hex;
  const _ColorOption({required this.label, required this.hex});
}

/// An expandable tile representing a server collection in the sidebar.
///
/// Displays the collection name with a color indicator dot, and expands
/// to reveal the servers within that collection. Supports right-click
/// context menu for rename, change color, and delete operations.
class CollectionTile extends ConsumerStatefulWidget {
  const CollectionTile({
    super.key,
    required this.collection,
    this.selectedServerId,
    this.onServerTap,
    this.onServerEdit,
    this.onServerDuplicate,
    this.onServerDelete,
    this.onAddServer,
    this.onRename,
    this.onChangeColor,
    this.onDelete,
  });

  /// The collection entity to display.
  final CollectionEntity collection;

  /// The currently selected server ID, if any.
  final int? selectedServerId;

  /// Called when a server within this collection is tapped.
  final ValueChanged<ServerEntity>? onServerTap;

  /// Called when "Edit" is selected on a server's context menu.
  final ValueChanged<ServerEntity>? onServerEdit;

  /// Called when "Duplicate" is selected on a server's context menu.
  final ValueChanged<ServerEntity>? onServerDuplicate;

  /// Called when "Delete" is selected on a server's context menu.
  final ValueChanged<ServerEntity>? onServerDelete;

  /// Called when the "+" button is tapped to add a server to this collection.
  final VoidCallback? onAddServer;

  /// Called when "Rename" is selected from the collection context menu.
  final VoidCallback? onRename;

  /// Called when "Change Color" is selected from the collection context menu.
  final VoidCallback? onChangeColor;

  /// Called when "Delete" is selected from the collection context menu.
  final VoidCallback? onDelete;

  @override
  ConsumerState<CollectionTile> createState() => _CollectionTileState();
}

class _CollectionTileState extends ConsumerState<CollectionTile> {
  bool _isExpanded = true;

  Color _parseCollectionColor() {
    final hex = widget.collection.color;
    if (hex == null || hex.length < 7) {
      return AppColors.disconnected;
    }
    try {
      final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
      return Color(value | 0xFF000000);
    } catch (_) {
      return AppColors.disconnected;
    }
  }

  Future<void> _showContextMenu(Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final result = await showMenu<_CollectionContextAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: const [
        PopupMenuItem(
          value: _CollectionContextAction.rename,
          child: _ContextMenuItem(
            icon: Icons.edit_outlined,
            label: 'Rename',
          ),
        ),
        PopupMenuItem(
          value: _CollectionContextAction.changeColor,
          child: _ContextMenuItem(
            icon: Icons.palette_outlined,
            label: 'Change Color',
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _CollectionContextAction.delete,
          child: _ContextMenuItem(
            icon: Icons.delete_outlined,
            label: 'Delete',
            isDestructive: true,
          ),
        ),
      ],
    );

    switch (result) {
      case _CollectionContextAction.rename:
        widget.onRename?.call();
      case _CollectionContextAction.changeColor:
        widget.onChangeColor?.call();
      case _CollectionContextAction.delete:
        widget.onDelete?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final servers = ref.watch(
      serversByCollectionProvider(widget.collection.id),
    );
    final color = _parseCollectionColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Collection header ----
        GestureDetector(
          onSecondaryTapUp: (details) =>
              _showContextMenu(details.globalPosition),
          child: InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Expand/collapse chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Color indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Collection name
                  Expanded(
                    child: Text(
                      widget.collection.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Add server button
                  if (widget.onAddServer != null)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        onPressed: widget.onAddServer,
                        icon: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        padding: EdgeInsets.zero,
                        splashRadius: 14,
                        tooltip: 'Add server',
                      ),
                    ),

                  const SizedBox(width: 4),

                  // Server count badge
                  servers.when(
                    data: (list) => Text(
                      '${list.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ---- Server list (expandable) ----
        // AnimatedSize only builds children when expanded, avoiding
        // the cost of constructing the full server list while collapsed.
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? servers.when(
                  data: (list) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: list
                        .map(
                          (server) => ServerCard(
                            server: server,
                            isSelected:
                                server.id == widget.selectedServerId,
                            onTap: () =>
                                widget.onServerTap?.call(server),
                            onEdit: () =>
                                widget.onServerEdit?.call(server),
                            onDuplicate: () =>
                                widget.onServerDuplicate?.call(server),
                            onDelete: () =>
                                widget.onServerDelete?.call(server),
                          ),
                        )
                        .toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Error loading servers',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// A single row within the collection context menu.
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
    final theme = Theme.of(context);
    final color = isDestructive
        ? AppColors.error
        : theme.colorScheme.onSurface;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
