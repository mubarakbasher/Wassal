import 'package:equatable/equatable.dart';

class SalesData extends Equatable {
  final String date;
  final double amount;

  const SalesData({required this.date, required this.amount});
  
  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, amount];
}
