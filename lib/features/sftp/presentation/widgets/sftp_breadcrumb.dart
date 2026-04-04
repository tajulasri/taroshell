import 'package:flutter/material.dart';

import 'package:taroshell/core/theme/app_colors.dart';

/// Breadcrumb navigation bar for the SFTP file browser.
///
/// Displays the current path as a series of clickable segments,
/// allowing the user to jump to any ancestor directory. A leading
/// home icon navigates to the root or home directory.
class SftpBreadcrumb extends StatelessWidget {
  const SftpBreadcrumb({
    super.key,
    required this.currentPath,
    required this.onNavigate,
    required this.onHome,
  });

  /// The current absolute remote path.
  final String currentPath;

  /// Callback invoked when a path segment is tapped.
  /// Receives the absolute path up to and including the tapped segment.
  final ValueChanged<String> onNavigate;

  /// Callback invoked when the home icon is tapped.
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final segments = _buildSegments();

    return Container(
      height: _kBreadcrumbHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildHomeButton(isDark, theme),
          const SizedBox(width: 4),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildBreadcrumbChips(segments, isDark, theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget builders
  // ---------------------------------------------------------------------------

  Widget _buildHomeButton(bool isDark, ThemeData theme) {
    return InkWell(
      onTap: onHome,
      borderRadius: BorderRadius.circular(_kChipBorderRadius),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.home_outlined,
          size: _kIconSize,
          color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        ),
      ),
    );
  }

  List<Widget> _buildBreadcrumbChips(
    List<_PathSegment> segments,
    bool isDark,
    ThemeData theme,
  ) {
    final widgets = <Widget>[];
    final textColor = isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final activeColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final separatorColor = textColor.withValues(alpha: 0.3);

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isLast = i == segments.length - 1;

      // Separator
      if (i > 0) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.chevron_right,
              size: _kSeparatorSize,
              color: separatorColor,
            ),
          ),
        );
      }

      // Segment chip
      widgets.add(
        InkWell(
          onTap: isLast ? null : () => onNavigate(segment.path),
          borderRadius: BorderRadius.circular(_kChipBorderRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: isLast
                ? BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(_kChipBorderRadius),
                  )
                : null,
            child: Text(
              segment.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isLast ? activeColor : textColor.withValues(alpha: 0.7),
                fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // Path parsing
  // ---------------------------------------------------------------------------

  List<_PathSegment> _buildSegments() {
    final parts = currentPath.split('/').where((p) => p.isNotEmpty).toList();
    final segments = <_PathSegment>[
      const _PathSegment(label: '/', path: '/'),
    ];

    for (var i = 0; i < parts.length; i++) {
      final path = '/${parts.sublist(0, i + 1).join('/')}';
      segments.add(_PathSegment(label: parts[i], path: path));
    }

    return segments;
  }

  // ---------------------------------------------------------------------------
  // Layout constants
  // ---------------------------------------------------------------------------

  static const double _kBreadcrumbHeight = 34;
  static const double _kIconSize = 16;
  static const double _kSeparatorSize = 14;
  static const double _kChipBorderRadius = 4;
}

/// A single segment of the breadcrumb path.
class _PathSegment {
  const _PathSegment({
    required this.label,
    required this.path,
  });

  /// Display label for this segment.
  final String label;

  /// Absolute path up to and including this segment.
  final String path;
}
