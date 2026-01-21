import '../../../../core/api/api_client.dart';
// import '../../../../core/constants/app_constants.dart'; // No longer needed as ApiClient handles base url
import '../models/hotspot_profile_model.dart';
import '../models/voucher_model.dart';

abstract class VoucherRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRouters();
  Future<List<HotspotProfileModel>> getProfiles(String routerId);
  Future<List<VoucherModel>> generateVoucher({
    required String routerId,
    required String profileId,
    required String planName,
    required double price,
    int? duration,
    int? dataLimit,
    int? quantity,
  });
  Future<List<VoucherModel>> getVouchers({
    String? routerId,
    String? status,
  });
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final ApiClient apiClient;

  VoucherRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getRouters() async {
    final response = await apiClient.get('/routers');
    return List<Map<String, dynamic>>.from(response.data);
  }

  @override
  Future<List<HotspotProfileModel>> getProfiles(String routerId) async {
    final response = await apiClient.get(
      '/profiles',
      queryParameters: {'routerId': routerId},
    );
    return (response.data as List)
        .map((e) => HotspotProfileModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<VoucherModel>> generateVoucher({
    required String routerId,
    required String profileId,
    required String planName,
    required double price,
    int? duration,
    int? dataLimit,
    int? quantity,
  }) async {
    final response = await apiClient.post(
      '/vouchers',
      data: {
        'routerId': routerId,
        'profileId': profileId,
        'planName': planName,
        'price': price,
        'planType': duration != null ? 'TIME_BASED' : 'DATA_BASED',
        'duration': duration,
        'dataLimit': dataLimit,
        'quantity': quantity ?? 1,
      },
    );
    
    // Response wrapper: { count: 1, vouchers: [...] }
    final vouchersList = response.data['vouchers'] as List;
    return vouchersList.map((e) => VoucherModel.fromJson(e)).toList();
  }

  @override
  Future<List<VoucherModel>> getVouchers({
    String? routerId,
    String? status,
  }) async {
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
  }
}
