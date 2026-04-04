import 'package:flutter/material.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/presentation/widgets/connection_status_badge.dart';

/// Menu item identifiers for the server context menu.
enum _ServerContextAction {
  edit,
  duplicate,
  delete,
}

/// A card widget displaying a server connection profile.
///
/// Shows the server label, host:port, username, auth type icon, and
/// connection status. Supports tap-to-connect, right-click / long-press
/// context menu for edit, duplicate, and delete operations.
class ServerCard extends StatefulWidget {
  const ServerCard({
    super.key,
    required this.server,
    this.isSelected = false,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  /// The server entity to display.
  final ServerEntity server;

  /// Whether this card is currently selected / active.
  final bool isSelected;

  /// Current connection status for the status badge.
  final ConnectionStatus connectionStatus;

  /// Called when the card is tapped (triggers connection).
  final VoidCallback? onTap;

  /// Called when "Edit" is chosen from the context menu.
  final VoidCallback? onEdit;

  /// Called when "Duplicate" is chosen from the context menu.
  final VoidCallback? onDuplicate;

  /// Called when "Delete" is chosen from the context menu.
  final VoidCallback? onDelete;

  @override
  State<ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<ServerCard> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  // Pre-computed alpha colors to avoid per-frame allocation.
  static const Color _darkHoverColor = AppColors.darkSurfaceVariantHalf;
  static const Color _lightHoverColor = AppColors.lightSurfaceVariant;

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  IconData _authTypeIcon() {
    switch (widget.server.authType) {
      case AuthType.password:
        return Icons.password_rounded;
      case AuthType.key:
      case AuthType.keyWithPassphrase:
        return Icons.vpn_key_rounded;
    }
  }

  String _authTypeTooltip() {
    switch (widget.server.authType) {
      case AuthType.password:
        return 'Password authentication';
      case AuthType.key:
        return 'SSH key authentication';
      case AuthType.keyWithPassphrase:
        return 'SSH key with passphrase';
    }
  }

  Future<void> _showContextMenu(Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    final result = await showMenu<_ServerContextAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: const [
        PopupMenuItem(
          value: _ServerContextAction.edit,
          child: _ContextMenuItem(
            icon: Icons.edit_outlined,
            label: 'Edit',
          ),
        ),
        PopupMenuItem(
          value: _ServerContextAction.duplicate,
          child: _ContextMenuItem(
            icon: Icons.copy_outlined,
            label: 'Duplicate',
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ServerContextAction.delete,
          child: _ContextMenuItem(
            icon: Icons.delete_outlined,
            label: 'Delete',
            isDestructive: true,
          ),
        ),
      ],
    );

    switch (result) {
      case _ServerContextAction.edit:
        widget.onEdit?.call();
      case _ServerContextAction.duplicate:
        widget.onDuplicate?.call();
      case _ServerContextAction.delete:
        widget.onDelete?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final server = widget.server;

    final selectedColor = theme.colorScheme.primary.withValues(alpha: 0.12);
    final hoverColor = isDark ? _darkHoverColor : _lightHoverColor;

    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTapUp: (details) =>
            _showContextMenu(details.globalPosition),
        onLongPressStart: (details) =>
            _showContextMenu(details.globalPosition),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, isHovered, child) {
            Color backgroundColor;
            if (widget.isSelected) {
              backgroundColor = selectedColor;
            } else if (isHovered) {
              backgroundColor = hoverColor;
            } else {
              backgroundColor = Colors.transparent;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: widget.isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: child,
            );
          },
          // Static card content — does not rebuild on hover changes.
          child: Row(
            children: [
              // Auth type icon
              Tooltip(
                message: _authTypeTooltip(),
                child: Icon(
                  _authTypeIcon(),
                  size: 16,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 10),

              // Server info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      server.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${server.username}@${server.host}:${server.port}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkOnSurfaceMuted
                            : AppColors.lightOnSurfaceMuted,
                        fontSize: 11,
                        fontFamily: 'JetBrainsMono',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Favorite indicator
              if (server.isFavorite)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                ),

              // Connection status
              ConnectionStatusBadge(status: widget.connectionStatus),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single row within the server context menu.
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
