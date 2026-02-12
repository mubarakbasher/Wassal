import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/router.dart';

abstract class RouterRepository {
  Future<Either<Failure, List<Router>>> getRouters();
  
  Future<Either<Failure, Router>> getRouterById(String id);
  
  Future<Either<Failure, Router>> createRouter({
    required String name,
    required String ipAddress,
    required int apiPort,
    required String username,
    required String password,
  });
  
  Future<Either<Failure, Router>> updateRouter({
    required String id,
    required String name,
    required String ipAddress,
    required int apiPort,
    required String username,
    String? password,
  });
  
  Future<Either<Failure, void>> deleteRouter(String id);
  
  Future<Either<Failure, Map<String, dynamic>>> checkRouterHealth(String id);
  
  Future<Either<Failure, Map<String, dynamic>>> getRouterSystemInfo(String id);
  
  Future<Either<Failure, Map<String, dynamic>>> getRouterStats(String id);
}
