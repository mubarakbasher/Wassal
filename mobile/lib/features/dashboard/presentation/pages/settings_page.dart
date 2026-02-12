import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'monitoring_page.dart';
import 'reports_page.dart';
import 'hotspot_profiles_page.dart';
import 'subscription_page.dart';
import '../../../../features/profiles/presentation/pages/profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/notifications/presentation/pages/notification_settings_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Refresh profile data when entering settings to ensure subscription status is up to date
    context.read<AuthBloc>().add(const GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Management'),
          _buildSettingsTile(
            context,
            icon: Icons.analytics_outlined,
            title: 'Monitoring & Analytics',
            subtitle: 'Real-time stats, bandwidth, and health',
             onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonitoringPage()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.bar_chart_rounded,
            title: 'Sales & Reports',
            subtitle: 'Voucher sales, revenue, and exports',
             onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.person_pin,
            title: 'Hotspot Profiles',
            subtitle: 'Manage hotspot user profiles',
             onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HotspotProfilesPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('General'),

          // Subscription tile with live status
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String subtitle = 'View plans and manage subscription';
              Widget? trailing;

              if (state is AuthAuthenticated && state.user.subscription != null) {
                final sub = state.user.subscription!;
                final isExpired = sub.expiresAt.isBefore(DateTime.now());
                final isActive = sub.status == 'ACTIVE' && !isExpired;

                subtitle = '${sub.planName} • ${isActive ? 'Active' : isExpired ? 'Expired' : sub.status}';
                trailing = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : isExpired ? 'Expired' : sub.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              } else {
                subtitle = 'No active plan — select one';
                trailing = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'None',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              }

              return _buildSettingsTileCustom(
                context,
                icon: Icons.workspace_premium_outlined,
                title: 'Subscription',
                subtitle: subtitle,
                trailing: trailing,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                  ).then((_) {
                    // Refresh subscription status when coming back
                    context.read<AuthBloc>().add(const GetProfileEvent());
                  });
                },
              );
            },
          ),

          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Manage your account',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Configure alerts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
              );
            },
          ),
           _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _buildSettingsTileCustom(
      context,
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSettingsTileCustom(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
