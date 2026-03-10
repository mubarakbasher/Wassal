import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int activeUsers;
  final int totalUsers;
  final int totalRouters;
  final bool isOnline;
  final double totalRevenue;
  final List<FlSpot> activityHistory;
  final String? refreshError;

  const DashboardLoaded({
    required this.activeUsers,
    required this.totalUsers,
    required this.totalRouters,
    required this.isOnline,
    this.totalRevenue = 0.0,
    this.activityHistory = const [],
    this.refreshError,
  });

  DashboardLoaded copyWith({
    int? activeUsers,
    int? totalUsers,
    int? totalRouters,
    bool? isOnline,
    double? totalRevenue,
    List<FlSpot>? activityHistory,
    String? Function()? refreshError,
  }) {
    return DashboardLoaded(
      activeUsers: activeUsers ?? this.activeUsers,
      totalUsers: totalUsers ?? this.totalUsers,
      totalRouters: totalRouters ?? this.totalRouters,
      isOnline: isOnline ?? this.isOnline,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      activityHistory: activityHistory ?? this.activityHistory,
      refreshError: refreshError != null ? refreshError() : this.refreshError,
    );
  }

  @override
  List<Object?> get props => [activeUsers, totalUsers, totalRouters, isOnline, totalRevenue, activityHistory, refreshError];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
