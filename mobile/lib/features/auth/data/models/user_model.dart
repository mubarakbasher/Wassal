import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.networkName,
    required super.role,
    required super.isActive,
    required super.createdAt,
    super.subscription,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription'] as Map<String, dynamic>?;
    UserSubscription? subscription;
    if (sub != null) {
      final plan = sub['plan'] as Map<String, dynamic>?;
      subscription = UserSubscription(
        status: sub['status'] as String? ?? 'UNKNOWN',
        planName: plan?['name'] as String? ?? 'Unknown Plan',
        expiresAt: sub['expiresAt'] != null
            ? DateTime.parse(sub['expiresAt'] as String)
            : DateTime.now(),
      );
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: (json['name'] as String?) ?? '',
      networkName: json['networkName'] as String?,
      role: json['role'] as String? ?? 'USER',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      subscription: subscription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'networkName': networkName,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      // We generally don't need to serialize subscription back to server for this app, 
      // but if we did, we'd map it here.
    };
  }
}
