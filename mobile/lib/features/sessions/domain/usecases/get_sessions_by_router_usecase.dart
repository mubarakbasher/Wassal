import '../entities/session.dart';
import '../repositories/session_repository.dart';

class GetSessionsByRouterUseCase {
  final SessionRepository repository;

  GetSessionsByRouterUseCase(this.repository);

  Future<List<Session>> call(String routerId, {bool? activeOnly}) {
    return repository.getSessionsByRouter(routerId, activeOnly: activeOnly);
  }
}
