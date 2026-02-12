import '../models/session_model.dart';
import '../models/session_statistics_model.dart';

abstract class SessionRemoteDataSource {
  Future<List<SessionModel>> getSessions({bool? activeOnly});
  Future<List<SessionModel>> getSessionsByRouter(String routerId, {bool? activeOnly});
  Future<SessionModel> getSessionById(String id);
  Future<SessionStatisticsModel> getStatistics({String? routerId});
  Future<void> terminateSession(String sessionId);
}
