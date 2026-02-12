import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/api/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/update_profile_dto.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String userId, UpdateProfileDto dto);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  ProfileRemoteDataSourceImpl({
    required this.apiClient,
    required this.secureStorage,
  });

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.get('/auth/profile');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get profile: ${e.message}');
    }
  }

  @override
  Future<UserModel> updateProfile(String userId, UpdateProfileDto dto) async {
    try {
      final response = await apiClient.patch(
        '/users/$userId',
        data: dto.toJson(),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('You do not have permission to update this profile');
      }
      throw Exception('Failed to update profile: ${e.message}');
    }
  }
}
