import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/settings/presentation/providers/settings_provider.dart';
import 'package:taroshell/features/settings/presentation/widgets/font_size_slider.dart';
import 'package:taroshell/features/settings/presentation/widgets/theme_toggle.dart';

/// Application settings screen for configuring TaroShell preferences.
///
/// Organized into card-based sections: Appearance, Terminal, and General.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // ---------------------------------------------------------------------------
  // Section header labels
  // ---------------------------------------------------------------------------
  static const String _sectionAppearance = 'Appearance';
  static const String _sectionTerminal = 'Terminal';
  static const String _sectionGeneral = 'General';

  // ---------------------------------------------------------------------------
  // Scrollback buffer boundaries
  // ---------------------------------------------------------------------------
  static const double _scrollbackMin = 1000;
  static const double _scrollbackMax = 100000;
  static const int _scrollbackDivisions = 99;

  // ---------------------------------------------------------------------------
  // Connection timeout boundaries
  // ---------------------------------------------------------------------------
  static const double _timeoutMin = 5;
  static const double _timeoutMax = 120;
  static const int _timeoutDivisions = 23;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        children: [
          // ---- Page title ----
          Text(
            'Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Configure your Taro Shell preferences',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Appearance section ----
          _SettingsSection(
            title: _sectionAppearance,
            icon: Icons.palette_outlined,
            children: [
              _SettingsRow(
                label: 'Theme Mode',
                description: 'Choose between dark, light, or system theme',
                child: const ThemeToggle(),
              ),
              const Divider(height: 32),
              const FontSizeSlider(),
            ],
          ),
          const SizedBox(height: 16),

          // ---- Terminal section ----
          _SettingsSection(
            title: _sectionTerminal,
            icon: Icons.terminal_rounded,
            children: [
              _ScrollbackSetting(ref: ref),
              const Divider(height: 32),
              _CursorStyleSetting(),
            ],
          ),
          const SizedBox(height: 16),

          // ---- General section ----
          _SettingsSection(
            title: _sectionGeneral,
            icon: Icons.settings_outlined,
            children: [
              _DefaultPortSetting(ref: ref),
              const Divider(height: 32),
              _ConnectionTimeoutSetting(ref: ref),
              const Divider(height: 32),
              _HiddenFilesSetting(ref: ref),
            ],
          ),
          const SizedBox(height: 16),

          // ---- About section ----
          const _AboutSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// =============================================================================
// Settings section card wrapper
// =============================================================================

/// A card-based section container with a header icon and title.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Section header ----
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Section content ----
            ...children,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Settings row helper
// =============================================================================

/// A labeled row with description text and a trailing control widget.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    required this.description,
    required this.child,
  });

  final String label;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        child,
      ],
    );
  }
}

// =============================================================================
// Scrollback buffer setting
// =============================================================================

class _ScrollbackSetting extends StatelessWidget {
  const _ScrollbackSetting({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final scrollback = ref.watch(scrollbackLinesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scrollback Buffer',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatScrollback(scrollback),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Number of lines kept in the terminal history',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: scrollback.toDouble(),
          min: SettingsScreen._scrollbackMin,
          max: SettingsScreen._scrollbackMax,
          divisions: SettingsScreen._scrollbackDivisions,
          onChanged: (value) {
            ref.read(scrollbackLinesProvider.notifier).state = value.round();
          },
        ),
      ],
    );
  }

  String _formatScrollback(int value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}k lines';
    }
    return '$value lines';
  }
}

// =============================================================================
// Cursor style setting
// =============================================================================

/// Available terminal cursor styles.
enum CursorStyle {
  block('Block', Icons.square_outlined),
  underline('Underline', Icons.horizontal_rule_rounded),
  bar('Bar', Icons.view_column_outlined);

  const CursorStyle(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Provider for the terminal cursor style selection.
final cursorStyleProvider = StateProvider<CursorStyle>(
  (ref) => CursorStyle.block,
);

class _CursorStyleSetting extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(cursorStyleProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cursor Style',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Shape of the terminal cursor',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<CursorStyle>(
          segments: CursorStyle.values
              .map(
                (style) => ButtonSegment<CursorStyle>(
                  value: style,
                  icon: Icon(style.icon, size: 18),
                  label: Text(style.label),
                ),
              )
              .toList(),
          selected: {currentStyle},
          onSelectionChanged: (selection) {
            ref.read(cursorStyleProvider.notifier).state = selection.first;
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStateProperty.all(
              theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Default SSH port setting
// =============================================================================

class _DefaultPortSetting extends StatelessWidget {
  const _DefaultPortSetting({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final port = ref.watch(defaultSshPortProvider);
    final theme = Theme.of(context);

    return _SettingsRow(
      label: 'Default SSH Port',
      description: 'Port used when creating new server connections',
      child: SizedBox(
        width: 100,
        child: TextFormField(
          initialValue: port.toString(),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0 && parsed <= 65535) {
              ref.read(defaultSshPortProvider.notifier).state = parsed;
            }
          },
        ),
      ),
    );
  }
}

// =============================================================================
// Connection timeout setting
// =============================================================================

class _ConnectionTimeoutSetting extends StatelessWidget {
  const _ConnectionTimeoutSetting({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final timeout = ref.watch(connectionTimeoutProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Connection Timeout',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${timeout}s',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Maximum time to wait when establishing an SSH connection',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: timeout.toDouble(),
          min: SettingsScreen._timeoutMin,
          max: SettingsScreen._timeoutMax,
          divisions: SettingsScreen._timeoutDivisions,
          onChanged: (value) {
            ref.read(connectionTimeoutProvider.notifier).state = value.round();
          },
        ),
      ],
    );
  }
}

// =============================================================================
// Hidden files toggle
// =============================================================================

class _HiddenFilesSetting extends StatelessWidget {
  const _HiddenFilesSetting({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final showHidden = ref.watch(showHiddenFilesProvider);

    return _SettingsRow(
      label: 'Show Hidden Files',
      description: 'Display files starting with a dot in the SFTP browser',
      child: Switch(
        value: showHidden,
        onChanged: (value) {
          ref.read(showHiddenFilesProvider.notifier).state = value;
        },
      ),
    );
  }
}

// =============================================================================
// About section
// =============================================================================

/// Displays application branding, version, author, and copyright.
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Section header ----
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'About',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Logo + app info ----
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      width: 72,
                      height: 72,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceSubtle
                          : AppColors.lightOnSurfaceSubtle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A professional SSH console for desktop',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurfaceMuted
                          : AppColors.lightOnSurfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    theme: theme,
                    isDark: isDark,
                    label: 'Author',
                    value: AppConstants.appAuthorEmail,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.appCopyright,
                    style: theme.textTheme.labelSmall?.copyWith(
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
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required bool isDark,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.darkOnSurfaceSubtle
                : AppColors.lightOnSurfaceSubtle,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkOnSurface
                : AppColors.lightOnSurface,
          ),
        ),
      ],
    );
  }
}
