import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/routers/presentation/bloc/router_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/api/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_profile_usecase.dart';
import 'features/routers/data/datasources/router_remote_data_source.dart';
import 'features/routers/data/repositories/router_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final apiClient = ApiClient();
    const secureStorage = FlutterSecureStorage();
    
    final authLocalDataSource = AuthLocalDataSourceImpl(
      secureStorage: secureStorage,
    );
    
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      apiClient: apiClient,
    );
    
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    final routerRemoteDataSource = RouterRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    final routerRepository = RouterRepositoryImpl(
      remoteDataSource: routerRemoteDataSource,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            loginUseCase: LoginUseCase(authRepository),
            registerUseCase: RegisterUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
            getProfileUseCase: GetProfileUseCase(authRepository),
            authRepository: authRepository,
          )..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider(
          create: (context) => RouterBloc(
            repository: routerRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'MikroTik Hotspot Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            error: AppColors.error,
          ),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const DashboardPage();
            }
            return const LoginPage();
          },
        ),
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
        },
      ),
    );
  }
}
