import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(email, password);
      
      // Cache access token
      final token = result['accessToken'] as String;
      await localDataSource.cacheToken(token);
      
      // Cache refresh token
      final refreshToken = result['refreshToken'] as String?;
      if (refreshToken != null) {
        await localDataSource.cacheRefreshToken(refreshToken);
      }
      
      // Cache user
      final user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      await localDataSource.cacheUser(user);
      
      return Right(result);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
    String role = 'OPERATOR',
  }) async {
    try {
      final result = await remoteDataSource.register(email, password, name, role);
      
      // Cache access token
      final token = result['accessToken'] as String;
      await localDataSource.cacheToken(token);
      
      // Cache refresh token
      final refreshToken = result['refreshToken'] as String?;
      if (refreshToken != null) {
        await localDataSource.cacheRefreshToken(refreshToken);
      }
      
      // Cache user
      final user = UserModel.fromJson(result['user'] as Map<String, dynamic>);
      await localDataSource.cacheUser(user);
      
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      // Always fetch fresh data from server to ensure up-to-date profile
      final user = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(user);
      
      return Right(_mapUserModelToEntity(user));
    } on AuthenticationException catch (e) {
      // If server fails, try cached user as fallback
      try {
        final cachedUser = await localDataSource.getUser();
        if (cachedUser != null) {
          return Right(_mapUserModelToEntity(cachedUser));
        }
      } catch (_) {}
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      // If server fails, try cached user as fallback
      try {
        final cachedUser = await localDataSource.getUser();
        if (cachedUser != null) {
          return Right(_mapUserModelToEntity(cachedUser));
        }
      } catch (_) {}
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? password,
    String? networkName,
  }) async {
    try {
      final cachedUser = await localDataSource.getUser();
      if (cachedUser == null) {
        return Left(AuthenticationFailure('User not found'));
      }

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (password != null) data['password'] = password;
      if (networkName != null) data['networkName'] = networkName;

      final updatedUser = await remoteDataSource.updateProfile(cachedUser.id, data);
      await localDataSource.cacheUser(updatedUser);

      return Right(_mapUserModelToEntity(updatedUser));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  User _mapUserModelToEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      networkName: model.networkName,
      role: model.role,
      isActive: model.isActive,
      createdAt: model.createdAt,
      subscription: model.subscription,
    );
  }
}
