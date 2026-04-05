import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/sftp/presentation/screens/sftp_screen.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';
import 'package:taroshell/features/terminal/presentation/widgets/connection_banner.dart';
import 'package:taroshell/features/terminal/presentation/widgets/terminal_tab_bar.dart';
import 'package:taroshell/features/terminal/presentation/widgets/terminal_view_wrapper.dart';

/// Provider signaling a retry request from an errored session.
///
/// When set to a non-null server ID, the sidebar picks it up and
/// re-triggers the full connection flow (credential resolution, etc.).
/// Reset to `null` after handling.
final retryConnectionProvider = StateProvider<int?>((ref) => null);

/// Enumeration of the content panels available in the bottom toggle bar.
enum _ContentPanel {
  terminal,
  sftp,
}

/// Main terminal screen displaying the SSH session interface.
///
/// Layout (top to bottom):
/// 1. [TerminalTabBar] -- tabs for each active session.
/// 2. [ConnectionBanner] -- host info and uptime for the current session.
/// 3. Terminal view ([TerminalViewWrapper]) -- the xterm widget.
/// 4. Bottom toggle bar -- switches between Terminal and SFTP modes.
class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({
    super.key,
    this.onQuickConnect,
    this.onChooseSavedServer,
  });

  /// Callback invoked when the user selects "Quick Connect" from the
  /// tab bar `+` menu.
  final VoidCallback? onQuickConnect;

  /// Callback invoked when the user selects "Choose Saved Server…" from
  /// the tab bar `+` menu.
  final VoidCallback? onChooseSavedServer;

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  _ContentPanel _activePanel = _ContentPanel.terminal;

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(activeSessionsProvider);
    final currentSession = ref.watch(currentSessionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (sessions.isEmpty || currentSession == null) {
      return _buildEmptyState(context, isDark);
    }

    return Column(
      children: [
        // Tab bar
        TerminalTabBar(
          onQuickConnect: widget.onQuickConnect,
          onChooseSavedServer: widget.onChooseSavedServer,
        ),

        // Content area — varies based on session status.
        Expanded(
          child: _buildSessionContent(currentSession, isDark, theme),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Session content by status
  // ---------------------------------------------------------------------------

  Widget _buildSessionContent(
    TerminalSession session,
    bool isDark,
    ThemeData theme,
  ) {
    switch (session.status) {
      case ConnectionStatus.connecting:
        return _buildConnectingState(session, isDark, theme);
      case ConnectionStatus.error:
        return _buildErrorState(session, isDark, theme);
      case ConnectionStatus.connected:
        return _buildConnectedContent(session, isDark, theme);
    }
  }

  Widget _buildConnectedContent(
    TerminalSession session,
    bool isDark,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Connection banner
        ConnectionBanner(
          session: session,
          onReconnect: session.isConnected
              ? null
              : () {
                  // Reconnect logic will be wired in a future phase when
                  // the server list provider is available to re-resolve
                  // credentials.
                },
        ),

        // Main content area
        Expanded(
          child: _activePanel == _ContentPanel.terminal
              ? TerminalViewWrapper(
                  key: ValueKey(session.id),
                  terminal: session.terminal,
                )
              : SftpScreen(
                  key: ValueKey('sftp_${session.id}'),
                  sessionId: session.id,
                ),
        ),

        // Bottom toggle bar
        _buildBottomToggleBar(isDark, theme),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Connecting state
  // ---------------------------------------------------------------------------

  Widget _buildConnectingState(
    TerminalSession session,
    bool isDark,
    ThemeData theme,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Connecting to ${session.connectionString}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppConstants.defaultTerminalFontFamily,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.lightOnSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Establishing SSH connection',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface.withValues(alpha: 0.5)
                  : AppColors.lightOnSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------

  Widget _buildErrorState(
    TerminalSession session,
    bool isDark,
    ThemeData theme,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Failed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppColors.darkOnSurface
                    : AppColors.lightOnSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.connectionString,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: AppConstants.defaultTerminalFontFamily,
                color: isDark
                    ? AppColors.darkOnSurface.withValues(alpha: 0.6)
                    : AppColors.lightOnSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                session.errorMessage ?? 'An unknown error occurred.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkOnSurface.withValues(alpha: 0.8)
                      : AppColors.lightOnSurface.withValues(alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    ref
                        .read(activeSessionsProvider.notifier)
                        .removeSession(
                          session.id,
                          ref.read(sshServiceProvider),
                        );
                  },
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _onRetry(session),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onRetry(TerminalSession session) {
    // Remove the errored session first.
    ref.read(activeSessionsProvider.notifier).removeSession(
          session.id,
          ref.read(sshServiceProvider),
        );

    // Signal the sidebar to re-trigger the full connection flow
    // (credential resolution, password prompt, etc.) for this server.
    ref.read(retryConnectionProvider.notifier).state = session.serverId;
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terminal_rounded,
            size: 64,
            color: isDark
                ? AppColors.darkOnSurface.withValues(alpha: 0.2)
                : AppColors.lightOnSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No active sessions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface.withValues(alpha: 0.5)
                  : AppColors.lightOnSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a server from the sidebar to connect',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface.withValues(alpha: 0.35)
                  : AppColors.lightOnSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom toggle bar
  // ---------------------------------------------------------------------------

  Widget _buildBottomToggleBar(bool isDark, ThemeData theme) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            label: 'Terminal',
            icon: Icons.terminal_rounded,
            isActive: _activePanel == _ContentPanel.terminal,
            isDark: isDark,
            theme: theme,
            onTap: () => setState(() => _activePanel = _ContentPanel.terminal),
          ),
          _buildToggleButton(
            label: 'SFTP',
            icon: Icons.folder_outlined,
            isActive: _activePanel == _ContentPanel.sftp,
            isDark: isDark,
            theme: theme,
            onTap: () => setState(() => _activePanel = _ContentPanel.sftp),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final activeColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final inactiveColor = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
        : AppColors.lightOnSurface.withValues(alpha: 0.5);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : inactiveColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
