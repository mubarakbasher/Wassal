import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/repositories/router_repository.dart';
import 'router_event.dart';
import 'router_state.dart';

class RouterBloc extends Bloc<RouterEvent, RouterState> {
  final RouterRepository repository;

  RouterBloc({required this.repository}) : super(const RouterInitial()) {
    on<LoadRoutersEvent>(_onLoadRouters);
    on<CreateRouterEvent>(_onCreateRouter);
    on<UpdateRouterEvent>(_onUpdateRouter);
    on<DeleteRouterEvent>(_onDeleteRouter);
    on<CheckRouterHealthEvent>(_onCheckHealth);
    on<GetRouterStatsEvent>(_onGetRouterStats);
    on<SelectRouterEvent>(_onSelectRouter);
  }

  Future<void> _onGetRouterStats(
    GetRouterStatsEvent event,
    Emitter<RouterState> emit,
  ) async {
    // Keep loading state separate so we don't clear list?
    // Or assume UI handles it. Let's emit Loading then Result.
    // Ideally we might want separate state or status, but RouterState is single-stream.
    // If we emit RouterLoading, we might lose list of routers if UI listens to generic RouterLoaded.
    // But RouterStatsLoaded is a distinct state.
    emit(const RouterLoading());

    final result = await repository.getRouterStats(event.id);

    result.fold(
      (failure) => emit(RouterError(failure.message)),
      (stats) => emit(RouterStatsLoaded(stats)),
    );
  }

  Future<void> _onLoadRouters(
    LoadRoutersEvent event,
    Emitter<RouterState> emit,
  ) async {
    emit(const RouterLoading());

    final result = await repository.getRouters();

    result.fold(
      (failure) => emit(RouterError(failure.message)),
      (routers) => emit(RouterLoaded(routers: routers)),
    );
  }

  Future<void> _onCreateRouter(
    CreateRouterEvent event,
    Emitter<RouterState> emit,
  ) async {
    emit(const RouterLoading());

    final result = await repository.createRouter(
      name: event.name,
      ipAddress: event.ipAddress,
      apiPort: event.apiPort,
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(RouterError(failure.message)),
      (router) async {
        emit(const RouterOperationSuccess('Router added successfully'));
        // Reload routers
        add(const LoadRoutersEvent());
      },
    );
  }

  Future<void> _onUpdateRouter(
    UpdateRouterEvent event,
    Emitter<RouterState> emit,
  ) async {
    emit(const RouterLoading());

    final result = await repository.updateRouter(
      id: event.id,
      name: event.name,
      ipAddress: event.ipAddress,
      apiPort: event.apiPort,
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(RouterError(failure.message)),
      (router) {
        emit(const RouterOperationSuccess('Router updated successfully'));
        // Reload routers
        add(const LoadRoutersEvent());
      },
    );
  }

  Future<void> _onDeleteRouter(
    DeleteRouterEvent event,
    Emitter<RouterState> emit,
  ) async {
    final result = await repository.deleteRouter(event.id);

    result.fold(
      (failure) => emit(RouterError(failure.message)),
      (_) {
        emit(const RouterOperationSuccess('Router deleted successfully'));
        // Reload routers
        add(const LoadRoutersEvent());
      },
    );
  }

  Future<void> _onCheckHealth(
    CheckRouterHealthEvent event,
    Emitter<RouterState> emit,
  ) async {
    final result = await repository.checkRouterHealth(event.id);

    result.fold(
      (failure) => emit(RouterError(failure.message)),
      (health) {
        // You can show health status in UI
        emit(RouterOperationSuccess('Health check completed'));
      },
    );
  }

  void _onSelectRouter(SelectRouterEvent event, Emitter<RouterState> emit) {
    if (state is RouterLoaded) {
      emit((state as RouterLoaded).copyWith(selectedRouter: event.router));
    }
  }
}
