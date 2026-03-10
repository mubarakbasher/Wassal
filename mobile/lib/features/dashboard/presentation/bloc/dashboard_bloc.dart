import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/utils/error_handler.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiClient apiClient;
  Timer? _timer;
  final List<FlSpot> _activityHistory = [];
  String? _currentRouterId;

  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 2);

  DashboardBloc({required this.apiClient}) : super(DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<RefreshDashboardStats>(_onRefreshDashboardStats);
    on<PauseDashboardPolling>(_onPauseDashboardPolling);
    on<ResumeDashboardPolling>(_onResumeDashboardPolling);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<bool> _hasConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return !result.contains(ConnectivityResult.none);
    } catch (_) {
      return true; // Assume connected if check fails; let the API call decide
    }
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    _timer?.cancel();

    if (!await _hasConnectivity()) {
      emit(const DashboardError('No internet connection.\n\nPlease check your Wi-Fi or mobile data and try again.'));
      return;
    }

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final routersResponse = await apiClient.get('/routers');
        final routersData = routersResponse.data;
        final List routers = routersData is List ? routersData : [];
        final totalRouters = routers.length;

        _currentRouterId = event.routerId;
        if (_currentRouterId == null && routers.isNotEmpty) {
          _currentRouterId = routers[0]['id'];
        }

        await _fetchAndEmitStats(emit, totalRouters);

        _timer = Timer.periodic(const Duration(seconds: 30), (_) {
          add(RefreshDashboardStats());
        });

        return;
      } catch (e) {
        if (attempt == _maxRetries) {
          emit(DashboardError(ErrorHandler.mapDioErrorToMessage(e)));
          return;
        }
        await Future.delayed(_baseRetryDelay * attempt);
      }
    }
  }

  Future<void> _onRefreshDashboardStats(
    RefreshDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    final previousState = state;

    try {
      int totalRouters = 0;
      if (previousState is DashboardLoaded) {
        totalRouters = previousState.totalRouters;
      }
      await _fetchAndEmitStats(emit, totalRouters);
    } catch (e) {
      if (previousState is DashboardLoaded) {
        emit(previousState.copyWith(
          refreshError: () => ErrorHandler.mapDioErrorToMessage(e),
        ));
      }
    }
  }

  void _onPauseDashboardPolling(
    PauseDashboardPolling event,
    Emitter<DashboardState> emit,
  ) {
    _timer?.cancel();
    _timer = null;
  }

  void _onResumeDashboardPolling(
    ResumeDashboardPolling event,
    Emitter<DashboardState> emit,
  ) {
    if (_timer == null && state is DashboardLoaded) {
      add(RefreshDashboardStats());
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        add(RefreshDashboardStats());
      });
    }
  }

  Future<void> _fetchAndEmitStats(Emitter<DashboardState> emit, int totalRouters) async {
    int activeUsers = 0;
    int totalUsers = 0;
    bool isOnline = false;
    double revenue = 0.0;

    if (_currentRouterId != null) {
      try {
        final statsResponse = await apiClient.get('/routers/$_currentRouterId/stats');
        final statsData = statsResponse.data;

        activeUsers = statsData['activeUsers'] ?? 0;
        totalUsers = statsData['totalVouchers'] ?? statsData['totalUsers'] ?? 0;
        isOnline = statsData['isOnline'] ?? false;

        var rev = statsData['totalRevenue'];
        if (rev is int) revenue = rev.toDouble();
        else if (rev is double) revenue = rev;
        else if (rev is String) revenue = double.tryParse(rev) ?? 0.0;
      } catch (_) {
        // Stats fetch failed — proceed with defaults
      }
    }

    double nextX = 0;
    if (_activityHistory.isNotEmpty) {
      nextX = _activityHistory.last.x + 1;
    }

    _activityHistory.add(FlSpot(nextX, activeUsers.toDouble()));

    if (_activityHistory.length > 20) {
      _activityHistory.removeAt(0);
    }

    emit(DashboardLoaded(
      activeUsers: activeUsers,
      totalUsers: totalUsers,
      totalRouters: totalRouters,
      isOnline: isOnline,
      totalRevenue: revenue,
      activityHistory: List.of(_activityHistory),
    ));
  }
}
