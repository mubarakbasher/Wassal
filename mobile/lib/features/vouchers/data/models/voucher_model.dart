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
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      planName: json['planName'],
      price: (json['price'] as num).toDouble(),
      profileName: json['profile'] != null ? json['profile']['name'] : null,
      serialNumber: json['serialNumber'],
      status: json['status'] ?? 'active', // Default to active if missing
    );
  }
}
