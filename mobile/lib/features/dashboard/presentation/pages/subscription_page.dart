import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../subscriptions/data/models/payment_model.dart';

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
      if (mounted && response.statusCode == 200) {
        setState(() {
          _plans = response.data is List ? response.data : [];
          _loadingPlans = false;
        });
      }
    } catch (e) {
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

  Future<void> _requestSubscription(String planId, String planName, double price) async {
    _showPaymentFlowSheet(planId, planName, price);
  }

  void _showPaymentFlowSheet(String planId, String planName, double price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentFlowSheet(
        planId: planId,
        planName: planName,
        price: price,
        apiClient: context.read<ApiClient>(),
        onComplete: () {
          context.read<AuthBloc>().add(const GetProfileEvent());
          _loadMySubscription();
        },
      ),
    );
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
                    _buildCurrentStatus(),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.availablePlans, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.selectPlanFits,
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
            child: Text(AppLocalizations.of(context)!.subscription, style: AppTextStyles.headlineMedium),
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
            Text(
              AppLocalizations.of(context)!.noActiveSubscription,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.choosePlanBelow,
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
        ? AppLocalizations.of(context)!.active
        : isExpired
            ? AppLocalizations.of(context)!.expired
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
                          ? AppLocalizations.of(context)!.daysRemaining(daysLeft)
                          : isExpired
                              ? AppLocalizations.of(context)!.subscriptionExpired
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
                  AppLocalizations.of(context)!.startDate,
                  sub['startDate'] != null
                      ? sub['startDate'].toString().split('T')[0]
                      : '-',
                  Icons.calendar_today_outlined,
                ),
                const SizedBox(width: 16),
                _buildSubInfoItem(
                  AppLocalizations.of(context)!.expires,
                  expiresAt.toString().split(' ')[0],
                  Icons.event_outlined,
                ),
              ],
            ),
          ],
          if (sub['plan'] != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildFeatureRow(Icons.router_outlined, AppLocalizations.of(context)!.maxRouters, '${sub['plan']['maxRouters'] ?? 1}'),
            const SizedBox(height: 8),
            _buildFeatureRow(Icons.people_outline, AppLocalizations.of(context)!.maxHotspotUsers, '${sub['plan']['maxHotspotUsers'] == 0 ? AppLocalizations.of(context)!.unlimited : sub['plan']['maxHotspotUsers'] ?? 50}'),
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
            AppLocalizations.of(context)!.failedLoadPlans,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.checkConnectionTryAgain,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadPlans,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppLocalizations.of(context)!.retry),
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
            AppLocalizations.of(context)!.noPlansAvailable,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.contactAdminPlans,
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
                              child: Text(
                                AppLocalizations.of(context)!.current,
                                style: const TextStyle(
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
                      '${price.toStringAsFixed(0)} SDG',
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

            _buildPlanFeature(Icons.router_outlined, 'Up to ${plan['maxRouters'] ?? 1} router(s)'),
            const SizedBox(height: 8),
            _buildPlanFeature(
              Icons.people_outline,
              plan['maxHotspotUsers'] == 0
                  ? AppLocalizations.of(context)!.unlimitedHotspotUsers
                  : 'Up to ${plan['maxHotspotUsers'] ?? 50} hotspot users',
            ),
            const SizedBox(height: 8),
            _buildPlanFeature(
              Icons.confirmation_number_outlined,
              plan['allowVouchers'] == true ? AppLocalizations.of(context)!.voucherSystemIncluded : AppLocalizations.of(context)!.noVoucherSystem,
              available: plan['allowVouchers'] == true,
            ),
            const SizedBox(height: 8),
            _buildPlanFeature(
              Icons.bar_chart_rounded,
              plan['allowReports'] == true ? AppLocalizations.of(context)!.reportsAnalytics : AppLocalizations.of(context)!.noReports,
              available: plan['allowReports'] == true,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (isCurrentPlan && isActiveSub) || _requesting
                    ? null
                    : () => _requestSubscription(plan['id'], plan['name'], price),
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
                            ? AppLocalizations.of(context)!.currentPlan
                            : AppLocalizations.of(context)!.selectPlan,
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

// ---------------------------------------------------------------------------
// Payment Flow Bottom Sheet
// ---------------------------------------------------------------------------

class _PaymentFlowSheet extends StatefulWidget {
  final String planId;
  final String planName;
  final double price;
  final ApiClient apiClient;
  final VoidCallback onComplete;

  const _PaymentFlowSheet({
    required this.planId,
    required this.planName,
    required this.price,
    required this.apiClient,
    required this.onComplete,
  });

  @override
  State<_PaymentFlowSheet> createState() => _PaymentFlowSheetState();
}

class _PaymentFlowSheetState extends State<_PaymentFlowSheet> {
  int _step = 0; // 0=instructions, 1=upload proof, 2=submitting, 3=done
  BankInfo? _bankInfo;
  bool _loadingBank = true;
  String? _paymentId;
  File? _proofImage;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBankInfo();
  }

  Future<void> _loadBankInfo() async {
    try {
      final response = await widget.apiClient.get(ApiEndpoints.bankInfo);
      if (mounted && response.statusCode == 200) {
        setState(() {
          _bankInfo = BankInfo.fromJson(response.data as Map<String, dynamic>);
          _loadingBank = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingBank = false;
          _error = 'Failed to load bank info';
        });
      }
    }
  }

  Future<void> _createPaymentRequest() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final response = await widget.apiClient.post(
        ApiEndpoints.requestSubscription,
        data: {'planId': widget.planId},
      );
      if (mounted) {
        final data = response.data;
        _paymentId = data['payment']?['id'];
        setState(() {
          _step = 1;
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to create request: $e';
          _submitting = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _proofImage = File(picked.path));
    }
  }

  Future<void> _submitProof() async {
    if (_proofImage == null || _paymentId == null) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.apiClient.uploadFile(
        ApiEndpoints.uploadProof(_paymentId!),
        _proofImage!,
        fieldName: 'proof',
      );
      if (mounted) {
        setState(() {
          _step = 3;
          _submitting = false;
        });
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to upload proof: $e';
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _step == 3 ? AppLocalizations.of(context)!.requestSubmitted : AppLocalizations.of(context)!.paymentFor(widget.planName),
              style: AppTextStyles.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          if (_step < 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${widget.price.toStringAsFixed(0)} SDG',
                style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary),
              ),
            ),
          const SizedBox(height: 16),
          if (_step < 2) _buildStepIndicator(),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          _buildStepDot(0, AppLocalizations.of(context)!.bankInfo),
          Expanded(child: Container(height: 2, color: _step >= 1 ? AppColors.primary : Colors.grey[300])),
          _buildStepDot(1, AppLocalizations.of(context)!.uploadProof),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _step >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : Colors.grey[300],
          ),
          child: Center(
            child: isActive && _step > step
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildBankInfoStep();
      case 1:
        return _buildUploadStep();
      case 3:
        return _buildSuccessStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBankInfoStep() {
    if (_loadingBank) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.transferInstructions,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildBankDetailRow(AppLocalizations.of(context)!.bank, _bankInfo?.bankName ?? '-'),
        _buildBankDetailRow(AppLocalizations.of(context)!.accountName, _bankInfo?.accountName ?? '-'),
        _buildBankDetailRow(
          AppLocalizations.of(context)!.accountNumber,
          _bankInfo?.accountNumber ?? '-',
          copyable: true,
        ),
        _buildBankDetailRow(AppLocalizations.of(context)!.amount, '${widget.price.toStringAsFixed(0)} SDG'),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _createPaymentRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    AppLocalizations.of(context)!.iveSentMoney,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.copiedToClipboard),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Icon(Icons.copy, size: 18, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.camera_alt_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.uploadPaymentProof,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _proofImage != null ? AppColors.success : Colors.grey[300]!,
                width: _proofImage != null ? 2 : 1,
              ),
            ),
            child: _proofImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_proofImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.tapToSelectImage,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.pngJpgUpTo5mb,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
          ),
        ),
        if (_proofImage != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppLocalizations.of(context)!.changeImage),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: AppColors.error, fontSize: 13)),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting
                    ? null
                    : () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.requestSavedUploadLater),
                            backgroundColor: AppColors.info,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        widget.onComplete();
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Text(AppLocalizations.of(context)!.skipForNow, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: (_proofImage != null && !_submitting) ? _submitProof : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        AppLocalizations.of(context)!.submitProof,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.paymentProofSubmitted,
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.subscriptionRequestSubmitted,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              AppLocalizations.of(context)!.done,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
