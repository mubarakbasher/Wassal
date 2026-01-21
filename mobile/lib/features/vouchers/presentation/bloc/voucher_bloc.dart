import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/voucher_repository.dart';
import 'voucher_event.dart';
import 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final VoucherRepository repository;

  VoucherBloc({required this.repository}) : super(VoucherInitial()) {
    on<LoadVoucherFormData>(_onLoadFormData);
    on<SelectRouter>(_onSelectRouter);
    on<GenerateVoucherEvent>(_onGenerateVoucher);
    on<LoadVouchersEvent>(_onLoadVouchers);
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
      emit(VoucherLoading());
      final result = await repository.generateVoucher(
          routerId: event.routerId,
          profileId: event.profileId,
          planName: event.planName,
          price: event.price,
          duration: event.duration,
          dataLimit: event.dataLimit,
          quantity: event.quantity,
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
    emit(VoucherLoading());
    final result = await repository.getVouchers(
      routerId: event.routerId,
      status: event.status,
    );
    
    result.fold(
      (failure) => emit(VoucherError(failure)),
      (vouchers) {
         // Filter by search if needed (client-side for now or assuming backend does it)
         // And calculate stats
         final activeCount = vouchers.where((v) => v.status == 'active').length; // Assuming status string
         // ... other stats
         
         emit(VouchersListLoaded(
           vouchers: vouchers,
           stats: {'total': vouchers.length, 'active': activeCount},
         ));
      },
    );
  }
}
