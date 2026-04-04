import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';

/// Abstract interface for managing active SSH terminal sessions.
///
/// Implementations hold sessions in memory (they are ephemeral and not
/// persisted across app restarts). The repository tracks which session
/// is currently visible and provides add/remove/select operations.
abstract class SessionRepository {
  /// All currently active terminal sessions, ordered by creation time.
  List<TerminalSession> get activeSessions;

  /// The session that is currently displayed in the terminal view.
  ///
  /// Returns `null` when no sessions are active.
  TerminalSession? get currentSession;

  /// Registers a newly connected session.
  void addSession(TerminalSession session);

  /// Removes a session by its [sessionId] and cleans up resources.
  ///
  /// If the removed session was the current session, the implementation
  /// should automatically select an adjacent session (or `null` if empty).
  void removeSession(String sessionId);

  /// Sets the session identified by [sessionId] as the currently visible one.
  void setCurrentSession(String sessionId);

  /// Reorders a session from [oldIndex] to [newIndex] in the tab order.
  void reorderSession(int oldIndex, int newIndex);
}
