import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/error_handler.dart';
import '../models/sales_model.dart';
import '../models/sales_history_item.dart';

abstract class SalesRemoteDataSource {
  Future<List<SalesData>> getSalesChart({required String range});
  Future<List<SalesHistoryItem>> getSalesHistory();
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final ApiClient apiClient;

  SalesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SalesData>> getSalesChart({required String range}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.salesChart,
        queryParameters: {'range': range},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => SalesData.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load sales chart');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<SalesHistoryItem>> getSalesHistory() async {
    try {
      final response = await apiClient.get(ApiEndpoints.salesHistory);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => SalesHistoryItem.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load sales history');
      }
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.mapDioErrorToMessage(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
