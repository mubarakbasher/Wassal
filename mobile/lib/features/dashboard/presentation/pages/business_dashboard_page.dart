import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../widgets/activity_chart_widget.dart';
import '../widgets/summary_card_widget.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:mobile/features/routers/presentation/pages/add_router_page.dart';
import '../../../vouchers/presentation/pages/generate_voucher_page.dart';
import 'subscription_page.dart';

class BusinessDashboardPage extends StatelessWidget {
  const BusinessDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    // Auto-load stats (fetches all routers and defaults to first)
    context.read<DashboardBloc>().add(const LoadDashboardStats());
  }

  bool _hasActiveSubscription(AuthState authState) {
    if (authState is AuthAuthenticated) {
      final sub = authState.user.subscription;
      if (sub != null &&
          sub.status == 'ACTIVE' &&
          sub.expiresAt.isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userName =
            authState is AuthAuthenticated ? authState.user.name : 'User';

        return BlocListener<DashboardBloc, DashboardState>(
          listenWhen: (previous, current) =>
              current is DashboardLoaded && current.refreshError != null,
          listener: (context, state) {
            if (state is DashboardLoaded && state.refreshError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.refreshError!),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardError) {
                if (SubscriptionRequiredWidget.isSubscriptionError(
                    state.message)) {
                  return const SubscriptionRequiredWidget();
                }
                return _buildErrorState(userName, authState, state.message);
              }

              if (state is DashboardLoading) {
                return _buildLoadingState(userName, authState);
              }

              String totalRouters = "0";
              String activeUsers = "0";
              String totalUsers = "0";
              String totalRevenue = "0 SDG";
              bool isActiveUsersHighlight = true;

              if (state is DashboardLoaded) {
                activeUsers = state.activeUsers.toString();
                totalRouters = state.totalRouters.toString();
                totalUsers = state.totalUsers.toString();
                totalRevenue =
                    "${state.totalRevenue.toStringAsFixed(0)} SDG";
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  context
                      .read<DashboardBloc>()
                      .add(const LoadDashboardStats());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    Text(
                      AppLocalizations.of(context)!.hello(userName),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.hotspotOverview,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSubscriptionBanner(authState),

                    const SizedBox(height: 24),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      children: [
                        SummaryCardWidget(
                          title: AppLocalizations.of(context)!.totalRouters,
                          value: totalRouters,
                          subtitle: AppLocalizations.of(context)!.online,
                          icon: Icons.router,
                          isActive: false,
                        ),
                        SummaryCardWidget(
                          title: AppLocalizations.of(context)!.activeUsers,
                          value: activeUsers,
                          subtitle: AppLocalizations.of(context)!.users,
                          icon: Icons.people,
                          isActive: isActiveUsersHighlight,
                        ),
                        SummaryCardWidget(
                          title: AppLocalizations.of(context)!.totalUsers,
                          value: totalUsers,
                          subtitle: AppLocalizations.of(context)!.registered,
                          icon: Icons.people_outline,
                          isActive: false,
                        ),
                        SummaryCardWidget(
                          title: AppLocalizations.of(context)!.revenue,
                          value: totalRevenue,
                          subtitle: '',
                          icon: Icons.payments_outlined,
                          isActive: false,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Text(
                      AppLocalizations.of(context)!.activeUsersRealtime,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ActivityChartWidget(),

                    const SizedBox(height: 30),

                    Text(
                      AppLocalizations.of(context)!.quickActions,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildQuickAction(context, authState,
                                Icons.add, AppLocalizations.of(context)!.addRouter, AppColors.primary)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _buildQuickAction(
                                context,
                                authState,
                                Icons.print,
                                AppLocalizations.of(context)!.printVoucher,
                                AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionBanner(AuthState authState) {
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final sub = authState.user.subscription;
    final bool isActive = sub != null &&
        sub.status == 'ACTIVE' &&
        sub.expiresAt.isAfter(DateTime.now());

    if (isActive) {
      final daysLeft = sub!.expiresAt.difference(DateTime.now()).inDays;
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
          ).then((_) {
            if (mounted) {
              context.read<AuthBloc>().add(const GetProfileEvent());
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.workspace_premium_outlined,
                    color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.planName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.daysRemaining(daysLeft),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.active,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No subscription or expired/pending
    final statusLabel = sub == null
        ? AppLocalizations.of(context)!.noPlan
        : sub.expiresAt.isBefore(DateTime.now())
            ? 'Expired'
            : sub.status;
    final statusColor = sub == null ? AppColors.warning : AppColors.error;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionPage()),
        ).then((_) {
          if (mounted) {
            context.read<AuthBloc>().add(const GetProfileEvent());
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.workspace_premium_outlined,
                  color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub?.planName ?? AppLocalizations.of(context)!.noSubscription,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    sub == null
                        ? AppLocalizations.of(context)!.tapToSelectPlan
                        : AppLocalizations.of(context)!.tapToManagePlan,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(String userName, AuthState authState) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          AppLocalizations.of(context)!.hello(userName),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.hotspotOverview,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildSubscriptionBanner(authState),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.loadingDashboard,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String userName, AuthState authState, String message) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        Text(
          AppLocalizations.of(context)!.hello(userName),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.hotspotOverview,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildSubscriptionBanner(authState),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 40,
                  color: AppColors.error.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.failedLoadDashboard,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<DashboardBloc>()
                      .add(const LoadDashboardStats());
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.tryAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(BuildContext context, AuthState authState,
      IconData icon, String label, Color color) {
    final hasSubscription = _hasActiveSubscription(authState);

    return GestureDetector(
      onTap: () {
        if (!hasSubscription) {
          _showSubscriptionRequiredDialog(context);
          return;
        }
        if (label == AppLocalizations.of(context)!.addRouter) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRouterPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const GenerateVoucherPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: hasSubscription ? color : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: hasSubscription ? Colors.black : Colors.grey,
              ),
            ),
            if (!hasSubscription) ...[
              const SizedBox(height: 4),
              Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
            ],
          ],
        ),
      ),
    );
  }

  void _showSubscriptionRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.warning),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context)!.subscriptionRequired),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.subscriptionRequiredMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              ).then((_) {
                if (mounted) {
                  context.read<AuthBloc>().add(const GetProfileEvent());
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppLocalizations.of(context)!.viewPlans),
          ),
        ],
      ),
    );
  }
}
