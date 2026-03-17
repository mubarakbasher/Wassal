import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/router.dart';
import '../../domain/repositories/router_repository.dart';
import 'router_event.dart';
import 'router_state.dart';

class RouterBloc extends Bloc<RouterEvent, RouterState> {
  final RouterRepository repository;

  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 2);

  RouterBloc({required this.repository}) : super(const RouterInitial()) {
    on<LoadRoutersEvent>(_onLoadRouters);
    on<CreateRouterEvent>(_onCreateRouter);
    on<UpdateRouterEvent>(_onUpdateRouter);
    on<DeleteRouterEvent>(_onDeleteRouter);
    on<CheckRouterHealthEvent>(_onCheckHealth);
    on<GetRouterStatsEvent>(_onGetRouterStats);
    on<SelectRouterEvent>(_onSelectRouter);
    on<RefreshRouterStatusesEvent>(_onRefreshRouterStatuses);
  }

  Future<void> _onGetRouterStats(
    GetRouterStatsEvent event,
    Emitter<RouterState> emit,
  ) async {
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
    if (!event.statusOnly) {
      emit(const RouterLoading());
    }

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      final result = await repository.getRouters(statusOnly: event.statusOnly);

      final succeeded = result.fold<bool>(
        (failure) {
          if (attempt == _maxRetries ||
              !ErrorHandler.isNetworkErrorMessage(failure.message)) {
            emit(RouterError(failure.message));
            return false;
          }
          return false;
        },
        (routers) {
          emit(RouterLoaded(routers: routers));
          add(const RefreshRouterStatusesEvent());
          return true;
        },
      );

      if (succeeded) return;

      // Don't delay after the last failed attempt
      if (attempt < _maxRetries) {
        await Future.delayed(_baseRetryDelay * attempt);
      }
    }
  }

  /// Fires background health checks for each router and updates status in-place
  Future<void> _onRefreshRouterStatuses(
    RefreshRouterStatusesEvent event,
    Emitter<RouterState> emit,
  ) async {
    if (state is! RouterLoaded) return;
    final currentState = state as RouterLoaded;
    final routers = currentState.routers;
    if (routers.isEmpty) return;

    // Mark all as checking
    emit(currentState.copyWith(
      checkingStatuses: routers.map((r) => r.id).toSet(),
    ));

    // Check each router's health sequentially to avoid overwhelming the server
    for (final router in routers) {
      if (state is! RouterLoaded) return; // State changed, stop
      final loaded = state as RouterLoaded;

      final result = await repository.checkRouterHealth(router.id);

      result.fold(
        (_) {
          // On error, just remove from checking set
          if (state is RouterLoaded) {
            final s = state as RouterLoaded;
            final updated = Set<String>.from(s.checkingStatuses)..remove(router.id);
            emit(s.copyWith(checkingStatuses: updated));
          }
        },
        (health) {
          if (state is RouterLoaded) {
            final s = state as RouterLoaded;
            final newStatus = health['status'] ?? router.status;
            final lastSeenStr = health['lastSeen'];
            DateTime? lastSeen;
            if (lastSeenStr is String) {
              lastSeen = DateTime.tryParse(lastSeenStr);
            }

            final updatedRouters = s.routers.map((r) {
              if (r.id == router.id) {
                return Router(
                  id: r.id,
                  name: r.name,
                  ipAddress: r.ipAddress,
                  apiPort: r.apiPort,
                  username: r.username,
                  status: newStatus,
                  lastSeen: lastSeen ?? r.lastSeen,
                  createdAt: r.createdAt,
                );
              }
              return r;
            }).toList();

            final updated = Set<String>.from(s.checkingStatuses)..remove(router.id);
            emit(s.copyWith(routers: updatedRouters, checkingStatuses: updated));
          }
        },
      );
    }
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
