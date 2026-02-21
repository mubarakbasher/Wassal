import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/error_handler.dart';
import '../models/hotspot_profile_model.dart';
import '../models/voucher_model.dart';

abstract class VoucherRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRouters();
  Future<List<HotspotProfileModel>> getProfiles(String routerId);
  Future<List<VoucherModel>> generateVoucher({
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
  });
  Future<List<VoucherModel>> getVouchers({
    String? routerId,
    String? status,
  });
  Future<Map<String, dynamic>> getStatistics({String? routerId});
  Future<void> deleteVouchers(List<String> ids);
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final ApiClient apiClient;

  VoucherRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getRouters() async {
    try {
      final response = await apiClient.get('/routers');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<HotspotProfileModel>> getProfiles(String routerId) async {
    try {
      final response = await apiClient.get(
        '/routers/$routerId/profiles/mikrotik',
      );
      // Map Mikrotik response to HotspotProfileModel
      // Mikrotik returns [{ ".id": "*1", "name": "default", ... }]
      return (response.data as List).map((e) {
        return HotspotProfileModel(
          id: e['.id'] ?? e['id'] ?? 'unknown',
          name: e['name'] ?? 'Unknown',
          rateLimit: e['rate-limit'],
        );
      }).toList();
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> generateVoucher({
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
      final data = {
        'routerId': routerId,
        'planName': planName,
        'price': price,
        'planType': duration != null ? 'TIME_BASED' : 'DATA_BASED',
        'duration': duration,
        'dataLimit': dataLimit,
        'quantity': quantity ?? 1,
        'charset': charset ?? 'ALPHANUMERIC',
        'authType': authType ?? 'USER_SAME_PASS',
      };

      if (profileId != null) data['profileId'] = profileId;
      if (mikrotikProfile != null) data['mikrotikProfile'] = mikrotikProfile;
      if (countType != null) data['countType'] = countType;

      final response = await apiClient.post(
        '/vouchers',
        data: data,
      );

      // Response wrapper: { count: 1, vouchers: [...] }
      final vouchersList = response.data['vouchers'] as List;
      return vouchersList.map((e) => VoucherModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getVouchers({
    String? routerId,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (routerId != null) queryParams['routerId'] = routerId;
      if (status != null) queryParams['status'] = status;

      final response = await apiClient.get(
        '/vouchers',
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((e) => VoucherModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics({String? routerId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (routerId != null) queryParams['routerId'] = routerId;

      final response = await apiClient.get(
        '/vouchers/statistics',
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVouchers(List<String> ids) async {
    try {
      // Assuming backend supports bulk delete via body on DELETE
      // Or POST /vouchers/delete. Let's try standard DELETE with data
      await apiClient.delete(
        '/vouchers',
        data: {'ids': ids},
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
