import 'package:equatable/equatable.dart';
import '../../data/models/sales_model.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object?> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<SalesData> sales;

  const SalesLoaded({required this.sales});

  @override
  List<Object?> get props => [sales];
}

class SalesHistoryLoaded extends SalesState {
  final List<dynamic> history; // Using dynamic or SalesHistoryItem

  const SalesHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

class SalesError extends SalesState {
  final String message;

  const SalesError({required this.message});

  @override
  List<Object?> get props => [message];
}
