import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';
import 'package:taroshell/features/terminal/presentation/screens/terminal_screen.dart';
import 'package:taroshell/shared/widgets/quick_connect_dialog.dart';

/// Main connections content area displaying the terminal or welcome state.
///
/// Shows the [TerminalScreen] when there are active SSH sessions, or a
/// welcoming empty state with guidance when no sessions exist.
class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(activeSessionsProvider);
    final hasActiveSessions = sessions.isNotEmpty;

    if (hasActiveSessions) {
      return TerminalScreen(
        onQuickConnect: () => _showQuickConnect(context),
        onChooseSavedServer: () => _showSidebarHint(context),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return _buildWelcomeState(context, theme, isDark);
  }

  Future<void> _showQuickConnect(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const QuickConnectDialog(),
    );
  }

  void _showSidebarHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select a saved server from the sidebar.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildWelcomeState(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Terminal icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkPrimaryAlpha10
                  : AppColors.lightPrimaryAlpha10,
            ),
            child: Icon(
              Icons.terminal_rounded,
              size: 40,
              color: isDark
                  ? AppColors.darkPrimaryAlpha60
                  : AppColors.lightPrimaryAlpha60,
            ),
          ),
          const SizedBox(height: 24),

          // Welcome heading
          Text(
            'No Active Connection',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Select a server from the sidebar to connect,\nor add a new server to get started.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkOnSurfaceMuted
                  : AppColors.lightOnSurfaceMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Keyboard shortcut hints
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark
                  ? AppColors.darkSurfaceVariantHalf
                  : AppColors.lightSurfaceVariant,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ShortcutHint(
                  keys: _platformModifier(context, 'N'),
                  description: 'New server',
                  theme: theme,
                ),
                const SizedBox(height: 6),
                _ShortcutHint(
                  keys: _platformModifier(context, 'N', shift: true),
                  description: 'Quick connect',
                  theme: theme,
                ),
                const SizedBox(height: 6),
                _ShortcutHint(
                  keys: _platformModifier(context, 'K'),
                  description: 'Search servers',
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _platformModifier(
    BuildContext context,
    String key, {
    bool shift = false,
  }) {
    // macOS uses Cmd (⌘), other platforms use Ctrl. Shift is rendered as ⇧
    // on macOS to match native menu conventions.
    final platform = Theme.of(context).platform;
    final isMac = platform == TargetPlatform.macOS;
    final modifier = isMac ? '\u2318' : 'Ctrl+';
    final shiftModifier = shift ? (isMac ? '\u21e7' : 'Shift+') : '';
    return isMac
        ? '$shiftModifier$modifier$key'
        : '$modifier$shiftModifier$key';
  }
}

/// Displays a keyboard shortcut hint row.
class _ShortcutHint extends StatelessWidget {
  const _ShortcutHint({
    required this.keys,
    required this.description,
    required this.theme,
  });

  final String keys;
  final String description;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
          child: Text(
            keys,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppConstants.defaultTerminalFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkOnSurfaceSubtle
                : AppColors.lightOnSurfaceSubtle,
          ),
        ),
      ],
    );
  }
}
