import '../../domain/entities/session.dart';
import '../../domain/entities/session_statistics.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;

  SessionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Session>> getSessions({bool? activeOnly}) async {
    try {
      final models = await remoteDataSource.getSessions(activeOnly: activeOnly);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get sessions: $e');
    }
  }

  @override
  Future<List<Session>> getSessionsByRouter(
    String routerId, {
    bool? activeOnly,
  }) async {
    try {
      final models = await remoteDataSource.getSessionsByRouter(
        routerId,
        activeOnly: activeOnly,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get sessions by router: $e');
    }
  }

  @override
  Future<Session> getSessionById(String id) async {
    try {
      final model = await remoteDataSource.getSessionById(id);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  @override
  Future<SessionStatistics> getStatistics({String? routerId}) async {
    try {
      final model = await remoteDataSource.getStatistics(routerId: routerId);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  @override
  Future<void> terminateSession(String sessionId) async {
    try {
      await remoteDataSource.terminateSession(sessionId);
    } catch (e) {
      throw Exception('Failed to terminate session: $e');
    }
  }
}
