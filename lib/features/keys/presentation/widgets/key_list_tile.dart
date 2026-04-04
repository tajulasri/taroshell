import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/keys/domain/entities/ssh_key.dart';

/// Display constants for key list tiles.
abstract final class _KeyTileConstants {
  static const double iconSize = 36.0;
  static const double badgeFontSize = 10.0;
  static const double badgePaddingHorizontal = 8.0;
  static const double badgePaddingVertical = 3.0;
  static const double badgeBorderRadius = 6.0;
  static const int fingerprintMaxLength = 32;
  static const String dateFormat = 'dd MMM yyyy';
}

/// A list tile displaying an SSH key's metadata with contextual actions.
///
/// Shows the key label, type badge, truncated fingerprint, creation date,
/// and provides actions for copying the public key and deleting the key.
class KeyListTile extends StatelessWidget {
  const KeyListTile({
    super.key,
    required this.keyEntity,
    required this.onCopyPublicKey,
    required this.onDelete,
  });

  /// The SSH key entity to display.
  final SshKeyEntity keyEntity;

  /// Callback invoked when the user copies the public key.
  final VoidCallback onCopyPublicKey;

  /// Callback invoked when the user requests key deletion.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormatter = DateFormat(_KeyTileConstants.dateFormat);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Key type icon
            _buildKeyIcon(isDark),
            const SizedBox(width: 14),

            // Key details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label and badge row
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          keyEntity.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildKeyTypeBadge(theme, isDark),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Fingerprint
                  Text(
                    _truncatedFingerprint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkOnSurface.withValues(alpha: 0.6)
                          : AppColors.lightOnSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Created date
                  Text(
                    'Created ${dateFormatter.format(keyEntity.createdAt)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkOnSurface.withValues(alpha: 0.4)
                          : AppColors.lightOnSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  /// Returns the appropriate icon for the key type.
  Widget _buildKeyIcon(bool isDark) {
    final isEd25519 = keyEntity.keyType == KeyType.ed25519;

    return Container(
      width: _KeyTileConstants.iconSize,
      height: _KeyTileConstants.iconSize,
      decoration: BoxDecoration(
        color: (isEd25519 ? AppColors.connected : AppColors.info)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isEd25519 ? Icons.enhanced_encryption_rounded : Icons.key_rounded,
        size: 20,
        color: isEd25519 ? AppColors.connected : AppColors.info,
      ),
    );
  }

  /// Builds the key type badge (e.g. "Ed25519", "RSA 4096").
  Widget _buildKeyTypeBadge(ThemeData theme, bool isDark) {
    final isEd25519 = keyEntity.keyType == KeyType.ed25519;
    final badgeColor = isEd25519 ? AppColors.connected : AppColors.info;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _KeyTileConstants.badgePaddingHorizontal,
        vertical: _KeyTileConstants.badgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius:
            BorderRadius.circular(_KeyTileConstants.badgeBorderRadius),
      ),
      child: Text(
        keyEntity.keyTypeDisplayName,
        style: TextStyle(
          fontSize: _KeyTileConstants.badgeFontSize,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  /// The fingerprint, truncated for display with an ellipsis.
  String get _truncatedFingerprint {
    final fp = keyEntity.fingerprint;
    if (fp.length <= _KeyTileConstants.fingerprintMaxLength) return fp;
    return '${fp.substring(0, _KeyTileConstants.fingerprintMaxLength)}...';
  }

  /// Builds the copy and delete action buttons.
  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Copy public key',
          child: IconButton(
            icon: const Icon(Icons.content_copy_rounded, size: 18),
            onPressed: onCopyPublicKey,
            splashRadius: 18,
            visualDensity: VisualDensity.compact,
          ),
        ),
        Tooltip(
          message: 'Delete key',
          child: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.error.withValues(alpha: 0.8),
            ),
            onPressed: onDelete,
            splashRadius: 18,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}
