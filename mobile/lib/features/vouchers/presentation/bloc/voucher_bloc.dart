import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/voucher_repository.dart';
import 'voucher_event.dart';
import 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final VoucherRepository repository;
  static const int _pageSize = 20;

  VoucherBloc({required this.repository}) : super(VoucherInitial()) {
    on<LoadVoucherFormData>(_onLoadFormData);
    on<SelectRouter>(_onSelectRouter);
    on<GenerateVoucherEvent>(_onGenerateVoucher);
    on<LoadVouchersEvent>(_onLoadVouchers);
    on<LoadMoreVouchersEvent>(_onLoadMoreVouchers);
    on<LoadVoucherStats>(_onLoadVoucherStats);
    on<DeleteVouchersEvent>(_onDeleteVouchers);
  }

  Future<void> _onDeleteVouchers(
    DeleteVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    // Optimistic Update: Immediately remove from list
    final currentState = state;
    if (currentState is VouchersListLoaded) {
      final updatedVouchers = currentState.vouchers
        .where((v) => !event.voucherIds.contains(v.id))
        .toList();
      
      emit(currentState.copyWith(
        vouchers: updatedVouchers,
        // Reset selection in UI will happen via listener or UI state
      ));
      
      // Call repository to actually delete
      // TODO: Implement deleteVouchers in repository
      // For now we assume success or handle error silently/via snackbar in UI
      // await repository.deleteVouchers(event.voucherIds); 
    }
  }

  Future<void> _onLoadVoucherStats(
    LoadVoucherStats event,
    Emitter<VoucherState> emit,
  ) async {
   // Don't overwrite form data state (user is on generate page)
   if (state is VoucherFormDataLoaded) return;

   // We don't want to emit loading here to avoid full page flicker
     // Instead we could emit a background loading state if needed, but for now we'll just emit new stats
     final result = await repository.getStatistics(routerId: event.routerId);
     
     result.fold(
        (failure) {
            // Ignore failure for stats polling or handle silently
        },
        (stats) {
            final currentState = state;
            if (currentState is VouchersListLoaded) {
                 // Convert map to int map for safety
                 final safeStats = stats.map((key, value) => MapEntry(key, value is int ? value : (int.tryParse(value.toString()) ?? 0)));
                 
                 emit(VouchersListLoaded(
                   vouchers: currentState.vouchers,
                   stats: safeStats,
                 ));
            } else {
                 emit(VoucherStatsLoaded(stats));
            }
        }
     );
  }

  Future<void> _onLoadFormData(
    LoadVoucherFormData event,
    Emitter<VoucherState> emit,
  ) async {
    emit(VoucherLoading());
    final result = await repository.getRouters();
    
    result.fold(
      (failure) => emit(VoucherError(failure)),
      (routers) {
           // Default state with routers loaded
           emit(VoucherFormDataLoaded(routers: routers));
           
           // Auto-select first router if available (Optional, UX choice)
           if (routers.isNotEmpty) {
               add(SelectRouter(routers.first['id']));
           }
      },
    );
  }

  Future<void> _onSelectRouter(
    SelectRouter event,
    Emitter<VoucherState> emit,
  ) async {
      final currentState = state;
      if (currentState is VoucherFormDataLoaded) {
          // Update state to show loading profiles
          emit(currentState.copyWith(
              selectedRouterId: event.routerId,
              isLoadingProfiles: true,
              profiles: [], // Clear previous profiles
          ));

          final result = await repository.getProfiles(event.routerId);
           result.fold(
              (failure) => emit(VoucherError(failure)), // Or handle profile error gracefully within FormDataLoaded
              (profiles) {
                  // Emit new state with profiles
                  emit(currentState.copyWith(
                      selectedRouterId: event.routerId,
                      isLoadingProfiles: false,
                      profiles: profiles,
                  ));
              }
           );
      }
  }

  Future<void> _onGenerateVoucher(
    GenerateVoucherEvent event,
    Emitter<VoucherState> emit,
  ) async {
    final currentState = state;
    if (currentState is VoucherFormDataLoaded) {
      emit(VoucherGenerating(
        routers: currentState.routers,
        selectedRouterId: currentState.selectedRouterId,
        profiles: currentState.profiles,
        isLoadingProfiles: currentState.isLoadingProfiles,
      ));
    } else {
      emit(VoucherLoading());
    }
      final result = await repository.generateVoucher(
          routerId: event.routerId,
          profileId: event.profileId,
          mikrotikProfile: event.mikrotikProfile,
          planName: event.planName,
          price: event.price,
          duration: event.duration,
          dataLimit: event.dataLimit,
          quantity: event.quantity,
          charset: event.charset,
          authType: event.authType,
          countType: event.countType,
      );

      result.fold(
          (failure) => emit(VoucherError(failure)),
          (vouchers) => emit(VoucherGenerated(vouchers)),
      );
  }

  Future<void> _onLoadVouchers(
    LoadVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
  // Don't overwrite state during active voucher generation
  if (state is VoucherGenerating) return;

  emit(VoucherLoading());
    final result = await repository.getVouchers(
      routerId: event.routerId,
      status: event.status,
    );
    
    result.fold(
      (failure) => emit(VoucherError(failure)),
      (vouchers) {
         // Client-side search filtering
         var filteredVouchers = vouchers;
         if (event.search != null && event.search!.isNotEmpty) {
           final searchLower = event.search!.toLowerCase();
           filteredVouchers = vouchers.where((v) =>
             v.username.toLowerCase().contains(searchLower) ||
             v.planName.toLowerCase().contains(searchLower) ||
             v.status.toLowerCase().contains(searchLower)
           ).toList();
         }
         
         // Calculate stats from all vouchers (not filtered)
         final activeCount = vouchers.where((v) => v.status == 'active').length;
         final totalRevenue = vouchers.fold<double>(0, (sum, v) => sum + v.price);
         
         // Paginate on client side for now
         final paginatedVouchers = filteredVouchers.take(_pageSize).toList();
         
         emit(VouchersListLoaded(
           vouchers: paginatedVouchers,
           stats: {
             'total': filteredVouchers.length,
             'active': activeCount,
             'totalRevenue': totalRevenue.toInt(),
           },
           hasReachedMax: filteredVouchers.length <= _pageSize,
           currentPage: 1,
           totalCount: filteredVouchers.length,
         ));
      },
    );
  }

  Future<void> _onLoadMoreVouchers(
    LoadMoreVouchersEvent event,
    Emitter<VoucherState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VouchersListLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;
    
    // Mark as loading more
    emit(currentState.copyWith(isLoadingMore: true));
    
    final result = await repository.getVouchers(
      routerId: event.routerId,
      status: event.status,
    );
    
    result.fold(
      (failure) {
        // Stop loading but don't show error for load more
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (vouchers) {
        // Apply search filter if needed
        var filteredVouchers = vouchers;
        if (event.search != null && event.search!.isNotEmpty) {
          final searchLower = event.search!.toLowerCase();
          filteredVouchers = vouchers.where((v) =>
            v.username.toLowerCase().contains(searchLower) ||
            v.planName.toLowerCase().contains(searchLower) ||
            v.status.toLowerCase().contains(searchLower)
          ).toList();
        }
        
        final nextPage = currentState.currentPage + 1;
        final startIndex = currentState.vouchers.length;
        final endIndex = startIndex + _pageSize;
        
        if (startIndex >= filteredVouchers.length) {
          emit(currentState.copyWith(
            hasReachedMax: true,
            isLoadingMore: false,
          ));
          return;
        }
        
        final newVouchers = filteredVouchers.skip(startIndex).take(_pageSize).toList();
        
        emit(currentState.copyWith(
          vouchers: [...currentState.vouchers, ...newVouchers],
          hasReachedMax: endIndex >= filteredVouchers.length,
          isLoadingMore: false,
          currentPage: nextPage,
        ));
      },
    );
  }
}
