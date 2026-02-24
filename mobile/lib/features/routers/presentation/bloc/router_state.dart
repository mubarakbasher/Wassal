import 'package:equatable/equatable.dart';
import '../../domain/entities/router.dart';

abstract class RouterState extends Equatable {
  const RouterState();

  @override
  List<Object?> get props => [];
}

class RouterInitial extends RouterState {
  const RouterInitial();
}

class RouterLoading extends RouterState {
  const RouterLoading();
}

class RouterLoaded extends RouterState {
  final List<Router> routers;
  final Router? selectedRouter;
  final Set<String> checkingStatuses;

  const RouterLoaded({
    required this.routers,
    this.selectedRouter,
    this.checkingStatuses = const {},
  });

  @override
  List<Object?> get props => [routers, selectedRouter, checkingStatuses];

  RouterLoaded copyWith({
    List<Router>? routers,
    Router? selectedRouter,
    Set<String>? checkingStatuses,
  }) {
    return RouterLoaded(
      routers: routers ?? this.routers,
      selectedRouter: selectedRouter ?? this.selectedRouter,
      checkingStatuses: checkingStatuses ?? this.checkingStatuses,
    );
  }
}

class RouterError extends RouterState {
  final String message;

  const RouterError(this.message);

  @override
  List<Object?> get props => [message];
}

class RouterOperationSuccess extends RouterState {
  final String message;

  const RouterOperationSuccess(this.message);

  List<Object?> get props => [message];
}

class RouterStatsLoaded extends RouterState {
  final Map<String, dynamic> stats;

  const RouterStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}
