import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/sales_model.dart';
import '../../data/models/sales_history_item.dart';

abstract class SalesRepository {
  Future<Either<Failure, List<SalesData>>> getSalesChart(String range);
  Future<Either<Failure, List<SalesHistoryItem>>> getSalesHistory();
}
