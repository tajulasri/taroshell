import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';

/// Height of each tab item in the terminal tab bar.
const double _tabHeight = 36.0;

/// Custom tab bar displaying active SSH sessions.
///
/// Features:
/// - Each tab shows the server label with a close button.
/// - The active tab is highlighted with an accent-colored bottom indicator.
/// - Tabs are reorderable via drag-and-drop.
/// - A trailing "+" button allows opening new connections.
class TerminalTabBar extends ConsumerWidget {
  const TerminalTabBar({
    super.key,
    this.onAddSession,
  });

  /// Callback invoked when the "+" (add session) button is pressed.
  final VoidCallback? onAddSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeSessionsProvider);
    final currentSession = ref.watch(currentSessionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: _tabHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Scrollable tab list
          Expanded(
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 4,
                  color: Colors.transparent,
                  child: child,
                );
              },
              onReorder: (oldIndex, newIndex) {
                // ReorderableListView adjusts newIndex when moving down.
                final adjustedNewIndex =
                    oldIndex < newIndex ? newIndex - 1 : newIndex;
                ref
                    .read(activeSessionsProvider.notifier)
                    .reorderSession(oldIndex, adjustedNewIndex);
              },
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final isActive = session.id == currentSession?.id;
                return ReorderableDragStartListener(
                  key: ValueKey(session.id),
                  index: index,
                  child: _SessionTab(
                    session: session,
                    isActive: isActive,
                    onTap: () {
                      ref
                          .read(activeSessionsProvider.notifier)
                          .setCurrentSession(session.id);
                    },
                    onClose: () async {
                      // Skip disconnect confirmation for non-connected sessions
                      // (connecting or errored) — there's no SSH session to close.
                      if (session.status != ConnectionStatus.connected) {
                        ref
                            .read(activeSessionsProvider.notifier)
                            .removeSession(session.id, ref.read(sshServiceProvider));
                        return;
                      }
                      final confirmed = await _showDisconnectConfirmDialog(
                        context,
                        session,
                      );
                      if (confirmed) {
                        ref
                            .read(activeSessionsProvider.notifier)
                            .removeSession(session.id, ref.read(sshServiceProvider));
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Add session button
          _buildAddButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return Tooltip(
      message: 'New connection',
      child: InkWell(
        onTap: onAddSession,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: _tabHeight,
          height: _tabHeight,
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 18,
            color: isDark
                ? AppColors.darkOnSurface.withValues(alpha: 0.7)
                : AppColors.lightOnSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

Future<bool> _showDisconnectConfirmDialog(
  BuildContext context,
  TerminalSession session,
) async {
  final theme = Theme.of(context);
  final portSuffix =
      session.port != AppConstants.defaultSshPort ? ':${session.port}' : '';
  final connectionString =
      '${session.username}@${session.host}$portSuffix';

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('End Session'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disconnect from "${session.label}"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      connectionString,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: AppConstants.defaultTerminalFontFamily,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Disconnect'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Individual session tab widget.
class _SessionTab extends StatelessWidget {
  const _SessionTab({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final TerminalSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final bgColor = isActive
        ? (isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground)
        : Colors.transparent;
    final textColor = isActive
        ? (isDark ? AppColors.darkOnBackground : AppColors.lightOnBackground)
        : (isDark
            ? AppColors.darkOnSurface.withValues(alpha: 0.6)
            : AppColors.lightOnSurface.withValues(alpha: 0.6));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 200,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connection status indicator
            _buildStatusIndicator(),
            const SizedBox(width: 8),

            // Server label
            Flexible(
              child: Text(
                session.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 6),

            // Close button
            _buildCloseButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (session.status) {
      case ConnectionStatus.connecting:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        );
      case ConnectionStatus.error:
        return const Icon(
          Icons.circle,
          size: 7,
          color: AppColors.error,
        );
      case ConnectionStatus.connected:
        return Icon(
          Icons.circle,
          size: 7,
          color: session.isConnected
              ? AppColors.connected
              : AppColors.disconnected,
        );
    }
  }

  Widget _buildCloseButton(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onClose,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            Icons.close,
            size: 14,
            color: isDark
                ? AppColors.darkOnSurface.withValues(alpha: 0.5)
                : AppColors.lightOnSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
