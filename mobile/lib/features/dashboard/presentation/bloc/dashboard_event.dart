import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardStats extends DashboardEvent {
  final String? routerId;

  const LoadDashboardStats([this.routerId]);

  @override
  List<Object?> get props => [routerId];
}

class RefreshDashboardStats extends DashboardEvent {}
