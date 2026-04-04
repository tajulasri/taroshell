import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/keys/domain/entities/ssh_key.dart';
import 'package:taroshell/features/keys/presentation/providers/key_provider.dart';
import 'package:taroshell/features/keys/presentation/widgets/generate_key_dialog.dart';
import 'package:taroshell/features/keys/presentation/widgets/import_key_dialog.dart';
import 'package:taroshell/features/keys/presentation/widgets/key_list_tile.dart';

/// UI strings used throughout the key management screen.
abstract final class _ScreenStrings {
  static const String title = 'SSH Key Management';
  static const String subtitle = 'Generate, import, and manage your SSH keys';
  static const String generateButton = 'Generate New Key';
  static const String importButton = 'Import Key';
  static const String emptyStateTitle = 'No SSH Keys';
  static const String emptyStateSubtitle =
      'Generate a new key or import an existing one to get started.';
  static const String errorPrefix = 'Failed to load keys';
  static const String deleteConfirmTitle = 'Delete SSH Key';
  static const String deleteConfirmMessage =
      'Are you sure you want to permanently delete this key? '
      'Servers using this key will no longer be able to authenticate.';
  static const String deleteButton = 'Delete';
  static const String cancelButton = 'Cancel';
  static const String publicKeyCopied = 'Public key copied to clipboard';
}

/// SSH key management screen for generating, importing, and managing keys.
///
/// Displays a list of all stored SSH keys with actions for copying public
/// keys, exporting, and deleting. Provides dialogs for generating new keys
/// and importing existing PEM files.
class KeyManagementScreen extends ConsumerWidget {
  const KeyManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keysAsync = ref.watch(allKeysProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, theme, isDark, ref),
          const SizedBox(height: 24),

          // Key list
          Expanded(
            child: keysAsync.when(
              data: (keys) => keys.isEmpty
                  ? _buildEmptyState(theme, isDark)
                  : _buildKeyList(context, ref, keys),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => _buildErrorState(theme, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        // Title section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ScreenStrings.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _ScreenStrings.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkOnSurface.withValues(alpha: 0.6)
                      : AppColors.lightOnSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        // Action buttons
        OutlinedButton.icon(
          onPressed: () => _showImportDialog(context),
          icon: const Icon(Icons.file_upload_outlined, size: 18),
          label: const Text(_ScreenStrings.importButton),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showGenerateDialog(context),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text(_ScreenStrings.generateButton),
        ),
      ],
    );
  }

  Widget _buildKeyList(
    BuildContext context,
    WidgetRef ref,
    List<SshKeyEntity> keys,
  ) {
    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        return KeyListTile(
          keyEntity: key,
          onCopyPublicKey: () => _handleCopyPublicKey(context, key),
          onDelete: () => _showDeleteConfirmation(context, ref, key),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.vpn_key_off_rounded,
            size: 64,
            color: isDark
                ? AppColors.darkOnSurface.withValues(alpha: 0.2)
                : AppColors.lightOnSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _ScreenStrings.emptyStateTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkOnSurface.withValues(alpha: 0.5)
                  : AppColors.lightOnSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _ScreenStrings.emptyStateSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkOnSurface.withValues(alpha: 0.4)
                  : AppColors.lightOnSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            _ScreenStrings.errorPrefix,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _showGenerateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const GenerateKeyDialog(),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ImportKeyDialog(),
    );
  }

  void _handleCopyPublicKey(BuildContext context, SshKeyEntity key) {
    Clipboard.setData(ClipboardData(text: key.publicKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_ScreenStrings.publicKeyCopied),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    SshKeyEntity key,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(_ScreenStrings.deleteConfirmTitle),
        content: Text(
          '${_ScreenStrings.deleteConfirmMessage}\n\nKey: ${key.label}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(_ScreenStrings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(deleteKeyProvider(key.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(_ScreenStrings.deleteButton),
          ),
        ],
      ),
    );
  }
}
