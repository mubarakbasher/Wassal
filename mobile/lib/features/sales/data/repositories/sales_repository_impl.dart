import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/sales_remote_data_source.dart';
import '../../data/models/sales_model.dart';
import '../../data/models/sales_history_item.dart';
import '../../domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;

  SalesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SalesData>>> getSalesChart(String range) async {
    try {
      final sales = await remoteDataSource.getSalesChart(range: range);
      return Right(sales);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesHistoryItem>>> getSalesHistory() async {
    try {
      final history = await remoteDataSource.getSalesHistory();
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
