import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String username;
  final String? ipAddress;
  final String? macAddress;
  final int bytesIn;
  final int bytesOut;
  final int uptime; // in seconds
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final String routerId;
  final String? routerName;
  final String? voucherId;

  const Session({
    required this.id,
    required this.username,
    this.ipAddress,
    this.macAddress,
    required this.bytesIn,
    required this.bytesOut,
    required this.uptime,
    required this.startTime,
    this.endTime,
    required this.isActive,
    required this.routerId,
    this.routerName,
    this.voucherId,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        ipAddress,
        macAddress,
        bytesIn,
        bytesOut,
        uptime,
        startTime,
        endTime,
        isActive,
        routerId,
        routerName,
        voucherId,
      ];
}
