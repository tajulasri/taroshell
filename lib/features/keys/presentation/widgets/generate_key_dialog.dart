import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/keys/domain/entities/ssh_key.dart';
import 'package:taroshell/features/keys/presentation/providers/key_provider.dart';

/// Labels and messages used in the generate key dialog.
abstract final class _GenerateDialogStrings {
  static const String title = 'Generate New SSH Key';
  static const String labelFieldHint = 'Key name (e.g. My Server Key)';
  static const String labelFieldLabel = 'Label';
  static const String keyTypeLabel = 'Key Type';
  static const String generateButton = 'Generate';
  static const String cancelButton = 'Cancel';
  static const String closeButton = 'Close';
  static const String copyButton = 'Copy Public Key';
  static const String copiedMessage = 'Public key copied to clipboard';

  static const String successTitle = 'Key Generated Successfully';
  static const String publicKeyLabel = 'Public Key';
  static const String labelRequired = 'Please enter a label for the key';
  static const String recommendedSuffix = ' (Recommended)';
}

/// Key type option model for the dropdown selector.
class _KeyTypeOption {
  const _KeyTypeOption({
    required this.keyType,
    required this.displayName,
    this.isRecommended = false,
  });

  final KeyType keyType;
  final String displayName;
  final bool isRecommended;
}

/// Available key type options.
const List<_KeyTypeOption> _keyTypeOptions = [
  _KeyTypeOption(
    keyType: KeyType.ed25519,
    displayName: 'Ed25519',
    isRecommended: true,
  ),
  _KeyTypeOption(
    keyType: KeyType.rsa4096,
    displayName: 'RSA 4096',
  ),
  _KeyTypeOption(
    keyType: KeyType.rsa2048,
    displayName: 'RSA 2048',
  ),
];

/// Dialog for generating a new SSH key pair.
///
/// Allows the user to specify a label and key type, then generates the
/// key in a background isolate. On success, displays the public key with
/// a copy-to-clipboard action.
class GenerateKeyDialog extends ConsumerStatefulWidget {
  const GenerateKeyDialog({super.key});

  @override
  ConsumerState<GenerateKeyDialog> createState() => _GenerateKeyDialogState();
}

class _GenerateKeyDialogState extends ConsumerState<GenerateKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  KeyType _selectedKeyType = KeyType.ed25519;
  bool _isGenerating = false;
  SshKeyEntity? _generatedKey;
  String? _errorMessage;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final params = GenerateKeyParams(
        label: _labelController.text.trim(),
        keyType: _selectedKeyType,
      );

      final result = await ref.read(
        generateKeyProvider(params).future,
      );

      if (mounted) {
        setState(() {
          _generatedKey = result;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isGenerating = false;
        });
      }
    }
  }

  void _handleCopyPublicKey() {
    if (_generatedKey == null) return;

    Clipboard.setData(ClipboardData(text: _generatedKey!.publicKey));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(_GenerateDialogStrings.copiedMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _generatedKey != null
              ? _buildSuccessContent(theme, isDark)
              : _buildFormContent(theme, isDark),
        ),
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          _GenerateDialogStrings.title,
          style: theme.dialogTheme.titleTextStyle,
        ),
        const SizedBox(height: 20),

        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label field
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: _GenerateDialogStrings.labelFieldLabel,
                  hintText: _GenerateDialogStrings.labelFieldHint,
                ),
                autofocus: true,
                enabled: !_isGenerating,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _GenerateDialogStrings.labelRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Key type selector
              Text(
                _GenerateDialogStrings.keyTypeLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildKeyTypeSelector(theme, isDark),
            ],
          ),
        ),

        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isGenerating ? null : () => Navigator.pop(context),
              child: const Text(_GenerateDialogStrings.cancelButton),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isGenerating ? null : _handleGenerate,
              child: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(_GenerateDialogStrings.generateButton),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyTypeSelector(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _keyTypeOptions.map((option) {
        final isSelected = _selectedKeyType == option.keyType;
        final borderColor = isSelected
            ? theme.colorScheme.primary
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

        return InkWell(
          onTap: _isGenerating
              ? null
              : () => setState(() => _selectedKeyType = option.keyType),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
            ),
            child: Text(
              option.isRecommended
                  ? '${option.displayName}${_GenerateDialogStrings.recommendedSuffix}'
                  : option.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSuccessContent(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success header
        Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.connected,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              _GenerateDialogStrings.successTitle,
              style: theme.dialogTheme.titleTextStyle,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Public key label
        Text(
          _GenerateDialogStrings.publicKeyLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Public key display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: SelectableText(
            _generatedKey!.publicKey,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppConstants.defaultTerminalFontFamily,
              fontSize: 11,
            ),
            maxLines: 4,
          ),
        ),
        const SizedBox(height: 20),

        // Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: _handleCopyPublicKey,
              icon: const Icon(Icons.content_copy_rounded, size: 16),
              label: const Text(_GenerateDialogStrings.copyButton),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(_GenerateDialogStrings.closeButton),
            ),
          ],
        ),
      ],
    );
  }
}
