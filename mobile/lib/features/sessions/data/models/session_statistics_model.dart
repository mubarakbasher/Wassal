import '../../domain/entities/session_statistics.dart';

class SessionStatisticsModel {
  final int totalSessions;
  final int activeSessions;
  final int totalBandwidthIn;
  final int totalBandwidthOut;
  final int averageUptime;

  SessionStatisticsModel({
    required this.totalSessions,
    required this.activeSessions,
    required this.totalBandwidthIn,
    required this.totalBandwidthOut,
    required this.averageUptime,
  });

  factory SessionStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SessionStatisticsModel(
      totalSessions: json['totalSessions'] as int,
      activeSessions: json['activeSessions'] as int,
      totalBandwidthIn: json['totalBandwidthIn'] as int,
      totalBandwidthOut: json['totalBandwidthOut'] as int,
      averageUptime: json['averageUptime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'activeSessions': activeSessions,
      'totalBandwidthIn': totalBandwidthIn,
      'totalBandwidthOut': totalBandwidthOut,
      'averageUptime': averageUptime,
    };
  }

  SessionStatistics toEntity() {
    return SessionStatistics(
      totalSessions: totalSessions,
      activeSessions: activeSessions,
      totalBandwidthIn: totalBandwidthIn,
      totalBandwidthOut: totalBandwidthOut,
      averageUptime: averageUptime,
    );
  }
}
