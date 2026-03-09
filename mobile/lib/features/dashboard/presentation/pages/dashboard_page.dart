import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../routers/presentation/bloc/router_bloc.dart';
import '../../../routers/presentation/bloc/router_event.dart';
import '../../../vouchers/presentation/bloc/voucher_bloc.dart';
import '../../../vouchers/presentation/bloc/voucher_event.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../widgets/dashboard_app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import 'home_routers_page.dart';
import 'business_dashboard_page.dart';
import '../../../vouchers/presentation/pages/voucher_management_page.dart';
import '../../../profiles/presentation/pages/profile_page.dart';
import 'settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  int _currentIndex = 1; // Default to Business Dashboard (index 1)
  
  // GlobalKey to access VoucherManagementPage state
  final GlobalKey<VoucherManagementPageState> _voucherPageKey = GlobalKey<VoucherManagementPageState>();

  // Cache pages so they aren't recreated on every tab switch
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pages = [
      const HomeRoutersPage(),
      const BusinessDashboardPage(),
      VoucherManagementPage(key: _voucherPageKey),
      const SettingsPage(),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _refreshCurrentPage();
      });
    } else if (state == AppLifecycleState.paused) {
      context.read<DashboardBloc>().add(const PauseDashboardPolling());
    }
  }

  void _refreshCurrentPage() {
    switch (_currentIndex) {
      case 0:
        context.read<RouterBloc>().add(const LoadRoutersEvent());
        break;
      case 1:
        context.read<DashboardBloc>().add(const ResumeDashboardPolling());
        context.read<DashboardBloc>().add(const LoadDashboardStats());
        break;
      case 2:
        context.read<VoucherBloc>().add(LoadVoucherStats());
        context.read<VoucherBloc>().add(const LoadVouchersEvent());
        break;
      case 3:
        break;
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _enterSelectionMode() {
    // Trigger selection mode in VoucherManagementPage
    _voucherPageKey.currentState?.enterSelectionModeFromOutside();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthAuthenticated 
            ? authState.user.name 
            : 'User';

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: DashboardAppBarWidget(
            userName: userName,
            onLogout: () {
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            onProfileTap: _navigateToProfile,
            showSelectOption: _currentIndex == 2, // Only show on Vouchers tab
            onSelectModePressed: _enterSelectionMode,
          ),
          drawer: const AppDrawerWidget(),
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: _currentIndex,
            onTap: (index) {
              // Pause/resume dashboard polling based on tab visibility
              if (index == 1 && _currentIndex != 1) {
                context.read<DashboardBloc>().add(const ResumeDashboardPolling());
              } else if (index != 1 && _currentIndex == 1) {
                context.read<DashboardBloc>().add(const PauseDashboardPolling());
              }
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.router),
                label: AppLocalizations.of(context)!.routers,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard),
                label: AppLocalizations.of(context)!.dashboard,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.confirmation_number),
                label: AppLocalizations.of(context)!.vouchers,
              ),
               BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: AppLocalizations.of(context)!.settings,
              ),
            ],
          ),
        );
      },
    );
  }
}
