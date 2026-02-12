import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<dynamic> _plans = [];
  Map<String, dynamic>? _mySubscription;
  bool _loadingPlans = true;
  bool _loadingSub = true;
  bool _requesting = false;
  String? _plansError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPlans(), _loadMySubscription()]);
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loadingPlans = true;
      _plansError = null;
    });
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(ApiEndpoints.subscriptionPlans);
      debugPrint('Plans response: ${response.statusCode} - ${response.data}');
      if (mounted && response.statusCode == 200) {
        setState(() {
          _plans = response.data is List ? response.data : [];
          _loadingPlans = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load plans: $e');
      if (mounted) {
        setState(() {
          _loadingPlans = false;
          _plansError = e.toString();
        });
      }
    }
  }

  Future<void> _loadMySubscription() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(ApiEndpoints.mySubscription);
      if (mounted && response.statusCode == 200) {
        setState(() {
          _mySubscription = response.data;
          _loadingSub = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSub = false);
      }
    }
  }

  Future<void> _requestSubscription(String planId, String planName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Request Subscription'),
        content: Text(
          'Request the "$planName" plan? An admin will review and approve your subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Request'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _requesting = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.post(
        ApiEndpoints.requestSubscription,
        data: {'planId': planId},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Request submitted!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Refresh profile to update subscription status
        context.read<AuthBloc>().add(const GetProfileEvent());
        await _loadMySubscription();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _requesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Current Subscription Status
                    _buildCurrentStatus(),
                    const SizedBox(height: 24),

                    // Available Plans
                    Text('Available Plans', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Select a plan that fits your needs',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    if (_loadingPlans)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (_plansError != null)
                      _buildPlansError()
                    else if (_plans.isEmpty)
                      _buildEmptyPlans()
                    else
                      ..._plans.map((plan) => _buildPlanCard(plan)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text('Subscription', style: AppTextStyles.headlineMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
    if (_loadingSub) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final status = _mySubscription?['status'] ?? 'NONE';
    final sub = _mySubscription?['subscription'];

    if (status == 'NONE' || sub == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Subscription',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a plan below to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    final isActive = status == 'ACTIVE';
    final isExpired = status == 'EXPIRED';
    final statusColor = isActive
        ? AppColors.success
        : isExpired
            ? AppColors.error
            : AppColors.warning;
    final statusLabel = isActive
        ? 'Active'
        : isExpired
            ? 'Expired'
            : status;

    final expiresAt = sub['expiresAt'] != null
        ? DateTime.tryParse(sub['expiresAt'].toString())
        : null;
    final daysLeft = expiresAt != null
        ? expiresAt.difference(DateTime.now()).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.star_rounded, color: statusColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub['planName'] ?? 'Unknown Plan',
                      style: AppTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive && daysLeft > 0
                          ? '$daysLeft days remaining'
                          : isExpired
                              ? 'Subscription expired'
                              : status,
                      style: AppTextStyles.bodySmall.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (expiresAt != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSubInfoItem(
                  'Start Date',
                  sub['startDate'] != null
                      ? sub['startDate'].toString().split('T')[0]
                      : '-',
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(width: 16),
                _buildSubInfoItem(
                  'Expires',
                  expiresAt.toString().split(' ')[0],
                  Icons.event_outlined,
                ),
              ],
            ),
          ],
          // Show plan features if available
          if (sub['plan'] != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.router_outlined, 'Max Routers', '${sub['plan']['maxRouters'] ?? 1}'),
            const SizedBox(height: 8),
            _buildFeatureRow(Icons.people_outline, 'Max Hotspot Users', '${sub['plan']['maxHotspotUsers'] == 0 ? 'Unlimited' : sub['plan']['maxHotspotUsers'] ?? 50}'),
          ],
        ],
      ),
    );
  }

  Widget _buildSubInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.bodyMedium),
        const Spacer(),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPlansError() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.error.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(
            'Failed to load plans',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadPlans,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlans() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No plans available',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact your administrator to set up subscription plans',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan) {
    final currentPlanId = _mySubscription?['subscription']?['planId'];
    final isCurrentPlan = plan['id'] == currentPlanId;
    final isActiveSub = _mySubscription?['status'] == 'ACTIVE';
    final price = plan['price'] is String
        ? double.tryParse(plan['price']) ?? 0
        : (plan['price'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['name'] ?? 'Plan',
                            style: AppTextStyles.titleLarge,
                          ),
                          if (isCurrentPlan) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'CURRENT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (plan['description'] != null && plan['description'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            plan['description'],
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '/ ${plan['durationDays']} days',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Features
            _buildPlanFeature(Icons.router_outlined, 'Up to ${plan['maxRouters'] ?? 1} router(s)'),
            const SizedBox(height: 8),
            _buildPlanFeature(
              Icons.people_outline,
              plan['maxHotspotUsers'] == 0
                  ? 'Unlimited hotspot users'
                  : 'Up to ${plan['maxHotspotUsers'] ?? 50} hotspot users',
            ),
            const SizedBox(height: 8),
            _buildPlanFeature(
              Icons.confirmation_number_outlined,
              plan['allowVouchers'] == true ? 'Voucher system included' : 'No voucher system',
              available: plan['allowVouchers'] == true,
            ),
            const SizedBox(height: 8),
            _buildPlanFeature(
              Icons.bar_chart_rounded,
              plan['allowReports'] == true ? 'Reports & analytics' : 'No reports',
              available: plan['allowReports'] == true,
            ),

            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isCurrentPlan && isActiveSub) || _requesting
                    ? null
                    : () => _requestSubscription(plan['id'], plan['name']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentPlan && isActiveSub
                      ? Colors.grey[300]
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _requesting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isCurrentPlan && isActiveSub
                            ? 'Current Plan'
                            : 'Select Plan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanFeature(IconData icon, String text, {bool available = true}) {
    return Row(
      children: [
        Icon(
          available ? Icons.check_circle_outline : Icons.cancel_outlined,
          size: 18,
          color: available ? AppColors.success : AppColors.textTertiary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: available ? AppColors.textPrimary : AppColors.textTertiary,
              decoration: available ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }
}
