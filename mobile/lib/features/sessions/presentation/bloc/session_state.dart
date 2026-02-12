import 'package:equatable/equatable.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_statistics.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionsLoaded extends SessionState {
  final List<Session> sessions;
  final SessionStatistics? statistics;

  const SessionsLoaded(this.sessions, {this.statistics});

  @override
  List<Object?> get props => [sessions, statistics];
}

class SessionTerminated extends SessionState {
  final String message;

  const SessionTerminated(this.message);

  @override
  List<Object?> get props => [message];
}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}
