import 'package:dartz/dartz.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/voucher.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../datasources/voucher_remote_data_source.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource remoteDataSource;

  VoucherRepositoryImpl({required this.remoteDataSource});

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
    required String profileId,
    required String planName,
    required double price,
    int? duration,
    int? dataLimit,
    int? quantity,
  }) async {
     try {
      final result = await remoteDataSource.generateVoucher(
          routerId: routerId,
          profileId: profileId,
          planName: planName,
          price: price,
          duration: duration,
          dataLimit: dataLimit,
          quantity: quantity
      );
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
    try {
      final result = await remoteDataSource.getVouchers(
        routerId: routerId,
        status: status,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
