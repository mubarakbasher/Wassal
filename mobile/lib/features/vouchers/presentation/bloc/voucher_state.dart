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

class VoucherGenerating extends VoucherFormDataLoaded {
  const VoucherGenerating({
    required super.routers,
    super.selectedRouterId,
    super.profiles,
    super.isLoadingProfiles,
  });
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
  final bool hasReachedMax;
  final bool isLoadingMore;
  final int currentPage;
  final int totalCount;

  const VouchersListLoaded({
    required this.vouchers,
    this.stats = const {},
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [vouchers, stats, hasReachedMax, isLoadingMore, currentPage, totalCount];

  VouchersListLoaded copyWith({
    List<Voucher>? vouchers,
    Map<String, int>? stats,
    bool? hasReachedMax,
    bool? isLoadingMore,
    int? currentPage,
    int? totalCount,
  }) {
    return VouchersListLoaded(
      vouchers: vouchers ?? this.vouchers,
      stats: stats ?? this.stats,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class VoucherStatsLoaded extends VoucherState {
  final Map<String, dynamic> stats;
  const VoucherStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class VoucherError extends VoucherState {
  final String message;

  const VoucherError(this.message);

  @override
  List<Object?> get props => [message];
}
