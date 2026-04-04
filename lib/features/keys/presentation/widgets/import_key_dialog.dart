import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/keys/presentation/providers/key_provider.dart';

/// Labels and messages used in the import key dialog.
abstract final class _ImportDialogStrings {
  static const String title = 'Import SSH Private Key';
  static const String labelFieldLabel = 'Label';
  static const String labelFieldHint = 'Key name (e.g. Imported Server Key)';
  static const String labelRequired = 'Please enter a label for the key';
  static const String selectFileButton = 'Select PEM File';
  static const String changeFileButton = 'Change File';
  static const String noFileSelected = 'No file selected';
  static const String fileRequired = 'Please select a private key file';
  static const String importButton = 'Import';
  static const String cancelButton = 'Cancel';

  static const String successMessage = 'SSH key imported successfully';
  static const String fileLabel = 'Private Key File';
}

/// Allowed file extensions for PEM key files (validated after selection).
///
/// Uses [FileType.any] at the picker level because SSH private keys commonly
/// have no extension (e.g. `~/.ssh/id_rsa`, `~/.ssh/id_ed25519`) and reside
/// in hidden directories. Extension-based filtering would prevent users from
/// selecting these files. Format validation occurs during import instead.

/// Dialog for importing an existing SSH private key from a PEM file.
///
/// Provides a file picker for selecting the key file, validates the format,
/// encrypts the private key, and persists the imported key to the database.
class ImportKeyDialog extends ConsumerStatefulWidget {
  const ImportKeyDialog({super.key});

  @override
  ConsumerState<ImportKeyDialog> createState() => _ImportKeyDialogState();
}

class _ImportKeyDialogState extends ConsumerState<ImportKeyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handleSelectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: _ImportDialogStrings.title,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleImport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFilePath == null) {
      setState(() {
        _errorMessage = _ImportDialogStrings.fileRequired;
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final params = ImportKeyParams(
        label: _labelController.text.trim(),
        filePath: _selectedFilePath!,
      );

      await ref.read(importKeyProvider(params).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_ImportDialogStrings.successMessage),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _ImportDialogStrings.title,
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
                        labelText: _ImportDialogStrings.labelFieldLabel,
                        hintText: _ImportDialogStrings.labelFieldHint,
                      ),
                      autofocus: true,
                      enabled: !_isImporting,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return _ImportDialogStrings.labelRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // File picker section
                    Text(
                      _ImportDialogStrings.fileLabel,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilePicker(theme, isDark),
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
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isImporting ? null : () => Navigator.pop(context),
                    child: const Text(_ImportDialogStrings.cancelButton),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isImporting ? null : _handleImport,
                    child: _isImporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(_ImportDialogStrings.importButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker(ThemeData theme, bool isDark) {
    final hasFile = _selectedFilePath != null;

    return Container(
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
      child: Row(
        children: [
          Icon(
            hasFile ? Icons.description_outlined : Icons.upload_file_rounded,
            size: 20,
            color: hasFile
                ? AppColors.connected
                : (isDark
                    ? AppColors.darkOnSurface.withValues(alpha: 0.5)
                    : AppColors.lightOnSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasFile
                  ? _selectedFileName ?? _selectedFilePath!
                  : _ImportDialogStrings.noFileSelected,
              style: theme.textTheme.bodySmall?.copyWith(
                color: hasFile
                    ? theme.colorScheme.onSurface
                    : (isDark
                        ? AppColors.darkOnSurface.withValues(alpha: 0.5)
                        : AppColors.lightOnSurface.withValues(alpha: 0.5)),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _isImporting ? null : _handleSelectFile,
            child: Text(
              hasFile
                  ? _ImportDialogStrings.changeFileButton
                  : _ImportDialogStrings.selectFileButton,
            ),
          ),
        ],
      ),
    );
  }
}
