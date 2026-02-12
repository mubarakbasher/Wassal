import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../routers/presentation/pages/routers_management_page.dart';
import '../pages/monitoring_page.dart';
import '../pages/reports_page.dart';

class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName = authState is AuthAuthenticated
            ? (authState.user.name.isNotEmpty ? authState.user.name : 'User')
            : 'User';
        final userEmail = authState is AuthAuthenticated
            ? authState.user.email
            : '';

        return Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                accountName: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.router),
                title: const Text('Routers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoutersManagementPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Monitoring'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MonitoringPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportsPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings tab (index 3 in bottom nav)
                  // The parent DashboardPage controls tabs, so we just pop
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
