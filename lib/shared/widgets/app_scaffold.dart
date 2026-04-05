import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/shortcuts/app_shortcuts.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/connections/presentation/widgets/server_form_dialog.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';
import 'package:taroshell/shared/widgets/quick_connect_dialog.dart';
import 'package:taroshell/shared/widgets/sidebar.dart';

/// Status bar text shown when no SSH sessions are active.
const String _statusDisconnected = 'No active connections';

/// Label prefix shown in the status bar for an active connection.
const String _statusConnectedPrefix = 'Connected';

/// Label for the session duration indicator.
const String _statusSessionPrefix = 'Session';

/// Root layout scaffold wrapping every routed screen.
///
/// Provides:
/// - A custom drag-enabled title bar (replacing native chrome)
/// - A resizable sidebar on the left
/// - The main content area on the right
/// - A dynamic status bar at the bottom reflecting connection state
/// - Application-wide keyboard shortcuts
class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({
    super.key,
    required this.currentPath,
    required this.child,
  });

  /// Current route path forwarded to the sidebar for highlight state.
  final String currentPath;

  /// The routed page content.
  final Widget child;

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  final ValueNotifier<double> _sidebarWidth =
      ValueNotifier<double>(AppConstants.sidebarWidth);

  @override
  void dispose() {
    _sidebarWidth.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Global shortcut handlers
  // ---------------------------------------------------------------------------

  Future<void> _openNewServerDialog() async {
    await ServerFormDialog.show(context, ref);
  }

  Future<void> _openQuickConnectDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const QuickConnectDialog(),
    );
  }

  void _focusSidebarSearch() {
    ref.read(sidebarSearchFocusNodeProvider).requestFocus();
  }

  // ---------------------------------------------------------------------------
  // Sidebar resize
  // ---------------------------------------------------------------------------

  void _onDragUpdate(DragUpdateDetails details) {
    _sidebarWidth.value = (_sidebarWidth.value + details.delta.dx).clamp(
      AppConstants.sidebarMinWidth,
      AppConstants.sidebarMaxWidth,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShortcutsWrapper(
      onNewServer: _openNewServerDialog,
      onQuickConnect: _openQuickConnectDialog,
      onFocusSearch: _focusSidebarSearch,
      child: Scaffold(
        body: Column(
          children: [
            // ---- Custom title bar ----
            _buildTitleBar(context, isDark),

            // ---- Main area: sidebar + content ----
            Expanded(
              child: Row(
                children: [
                  // Sidebar (width driven by ValueNotifier)
                  ValueListenableBuilder<double>(
                    valueListenable: _sidebarWidth,
                    builder: (context, width, child) {
                      return SizedBox(width: width, child: child);
                    },
                    child: Sidebar(currentPath: widget.currentPath),
                  ),

                  // Resize handle
                  _buildResizeHandle(isDark),

                  // Content with RepaintBoundary to isolate from sidebar
                  Expanded(
                    child: RepaintBoundary(child: widget.child),
                  ),
                ],
              ),
            ),

            // ---- Status bar (self-contained timer) ----
            const _StatusBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Title bar
  // ---------------------------------------------------------------------------

  Widget _buildTitleBar(BuildContext context, bool isDark) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: () async {
        final isMaximized = await windowManager.isMaximized();
        if (isMaximized) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      },
      child: Container(
        height: AppConstants.titleBarHeight,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: Row(
          children: [
            // macOS traffic lights spacing
            const SizedBox(width: 78),
            Expanded(
              child: Center(
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
            _TitleBarQuickConnectButton(isDark: isDark),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Resize handle between sidebar and content
  // ---------------------------------------------------------------------------

  Widget _buildResizeHandle(bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        child: Container(
          width: 4,
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
    );
  }
}

// =============================================================================
// Title Bar — Quick Connect action
// =============================================================================

/// Compact icon button in the title bar that opens the [QuickConnectDialog].
///
/// Placed on the right edge (opposite the macOS traffic lights) so the
/// sidebar action row can stay focused on saved-server management.
class _TitleBarQuickConnectButton extends StatelessWidget {
  const _TitleBarQuickConnectButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final iconColor = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.7)
        : AppColors.lightOnSurface.withValues(alpha: 0.7);

    return Tooltip(
      message: 'Quick Connect',
      child: SizedBox(
        width: 32,
        height: 28,
        // Swallow the title bar's pan-to-drag gesture so the button stays
        // clickable even though it sits inside a drag region.
        child: GestureDetector(
          onPanStart: (_) {},
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => const QuickConnectDialog(),
              ),
              child: Icon(
                Icons.flash_on_outlined,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Status Bar — self-contained widget with its own timer
// =============================================================================

/// A status bar that manages its own 1-second timer, preventing full scaffold
/// rebuilds on every tick.
class _StatusBar extends ConsumerStatefulWidget {
  const _StatusBar();

  @override
  ConsumerState<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends ConsumerState<_StatusBar> {
  Timer? _uptimeTimer;

  @override
  void initState() {
    super.initState();
    _uptimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final session = ref.read(currentSessionProvider);
        if (session != null && session.isConnected && mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _uptimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final session = ref.watch(currentSessionProvider);
    final isConnected = session != null && session.isConnected;
    final statusColor =
        isConnected ? AppColors.connected : AppColors.disconnected;

    final muted =
        isDark ? AppColors.darkOnSurfaceMuted : AppColors.lightOnSurfaceMuted;
    final subtleMuted =
        isDark ? AppColors.darkOnSurfaceSubtle : AppColors.lightOnSurfaceSubtle;

    return Container(
      height: AppConstants.statusBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Row(
        children: [
          // ---- Connection indicator dot ----
          Icon(Icons.circle, size: 8, color: statusColor),
          const SizedBox(width: 6),

          // ---- Connection info or disconnected message ----
          if (isConnected)
            Expanded(
              child: Text(
                '$_statusConnectedPrefix: ${session.label} '
                '(${session.host}:${session.port})'
                ' | $_statusSessionPrefix: ${session.formattedUptime}',
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            )
          else
            Expanded(
              child: Text(
                _statusDisconnected,
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
            ),

          // ---- App name branding ----
          Text(
            AppConstants.appName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: subtleMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
