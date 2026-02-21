import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/voucher_remote_data_source.dart';
import '../datasources/voucher_local_data_source.dart';
import '../models/voucher_model.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource remoteDataSource;
  final VoucherLocalDataSource? localDataSource;

  VoucherRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  /// Check if device has internet connectivity
  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (e) {
      return true; // Assume connected if check fails
    }
  }

  @override
  Future<Either<String, List<Map<String, dynamic>>>> getRouters() async {
    try {
      final result = await remoteDataSource.getRouters();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<HotspotProfile>>> getProfiles(String routerId) async {
    try {
      final result = await remoteDataSource.getProfiles(routerId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Voucher>>> generateVoucher({
    required String routerId,
    String? profileId,
    String? mikrotikProfile,
    required String planName,
    required double price,
    int? duration,
    int? dataLimit,
    int? quantity,
    String? charset,
    String? authType,
    String? countType,
  }) async {
    try {
      final result = await remoteDataSource.generateVoucher(
        routerId: routerId,
        profileId: profileId,
        mikrotikProfile: mikrotikProfile,
        planName: planName,
        price: price,
        duration: duration,
        dataLimit: dataLimit,
        quantity: quantity,
        charset: charset,
        authType: authType,
        countType: countType,
      );
      
      // Invalidate cache after generating new vouchers
      await localDataSource?.clearCache();
      
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Voucher>>> getVouchers({
    String? routerId,
    String? status,
  }) async {
    final hasConnection = await _hasConnectivity();
    
    // Try to fetch from network first
    if (hasConnection) {
      try {
        final result = await remoteDataSource.getVouchers(
          routerId: routerId,
          status: status,
        );
        
        // Cache the results
        if (localDataSource != null) {
          await localDataSource!.cacheVouchers(
            result.map((v) => v as VoucherModel).toList(),
          );
        }
        
        return Right(result);
      } catch (e) {
        // If network fails, try cache
        return _getFromCacheOrFail(e.toString());
      }
    }
    
    // No connection, use cache
    return _getFromCacheOrFail('No internet connection');
  }

  Future<Either<String, List<Voucher>>> _getFromCacheOrFail(String networkError) async {
    if (localDataSource == null) {
      return Left(networkError);
    }
    
    try {
      final cached = await localDataSource!.getCachedVouchers();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(networkError);
    } catch (e) {
      return Left(networkError);
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getStatistics({String? routerId}) async {
    final hasConnection = await _hasConnectivity();
    
    if (hasConnection) {
      try {
        final result = await remoteDataSource.getStatistics(routerId: routerId);
        
        // Cache statistics
        if (localDataSource != null) {
          await localDataSource!.cacheStatistics(result, routerId: routerId);
        }
        
        return Right(result);
      } catch (e) {
        // Try cache on failure
        return _getStatsFromCacheOrFail(e.toString(), routerId);
      }
    }
    
    return _getStatsFromCacheOrFail('No internet connection', routerId);
  }

  Future<Either<String, Map<String, dynamic>>> _getStatsFromCacheOrFail(
    String networkError,
    String? routerId,
  ) async {
    if (localDataSource == null) {
      return Left(networkError);
    }
    
    try {
      final cached = await localDataSource!.getCachedStatistics(routerId: routerId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(networkError);
    } catch (e) {
      return Left(networkError);
    }
  }

  @override
  Future<Either<String, void>> deleteVouchers(List<String> ids) async {
    try {
      if (await _hasConnectivity()) {
        await remoteDataSource.deleteVouchers(ids);
        return const Right(null);
      }
      return const Left('No internet connection');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
