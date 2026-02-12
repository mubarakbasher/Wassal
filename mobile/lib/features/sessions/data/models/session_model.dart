import '../../domain/entities/session.dart';

class SessionModel {
  final String id;
  final String username;
  final String? ipAddress;
  final String? macAddress;
  final int bytesIn;
  final int bytesOut;
  final int uptime;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isActive;
  final String routerId;
  final String? routerName;
  final String? voucherId;

  SessionModel({
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

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      username: json['username'] as String,
      ipAddress: json['ipAddress'] as String?,
      macAddress: json['macAddress'] as String?,
      bytesIn: _parseBigInt(json['bytesIn']),
      bytesOut: _parseBigInt(json['bytesOut']),
      uptime: json['uptime'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      isActive: json['isActive'] as bool,
      routerId: json['routerId'] as String,
      routerName: json['router'] != null ? json['router']['name'] as String? : null,
      voucherId: json['voucherId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'bytesIn': bytesIn,
      'bytesOut': bytesOut,
      'uptime': uptime,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
      'routerId': routerId,
      'voucherId': voucherId,
    };
  }

  Session toEntity() {
    return Session(
      id: id,
      username: username,
      ipAddress: ipAddress,
      macAddress: macAddress,
      bytesIn: bytesIn,
      bytesOut: bytesOut,
      uptime: uptime,
      startTime: startTime,
      endTime: endTime,
      isActive: isActive,
      routerId: routerId,
      routerName: routerName,
      voucherId: voucherId,
    );
  }

  static int _parseBigInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
