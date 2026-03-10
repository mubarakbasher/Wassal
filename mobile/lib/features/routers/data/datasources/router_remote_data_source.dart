import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/error_handler.dart';
import '../models/router_model.dart';

abstract class RouterRemoteDataSource {
  Future<List<RouterModel>> getRouters({bool statusOnly = false});
  Future<RouterModel> getRouterById(String id);
  Future<RouterModel> createRouter(Map<String, dynamic> data);
  Future<RouterModel> updateRouter(String id, Map<String, dynamic> data);
  Future<void> deleteRouter(String id);
  Future<Map<String, dynamic>> checkRouterHealth(String id);
  Future<Map<String, dynamic>> getRouterSystemInfo(String id);
  Future<Map<String, dynamic>> getRouterStats(String id);
  Future<List<dynamic>> getHotspotProfiles(String id);
}

class RouterRemoteDataSourceImpl implements RouterRemoteDataSource {
  final ApiClient apiClient;

  RouterRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RouterModel>> getRouters({bool statusOnly = false}) async {
    try {
      final endpoint = statusOnly
          ? '${ApiEndpoints.routers}?statusOnly=true'
          : ApiEndpoints.routers;
      final response = await apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! List) throw Exception('Unexpected response format');
        final List<dynamic> list = data;
        return list.map((json) => RouterModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load routers');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RouterModel> getRouterById(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.routerById(id));

      if (response.statusCode == 200) {
        return RouterModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load router');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RouterModel> createRouter(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.routers,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RouterModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to create router');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RouterModel> updateRouter(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.routerById(id),
        data: data,
      );

      if (response.statusCode == 200) {
        return RouterModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to update router');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteRouter(String id) async {
    try {
      final response = await apiClient.delete(ApiEndpoints.routerById(id));

      if (response.statusCode != 200) {
        throw ServerException('Failed to delete router');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> checkRouterHealth(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.routerHealth(id));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) throw Exception('Unexpected response format');
        return data;
      } else {
        throw ServerException('Failed to check router health');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getRouterSystemInfo(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.routerSystemInfo(id));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) throw Exception('Unexpected response format');
        return data;
      } else {
        throw ServerException('Failed to get system info');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getRouterStats(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.routerStats(id));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) throw Exception('Unexpected response format');
        return data;
      } else {
        throw ServerException('Failed to get router stats');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getHotspotProfiles(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.routerHotspotProfiles(id));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! List) throw Exception('Unexpected response format');
        final List<dynamic> list = data;
        return list;
      } else {
        throw ServerException('Failed to get hotspot profiles');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
