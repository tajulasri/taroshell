import 'package:flutter/material.dart';
import 'package:taroshell/core/theme/app_colors.dart';

/// Represents the possible states of an SSH connection.
enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
}

/// A compact badge widget displaying the current connection status.
///
/// Visual states:
/// - [ConnectionStatus.connected]: green dot with "Connected" label.
/// - [ConnectionStatus.disconnected]: gray dot, no label.
/// - [ConnectionStatus.connecting]: animated pulsing dot.
class ConnectionStatusBadge extends StatefulWidget {
  const ConnectionStatusBadge({
    super.key,
    required this.status,
    this.showLabel = false,
  });

  /// The current connection status to display.
  final ConnectionStatus status;

  /// Whether to show a text label beside the indicator dot.
  final bool showLabel;

  @override
  State<ConnectionStatusBadge> createState() => _ConnectionStatusBadgeState();
}

class _ConnectionStatusBadgeState extends State<ConnectionStatusBadge>
    with SingleTickerProviderStateMixin {
  static const int _pulseAnimationDurationMs = 1200;

  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimationIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ConnectionStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _setupAnimationIfNeeded();
    }
  }

  void _setupAnimationIfNeeded() {
    if (widget.status == ConnectionStatus.connecting) {
      _pulseController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _pulseAnimationDurationMs),
      );
      _pulseAnimation ??= Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _pulseController!,
          curve: Curves.easeInOut,
        ),
      );
      _pulseController!.repeat(reverse: true);
    } else {
      _pulseController?.stop();
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Color _dotColor() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return AppColors.connected;
      case ConnectionStatus.disconnected:
        return AppColors.disconnected;
      case ConnectionStatus.connecting:
        return AppColors.warning;
    }
  }

  String _label() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Offline';
      case ConnectionStatus.connecting:
        return 'Connecting';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _dotColor();

    final Widget dot;
    if (widget.status == ConnectionStatus.connecting &&
        _pulseAnimation != null) {
      dot = AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: _pulseAnimation!.value),
            ),
          );
        },
      );
    } else {
      dot = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
    }

    if (!widget.showLabel) {
      return dot;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          _label(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
