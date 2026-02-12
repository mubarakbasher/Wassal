import 'package:equatable/equatable.dart';

/// Enum representing the current phase of splash checks
enum SplashCheckPhase {
  logoAnimation,      // 0-1s
  checkingInternet,   // 1-1.7s
  checkingServer,     // 1.7-2.4s
  validatingSession,  // 2.4-3s
  loadingConfig,      // 3-3.5s
  showingResults,     // 3.5-4.5s
  ready,              // 4.5-6s
}

/// Enum for individual check types
enum SplashCheck {
  internet,
  server,
  session,
}

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state when splash screen loads
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// State during the checking process
class SplashChecking extends SplashState {
  final String statusText;
  final SplashCheckPhase phase;
  final Map<SplashCheck, bool?> checkResults;

  const SplashChecking({
    required this.statusText,
    required this.phase,
    this.checkResults = const {},
  });

  SplashChecking copyWith({
    String? statusText,
    SplashCheckPhase? phase,
    Map<SplashCheck, bool?>? checkResults,
  }) {
    return SplashChecking(
      statusText: statusText ?? this.statusText,
      phase: phase ?? this.phase,
      checkResults: checkResults ?? this.checkResults,
    );
  }

  @override
  List<Object?> get props => [statusText, phase, checkResults];
}

/// State when all checks pass and app is ready
class SplashReady extends SplashState {
  final bool isAuthenticated;
  
  const SplashReady({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}

/// State when there's no internet connection
class SplashNoInternet extends SplashState {
  const SplashNoInternet();
}

/// State when server is unreachable
class SplashServerError extends SplashState {
  final String message;
  
  const SplashServerError({this.message = 'Unable to connect to server'});

  @override
  List<Object?> get props => [message];
}

/// State when app is under maintenance
class SplashMaintenance extends SplashState {
  final String message;
  
  const SplashMaintenance({this.message = 'App is under maintenance'});

  @override
  List<Object?> get props => [message];
}
