import '../repositories/session_repository.dart';

class TerminateSessionUseCase {
  final SessionRepository repository;

  TerminateSessionUseCase(this.repository);

  Future<void> call(String sessionId) {
    return repository.terminateSession(sessionId);
  }
}
