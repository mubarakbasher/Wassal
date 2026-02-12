import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/sales_repository.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final SalesRepository repository;

  SalesBloc({required this.repository}) : super(SalesInitial()) {
    on<LoadSalesChartEvent>(_onLoadSalesChart);
    on<LoadSalesHistoryEvent>(_onLoadSalesHistory);
  }

  Future<void> _onLoadSalesHistory(
    LoadSalesHistoryEvent event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());
    final result = await repository.getSalesHistory();
    result.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (history) => emit(SalesHistoryLoaded(history: history)),
    );
  }

  Future<void> _onLoadSalesChart(
    LoadSalesChartEvent event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());

    final result = await repository.getSalesChart(event.range);

    result.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }
}
