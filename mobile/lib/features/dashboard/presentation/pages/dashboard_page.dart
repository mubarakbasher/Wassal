import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/dashboard_app_bar_widget.dart';
import '../widgets/time_range_selector_widget.dart';
import '../widgets/activity_chart_widget.dart';
import '../widgets/summary_card_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/dashboard_app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import 'home_routers_page.dart';
import 'business_dashboard_page.dart';
import '../../../vouchers/presentation/pages/voucher_management_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 1; // Default to Business Dashboard (index 1)

  final List<Widget> _pages = [
    const HomeRoutersPage(),
    const BusinessDashboardPage(), // Replaced Wellbeing
    const VoucherManagementPage(),
    const Center(child: Text('Settings')), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DashboardAppBarWidget(
        userName: 'User',
        onLogout: () {
          context.read<AuthBloc>().add(const LogoutEvent());
        },
      ),
      drawer: const AppDrawerWidget(), // Added Drawer
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary, // Use primary color for active
        unselectedItemColor: Colors.grey[400],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
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
            icon: Icon(Icons.dashboard), // Icon for Business Dashboard
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
  }
}
