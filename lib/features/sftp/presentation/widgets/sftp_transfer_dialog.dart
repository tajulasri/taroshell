import 'dart:async';

import 'package:flutter/material.dart';

import 'package:taroshell/core/theme/app_colors.dart';

/// Dialog that displays the progress of a file transfer (upload or download).
///
/// Shows:
/// - The file name being transferred
/// - A progress bar with percentage
/// - Transfer speed (computed from elapsed time and bytes transferred)
/// - A cancel button that invokes the [onCancel] callback
///
/// Auto-closes after a brief delay when transfer completes.
class SftpTransferDialog extends StatefulWidget {
  const SftpTransferDialog({
    super.key,
    required this.fileName,
    required this.isUpload,
    required this.onCancel,
  });

  /// The name of the file being transferred.
  final String fileName;

  /// Whether this is an upload (true) or download (false).
  final bool isUpload;

  /// Callback invoked when the user cancels the transfer.
  final VoidCallback onCancel;

  @override
  State<SftpTransferDialog> createState() => SftpTransferDialogState();
}

class SftpTransferDialogState extends State<SftpTransferDialog> {
  int _transferred = 0;
  int _total = 0;
  bool _isComplete = false;
  DateTime? _startTime;

  /// The auto-close delay after transfer completes.
  static const Duration _autoCloseDuration = Duration(milliseconds: 800);

  /// Updates the progress displayed in the dialog.
  ///
  /// Should be called from the parent via a [GlobalKey] reference.
  void updateProgress(int transferred, int total) {
    if (!mounted) return;
    _startTime ??= DateTime.now();
    setState(() {
      _transferred = transferred;
      _total = total;
    });

    if (total > 0 && transferred >= total && !_isComplete) {
      _isComplete = true;
      Timer(_autoCloseDuration, () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  double get _progress {
    if (_total <= 0) return 0;
    return (_transferred / _total).clamp(0.0, 1.0);
  }

  String get _percentage {
    return '${(_progress * 100).toStringAsFixed(1)}%';
  }

  String get _transferSpeed {
    if (_startTime == null || _transferred == 0) return '';
    final elapsed = DateTime.now().difference(_startTime!);
    if (elapsed.inMilliseconds == 0) return '';

    final bytesPerSecond = _transferred / elapsed.inMilliseconds * 1000;
    return _formatSpeed(bytesPerSecond);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isUpload ? Icons.upload_outlined : Icons.download_outlined,
            size: 20,
            color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isUpload ? 'Uploading' : 'Downloading',
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: _kDialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File name
            Text(
              widget.fileName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(_kProgressBarRadius),
              child: LinearProgressIndicator(
                value: _total > 0 ? _progress : null,
                minHeight: _kProgressBarHeight,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                valueColor: AlwaysStoppedAnimation(
                  _isComplete
                      ? AppColors.connected
                      : (isDark ? AppColors.darkAccent : AppColors.lightAccent),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Status line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isComplete
                      ? 'Complete'
                      : '$_percentage  ${_formatBytes(_transferred)} / ${_formatBytes(_total)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurface.withValues(alpha: 0.6)
                        : AppColors.lightOnSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                if (_transferSpeed.isNotEmpty)
                  Text(
                    _transferSpeed,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface.withValues(alpha: 0.6)
                          : AppColors.lightOnSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        if (!_isComplete)
          TextButton(
            onPressed: () {
              widget.onCancel();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Formatting helpers
  // ---------------------------------------------------------------------------

  static const int _kibibyte = 1024;
  static const int _mebibyte = 1024 * 1024;
  static const int _gibibyte = 1024 * 1024 * 1024;

  static String _formatBytes(int bytes) {
    if (bytes < _kibibyte) return '$bytes B';
    if (bytes < _mebibyte) return '${(bytes / _kibibyte).toStringAsFixed(1)} KB';
    if (bytes < _gibibyte) return '${(bytes / _mebibyte).toStringAsFixed(1)} MB';
    return '${(bytes / _gibibyte).toStringAsFixed(1)} GB';
  }

  static String _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < _kibibyte) return '${bytesPerSecond.toStringAsFixed(0)} B/s';
    if (bytesPerSecond < _mebibyte) {
      return '${(bytesPerSecond / _kibibyte).toStringAsFixed(1)} KB/s';
    }
    if (bytesPerSecond < _gibibyte) {
      return '${(bytesPerSecond / _mebibyte).toStringAsFixed(1)} MB/s';
    }
    return '${(bytesPerSecond / _gibibyte).toStringAsFixed(1)} GB/s';
  }

  // ---------------------------------------------------------------------------
  // Layout constants
  // ---------------------------------------------------------------------------

  static const double _kDialogWidth = 360;
  static const double _kProgressBarHeight = 6;
  static const double _kProgressBarRadius = 3;
}
