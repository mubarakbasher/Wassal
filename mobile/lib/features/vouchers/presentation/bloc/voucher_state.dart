import 'package:equatable/equatable.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/voucher.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();
  
  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {}

class VoucherLoading extends VoucherState {}

class VoucherFormDataLoaded extends VoucherState {
  final List<Map<String, dynamic>> routers;
  final String? selectedRouterId;
  final List<HotspotProfile> profiles;
  final bool isLoadingProfiles;

  const VoucherFormDataLoaded({
    this.routers = const [],
    this.selectedRouterId,
    this.profiles = const [],
    this.isLoadingProfiles = false,
  });

  @override
  List<Object?> get props => [routers, selectedRouterId, profiles, isLoadingProfiles];

  VoucherFormDataLoaded copyWith({
    List<Map<String, dynamic>>? routers,
    String? selectedRouterId,
    List<HotspotProfile>? profiles,
    bool? isLoadingProfiles,
  }) {
    return VoucherFormDataLoaded(
      routers: routers ?? this.routers,
      selectedRouterId: selectedRouterId ?? this.selectedRouterId,
      profiles: profiles ?? this.profiles,
      isLoadingProfiles: isLoadingProfiles ?? this.isLoadingProfiles,
    );
  }
}

class VoucherGenerated extends VoucherState {
  final List<Voucher> vouchers;

  const VoucherGenerated(this.vouchers);

  @override
  List<Object?> get props => [vouchers];
}

class VouchersListLoaded extends VoucherState {
  final List<Voucher> vouchers;
  final Map<String, int> stats;

  const VouchersListLoaded({
    required this.vouchers,
    this.stats = const {},
  });

  @override
  List<Object?> get props => [vouchers, stats];
}

class VoucherError extends VoucherState {
  final String message;

  const VoucherError(this.message);

  @override
  List<Object?> get props => [message];
}
