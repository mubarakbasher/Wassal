import '../entities/session_statistics.dart';
import '../repositories/session_repository.dart';

class GetSessionStatisticsUseCase {
  final SessionRepository repository;

  GetSessionStatisticsUseCase(this.repository);

  Future<SessionStatistics> call({String? routerId}) {
    return repository.getStatistics(routerId: routerId);
  }
}
