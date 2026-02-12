import '../entities/session.dart';
import '../entities/session_statistics.dart';

abstract class SessionRepository {
  Future<List<Session>> getSessions({bool? activeOnly});
  Future<List<Session>> getSessionsByRouter(String routerId, {bool? activeOnly});
  Future<Session> getSessionById(String id);
  Future<SessionStatistics> getStatistics({String? routerId});
  Future<void> terminateSession(String sessionId);
}
