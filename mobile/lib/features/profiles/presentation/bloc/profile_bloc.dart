import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    
    final result = await getProfileUseCase();
    
    result.fold(
      (failure) => emit(ProfileError(failure.toString())),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());
    
    final params = UpdateProfileParams(
      name: event.name,
      email: event.email,
      networkName: event.networkName,
    );
    
    final result = await updateProfileUseCase(params);
    
    result.fold(
      (failure) => emit(ProfileError(failure.toString())),
      (user) => emit(ProfileUpdateSuccess(user, 'Profile updated successfully')),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());
    
    final params = ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    
    final result = await changePasswordUseCase(params);
    
    result.fold(
      (failure) => emit(ProfileError(failure.toString())),
      (_) => emit(const PasswordChangeSuccess()),
    );
  }
}
