import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/router/app_router.dart';
import 'package:taroshell/core/theme/app_theme.dart';

/// Global theme mode provider.
///
/// Defaults to [ThemeMode.dark] to match the modern terminal aesthetic.
/// Consumers can toggle between dark, light, and system modes.
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.dark,
);

/// Root application widget.
///
/// Wires up Material theming, GoRouter navigation, and Riverpod state
/// management. This widget should be wrapped in a [ProviderScope] at the
/// entry point.
class TaroShellApp extends ConsumerWidget {
  const TaroShellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
