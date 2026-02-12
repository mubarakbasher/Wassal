import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessionsEvent extends SessionEvent {
  final bool? activeOnly;

  const LoadSessionsEvent({this.activeOnly});

  @override
  List<Object?> get props => [activeOnly];
}

class LoadSessionsByRouterEvent extends SessionEvent {
  final String routerId;
  final bool? activeOnly;

  const LoadSessionsByRouterEvent(this.routerId, {this.activeOnly});

  @override
  List<Object?> get props => [routerId, activeOnly];
}

class LoadSessionStatisticsEvent extends SessionEvent {
  final String? routerId;

  const LoadSessionStatisticsEvent({this.routerId});

  @override
  List<Object?> get props => [routerId];
}

class TerminateSessionEvent extends SessionEvent {
  final String sessionId;

  const TerminateSessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class RefreshSessionsEvent extends SessionEvent {
  const RefreshSessionsEvent();
}
