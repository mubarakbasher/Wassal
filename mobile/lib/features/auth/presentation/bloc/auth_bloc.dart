import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) {
        final user = data['user'];
        final token = data['accessToken'];
        
        emit(AuthAuthenticated(
          user: _mapToUser(user),
          token: token,
        ));
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      email: event.email,
      password: event.password,
      name: event.name,
      role: event.role,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (data) {
        final user = data['user'];
        final token = data['accessToken'];
        
        emit(AuthAuthenticated(
          user: _mapToUser(user),
          token: token,
        ));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final result = await getProfileUseCase();
      result.fold(
        (failure) => emit(const AuthUnauthenticated()),
        (user) => emit(AuthAuthenticated(
          user: user,
          token: '', // Token is already stored
        )),
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getProfileUseCase();
    
    // Preserve the token from current state if available
    String currentToken = '';
    if (state is AuthAuthenticated) {
      currentToken = (state as AuthAuthenticated).token;
    }
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(
        user: user,
        token: currentToken,
      )),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await updateProfileUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      networkName: event.networkName,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
         // Get token from previous state if available, or fetch from local storage if needed
         String token = '';
         if (state is AuthAuthenticated) {
           token = (state as AuthAuthenticated).token;
         }
         // In a real app we might need to re-login if password changed, 
         // but for now we assume token remains valid or we just update the user.
         emit(AuthAuthenticated(
            user: user,
            token: token,
         ));
      },
    );
  }

  User _mapToUser(dynamic userData) {
    if (userData is Map<String, dynamic>) {
      return UserModel.fromJson(userData);
    }
    throw Exception('Invalid user data format');
  }
}
