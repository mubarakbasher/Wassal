import '../../domain/entities/voucher.dart';

class VoucherModel extends Voucher {
  const VoucherModel({
    required super.id,
    required super.username,
    required super.password,
    required super.planName,
    required super.price,
    super.profileName,
    super.serialNumber,
    required super.status,
    super.duration,
    super.dataLimit,
    super.createdAt,
    super.expiresAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      planName: json['planName'],
      price: double.parse(json['price'].toString()),
      profileName: json['profile'] != null ? json['profile']['name'] : null,
      serialNumber: json['serialNumber'],
      status: json['status'] ?? 'active',
      duration: json['duration'] != null ? int.tryParse(json['duration'].toString()) : null,
      dataLimit: json['dataLimit'] != null ? int.tryParse(json['dataLimit'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'planName': planName,
      'price': price,
      'profileName': profileName,
      'serialNumber': serialNumber,
      'status': status,
      'duration': duration,
      'dataLimit': dataLimit,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
