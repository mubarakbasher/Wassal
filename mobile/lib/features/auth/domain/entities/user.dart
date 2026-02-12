import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? networkName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final UserSubscription? subscription;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.networkName,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.subscription,
  });

  @override
  List<Object?> get props => [id, email, name, networkName, role, isActive, createdAt, subscription];
}

class UserSubscription extends Equatable {
  final String status;
  final String planName;
  final DateTime expiresAt;

  const UserSubscription({
    required this.status,
    required this.planName,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [status, planName, expiresAt];
}
