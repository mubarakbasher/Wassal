import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../../core/constants/app_constants.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final Dio dio;
  Timer? _timer;
  List<FlSpot> _activityHistory = [];
  String? _currentRouterId;

  DashboardBloc({required this.dio}) : super(DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<RefreshDashboardStats>(_onRefreshDashboardStats);
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
        final routersResponse = await dio.get('${AppConstants.apiBaseUrl}/routers');
        final List routers = routersResponse.data as List;
        final totalRouters = routers.length;

        _currentRouterId = event.routerId;
        if (_currentRouterId == null && routers.isNotEmpty) {
            _currentRouterId = routers[0]['id'];
        }

        // Fetch initial data
        await _fetchAndEmitStats(emit, totalRouters);

        // Start polling
        _timer = Timer.periodic(const Duration(seconds: 5), (_) {
             add(RefreshDashboardStats());
        });

    } catch (e) {
      emit(DashboardError(e.toString()));
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

  Future<void> _fetchAndEmitStats(Emitter<DashboardState> emit, int totalRouters) async {
        int activeUsers = 0;
        int totalUsers = 0;
        bool isOnline = false;
        double revenue = 0.0;

        if (_currentRouterId != null) {
             try {
                final statsResponse = await dio.get('${AppConstants.apiBaseUrl}/routers/$_currentRouterId/stats');
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
