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
  final String? profileId;
  final String? mikrotikProfile;
  final String planName;
  final double price;
  final int? duration;
  final int? dataLimit;
  final int? quantity;
  final String? charset;
  final String? authType;
  final String? countType; // WALL_CLOCK or ONLINE_ONLY

  const GenerateVoucherEvent({
    required this.routerId,
    this.profileId,
    this.mikrotikProfile,
    required this.planName,
    required this.price,
    this.duration,
    this.dataLimit,
    this.quantity,
    this.charset,
    this.authType,
    this.countType,
  });

   @override
  List<Object?> get props => [routerId, profileId, mikrotikProfile, planName, price, duration, dataLimit, quantity, charset, authType, countType];
}

class LoadVouchersEvent extends VoucherEvent {
  final String? routerId;
  final String? status;
  final String? search;
  final bool refresh; // Force refresh from server

  const LoadVouchersEvent({
    this.routerId,
    this.status,
    this.search,
    this.refresh = true,
  });

  @override
  List<Object?> get props => [routerId, status, search, refresh];
}

class LoadMoreVouchersEvent extends VoucherEvent {
  final String? routerId;
  final String? status;
  final String? search;

  const LoadMoreVouchersEvent({
    this.routerId,
    this.status,
    this.search,
  });

  @override
  List<Object?> get props => [routerId, status, search];
}

class LoadVoucherStats extends VoucherEvent {
  final String? routerId;
  const LoadVoucherStats({this.routerId});

  @override
  List<Object?> get props => [routerId];
}

class DeleteVouchersEvent extends VoucherEvent {
  final List<String> voucherIds;
  const DeleteVouchersEvent(this.voucherIds);

  @override
  List<Object?> get props => [voucherIds];
}
