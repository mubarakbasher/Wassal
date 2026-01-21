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

  const DashboardLoaded({
    required this.activeUsers,
    required this.totalUsers,
    required this.totalRouters,
    required this.isOnline,
    this.totalRevenue = 0.0,
    this.activityHistory = const [],
  });

  @override
  List<Object?> get props => [activeUsers, totalUsers, totalRouters, isOnline, totalRevenue, activityHistory];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
