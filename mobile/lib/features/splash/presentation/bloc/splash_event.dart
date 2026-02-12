import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the splash screen checks
class StartSplashChecks extends SplashEvent {
  const StartSplashChecks();
}

/// Event to retry checks after an error
class RetrySplashChecks extends SplashEvent {
  const RetrySplashChecks();
}
