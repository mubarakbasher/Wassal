import '../entities/session.dart';
import '../repositories/session_repository.dart';

class GetSessionsUseCase {
  final SessionRepository repository;

  GetSessionsUseCase(this.repository);

  Future<List<Session>> call({bool? activeOnly}) {
    return repository.getSessions(activeOnly: activeOnly);
  }
}
