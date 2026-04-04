import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:taroshell/core/router/app_router.dart';

// =============================================================================
// Intents
// =============================================================================

/// Intent to open a new connection tab.
class NewConnectionIntent extends Intent {
  const NewConnectionIntent();
}

/// Intent to close the current active tab.
class CloseTabIntent extends Intent {
  const CloseTabIntent();
}

/// Intent to switch to the previous tab.
class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

/// Intent to switch to the next tab.
class NextTabIntent extends Intent {
  const NextTabIntent();
}

/// Intent to open the settings screen.
class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

// =============================================================================
// Shortcut mappings
// =============================================================================

/// Global keyboard shortcut bindings for TaroShell.
///
/// Bindings follow platform conventions (Ctrl on Linux/Windows, Meta on macOS
/// is handled automatically by [LogicalKeyboardKey]).
final Map<ShortcutActivator, Intent> appShortcuts = {
  const SingleActivator(LogicalKeyboardKey.keyT, control: true):
      const NewConnectionIntent(),
  const SingleActivator(LogicalKeyboardKey.keyW, control: true):
      const CloseTabIntent(),
  const SingleActivator(
    LogicalKeyboardKey.arrowLeft,
    control: true,
    shift: true,
  ): const PreviousTabIntent(),
  const SingleActivator(
    LogicalKeyboardKey.arrowRight,
    control: true,
    shift: true,
  ): const NextTabIntent(),
  const SingleActivator(LogicalKeyboardKey.comma, control: true):
      const OpenSettingsIntent(),
};

// =============================================================================
// Wrapper widget
// =============================================================================

/// Wraps a child widget tree with the application-level keyboard shortcuts.
///
/// Place this widget high in the tree (typically around the scaffold) so
/// shortcuts are available regardless of focus. Actions that depend on
/// runtime state (e.g. tab management) accept callbacks.
class AppShortcutsWrapper extends StatelessWidget {
  const AppShortcutsWrapper({
    super.key,
    required this.child,
    this.onNewConnection,
    this.onCloseTab,
    this.onPreviousTab,
    this.onNextTab,
  });

  /// The child widget tree to wrap with shortcuts.
  final Widget child;

  /// Callback invoked when the user presses Ctrl+T.
  final VoidCallback? onNewConnection;

  /// Callback invoked when the user presses Ctrl+W.
  final VoidCallback? onCloseTab;

  /// Callback invoked when the user presses Ctrl+Shift+Left.
  final VoidCallback? onPreviousTab;

  /// Callback invoked when the user presses Ctrl+Shift+Right.
  final VoidCallback? onNextTab;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: appShortcuts,
      child: Actions(
        actions: {
          NewConnectionIntent: CallbackAction<NewConnectionIntent>(
            onInvoke: (_) {
              onNewConnection?.call();
              return null;
            },
          ),
          CloseTabIntent: CallbackAction<CloseTabIntent>(
            onInvoke: (_) {
              onCloseTab?.call();
              return null;
            },
          ),
          PreviousTabIntent: CallbackAction<PreviousTabIntent>(
            onInvoke: (_) {
              onPreviousTab?.call();
              return null;
            },
          ),
          NextTabIntent: CallbackAction<NextTabIntent>(
            onInvoke: (_) {
              onNextTab?.call();
              return null;
            },
          ),
          OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
            onInvoke: (_) {
              context.go(AppRoutes.settings);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
