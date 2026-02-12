import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/session_repository.dart';
import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository repository;

  SessionBloc({required this.repository}) : super(SessionInitial()) {
    on<LoadSessionsEvent>(_onLoadSessions);
    on<LoadSessionsByRouterEvent>(_onLoadSessionsByRouter);
    on<LoadSessionStatisticsEvent>(_onLoadSessionStatistics);
    on<TerminateSessionEvent>(_onTerminateSession);
    on<RefreshSessionsEvent>(_onRefreshSessions);
  }

  Future<void> _onLoadSessions(
    LoadSessionsEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final sessions = await repository.getSessions(activeOnly: event.activeOnly);
      final statistics = await repository.getStatistics();
      emit(SessionsLoaded(sessions, statistics: statistics));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onLoadSessionsByRouter(
    LoadSessionsByRouterEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final sessions = await repository.getSessionsByRouter(
        event.routerId,
        activeOnly: event.activeOnly,
      );
      final statistics = await repository.getStatistics(routerId: event.routerId);
      emit(SessionsLoaded(sessions, statistics: statistics));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onLoadSessionStatistics(
    LoadSessionStatisticsEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      final statistics = await repository.getStatistics(routerId: event.routerId);
      // Keep existing sessions if loaded, just update statistics
      if (state is SessionsLoaded) {
        final currentState = state as SessionsLoaded;
        emit(SessionsLoaded(currentState.sessions, statistics: statistics));
      } else {
        // Load sessions too if not already loaded
        final sessions = event.routerId != null
            ? await repository.getSessionsByRouter(event.routerId!)
            : await repository.getSessions();
        emit(SessionsLoaded(sessions, statistics: statistics));
      }
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onTerminateSession(
    TerminateSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await repository.terminateSession(event.sessionId);
      emit(const SessionTerminated('Session terminated successfully'));
      
      // Reload sessions after termination
      if (state is SessionsLoaded) {
        final currentState = state as SessionsLoaded;
        final sessions = await repository.getSessions();
        emit(SessionsLoaded(sessions, statistics: currentState.statistics));
      }
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onRefreshSessions(
    RefreshSessionsEvent event,
    Emitter<SessionState> emit,
  ) async {
    // Don't show loading state for refresh
    try {
      final sessions = await repository.getSessions();
      final statistics = await repository.getStatistics();
      emit(SessionsLoaded(sessions, statistics: statistics));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}
