import 'package:equatable/equatable.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesChartEvent extends SalesEvent {
  final String range; // 'DAILY' or 'MONTHLY'

  const LoadSalesChartEvent({required this.range});

  @override
  List<Object?> get props => [range];
}

class LoadSalesHistoryEvent extends SalesEvent {}
