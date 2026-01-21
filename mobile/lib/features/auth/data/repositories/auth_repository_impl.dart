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
      
      // Cache token
      final token = result['accessToken'] as String;
      await localDataSource.cacheToken(token);
      
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
      
      // Cache token
      final token = result['accessToken'] as String;
      await localDataSource.cacheToken(token);
      
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
      // Try to get cached user first
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
       return Right(_mapUserModelToEntity(cachedUser));
      }
      
      // If not cached, fetch from remote
      final user = await remoteDataSource.getProfile();
      await localDataSource.cacheUser(user);
      
      return Right(_mapUserModelToEntity(user));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
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

  User _mapUserModelToEntity(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      role: model.role,
      isActive: model.isActive,
      createdAt: model.createdAt,
    );
  }
}
