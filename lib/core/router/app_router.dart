import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taroshell/features/connections/connections_screen.dart';
import 'package:taroshell/features/keys/key_management_screen.dart';
import 'package:taroshell/features/settings/settings_screen.dart';
import 'package:taroshell/shared/widgets/app_scaffold.dart';

/// Centralized route path constants to eliminate magic strings in navigation.
abstract final class AppRoutes {
  static const String connections = '/';
  static const String settings = '/settings';
  static const String keys = '/keys';
}

/// Application router configuration using [GoRouter].
///
/// Uses a [ShellRoute] to wrap all top-level screens in the shared
/// [AppScaffold] layout (sidebar + content area + status bar).
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.connections,
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppScaffold(
          currentPath: state.uri.path,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.connections,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ConnectionsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.keys,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: KeyManagementScreen(),
          ),
        ),
      ],
    ),
  ],
);
