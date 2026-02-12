import 'package:dartz/dartz.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/voucher.dart';

abstract class VoucherRepository {
  Future<Either<String, List<Map<String, dynamic>>>> getRouters();
  Future<Either<String, List<HotspotProfile>>> getProfiles(String routerId);
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
  });
  Future<Either<String, List<Voucher>>> getVouchers({
    String? routerId,
    String? status,
  });
  Future<Either<String, Map<String, dynamic>>> getStatistics({String? routerId});
  Future<Either<String, void>> deleteVouchers(List<String> ids);
}
