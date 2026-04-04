import 'package:taroshell/features/terminal/domain/entities/terminal_session.dart';
import 'package:taroshell/features/terminal/domain/repositories/session_repository.dart';

/// In-memory implementation of [SessionRepository].
///
/// Terminal sessions are ephemeral -- they exist only while the app is
/// running and are not persisted to the database. This implementation
/// maintains an ordered list of sessions and tracks the currently
/// selected session index for tab display.
class SessionRepositoryImpl implements SessionRepository {
  final List<TerminalSession> _sessions = [];
  String? _currentSessionId;

  @override
  List<TerminalSession> get activeSessions => List.unmodifiable(_sessions);

  @override
  TerminalSession? get currentSession {
    if (_currentSessionId == null || _sessions.isEmpty) {
      return null;
    }
    return _sessions.cast<TerminalSession?>().firstWhere(
          (session) => session?.id == _currentSessionId,
          orElse: () => null,
        );
  }

  @override
  void addSession(TerminalSession session) {
    _sessions.add(session);
    _currentSessionId = session.id;
  }

  @override
  void removeSession(String sessionId) {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    _sessions.removeAt(index);

    if (_currentSessionId == sessionId) {
      if (_sessions.isEmpty) {
        _currentSessionId = null;
      } else {
        // Select the nearest adjacent session.
        final newIndex = index.clamp(0, _sessions.length - 1);
        _currentSessionId = _sessions[newIndex].id;
      }
    }
  }

  @override
  void setCurrentSession(String sessionId) {
    final exists = _sessions.any((s) => s.id == sessionId);
    if (exists) {
      _currentSessionId = sessionId;
    }
  }

  @override
  void reorderSession(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _sessions.length ||
        newIndex < 0 ||
        newIndex >= _sessions.length) {
      return;
    }

    final session = _sessions.removeAt(oldIndex);
    _sessions.insert(newIndex, session);
  }
}
