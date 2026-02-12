import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/session_model.dart';
import '../models/session_statistics_model.dart';
import 'session_remote_data_source.dart';

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final ApiClient apiClient;

  SessionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SessionModel>> getSessions({bool? activeOnly}) async {
    try {
      final queryParams = activeOnly != null ? {'active': activeOnly.toString()} : null;
      
      final response = await apiClient.dio.get(
        '/sessions',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SessionModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch sessions: ${e.message}');
    }
  }

  @override
  Future<List<SessionModel>> getSessionsByRouter(
    String routerId, {
    bool? activeOnly,
  }) async {
    try {
      final queryParams = activeOnly != null ? {'active': activeOnly.toString()} : null;
      
      final response = await apiClient.dio.get(
        '/sessions/router/$routerId',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SessionModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch sessions for router: ${e.message}');
    }
  }

  @override
  Future<SessionModel> getSessionById(String id) async {
    try {
      final response = await apiClient.dio.get('/sessions/$id');
      return SessionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch session: ${e.message}');
    }
  }

  @override
  Future<SessionStatisticsModel> getStatistics({String? routerId}) async {
    try {
      final endpoint = routerId != null ? '/sessions/stats/$routerId' : '/sessions/stats';
      
      final response = await apiClient.dio.get(endpoint);
      return SessionStatisticsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch session statistics: ${e.message}');
    }
  }

  @override
  Future<void> terminateSession(String sessionId) async {
    try {
      await apiClient.dio.delete('/sessions/$sessionId');
    } on DioException catch (e) {
      throw Exception('Failed to terminate session: ${e.message}');
    }
  }
}
