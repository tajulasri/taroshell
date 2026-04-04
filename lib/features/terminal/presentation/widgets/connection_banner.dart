import 'dart:async';

import 'package:flutter/material.dart';

import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';

/// Compact banner displayed above the terminal view showing connection
/// metadata: user@host:port, session uptime, and a reconnect button
/// when the session is disconnected.
class ConnectionBanner extends StatefulWidget {
  const ConnectionBanner({
    super.key,
    required this.session,
    this.onReconnect,
  });

  /// The active session whose metadata is displayed.
  final TerminalSession session;

  /// Callback invoked when the user requests a reconnection.
  final VoidCallback? onReconnect;

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner> {
  Timer? _uptimeTimer;

  @override
  void initState() {
    super.initState();
    // Refresh the uptime display every second.
    _uptimeTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _uptimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final session = widget.session;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.6)
            : AppColors.lightSurfaceVariant.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection status dot
          Icon(
            Icons.circle,
            size: 8,
            color: session.isConnected
                ? AppColors.connected
                : AppColors.disconnected,
          ),
          const SizedBox(width: 8),

          // user@host:port
          Text(
            session.connectionString,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkOnSurface
                  : AppColors.lightOnSurface,
            ),
          ),

          const SizedBox(width: 16),

          // Uptime
          Text(
            session.formattedUptime,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface.withValues(alpha: 0.6)
                  : AppColors.lightOnSurface.withValues(alpha: 0.6),
            ),
          ),

          const Spacer(),

          // Reconnect button (shown only when disconnected)
          if (!session.isConnected && widget.onReconnect != null)
            TextButton.icon(
              onPressed: widget.onReconnect,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Reconnect'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
