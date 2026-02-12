import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String email, String password, String name, String role);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String id, Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Invalid credentials');
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException('Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ServerException('User already exists');
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get(ApiEndpoints.profile);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to get profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Not authenticated');
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.patch(
        '${ApiEndpoints.users}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException('Failed to update profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw AuthenticationException('Not authorized to update this profile');
      }
      throw ServerException(e.message ?? 'Server error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
