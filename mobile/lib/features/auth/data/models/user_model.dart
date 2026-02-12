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
    print("DEBUG: Parsing User JSON: $json"); // Debug log
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: (json['name'] as String?) ?? '',
      networkName: json['networkName'] as String?,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subscription: json['subscription'] != null
          ? UserSubscription(
              status: json['subscription']['status'] as String,
              planName: json['subscription']['plan']['name'] as String,
              expiresAt: DateTime.parse(json['subscription']['expiresAt'] as String),
            )
          : null,
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
