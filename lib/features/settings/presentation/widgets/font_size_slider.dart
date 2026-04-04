import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/settings/presentation/providers/settings_provider.dart';

/// Slider widget for adjusting the terminal font size with a live preview.
///
/// Displays the current value, snaps to whole numbers, and renders a
/// preview string in the selected terminal font at the chosen size.
class FontSizeSlider extends ConsumerWidget {
  const FontSizeSlider({super.key});

  static const String _previewText = r'user@server:~$ ls -la';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(fontSizeProvider);
    final fontFamily = ref.watch(terminalFontFamilyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Label and current value ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Font Size',
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
                '${fontSize.round()} px',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ---- Slider ----
        Row(
          children: [
            Text(
              '${AppConstants.minFontSize.round()}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Expanded(
              child: Slider(
                value: fontSize,
                min: AppConstants.minFontSize,
                max: AppConstants.maxFontSize,
                divisions: (AppConstants.maxFontSize - AppConstants.minFontSize)
                    .round(),
                onChanged: (value) {
                  ref.read(fontSizeProvider.notifier).state =
                      value.roundToDouble();
                },
              ),
            ),
            Text(
              '${AppConstants.maxFontSize.round()}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ---- Live preview ----
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackground
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Text(
            _previewText,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              color: isDark
                  ? AppColors.darkOnBackground
                  : AppColors.lightOnBackground,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
