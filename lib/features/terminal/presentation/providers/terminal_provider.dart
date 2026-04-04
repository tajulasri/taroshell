import 'package:dartssh2/dartssh2.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:xterm/xterm.dart';

import 'package:taroshell/core/constants/app_constants.dart';
import 'package:taroshell/core/database/app_database.dart';
import 'package:taroshell/core/utils/app_logger.dart';
import 'package:taroshell/features/connections/data/daos/connection_history_dao.dart';
import 'package:taroshell/features/connections/domain/entities/server.dart';
import 'package:taroshell/features/known_hosts/data/daos/known_host_dao.dart';
import 'package:taroshell/features/terminal/data/repositories/session_repository_impl.dart';
import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';
import 'package:taroshell/features/terminal/domain/repositories/session_repository.dart';
import 'package:taroshell/features/terminal/domain/services/ssh_service.dart';
import 'package:taroshell/main.dart';

// =============================================================================
// DAO providers
// =============================================================================

/// Provides the [KnownHostDao] for host key verification persistence.
final knownHostDaoProvider = Provider<KnownHostDao>((ref) {
  final db = ref.watch(databaseProvider);
  return KnownHostDao(db);
});

/// Provides the [ConnectionHistoryDao] for connection audit trail.
final connectionHistoryDaoProvider = Provider<ConnectionHistoryDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ConnectionHistoryDao(db);
});

// =============================================================================
// Service providers
// =============================================================================

/// Provides the singleton [SshService] instance.
final sshServiceProvider = Provider<SshService>((ref) {
  final knownHostDao = ref.watch(knownHostDaoProvider);
  return SshService(knownHostDao: knownHostDao);
});

// =============================================================================
// Repository providers
// =============================================================================

/// Provides the singleton [SessionRepository] for tracking active sessions.
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl();
});

// =============================================================================
// Session state management
// =============================================================================

/// Tracks the state of all active terminal sessions.
///
/// Uses [StateNotifier] so that UI widgets rebuild whenever sessions
/// are added, removed, reordered, or the current session changes.
class ActiveSessionsNotifier extends StateNotifier<List<TerminalSession>> {
  ActiveSessionsNotifier({
    required SessionRepository repository,
    required ConnectionHistoryDao historyDao,
  })  : _repository = repository,
        _historyDao = historyDao,
        super([]);

  final SessionRepository _repository;
  final ConnectionHistoryDao _historyDao;

  /// Current session ID tracked separately to trigger rebuilds.
  String? _currentSessionId;

  /// The ID of the currently selected session.
  String? get currentSessionId => _currentSessionId;

  static final _log = AppLogger.ssh;

  /// Adds a fully connected session and sets it as active.
  void addSession(TerminalSession session) {
    _log.i('Session added — id=${session.id}, host=${session.host}:${session.port}');
    _repository.addSession(session);
    _currentSessionId = session.id;
    state = List.unmodifiable(_repository.activeSessions);
  }

  /// Adds a pending (connecting) session and sets it as active immediately.
  ///
  /// The tab appears right away with a loading indicator while the SSH
  /// handshake proceeds in the background.
  void addPendingSession(TerminalSession session) {
    _log.i('Pending session added — id=${session.id}, host=${session.host}:${session.port}');
    _repository.addSession(session);
    _currentSessionId = session.id;
    state = List.unmodifiable(_repository.activeSessions);
  }

  /// Transitions a pending session to the connected state.
  ///
  /// Replaces the placeholder terminal with the live one and binds
  /// the SSH client. Called after a successful SSH handshake.
  void updateSessionConnected({
    required String sessionId,
    required SSHClient client,
    required Terminal terminal,
    required int historyId,
  }) {
    final session = _findSession(sessionId);
    if (session == null) return;

    _log.i('Session connected — id=$sessionId');
    session.status = ConnectionStatus.connected;
    session.isConnected = true;
    session.client = client;
    session.terminal = terminal;
    session.historyId = historyId;

    state = List.unmodifiable(_repository.activeSessions);
  }

  /// Transitions a pending session to the error state.
  ///
  /// The tab remains visible showing the error message inline, allowing
  /// the user to retry or dismiss.
  void updateSessionError({
    required String sessionId,
    required String errorMessage,
  }) {
    final session = _findSession(sessionId);
    if (session == null) return;

    _log.w('Session error — id=$sessionId, error=$errorMessage');
    session.status = ConnectionStatus.error;
    session.isConnected = false;
    session.errorMessage = errorMessage;

    state = List.unmodifiable(_repository.activeSessions);
  }

  /// Removes a session by ID and disconnects it.
  void removeSession(String sessionId, SshService sshService) {
    _log.i('Removing session — id=$sessionId');
    final session = _findSession(sessionId);
    if (session != null) {
      // Only disconnect if there's an active SSH connection.
      if (session.status == ConnectionStatus.connected) {
        sshService.disconnect(session);
      }

      // Record disconnection timestamp in history.
      if (session.historyId != null) {
        _historyDao.updateDisconnected(
          session.historyId!,
          DateTime.now(),
          null,
        );
      }
    }

    _repository.removeSession(sessionId);
    _currentSessionId = _repository.currentSession?.id;
    state = List.unmodifiable(_repository.activeSessions);
  }

  /// Switches the active session tab.
  void setCurrentSession(String sessionId) {
    _repository.setCurrentSession(sessionId);
    _currentSessionId = sessionId;
    // Trigger rebuild even though the list content hasn't changed --
    // downstream providers depend on currentSessionId.
    state = List.unmodifiable(_repository.activeSessions);
  }

  /// Reorders sessions in the tab bar.
  void reorderSession(int oldIndex, int newIndex) {
    _repository.reorderSession(oldIndex, newIndex);
    state = List.unmodifiable(_repository.activeSessions);
  }

  TerminalSession? _findSession(String sessionId) {
    return _repository.activeSessions.cast<TerminalSession?>().firstWhere(
          (s) => s?.id == sessionId,
          orElse: () => null,
        );
  }
}

/// Provider for the [ActiveSessionsNotifier].
final activeSessionsProvider =
    StateNotifierProvider<ActiveSessionsNotifier, List<TerminalSession>>(
  (ref) {
    final repository = ref.watch(sessionRepositoryProvider);
    final historyDao = ref.watch(connectionHistoryDaoProvider);
    return ActiveSessionsNotifier(
      repository: repository,
      historyDao: historyDao,
    );
  },
);

/// Derived provider that exposes the currently selected [TerminalSession].
final currentSessionProvider = Provider<TerminalSession?>((ref) {
  final sessions = ref.watch(activeSessionsProvider);
  final notifier = ref.watch(activeSessionsProvider.notifier);
  final currentId = notifier.currentSessionId;

  if (currentId == null || sessions.isEmpty) return null;
  return sessions.cast<TerminalSession?>().firstWhere(
        (s) => s?.id == currentId,
        orElse: () => null,
      );
});

// =============================================================================
// Connection orchestrator
// =============================================================================

const _uuid = Uuid();

/// Orchestrates the full SSH connection flow for a given [ServerEntity].
///
/// Creates a pending tab immediately for instant user feedback, then
/// runs the SSH handshake in the background. On success the tab transitions
/// to a live terminal; on failure it shows an inline error.
///
/// Returns the session ID of the created (pending) session.
String connectToServer({
  required WidgetRef ref,
  required ServerEntity server,
  required String? password,
  required SSHKeyPair? keyPair,
  required BuildContext context,
}) {
  final log = AppLogger.ssh;
  log.i('connectToServer — serverId=${server.id}, host=${server.host}:${server.port}');

  final sshService = ref.read(sshServiceProvider);
  final notifier = ref.read(activeSessionsProvider.notifier);
  final historyDao = ref.read(connectionHistoryDaoProvider);

  // 1. Create a pending session with a placeholder terminal immediately.
  final sessionId = _uuid.v4();
  final placeholderTerminal = Terminal(
    maxLines: AppConstants.defaultScrollbackLines,
  );

  final pendingSession = TerminalSession(
    id: sessionId,
    serverId: server.id,
    label: server.label,
    host: server.host,
    port: server.port,
    username: server.username,
    terminal: placeholderTerminal,
    connectedAt: DateTime.now(),
    isConnected: false,
    status: ConnectionStatus.connecting,
  );

  // 2. Add tab immediately — user sees spinner right away.
  notifier.addPendingSession(pendingSession);

  // 3. Run SSH connection in background.
  _performConnection(
    sessionId: sessionId,
    server: server,
    password: password,
    keyPair: keyPair,
    context: context,
    sshService: sshService,
    notifier: notifier,
    historyDao: historyDao,
    log: log,
  );

  return sessionId;
}

/// Performs the actual SSH connection asynchronously.
///
/// Updates the pending session to connected or error based on the outcome.
Future<void> _performConnection({
  required String sessionId,
  required ServerEntity server,
  required String? password,
  required SSHKeyPair? keyPair,
  required BuildContext context,
  required SshService sshService,
  required ActiveSessionsNotifier notifier,
  required ConnectionHistoryDao historyDao,
  required AppLogger log,
}) async {
  try {
    final session = await sshService.connect(
      server: server,
      password: password,
      keyPair: keyPair,
      context: context,
    );

    // Record successful connection in history.
    final historyId = await historyDao.insertHistory(
      ConnectionHistoryCompanion.insert(
        host: server.host,
        port: server.port,
        username: server.username,
        serverId: Value(server.id),
      ),
    );
    log.d('Connection history recorded — historyId=$historyId');

    // Transition pending session to connected.
    notifier.updateSessionConnected(
      sessionId: sessionId,
      client: session.client!,
      terminal: session.terminal,
      historyId: historyId,
    );

    log.i('connectToServer complete — sessionId=$sessionId');
  } catch (e, st) {
    log.e('Connection failed for server="${server.label}"', e, st);

    final message = switch (e) {
      SshAuthenticationException(:final message) => message,
      SshConnectionException(:final message) => message,
      HostKeyVerificationException(:final message) => message,
      _ => 'Connection failed: $e',
    };

    // Transition pending session to error.
    notifier.updateSessionError(
      sessionId: sessionId,
      errorMessage: message,
    );

    // Record failed connection attempt in history.
    historyDao.insertHistory(
      ConnectionHistoryCompanion.insert(
        host: server.host,
        port: server.port,
        username: server.username,
        serverId: Value(server.id),
        wasSuccessful: const Value(false),
        disconnectedAt: Value(DateTime.now()),
        errorMessage: Value('$e'),
      ),
    );
  }
}
