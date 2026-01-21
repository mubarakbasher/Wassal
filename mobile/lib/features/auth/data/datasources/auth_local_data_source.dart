import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getToken();
  Future<UserModel?> getUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    try {
      await secureStorage.write(
        key: AppConstants.accessTokenKey,
        value: token,
      );
    } catch (e) {
      throw CacheException('Failed to cache token');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await secureStorage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: AppConstants.accessTokenKey);
    } catch (e) {
      throw CacheException('Failed to get token');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = await secureStorage.read(key: AppConstants.userDataKey);
      if (userJson != null) {
        return UserModel.fromJson(jsonDecode(userJson));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: AppConstants.accessTokenKey);
      await secureStorage.delete(key: AppConstants.userDataKey);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}
