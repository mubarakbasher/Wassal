import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/router.dart';
import '../../domain/repositories/router_repository.dart';
import '../datasources/router_remote_data_source.dart';
import '../models/router_model.dart';

class RouterRepositoryImpl implements RouterRepository {
  final RouterRemoteDataSource remoteDataSource;

  RouterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Router>>> getRouters() async {
    try {
      final routers = await remoteDataSource.getRouters();
      return Right(routers.map(_mapToEntity).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Router>> getRouterById(String id) async {
    try {
      final router = await remoteDataSource.getRouterById(id);
      return Right(_mapToEntity(router));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Router>> createRouter({
    required String name,
    required String ipAddress,
    required int apiPort,
    required String username,
    required String password,
  }) async {
    try {
      final data = {
        'name': name,
        'ipAddress': ipAddress,
        'apiPort': apiPort,
        'username': username,
        'password': password,
      };
      
      final router = await remoteDataSource.createRouter(data);
      return Right(_mapToEntity(router));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Router>> updateRouter({
    required String id,
    required String name,
    required String ipAddress,
    required int apiPort,
    required String username,
    String? password,
  }) async {
    try {
      final data = {
        'name': name,
        'ipAddress': ipAddress,
        'apiPort': apiPort,
        'username': username,
        if (password != null) 'password': password,
      };
      
      final router = await remoteDataSource.updateRouter(id, data);
      return Right(_mapToEntity(router));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRouter(String id) async {
    try {
      await remoteDataSource.deleteRouter(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkRouterHealth(String id) async {
    try {
      final health = await remoteDataSource.checkRouterHealth(id);
      return Right(health);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRouterSystemInfo(String id) async {
    try {
      final info = await remoteDataSource.getRouterSystemInfo(id);
      return Right(info);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRouterStats(String id) async {
    try {
      final stats = await remoteDataSource.getRouterStats(id);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Router _mapToEntity(RouterModel model) {
    return Router(
      id: model.id,
      name: model.name,
      ipAddress: model.ipAddress,
      apiPort: model.apiPort,
      username: model.username,
      status: model.status,
      lastSeen: model.lastSeen,
      createdAt: model.createdAt,
    );
  }
}
