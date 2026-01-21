import 'package:equatable/equatable.dart';

class Router extends Equatable {
  final String id;
  final String name;
  final String ipAddress;
  final int apiPort;
  final String username;
  final String status;
  final DateTime? lastSeen;
  final DateTime createdAt;

  const Router({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.apiPort,
    required this.username,
    required this.status,
    this.lastSeen,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        ipAddress,
        apiPort,
        username,
        status,
        lastSeen,
        createdAt,
      ];
}
