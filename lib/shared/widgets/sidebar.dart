import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/router/app_router.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/core/theme/app_colors.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/connections/domain/entities/server_collection.dart';
import 'package:taroshell/features/connections/presentation/providers/collection_provider.dart';
import 'package:taroshell/features/connections/presentation/providers/server_provider.dart';
import 'package:taroshell/features/connections/presentation/providers/history_provider.dart';
import 'package:taroshell/features/connections/presentation/widgets/collection_tile.dart';
import 'package:taroshell/features/connections/presentation/widgets/recent_connections_tile.dart';
import 'package:taroshell/features/connections/presentation/widgets/server_card.dart';
import 'package:taroshell/features/connections/presentation/widgets/server_form_dialog.dart';
import 'package:taroshell/features/keys/presentation/providers/key_provider.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';
import 'package:taroshell/features/terminal/domain/services/ssh_service.dart';
import 'package:taroshell/features/terminal/presentation/providers/terminal_provider.dart';
import 'package:taroshell/features/terminal/presentation/screens/terminal_screen.dart';
import 'package:taroshell/features/terminal/presentation/widgets/password_prompt_dialog.dart';
import 'package:taroshell/shared/widgets/search_field.dart';

/// Provider tracking the currently selected server ID in the sidebar.
final selectedServerIdProvider = StateProvider<int?>((ref) => null);

/// Provider tracking the current sidebar search query.
final _sidebarSearchQueryProvider = StateProvider<String>((ref) => '');

/// Debounce duration for the sidebar search field.
const Duration _searchDebounceDuration = Duration(milliseconds: 300);

/// Left-hand sidebar providing navigation, server list, and collection tree.
///
/// Layout from top to bottom:
/// 1. App logo / name
/// 2. Search field
/// 3. Action buttons (Add Server / Add Collection)
/// 4. Scrollable content area (collections + ungrouped servers)
/// 5. Bottom action bar (Settings, Keys)
class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({
    super.key,
    required this.currentPath,
  });

  /// The current route path, used to highlight the active nav button.
  final String currentPath;

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      ref.read(_sidebarSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        children: [
          // ---- Header: App name ----
          _buildHeader(theme),
          const Divider(),

          // ---- Search ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SearchField(
              hintText: 'Search servers...',
              onChanged: _onSearchChanged,
            ),
          ),

          // ---- Action buttons ----
          _SidebarActionButtons(ref: ref),

          const SizedBox(height: 4),

          // ---- Scrollable content: collections + servers ----
          Expanded(
            child: _SidebarServerList(currentPath: widget.currentPath),
          ),

          const Divider(),

          // ---- Bottom navigation ----
          _buildBottomNav(context, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/app_logo.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            AppConstants.appName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _NavButton(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive: widget.currentPath == AppRoutes.settings,
            onTap: () => context.go(AppRoutes.settings),
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.vpn_key_outlined,
            label: 'Keys',
            isActive: widget.currentPath == AppRoutes.keys,
            onTap: () => context.go(AppRoutes.keys),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Action Buttons
// =============================================================================

/// Row of action buttons for adding servers and collections.
class _SidebarActionButtons extends StatelessWidget {
  const _SidebarActionButtons({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _CompactButton(
              icon: Icons.add_rounded,
              label: 'Server',
              onTap: () => _addServer(context),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _CompactButton(
              icon: Icons.create_new_folder_outlined,
              label: 'Collection',
              onTap: () => _addCollection(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addServer(BuildContext context) async {
    await ServerFormDialog.show(context, ref);
  }

  Future<void> _addCollection(BuildContext context) async {
    final name = await _showTextInputDialog(
      context: context,
      title: 'New Collection',
      labelText: 'Collection name',
      hintText: 'Production, Staging, etc.',
      confirmLabel: 'Create',
    );

    if (name != null && name.trim().isNotEmpty) {
      final actions = ref.read(collectionActionsProvider);
      await actions.add(
        CollectionEntity(
          id: 0,
          name: name.trim(),
          sortOrder: 0,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}

// =============================================================================
// Server List (scrollable content)
// =============================================================================

/// The scrollable content area showing collections and ungrouped servers.
class _SidebarServerList extends ConsumerStatefulWidget {
  const _SidebarServerList({required this.currentPath});

  final String currentPath;

  @override
  ConsumerState<_SidebarServerList> createState() => _SidebarServerListState();
}

class _SidebarServerListState extends ConsumerState<_SidebarServerList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collections = ref.watch(allCollectionsProvider);
    final ungroupedServers = ref.watch(serversByCollectionProvider(null));
    final recentHistory = ref.watch(recentHistoryProvider);
    final selectedServerId = ref.watch(selectedServerIdProvider);
    final searchQuery = ref.watch(_sidebarSearchQueryProvider).toLowerCase();

    // Listen for retry connection requests from the terminal screen.
    ref.listen<int?>(retryConnectionProvider, (previous, serverId) {
      if (serverId != null) {
        // Reset immediately to avoid re-triggering.
        ref.read(retryConnectionProvider.notifier).state = null;
        _onRetryConnection(context, serverId);
      }
    });

    final hasRecentEntries = recentHistory.valueOrNull?.isNotEmpty ?? false;
    final hasCollections = collections.valueOrNull?.isNotEmpty ?? false;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        // ---- Recent Connections ----
        RecentConnectionsTile(
          onEntryTap: (entry) =>
              _onHistoryEntryTap(context, ref, entry),
        ),

        // Divider between Recent and Collections when both have content
        if (hasRecentEntries && hasCollections)
          const Divider(indent: 12, endIndent: 12),

        // ---- Collections ----
        collections.when(
          data: (items) => Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (collection) => CollectionTile(
                    collection: collection,
                    selectedServerId: selectedServerId,
                    onServerTap: (server) => _onServerTap(context, ref, server),
                    onServerEdit: (server) =>
                        _onServerEdit(context, ref, server),
                    onServerDuplicate: (server) =>
                        _onServerDuplicate(ref, server),
                    onServerDelete: (server) =>
                        _onServerDelete(context, ref, server),
                    onAddServer: () => ServerFormDialog.show(
                      context,
                      ref,
                      initialCollectionId: collection.id,
                    ),
                    onRename: () =>
                        _onRenameCollection(context, ref, collection),
                    onChangeColor: () =>
                        _onChangeCollectionColor(context, ref, collection),
                    onDelete: () =>
                        _onDeleteCollection(context, ref, collection),
                  ),
                )
                .toList(),
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading collections',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ),

        // ---- Divider between collections and ungrouped ----
        // Only show when both collections and ungrouped servers exist.
        if (collections.valueOrNull?.isNotEmpty == true &&
            ungroupedServers.valueOrNull?.isNotEmpty == true)
          const Divider(indent: 12, endIndent: 12),

        // ---- Ungrouped servers section ----
        ungroupedServers.when(
          data: (servers) {
            final filtered = searchQuery.isEmpty
                ? servers
                : servers.where((s) =>
                    s.label.toLowerCase().contains(searchQuery) ||
                    s.host.toLowerCase().contains(searchQuery) ||
                    s.username.toLowerCase().contains(searchQuery)).toList();

            if (filtered.isEmpty && searchQuery.isEmpty) {
              // Only show "No servers yet" when collections are also empty.
              final hasCollections = collections.valueOrNull?.isNotEmpty ?? false;
              if (!hasCollections) {
                return _buildEmptyState(theme);
              }
              return const SizedBox.shrink();
            }

            if (filtered.isEmpty && searchQuery.isNotEmpty) {
              // Only show "No results" when collections are also empty,
              // otherwise matching servers may exist inside collections.
              final hasCollections = collections.valueOrNull?.isNotEmpty ?? false;
              if (!hasCollections) {
                return _buildNoResultsState(theme);
              }
              return const SizedBox.shrink();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'SERVERS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: theme.brightness == Brightness.dark
                          ? AppColors.darkOnSurfaceSubtle
                          : AppColors.lightOnSurfaceSubtle,
                    ),
                  ),
                ),
                ...filtered.map(
                  (server) => ServerCard(
                    server: server,
                    isSelected: server.id == selectedServerId,
                    onTap: () => _onServerTap(context, ref, server),
                    onEdit: () => _onServerEdit(context, ref, server),
                    onDuplicate: () => _onServerDuplicate(ref, server),
                    onDelete: () => _onServerDelete(context, ref, server),
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading servers',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No servers yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a server to get started',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No matching servers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // History entry actions
  // ---------------------------------------------------------------------------

  /// Handles a tap on a recent history entry.
  ///
  /// Attempts to look up the saved server by [serverId]. If the server still
  /// exists, uses the full [ServerEntity] for the connection flow. Otherwise,
  /// constructs a minimal entity from the history's host/port/username.
  Future<void> _onHistoryEntryTap(
    BuildContext context,
    WidgetRef ref,
    ConnectionHistoryData entry,
  ) async {
    final serverActions = ref.read(serverActionsProvider);
    ServerEntity? server;

    if (entry.serverId != null) {
      server = await serverActions.getById(entry.serverId!);
    }

    server ??= ServerEntity(
      id: 0,
      label: '${entry.username}@${entry.host}',
      host: entry.host,
      port: entry.port,
      username: entry.username,
      authType: AuthType.password,
      sortOrder: 0,
      isFavorite: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (!context.mounted) return;
    await _onServerTap(context, ref, server);
  }

  // ---------------------------------------------------------------------------
  // Server actions
  // ---------------------------------------------------------------------------

  Future<void> _onServerTap(
    BuildContext context,
    WidgetRef ref,
    ServerEntity server,
  ) async {
    ref.read(selectedServerIdProvider.notifier).state = server.id;

    // If an active or connecting session already exists, switch to it.
    final sessions = ref.read(activeSessionsProvider);
    final existing = sessions.cast<TerminalSession?>().firstWhere(
          (s) =>
              s?.serverId == server.id &&
              (s?.status == ConnectionStatus.connected ||
               s?.status == ConnectionStatus.connecting),
          orElse: () => null,
        );

    if (existing != null) {
      ref.read(activeSessionsProvider.notifier).setCurrentSession(existing.id);
      context.go(AppRoutes.connections);
      return;
    }

    // Confirm before initiating a new connection.
    final confirmed = await _showConnectConfirmDialog(context, server);
    if (!confirmed || !context.mounted) return;

    _onServerConnect(context, ref, server);
  }

  static final _log = AppLogger.ssh;

  /// Handles a retry request from an errored terminal tab.
  ///
  /// Looks up the server by ID and re-triggers the standard connection flow,
  /// including the confirm dialog and credential resolution.
  Future<void> _onRetryConnection(BuildContext context, int serverId) async {
    final serverActions = ref.read(serverActionsProvider);
    final server = await serverActions.getById(serverId);
    if (server == null || !context.mounted) return;

    await _onServerTap(context, ref, server);
  }

  Future<void> _onServerConnect(
    BuildContext context,
    WidgetRef ref,
    ServerEntity server,
  ) async {
    _log.i(
      'Initiating connection — server="${server.label}", '
      'authType=${server.authType.name}, keyId=${server.sshKeyId}',
    );

    // Resolve credentials based on auth type.
    String? password;
    SSHKeyPair? keyPair;

    try {
      switch (server.authType) {
        case AuthType.password:
          if (!context.mounted) return;
          password = await PasswordPromptDialog.show(context);
          if (password == null) return; // User cancelled.

        case AuthType.key:
          final pem = await _decryptStoredKey(ref, server.sshKeyId);
          keyPair = _parseKeyPair(pem);
          // If the key is passphrase-protected despite authType being `key`,
          // fall through to prompt for passphrase below.
          if (keyPair == null) {
            if (!context.mounted) return;
            final passphrase = await PasswordPromptDialog.show(
              context,
              isPassphrase: true,
            );
            if (passphrase == null) return;
            keyPair = _parseKeyPair(pem, passphrase: passphrase);
          }

        case AuthType.keyWithPassphrase:
          final pem = await _decryptStoredKey(ref, server.sshKeyId);
          if (!context.mounted) return;
          final passphrase = await PasswordPromptDialog.show(
            context,
            isPassphrase: true,
          );
          if (passphrase == null) return; // User cancelled.
          keyPair = _parseKeyPair(pem, passphrase: passphrase);
      }

      if (!context.mounted) return;

      // Navigate to connections route immediately so the user sees the tab.
      context.go(AppRoutes.connections);

      // Create pending tab and start SSH connection in background.
      // Errors are handled inline in the tab (no snackbar needed).
      connectToServer(
        ref: ref,
        server: server,
        password: password,
        keyPair: keyPair,
        context: context,
      );
    } catch (e, st) {
      // Credential resolution errors (key decryption, parse failures)
      // happen before the pending tab is created, so show a snackbar.
      _log.e('Credential resolution failed for server="${server.label}"', e, st);

      if (context.mounted) {
        final message = switch (e) {
          SshAuthenticationException(:final message) => message,
          _ => 'Failed to resolve credentials: $e',
        };
        _showErrorSnackBar(context, message);
      }
    }
  }

  /// Decrypts the app-level AES encryption on a stored SSH key and returns
  /// the raw PEM string.
  Future<String> _decryptStoredKey(WidgetRef ref, int? sshKeyId) async {
    _log.d('Decrypting stored key — keyId=$sshKeyId');

    if (sshKeyId == null) {
      throw const SshAuthenticationException(
        'No SSH key configured for this server.',
      );
    }

    final repository = ref.read(keyRepositoryProvider);
    final keyEntity = await repository.getKeyById(sshKeyId);

    if (keyEntity == null) {
      _log.w('SSH key not found — keyId=$sshKeyId');
      throw const SshAuthenticationException(
        'The configured SSH key was not found.',
      );
    }

    _log.d('Key found — keyId=$sshKeyId, decrypting private key');
    return repository.decryptPrivateKey(keyEntity.encryptedPrivateKey);
  }

  /// Parses a PEM string into an [SSHKeyPair].
  ///
  /// Returns `null` if the key is passphrase-protected and no [passphrase]
  /// was provided (instead of throwing), allowing the caller to prompt the
  /// user for a passphrase and retry.
  ///
  /// Throws [SshAuthenticationException] for unrecoverable parse failures.
  SSHKeyPair? _parseKeyPair(String pem, {String? passphrase}) {
    _log.d('Parsing key pair — hasPassphrase=${passphrase != null}');
    try {
      final keyPairs = SSHKeyPair.fromPem(pem, passphrase);
      if (keyPairs.isEmpty) {
        _log.e('Key pair parsing returned empty list');
        throw const SshAuthenticationException(
          'Failed to parse the SSH private key.',
        );
      }
      _log.d('Key pair parsed successfully');
      return keyPairs.first;
    } on SSHKeyDecryptError {
      // Key is encrypted and no passphrase was provided — signal caller
      // to prompt for passphrase by returning null.
      if (passphrase == null) {
        _log.d('Key is passphrase-protected, prompting user');
        return null;
      }
      _log.w('Invalid passphrase provided for key');
      throw const SshAuthenticationException(
        'Invalid passphrase for the SSH private key.',
      );
    }
  }

  Future<bool> _showConnectConfirmDialog(
    BuildContext context,
    ServerEntity server,
  ) async {
    final theme = Theme.of(context);
    final portSuffix =
        server.port != AppConstants.defaultSshPort ? ':${server.port}' : '';
    final connectionString = '${server.username}@${server.host}$portSuffix';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Connect to Server'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Open an SSH session to "${server.label}"?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        connectionString,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: AppConstants.defaultTerminalFontFamily,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onServerEdit(
    BuildContext context,
    WidgetRef ref,
    ServerEntity server,
  ) async {
    await ServerFormDialog.show(context, ref, existingServer: server);
  }

  Future<void> _onServerDuplicate(WidgetRef ref, ServerEntity server) async {
    final actions = ref.read(serverActionsProvider);
    await actions.duplicate(server);
  }

  Future<void> _onServerDelete(
    BuildContext context,
    WidgetRef ref,
    ServerEntity server,
  ) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: 'Delete Server',
      message: 'Are you sure you want to delete "${server.label}"? '
          'This action cannot be undone.',
    );

    if (confirmed) {
      final actions = ref.read(serverActionsProvider);
      await actions.delete(server.id);

      // Clear selection if the deleted server was selected
      if (ref.read(selectedServerIdProvider) == server.id) {
        ref.read(selectedServerIdProvider.notifier).state = null;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Collection actions
  // ---------------------------------------------------------------------------

  Future<void> _onRenameCollection(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity collection,
  ) async {
    final name = await _showTextInputDialog(
      context: context,
      title: 'Rename Collection',
      labelText: 'Collection name',
      initialValue: collection.name,
      confirmLabel: 'Rename',
    );

    if (name != null && name.trim().isNotEmpty) {
      final actions = ref.read(collectionActionsProvider);
      await actions.update(collection.copyWith(name: name.trim()));
    }
  }

  Future<void> _onChangeCollectionColor(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity collection,
  ) async {
    final color = await _showColorPickerDialog(context, collection.color);

    if (color != null) {
      final actions = ref.read(collectionActionsProvider);
      await actions.update(collection.copyWith(color: () => color));
    }
  }

  Future<void> _onDeleteCollection(
    BuildContext context,
    WidgetRef ref,
    CollectionEntity collection,
  ) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: 'Delete Collection',
      message:
          'Are you sure you want to delete "${collection.name}"? '
          'Servers in this collection will become ungrouped.',
    );

    if (confirmed) {
      final actions = ref.read(collectionActionsProvider);
      await actions.delete(collection.id);
    }
  }
}

// =============================================================================
// Compact button used in the sidebar action row
// =============================================================================

class _CompactButton extends StatelessWidget {
  const _CompactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Navigation button
// =============================================================================

/// A compact navigation button used in the sidebar bottom bar.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shared dialog helpers
// =============================================================================

/// Shows a simple text input dialog and returns the entered value, or `null`.
Future<String?> _showTextInputDialog({
  required BuildContext context,
  required String title,
  required String labelText,
  String? hintText,
  String? initialValue,
  String confirmLabel = 'OK',
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _TextInputDialog(
      title: title,
      labelText: labelText,
      hintText: hintText,
      initialValue: initialValue,
      confirmLabel: confirmLabel,
    ),
  );
}

/// Dialog with its own [TextEditingController] lifecycle, preventing
/// use-after-dispose errors during exit animations.
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.labelText,
    this.hintText,
    this.initialValue,
    required this.confirmLabel,
  });

  final String title;
  final String labelText;
  final String? hintText;
  final String? initialValue;
  final String confirmLabel;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

/// Shows a confirmation dialog and returns `true` if the user confirmed.
Future<bool> _showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  return result ?? false;
}

/// Shows a color picker dialog for collection color selection.
Future<String?> _showColorPickerDialog(
  BuildContext context,
  String? currentColor,
) async {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return AlertDialog(
        title: const Text('Choose Color'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: CollectionColors.options.map((option) {
            final color = Color(
              int.parse(option.hex.replaceFirst('#', ''), radix: 16) |
                  0xFF000000,
            );
            final isSelected = option.hex == currentColor;

            return Tooltip(
              message: option.label,
              child: InkWell(
                onTap: () => Navigator.of(dialogContext).pop(option.hex),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 2.5,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}
