import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';

import 'package:taroshell/features/connections/presentation/providers/collection_provider.dart';
import 'package:taroshell/features/connections/presentation/validators/server_form_validators.dart';
import 'package:taroshell/features/connections/presentation/providers/server_provider.dart';
import 'package:taroshell/features/keys/presentation/providers/key_provider.dart';

/// Dialog for adding or editing an SSH server connection profile.
///
/// Displays a form with fields for label, host, port, username, auth type,
/// SSH key selection, collection assignment, and notes. Validates all inputs
/// before submission.
///
/// Usage:
/// ```dart
/// final result = await ServerFormDialog.show(context, ref);
/// // result is the new server ID, or null if cancelled.
/// ```
class ServerFormDialog extends ConsumerStatefulWidget {
  const ServerFormDialog({
    super.key,
    this.existingServer,
    this.initialCollectionId,
  });

  /// If provided, the dialog operates in edit mode pre-populated with
  /// the server's current values.
  final ServerEntity? existingServer;

  /// If provided and not in edit mode, pre-selects this collection in the
  /// collection dropdown.
  final int? initialCollectionId;

  /// Shows the dialog and returns the resulting server ID or `null`.
  static Future<int?> show(
    BuildContext context,
    WidgetRef ref, {
    ServerEntity? existingServer,
    int? initialCollectionId,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServerFormDialog(
        existingServer: existingServer,
        initialCollectionId: initialCollectionId,
      ),
    );
  }

  @override
  ConsumerState<ServerFormDialog> createState() => _ServerFormDialogState();
}

class _ServerFormDialogState extends ConsumerState<ServerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _notesController;

  AuthType _selectedAuthType = AuthType.password;
  int? _selectedSshKeyId;
  int? _selectedCollectionId;
  bool _isSaving = false;

  bool get _isEditMode => widget.existingServer != null;

  @override
  void initState() {
    super.initState();
    final server = widget.existingServer;

    _labelController = TextEditingController(text: server?.label ?? '');
    _hostController = TextEditingController(text: server?.host ?? '');
    _portController = TextEditingController(
      text: '${server?.port ?? AppConstants.defaultSshPort}',
    );
    _usernameController = TextEditingController(text: server?.username ?? '');
    _notesController = TextEditingController(text: server?.notes ?? '');

    if (server != null) {
      _selectedAuthType = server.authType;
      _selectedSshKeyId = server.sshKeyId;
      _selectedCollectionId = server.collectionId;
    } else if (widget.initialCollectionId != null) {
      _selectedCollectionId = widget.initialCollectionId;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Submission
  // ---------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final actions = ref.read(serverActionsProvider);
      final now = DateTime.now();

      final server = ServerEntity(
        id: widget.existingServer?.id ?? 0,
        label: _labelController.text.trim(),
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        username: _usernameController.text.trim(),
        authType: _selectedAuthType,
        sshKeyId: _requiresKeySelection ? _selectedSshKeyId : null,
        collectionId: _selectedCollectionId,
        sortOrder: widget.existingServer?.sortOrder ?? 0,
        isFavorite: widget.existingServer?.isFavorite ?? false,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.existingServer?.createdAt ?? now,
        updatedAt: now,
      );

      final int resultId;
      if (_isEditMode) {
        await actions.update(server);
        resultId = server.id;
      } else {
        resultId = await actions.add(server);
      }

      if (mounted) {
        Navigator.of(context).pop(resultId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save server: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool get _requiresKeySelection =>
      _selectedAuthType == AuthType.key ||
      _selectedAuthType == AuthType.keyWithPassphrase;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(allCollectionsProvider);
    final sshKeys = ref.watch(allKeysProvider);

    return AlertDialog(
      title: Text(_isEditMode ? 'Edit Server' : 'Add Server'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- Label ----
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label',
                    hintText: 'My Production Server',
                    prefixIcon: Icon(Icons.label_outlined, size: 20),
                  ),
                  validator: ServerFormValidators.label,
                  textInputAction: TextInputAction.next,
                  autofocus: !_isEditMode,
                ),
                const SizedBox(height: 16),

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

                // ---- Auth Type ----
                DropdownButtonFormField<AuthType>(
                  initialValue: _selectedAuthType,
                  decoration: const InputDecoration(
                    labelText: 'Authentication',
                    prefixIcon: Icon(Icons.lock_outlined, size: 20),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AuthType.password,
                      child: Text('Password'),
                    ),
                    DropdownMenuItem(
                      value: AuthType.key,
                      child: Text('SSH Key'),
                    ),
                    DropdownMenuItem(
                      value: AuthType.keyWithPassphrase,
                      child: Text('SSH Key + Passphrase'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAuthType = value;
                        if (!_requiresKeySelection) {
                          _selectedSshKeyId = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // ---- SSH Key selector (conditional) ----
                if (_requiresKeySelection) ...[
                  sshKeys.when(
                    data: (keys) {
                      // Reset selection if the previously selected key
                      // no longer exists (e.g. deleted and re-imported).
                      final validKeyIds = keys.map((k) => k.id).toSet();
                      final effectiveKeyId = validKeyIds.contains(_selectedSshKeyId)
                          ? _selectedSshKeyId
                          : null;

                      if (effectiveKeyId != _selectedSshKeyId) {
                        // Schedule a post-frame update to avoid setState
                        // during build.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedSshKeyId = effectiveKeyId);
                          }
                        });
                      }

                      return DropdownButtonFormField<int?>(
                        initialValue: effectiveKeyId,
                        decoration: const InputDecoration(
                          labelText: 'SSH Key',
                          prefixIcon: Icon(Icons.vpn_key_outlined, size: 20),
                        ),
                        items: keys
                            .map(
                              (key) => DropdownMenuItem<int?>(
                                value: key.id,
                                child: Text(
                                  '${key.label} (${key.keyTypeDisplayName})',
                                ),
                              ),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an SSH key';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() => _selectedSshKeyId = value);
                        },
                      );
                    },
                    loading: () => const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'SSH Key',
                        prefixIcon: Icon(Icons.vpn_key_outlined, size: 20),
                      ),
                      child: LinearProgressIndicator(),
                    ),
                    error: (_, __) => const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'SSH Key',
                        prefixIcon: Icon(Icons.vpn_key_outlined, size: 20),
                      ),
                      child: Text('Failed to load SSH keys'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ---- Collection selector ----
                collections.when(
                  data: (items) => DropdownButtonFormField<int?>(
                    initialValue: _selectedCollectionId,
                    decoration: const InputDecoration(
                      labelText: 'Collection',
                      prefixIcon:
                          Icon(Icons.folder_outlined, size: 20),
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
                    onChanged: (value) {
                      setState(() => _selectedCollectionId = value);
                    },
                  ),
                  loading: () => const InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Collection',
                      prefixIcon: Icon(Icons.folder_outlined, size: 20),
                    ),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Collection',
                      prefixIcon: Icon(Icons.folder_outlined, size: 20),
                    ),
                    child: Text('Failed to load collections'),
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Notes ----
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any additional notes about this server...',
                    prefixIcon: Icon(Icons.notes_outlined, size: 20),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSubmit,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditMode ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
