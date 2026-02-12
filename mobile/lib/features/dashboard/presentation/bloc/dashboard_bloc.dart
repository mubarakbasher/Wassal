import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/utils/error_handler.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ApiClient apiClient;
  Timer? _timer;
  final List<FlSpot> _activityHistory = [];
  String? _currentRouterId;

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

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    _timer?.cancel();

    try {
        final routersResponse = await apiClient.get('/routers');
        final List routers = routersResponse.data as List;
        final totalRouters = routers.length;

        _currentRouterId = event.routerId;
        if (_currentRouterId == null && routers.isNotEmpty) {
            _currentRouterId = routers[0]['id'];
        }

        // Fetch initial data
        await _fetchAndEmitStats(emit, totalRouters);

        // Start polling every 30 seconds (was 5 seconds - too aggressive)
        _timer = Timer.periodic(const Duration(seconds: 30), (_) {
             add(RefreshDashboardStats());
        });

    } catch (e) {
      emit(DashboardError(ErrorHandler.mapDioErrorToMessage(e)));
    }
  }

  Future<void> _onRefreshDashboardStats(
    RefreshDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
       // We assume totalRouters doesn't change often, or we could refetch it too. 
       // For efficiency, we reuse the last known count or pass a placeholder if we stored it in class.
       // Ideally we store 'totalRouters' in class state too.
       // But 'state' has it.
       int totalRouters = 0;
       if (state is DashboardLoaded) {
           totalRouters = (state as DashboardLoaded).totalRouters;
       }
       await _fetchAndEmitStats(emit, totalRouters);
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
    // Only restart the timer if we have previously loaded data
    if (_timer == null && state is DashboardLoaded) {
      // Refresh immediately when resuming
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
                
             } catch (e) {
                 // ignore errors during poll
             }
        }

        // Update History
        // If history is empty, start X at 0. Otherwise X = lastX + 1
        double nextX = 0;
        if (_activityHistory.isNotEmpty) {
            nextX = _activityHistory.last.x + 1;
        }
        
        // Add new point
        _activityHistory.add(FlSpot(nextX, activeUsers.toDouble()));
        
        // Keep max 20 points
        if (_activityHistory.length > 20) {
            _activityHistory.removeAt(0);
        }
        
        emit(DashboardLoaded(
            activeUsers: activeUsers,
            totalUsers: totalUsers,
            totalRouters: totalRouters,
            isOnline: isOnline,
            totalRevenue: revenue,
            activityHistory: List.of(_activityHistory), // Send copy
        ));
  }
}
