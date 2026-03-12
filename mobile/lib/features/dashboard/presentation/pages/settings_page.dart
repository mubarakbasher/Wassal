import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';
import 'bills_page.dart';
import 'monitoring_page.dart';
import 'reports_page.dart';
import 'subscription_page.dart';
import '../../../../features/profiles/presentation/pages/profile_page.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/notifications/presentation/pages/notification_settings_page.dart';
import 'contact_page.dart';

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
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(AppLocalizations.of(context)!.management),
          _buildSettingsTile(
            context,
            icon: Icons.analytics_outlined,
            title: AppLocalizations.of(context)!.monitoringAnalytics,
            subtitle: AppLocalizations.of(context)!.monitoringSubtitle,
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
            title: AppLocalizations.of(context)!.salesReports,
            subtitle: AppLocalizations.of(context)!.salesReportsSubtitle,
             onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(AppLocalizations.of(context)!.general),

          // Subscription tile with live status
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String subtitle = AppLocalizations.of(context)!.viewPlansManageSub;
              Widget? trailing;

              if (state is AuthAuthenticated && state.user.subscription != null) {
                final sub = state.user.subscription!;
                final isExpired = sub.expiresAt.isBefore(DateTime.now());
                final isActive = sub.status == 'ACTIVE' && !isExpired;

                subtitle = '${sub.planName} • ${isActive ? AppLocalizations.of(context)!.active : isExpired ? AppLocalizations.of(context)!.expired : sub.status}';
                trailing = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? AppLocalizations.of(context)!.active : isExpired ? AppLocalizations.of(context)!.expired : sub.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                );
              } else {
                subtitle = AppLocalizations.of(context)!.noActivePlanSelect;
                trailing = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.none,
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
                title: AppLocalizations.of(context)!.subscription,
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
            icon: Icons.receipt_long_outlined,
            title: AppLocalizations.of(context)!.billsPayments,
            subtitle: AppLocalizations.of(context)!.viewPaymentHistory,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillsPage()),
              );
            },
          ),

          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context)!.profile,
            subtitle: AppLocalizations.of(context)!.manageYourAccount,
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
            title: AppLocalizations.of(context)!.notifications,
            subtitle: AppLocalizations.of(context)!.configureAlerts,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: AppLocalizations.of(context)!.language,
            subtitle: AppLocalizations.of(context)!.languageSubtitle,
            onTap: () {
              _showLanguageDialog(context);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.support_agent,
            title: AppLocalizations.of(context)!.contactUs,
            subtitle: AppLocalizations.of(context)!.contactUsSubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactPage()),
              );
            },
          ),
           _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: AppLocalizations.of(context)!.about,
            subtitle: AppLocalizations.of(context)!.appVersion,
            onTap: () {
              final l10n = AppLocalizations.of(context)!;
              showAboutDialog(
                context: context,
                applicationName: l10n.aboutTitle,
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.router, size: 48, color: AppColors.primary),
                children: [
                  Text(l10n.aboutDescription),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = context.read<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.selectLanguage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text(l10n.english),
              trailing: localeProvider.locale.languageCode == 'en'
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
              title: Text(l10n.arabic),
              trailing: localeProvider.locale.languageCode == 'ar'
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
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
