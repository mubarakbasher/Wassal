class RouterModel {
  final String id;
  final String name;
  final String ipAddress;
  final int apiPort;
  final String username;
  final String status;
  final DateTime? lastSeen;
  final DateTime createdAt;

  RouterModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.apiPort,
    required this.username,
    required this.status,
    this.lastSeen,
    required this.createdAt,
  });

  factory RouterModel.fromJson(Map<String, dynamic> json) {
    return RouterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      apiPort: json['apiPort'] as int,
      username: json['username'] as String,
      status: json['status'] as String,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ipAddress': ipAddress,
      'apiPort': apiPort,
      'username': username,
      'status': status,
      'lastSeen': lastSeen?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
