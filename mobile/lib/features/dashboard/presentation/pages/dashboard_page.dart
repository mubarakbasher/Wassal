import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 1; // Default to Business Dashboard (index 1)
  
  // GlobalKey to access VoucherManagementPage state
  final GlobalKey<VoucherManagementPageState> _voucherPageKey = GlobalKey<VoucherManagementPageState>();

  // Cache pages so they aren't recreated on every tab switch
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeRoutersPage(),
      const BusinessDashboardPage(),
      VoucherManagementPage(key: _voucherPageKey),
      const SettingsPage(),
    ];
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.router),
                label: 'Routers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number),
                label: 'Vouchers',
              ),
               BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
