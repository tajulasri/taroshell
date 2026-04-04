import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/core/utils/time_utils.dart';
import 'package:taroshell/features/connections/presentation/providers/history_provider.dart';

/// Callback signature for when a history entry is tapped for reconnection.
typedef OnHistoryEntryTap = void Function(ConnectionHistoryData entry);

/// A collapsible "Recent" section in the sidebar showing successful
/// connection history for quick reconnection.
///
/// Follows the same expand/collapse pattern as [CollectionTile]:
/// - [AnimatedRotation] chevron (150ms)
/// - [AnimatedSize] body reveal (200ms)
///
/// Hidden entirely when no successful history entries exist.
class RecentConnectionsTile extends ConsumerStatefulWidget {
  const RecentConnectionsTile({
    super.key,
    required this.onEntryTap,
  });

  /// Called when the user taps a history entry to initiate reconnection.
  final OnHistoryEntryTap onEntryTap;

  @override
  ConsumerState<RecentConnectionsTile> createState() =>
      _RecentConnectionsTileState();
}

class _RecentConnectionsTileState
    extends ConsumerState<RecentConnectionsTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(recentHistoryProvider);

    return historyAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();
        return _buildPanel(context, entries);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    List<ConnectionHistoryData> entries,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Header ----
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Expand/collapse chevron
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0.0,
                  duration: const Duration(
                    milliseconds: AppConstants.animationFastMs,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 4),

                // History icon
                Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: isDark
                      ? AppColors.darkOnSurfaceMuted
                      : AppColors.lightOnSurfaceMuted,
                ),
                const SizedBox(width: 6),

                // Label
                Expanded(
                  child: Text(
                    'Recent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Entry count badge
                Text(
                  '${entries.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---- Expandable body ----
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: entries
                      .map((entry) => _HistoryEntryCard(
                            entry: entry,
                            onTap: () => widget.onEntryTap(entry),
                          ))
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// =============================================================================
// Individual history entry card
// =============================================================================

class _HistoryEntryCard extends StatefulWidget {
  const _HistoryEntryCard({
    required this.entry,
    required this.onTap,
  });

  final ConnectionHistoryData entry;
  final VoidCallback onTap;

  @override
  State<_HistoryEntryCard> createState() => _HistoryEntryCardState();
}

class _HistoryEntryCardState extends State<_HistoryEntryCard> {
  final _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  String _formatConnectionString(ConnectionHistoryData entry) {
    final portSuffix =
        entry.port != AppConstants.defaultSshPort ? ':${entry.port}' : '';
    return '${entry.username}@${entry.host}$portSuffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: _isHovered,
      builder: (context, hovered, child) {
        return MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: AppConstants.animationFastMs,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: hovered
                    ? (isDark
                        ? AppColors.darkSurfaceVariantHalf
                        : AppColors.lightSurfaceVariant)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Clock icon
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.darkOnSurfaceSubtle
                        : AppColors.lightOnSurfaceSubtle,
                  ),
                  const SizedBox(width: 8),

                  // Connection string + timestamp
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatConnectionString(widget.entry),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily:
                                AppConstants.defaultTerminalFontFamily,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          TimeUtils.formatRelativeTime(
                            widget.entry.connectedAt,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkOnSurfaceSubtle
                                : AppColors.lightOnSurfaceSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
