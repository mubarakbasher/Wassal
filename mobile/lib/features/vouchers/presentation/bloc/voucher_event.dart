import 'package:equatable/equatable.dart';

abstract class VoucherEvent extends Equatable {
  const VoucherEvent();

  @override
  List<Object?> get props => [];
}

class LoadVoucherFormData extends VoucherEvent {}

class SelectRouter extends VoucherEvent {
  final String routerId;
  const SelectRouter(this.routerId);

  @override
  List<Object?> get props => [routerId];
}

class GenerateVoucherEvent extends VoucherEvent {
  final String routerId;
  final String profileId;
  final String planName;
  final double price;
  final int? duration;
  final int? dataLimit;
  final int? quantity;

  const GenerateVoucherEvent({
    required this.routerId,
    required this.profileId,
    required this.planName,
    required this.price,
    this.duration,
    this.dataLimit,
    this.quantity,
  });

   @override
  List<Object?> get props => [routerId, profileId, planName, price, duration, dataLimit, quantity];
}

class LoadVouchersEvent extends VoucherEvent {
  final String? routerId;
  final String? status;
  final String? search;

  const LoadVouchersEvent({
    this.routerId,
    this.status,
    this.search,
  });

  @override
  List<Object?> get props => [routerId, status, search];
}
