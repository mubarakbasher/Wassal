import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/startup_service.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final StartupService startupService;
  
  SplashBloc({required this.startupService}) : super(const SplashInitial()) {
    on<StartSplashChecks>(_onStartChecks);
    on<RetrySplashChecks>(_onRetryChecks);
  }

  Future<void> _onStartChecks(
    StartSplashChecks event,
    Emitter<SplashState> emit,
  ) async {
    await _runChecks(emit);
  }

  Future<void> _onRetryChecks(
    RetrySplashChecks event,
    Emitter<SplashState> emit,
  ) async {
    await _runChecks(emit);
  }

  Future<void> _runChecks(Emitter<SplashState> emit) async {
    // Phase 1: Logo animation (0-1s)
    emit(const SplashChecking(
      statusText: '',
      phase: SplashCheckPhase.logoAnimation,
    ));
    await Future.delayed(const Duration(milliseconds: 1000));

    // Phase 2: Check internet (1-1.7s)
    emit(const SplashChecking(
      statusText: 'Checking internet connection...',
      phase: SplashCheckPhase.checkingInternet,
    ));
    
    final hasInternet = await startupService.checkInternetConnection();
    await Future.delayed(const Duration(milliseconds: 700));

    if (!hasInternet) {
      emit(const SplashNoInternet());
      return;
    }

    // Update internet check result
    final resultsAfterInternet = {SplashCheck.internet: true};
    
    // Phase 3: Check server (1.7-2.4s)
    emit(SplashChecking(
      statusText: 'Connecting to server...',
      phase: SplashCheckPhase.checkingServer,
      checkResults: resultsAfterInternet,
    ));
    
    final serverResult = await startupService.pingServerHealth();
    await Future.delayed(const Duration(milliseconds: 700));

    if (!serverResult.isHealthy) {
      if (serverResult.isMaintenance) {
        emit(SplashMaintenance(message: serverResult.message ?? 'App is under maintenance'));
        return;
      }
      emit(SplashServerError(message: serverResult.message ?? 'Unable to connect to server'));
      return;
    }

    final resultsAfterServer = {
      ...resultsAfterInternet,
      SplashCheck.server: true,
    };

    // Phase 4: Validate session (2.4-3s)
    emit(SplashChecking(
      statusText: 'Validating session...',
      phase: SplashCheckPhase.validatingSession,
      checkResults: resultsAfterServer,
    ));
    
    final isAuthenticated = await startupService.validateSession();
    await Future.delayed(const Duration(milliseconds: 600));

    final resultsAfterSession = {
      ...resultsAfterServer,
      SplashCheck.session: isAuthenticated,
    };

    // Phase 5: Loading config (3-3.5s)
    emit(SplashChecking(
      statusText: 'Loading configuration...',
      phase: SplashCheckPhase.loadingConfig,
      checkResults: resultsAfterSession,
    ));
    
    await startupService.loadAppConfiguration();
    await Future.delayed(const Duration(milliseconds: 500));

    // Phase 6: Show results (3.5-4.5s)
    emit(SplashChecking(
      statusText: 'Almost ready...',
      phase: SplashCheckPhase.showingResults,
      checkResults: resultsAfterSession,
    ));
    await Future.delayed(const Duration(milliseconds: 1000));

    // Phase 7: Ready (4.5-6s)
    emit(SplashChecking(
      statusText: 'App is ready!',
      phase: SplashCheckPhase.ready,
      checkResults: resultsAfterSession,
    ));
    await Future.delayed(const Duration(milliseconds: 1500));

    // Final state - navigate based on authentication
    emit(SplashReady(isAuthenticated: isAuthenticated));
  }
}
