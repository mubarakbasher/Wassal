import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/error_handler.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getMyPayments();
  Future<BankInfo> getBankInfo();
  Future<void> uploadProof(String paymentId, File imageFile);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await apiClient.get(ApiEndpoints.myPayments);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw const ServerException('Failed to load payments');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BankInfo> getBankInfo() async {
    try {
      final response = await apiClient.get(ApiEndpoints.bankInfo);
      if (response.statusCode == 200) {
        return BankInfo.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Failed to load bank info');
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> uploadProof(String paymentId, File imageFile) async {
    try {
      final response = await apiClient.uploadFile(
        ApiEndpoints.uploadProof(paymentId),
        imageFile,
        fieldName: 'proof',
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const ServerException('Failed to upload proof');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
