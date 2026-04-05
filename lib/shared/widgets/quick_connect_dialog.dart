import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/presentation/providers/collection_provider.dart';
import 'package:taroshell/features/connections/presentation/providers/server_provider.dart';
import 'package:taroshell/features/connections/presentation/validators/server_form_validators.dart';
import 'package:taroshell/features/terminal/presentation/services/server_connect_coordinator.dart';

/// Authentication options available for a quick-connect session.
///
/// Narrower than [AuthType] because the quick-connect flow only supports
/// password auth or an ad-hoc PEM file from disk.
enum _QuickAuthMode {
  password(AuthType.password, 'Password'),
  keyFile(AuthType.key, 'Key file'),
  keyFileWithPassphrase(AuthType.keyWithPassphrase, 'Key file + passphrase');

  const _QuickAuthMode(this.authType, this.displayName);

  final AuthType authType;
  final String displayName;

  bool get requiresKeyFile => this != _QuickAuthMode.password;
}

/// Lightweight dialog for establishing an ephemeral SSH session without
/// first creating a saved server profile.
///
/// Supports password auth and ad-hoc PEM key files selected at connect time
/// (never persisted). A "Save this connection" checkbox optionally persists
/// the connection as a saved server profile.
class QuickConnectDialog extends ConsumerStatefulWidget {
  const QuickConnectDialog({super.key});

  @override
  ConsumerState<QuickConnectDialog> createState() =>
      _QuickConnectDialogState();
}

class _QuickConnectDialogState extends ConsumerState<QuickConnectDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _labelController;

  _QuickAuthMode _authMode = _QuickAuthMode.password;
  String? _keyFilePath;
  String? _keyFileName;
  bool _saveConnection = false;
  int? _selectedCollectionId;
  bool _isConnecting = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _portController =
        TextEditingController(text: '${AppConstants.defaultSshPort}');
    _usernameController = TextEditingController();
    _labelController = TextEditingController();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _pickKeyFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      dialogTitle: 'Select SSH Private Key',
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _keyFilePath = result.files.single.path;
        _keyFileName = result.files.single.name;
        _inlineError = null;
      });
    }
  }

  Future<void> _handleConnect() async {
    if (!_formKey.currentState!.validate()) return;

    if (_authMode.requiresKeyFile && _keyFilePath == null) {
      setState(() => _inlineError = 'Please select a key file.');
      return;
    }

    if (_saveConnection && _authMode.requiresKeyFile) {
      setState(() => _inlineError =
          "Saving a connection with an ad-hoc key file is not supported. "
          "Import the key first, or leave 'Save' unchecked.");
      return;
    }

    if (_authMode.requiresKeyFile) {
      final file = File(_keyFilePath!);
      if (!await file.exists()) {
        setState(() => _inlineError = 'The selected key file no longer exists.');
        return;
      }
    }

    setState(() {
      _isConnecting = true;
      _inlineError = null;
    });

    try {
      final host = _hostController.text.trim();
      final port = int.parse(_portController.text.trim());
      final username = _usernameController.text.trim();
      final now = DateTime.now();

      // Build the base entity. For saved connections we use the user-supplied
      // label; ephemeral sessions derive a display label from the connection
      // tuple so the tab reads as `user@host:port`.
      final portSuffix =
          port != AppConstants.defaultSshPort ? ':$port' : '';
      final ephemeralLabel = '$username@$host$portSuffix';

      int resolvedId = 0;
      String resolvedLabel = ephemeralLabel;

      if (_saveConnection) {
        final label = _labelController.text.trim();
        final toPersist = ServerEntity(
          id: 0,
          label: label,
          host: host,
          port: port,
          username: username,
          // Only password auth can be saved here (key-file auth is refused
          // above). Passphrase handling for password-based sessions does
          // not affect the stored auth type.
          authType: AuthType.password,
          collectionId: _selectedCollectionId,
          sortOrder: 0,
          isFavorite: false,
          createdAt: now,
          updatedAt: now,
        );
        resolvedId = await ref.read(serverActionsProvider).add(toPersist);
        resolvedLabel = label;
      }

      final server = ServerEntity(
        id: resolvedId,
        label: resolvedLabel,
        host: host,
        port: port,
        username: username,
        authType: _authMode.authType,
        sortOrder: 0,
        isFavorite: false,
        createdAt: now,
        updatedAt: now,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      await connectServer(
        context,
        ref,
        server,
        adHocKeyFilePath: _authMode.requiresKeyFile ? _keyFilePath : null,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _inlineError = 'Failed to start connection: $e';
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(allCollectionsProvider);

    return AlertDialog(
      title: const Text('Quick Connect'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Host + Port ----
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _hostController,
                        decoration: const InputDecoration(
                          labelText: 'Host',
                          hintText: '192.168.1.1 or example.com',
                          prefixIcon: Icon(Icons.dns_outlined, size: 20),
                        ),
                        validator: ServerFormValidators.host,
                        textInputAction: TextInputAction.next,
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                        ),
                        validator: ServerFormValidators.port,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ---- Username ----
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'root',
                    prefixIcon: Icon(Icons.person_outlined, size: 20),
                  ),
                  validator: ServerFormValidators.username,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // ---- Auth mode ----
                DropdownButtonFormField<_QuickAuthMode>(
                  initialValue: _authMode,
                  decoration: const InputDecoration(
                    labelText: 'Authentication',
                    prefixIcon: Icon(Icons.lock_outlined, size: 20),
                  ),
                  items: _QuickAuthMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(mode.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _authMode = value;
                      if (!value.requiresKeyFile) {
                        _keyFilePath = null;
                        _keyFileName = null;
                      }
                      _inlineError = null;
                    });
                  },
                ),

                // ---- Key file picker (conditional) ----
                if (_authMode.requiresKeyFile) ...[
                  const SizedBox(height: 12),
                  _KeyFilePicker(
                    fileName: _keyFileName,
                    onBrowse: _isConnecting ? null : _pickKeyFile,
                  ),
                ],

                const SizedBox(height: 16),

                // ---- Save toggle ----
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Save this connection'),
                  subtitle: const Text(
                    'Persist as a saved server for future use',
                  ),
                  value: _saveConnection,
                  onChanged: _isConnecting
                      ? null
                      : (value) => setState(() {
                            _saveConnection = value ?? false;
                            _inlineError = null;
                          }),
                ),

                // ---- Save fields (conditional) ----
                if (_saveConnection) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      hintText: 'My Production Server',
                      prefixIcon: Icon(Icons.label_outlined, size: 20),
                    ),
                    validator: _saveConnection
                        ? ServerFormValidators.label
                        : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  collections.when(
                    data: (items) => DropdownButtonFormField<int?>(
                      initialValue: _selectedCollectionId,
                      decoration: const InputDecoration(
                        labelText: 'Collection',
                        prefixIcon: Icon(Icons.folder_outlined, size: 20),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('None (ungrouped)'),
                        ),
                        ...items.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedCollectionId = value),
                    ),
                    loading: () => const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Collection',
                        prefixIcon: Icon(Icons.folder_outlined, size: 20),
                      ),
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, _) => const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Collection',
                        prefixIcon: Icon(Icons.folder_outlined, size: 20),
                      ),
                      child: Text('Failed to load collections'),
                    ),
                  ),
                ],

                // ---- Inline error ----
                if (_inlineError != null) ...[
                  const SizedBox(height: 12),
                  _InlineErrorBanner(message: _inlineError!),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isConnecting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isConnecting ? null : _handleConnect,
          child: _isConnecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Connect'),
        ),
      ],
    );
  }
}

/// Read-only display for the selected PEM file path with a Browse action.
class _KeyFilePicker extends StatelessWidget {
  const _KeyFilePicker({
    required this.fileName,
    required this.onBrowse,
  });

  final String? fileName;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = fileName != null;

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Key file',
        prefixIcon: Icon(Icons.vpn_key_outlined, size: 20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasFile ? fileName! : 'No file selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: hasFile
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.folder_open_outlined, size: 18),
            label: Text(hasFile ? 'Change' : 'Browse'),
          ),
        ],
      ),
    );
  }
}

/// Subtle inline banner used to surface validation or precondition errors
/// inside the dialog without triggering a snackbar on the parent screen.
class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
