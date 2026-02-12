import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../auth/domain/entities/user.dart';
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

        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            // Handle subscription error state
            if (state is DashboardError) {
              if (SubscriptionRequiredWidget.isSubscriptionError(
                  state.message)) {
                return const SubscriptionRequiredWidget();
              }
              return _buildErrorState(state.message);
            }

            // Handle loading state
            if (state is DashboardLoading) {
              return _buildLoadingState(userName, authState);
            }

            // Defaults
            String totalRouters = "0";
            String activeUsers = "0";
            String totalUsers = "0";
            String totalRevenue = "\$0.00";
            bool isActiveUsersHighlight = true;

            if (state is DashboardLoaded) {
              activeUsers = state.activeUsers.toString();
              totalRouters = state.totalRouters.toString();
              totalUsers = state.totalUsers.toString();
              totalRevenue =
                  "\$${state.totalRevenue.toStringAsFixed(2)}";
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
                  // Greeting
                  Text(
                    'Hello, $userName',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Here is your hotspot overview',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subscription Status Banner
                  _buildSubscriptionBanner(authState),

                  const SizedBox(height: 24),

                  // Summary Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      SummaryCardWidget(
                        title: 'Total Routers',
                        value: totalRouters,
                        subtitle: 'Online',
                        icon: Icons.router,
                        isActive: false,
                      ),
                      SummaryCardWidget(
                        title: 'Active Users',
                        value: activeUsers,
                        subtitle: 'Users',
                        icon: Icons.people,
                        isActive: isActiveUsersHighlight,
                      ),
                      SummaryCardWidget(
                        title: 'Total Users',
                        value: totalUsers,
                        subtitle: 'Registered',
                        icon: Icons.people_outline,
                        isActive: false,
                      ),
                      SummaryCardWidget(
                        title: 'Revenue',
                        value: totalRevenue,
                        subtitle: '',
                        icon: Icons.attach_money,
                        isActive: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Chart Section
                  const Text(
                    'Active Users Real-time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ActivityChartWidget(),

                  const SizedBox(height: 30),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildQuickAction(context, authState,
                              Icons.add, "Add Router", AppColors.primary)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildQuickAction(
                              context,
                              authState,
                              Icons.print,
                              "Print Voucher",
                              AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
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
                      '$daysLeft days remaining',
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
                child: const Text(
                  'Active',
                  style: TextStyle(
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
        ? 'No Plan'
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
                    sub?.planName ?? 'No Subscription',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    sub == null
                        ? 'Tap to select a plan'
                        : 'Tap to manage your plan',
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
          'Hello, $userName',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your hotspot overview',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildSubscriptionBanner(authState),
        const SizedBox(height: 40),
        const Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                'Loading dashboard...',
                style: TextStyle(
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: AppColors.error.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<DashboardBloc>()
                    .add(const LoadDashboardStats());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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
        if (label == "Add Router") {
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
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.warning),
            SizedBox(width: 10),
            Text('Subscription Required'),
          ],
        ),
        content: const Text(
          'You need an active subscription to use this feature. Would you like to view available plans?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }
}
