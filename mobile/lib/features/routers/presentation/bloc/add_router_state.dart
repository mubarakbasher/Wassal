import 'package:equatable/equatable.dart';

abstract class AddRouterState extends Equatable {
  const AddRouterState();

  @override
  List<Object> get props => [];
}

class AddRouterInitial extends AddRouterState {}

class AddRouterLoading extends AddRouterState {}

class AddRouterSuccess extends AddRouterState {}

class AddRouterFailure extends AddRouterState {
  final String message;

  const AddRouterFailure(this.message);

  @override
  List<Object> get props => [message];
}
