import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../routers/presentation/pages/routers_management_page.dart';

class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            accountName: const Text(
              'User Name', // TODO: Get from BLoC/Auth
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('user@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Navigate if needed, or if already on dashboard do nothing
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
            leading: const Icon(Icons.people),
            title: const Text('Hotspot Users'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Hotspot Users
            },
          ),
          ListTile(
            leading: const Icon(Icons.confirmation_number),
            title: const Text('Vouchers'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Vouchers
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Reports
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Settings
            },
          ),
        ],
      ),
    );
  }
}
