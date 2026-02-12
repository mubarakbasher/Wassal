import 'package:equatable/equatable.dart';

class SessionStatistics extends Equatable {
  final int totalSessions;
  final int activeSessions;
  final int totalBandwidthIn;
  final int totalBandwidthOut;
  final int averageUptime;

  const SessionStatistics({
    required this.totalSessions,
    required this.activeSessions,
    required this.totalBandwidthIn,
    required this.totalBandwidthOut,
    required this.averageUptime,
  });

  @override
  List<Object?> get props => [
        totalSessions,
        activeSessions,
        totalBandwidthIn,
        totalBandwidthOut,
        averageUptime,
      ];
}
