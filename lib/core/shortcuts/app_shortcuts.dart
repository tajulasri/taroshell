import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:taroshell/core/router/app_router.dart';

// =============================================================================
// Intents
// =============================================================================

/// Intent to open the "Add Server" dialog.
class NewServerIntent extends Intent {
  const NewServerIntent();
}

/// Intent to open the Quick Connect dialog for an ephemeral session.
class QuickConnectIntent extends Intent {
  const QuickConnectIntent();
}

/// Intent to focus the sidebar search field.
class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
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
/// Each logical binding is registered twice — once with `control` (for
/// Linux/Windows) and once with `meta` (for macOS `⌘`) — so the same
/// intent fires regardless of platform without a runtime check.
final Map<ShortcutActivator, Intent> appShortcuts = {
  // New server (saved profile)
  const SingleActivator(LogicalKeyboardKey.keyN, control: true):
      const NewServerIntent(),
  const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
      const NewServerIntent(),

  // Quick connect (ephemeral session)
  const SingleActivator(LogicalKeyboardKey.keyN, control: true, shift: true):
      const QuickConnectIntent(),
  const SingleActivator(LogicalKeyboardKey.keyN, meta: true, shift: true):
      const QuickConnectIntent(),

  // Focus sidebar search
  const SingleActivator(LogicalKeyboardKey.keyK, control: true):
      const FocusSearchIntent(),
  const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
      const FocusSearchIntent(),

  // Close current tab
  const SingleActivator(LogicalKeyboardKey.keyW, control: true):
      const CloseTabIntent(),
  const SingleActivator(LogicalKeyboardKey.keyW, meta: true):
      const CloseTabIntent(),

  // Previous / next tab
  const SingleActivator(
    LogicalKeyboardKey.arrowLeft,
    control: true,
    shift: true,
  ): const PreviousTabIntent(),
  const SingleActivator(
    LogicalKeyboardKey.arrowLeft,
    meta: true,
    shift: true,
  ): const PreviousTabIntent(),
  const SingleActivator(
    LogicalKeyboardKey.arrowRight,
    control: true,
    shift: true,
  ): const NextTabIntent(),
  const SingleActivator(
    LogicalKeyboardKey.arrowRight,
    meta: true,
    shift: true,
  ): const NextTabIntent(),

  // Settings
  const SingleActivator(LogicalKeyboardKey.comma, control: true):
      const OpenSettingsIntent(),
  const SingleActivator(LogicalKeyboardKey.comma, meta: true):
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
    this.onNewServer,
    this.onQuickConnect,
    this.onFocusSearch,
    this.onCloseTab,
    this.onPreviousTab,
    this.onNextTab,
  });

  /// The child widget tree to wrap with shortcuts.
  final Widget child;

  /// Callback invoked on Ctrl/⌘+N — open the Add Server dialog.
  final VoidCallback? onNewServer;

  /// Callback invoked on Ctrl/⌘+Shift+N — open the Quick Connect dialog.
  final VoidCallback? onQuickConnect;

  /// Callback invoked on Ctrl/⌘+K — focus the sidebar search field.
  final VoidCallback? onFocusSearch;

  /// Callback invoked on Ctrl/⌘+W — close the current terminal tab.
  final VoidCallback? onCloseTab;

  /// Callback invoked on Ctrl/⌘+Shift+Left — switch to the previous tab.
  final VoidCallback? onPreviousTab;

  /// Callback invoked on Ctrl/⌘+Shift+Right — switch to the next tab.
  final VoidCallback? onNextTab;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: appShortcuts,
      child: Actions(
        actions: {
          NewServerIntent: CallbackAction<NewServerIntent>(
            onInvoke: (_) {
              onNewServer?.call();
              return null;
            },
          ),
          QuickConnectIntent: CallbackAction<QuickConnectIntent>(
            onInvoke: (_) {
              onQuickConnect?.call();
              return null;
            },
          ),
          FocusSearchIntent: CallbackAction<FocusSearchIntent>(
            onInvoke: (_) {
              onFocusSearch?.call();
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
