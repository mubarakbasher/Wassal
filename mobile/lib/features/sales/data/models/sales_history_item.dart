import 'package:equatable/equatable.dart';

class SalesHistoryItem extends Equatable {
  final String id;
  final double amount;
  final String? customerName;
  final String soldAt;
  final String planName;
  final String routerName;

  const SalesHistoryItem({
    required this.id,
    required this.amount,
    this.customerName,
    required this.soldAt,
    required this.planName,
    required this.routerName,
  });

  factory SalesHistoryItem.fromJson(Map<String, dynamic> json) {
    return SalesHistoryItem(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      customerName: json['customerName'] as String?,
      soldAt: json['soldAt'] as String,
      planName: json['planName'] as String,
      routerName: json['routerName'] as String,
    );
  }

  @override
  List<Object?> get props => [id, amount, customerName, soldAt, planName, routerName];
}
