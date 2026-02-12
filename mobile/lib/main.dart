import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/routers/presentation/bloc/router_bloc.dart';
import 'features/vouchers/presentation/bloc/voucher_bloc.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/bloc/splash_event.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/splash/data/startup_service.dart';
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
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/routers/data/datasources/router_remote_data_source.dart';
import 'features/routers/data/repositories/router_repository_impl.dart';
import 'features/vouchers/data/datasources/voucher_remote_data_source.dart';
import 'features/vouchers/data/datasources/voucher_local_data_source.dart';
import 'features/vouchers/data/repositories/voucher_repository_impl.dart';
import 'features/sales/data/datasources/sales_remote_data_source.dart';
import 'features/sales/data/repositories/sales_repository_impl.dart';
import 'features/sales/presentation/bloc/sales_bloc.dart';

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

    final salesRemoteDataSource = SalesRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    final salesRepository = SalesRepositoryImpl(
      remoteDataSource: salesRemoteDataSource,
    );

    final voucherRemoteDataSource = VoucherRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    final voucherLocalDataSource = VoucherLocalDataSourceImpl();

    final voucherRepository = VoucherRepositoryImpl(
      remoteDataSource: voucherRemoteDataSource,
      localDataSource: voucherLocalDataSource,
    );

    // Startup service for splash screen checks
    final startupService = StartupService(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

    return RepositoryProvider<ApiClient>(
      create: (_) => apiClient,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SplashBloc(
              startupService: startupService,
            )..add(const StartSplashChecks()),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              loginUseCase: LoginUseCase(authRepository),
              registerUseCase: RegisterUseCase(authRepository),
              logoutUseCase: LogoutUseCase(authRepository),
              getProfileUseCase: GetProfileUseCase(authRepository),
              updateProfileUseCase: UpdateProfileUseCase(authRepository),
              authRepository: authRepository,
            ),
          ),
          BlocProvider(
            create: (context) => RouterBloc(
              repository: routerRepository,
            ),
          ),
          BlocProvider(
            create: (context) => SalesBloc(
              repository: salesRepository,
            ),
          ),
          BlocProvider(
            create: (context) => VoucherBloc(
              repository: voucherRepository,
            ),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(
              apiClient: apiClient,
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
            surface: AppColors.surface,
            error: AppColors.error,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: false,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.cardElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          cardTheme: CardThemeData(
            color: AppColors.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          useMaterial3: true,
        ),
        home: const SplashPage(),
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const DashboardPage(),
        },
      ),
      ),
    );
  }
}
