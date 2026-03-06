import 'package:equatable/equatable.dart';

class PaymentModel extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final String method;
  final String status;
  final String? proofUrl;
  final String? notes;
  final String planName;
  final int planDays;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.proofUrl,
    this.notes,
    required this.planName,
    required this.planDays,
    this.reviewedAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      amount: _parseDouble(json['amount']),
      currency: json['currency'] as String? ?? 'SDG',
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      proofUrl: json['proofUrl'] as String?,
      notes: json['notes'] as String?,
      planName: json['planName'] as String? ?? 'Unknown',
      planDays: json['planDays'] as int? ?? 0,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'].toString())
          : null,
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String get formattedAmount {
    final formatted = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(1);
    return '$formatted $currency';
  }

  @override
  List<Object?> get props => [id, amount, status, proofUrl, createdAt];
}

class BankInfo {
  final String bankName;
  final String accountName;
  final String accountNumber;

  const BankInfo({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      bankName: json['bankName'] as String? ?? '',
      accountName: json['accountName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
    );
  }
}
