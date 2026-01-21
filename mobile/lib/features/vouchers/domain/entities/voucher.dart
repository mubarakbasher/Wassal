import 'package:equatable/equatable.dart';

class Voucher extends Equatable {
  final String id;
  final String username;
  final String password;
  final String planName;
  final double price;
  final String? profileName;
  final String? serialNumber;
  final String status;

  const Voucher({
    required this.id,
    required this.username,
    required this.password,
    required this.planName,
    required this.price,
    this.profileName,
    this.serialNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [id, username, password, planName, price, profileName, serialNumber, status];
}
