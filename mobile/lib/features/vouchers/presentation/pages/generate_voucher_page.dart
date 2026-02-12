import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/voucher_bloc.dart';
import '../bloc/voucher_event.dart';
import '../bloc/voucher_state.dart';
import '../widgets/voucher_success_dialog.dart';

class GenerateVoucherPage extends StatelessWidget {
  const GenerateVoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GenerateVoucherView();
  }
}

class GenerateVoucherView extends StatefulWidget {
  const GenerateVoucherView({super.key});

  @override
  State<GenerateVoucherView> createState() => _GenerateVoucherViewState();
}

class _GenerateVoucherViewState extends State<GenerateVoucherView>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _progressController;

  // Form data
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController(text: "10");
  final _quantityController = TextEditingController(text: "1");
  final _limitValueController = TextEditingController(text: "1");

  String _limitType = "Time";
  String _timeUnit = "Hours";
  String _dataUnit = "GB";
  String? _selectedProfileId;
  String? _selectedPlanName;
  String _charset = "NUMERIC";
  String _authType = "USER_SAME_PASS";

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    // Load form data once on init, not in build() which fires on every rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherBloc>().add(LoadVoucherFormData());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _limitValueController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<VoucherBloc, VoucherState>(
        listener: (context, state) {
          if (state is VoucherError) {
            if (SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
              return; // Suppress snackbar for subscription errors, handled in builder
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          } else if (state is VoucherGenerated) {
            HapticFeedback.heavyImpact();
            // Get network name from AuthBloc
            String? networkName;
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              networkName = authState.user.networkName;
            }
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => VoucherSuccessDialog(
                vouchers: state.vouchers,
                networkName: networkName,
                onDismiss: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to list
                },
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VoucherLoading && state is! VoucherFormDataLoaded) {
            return _buildLoadingState();
          }

          if (state is VoucherError &&
              SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
            return SubscriptionRequiredWidget(
              message: SubscriptionRequiredWidget.cleanMessage(state.message),
            );
          }

          if (state is VoucherFormDataLoaded ||
              state is VoucherGenerating ||
              state is VoucherGenerated ||
              state is VoucherError) {
            final formData = _getFormData(state);
            if (formData == null) {
              return _buildLoadingState();
            }

            return Column(
              children: [
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1RouterSelection(formData),
                      _buildStep2ConfigurePlan(formData),
                      _buildStep3Confirm(formData),
                    ],
                  ),
                ),
              ],
            );
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  VoucherFormDataLoaded? _getFormData(VoucherState state) {
    if (state is VoucherFormDataLoaded) return state;
    final bloc = context.read<VoucherBloc>();
    if (bloc.state is VoucherFormDataLoaded) {
      return bloc.state as VoucherFormDataLoaded;
    }
    return null;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (_currentStep > 0) {
            _previousStep();
          } else {
            Navigator.pop(context);
          }
        },
        icon: Icon(
          _currentStep > 0 ? Icons.arrow_back_rounded : Icons.close_rounded,
          color: AppColors.textPrimary,
        ),
      ),
      title: Text(
        'Generate Voucher',
        style: AppTextStyles.titleLarge,
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    final steps = ['Select Router', 'Configure', 'Confirm'];
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              return Expanded(
                child: Row(
                  children: [
                    _buildStepCircle(index, isActive, isCompleted),
                    if (index < 2)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: isCompleted
                                ? AppColors.primaryGradient
                                : null,
                            color: isCompleted ? null : AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((entry) {
              final isActive = entry.key == _currentStep;
              return Text(
                entry.value,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int index, bool isActive, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.primaryGradient : null,
        color: isActive ? null : AppColors.cardElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? Colors.transparent : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : Text(
                '${index + 1}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading routers...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1RouterSelection(VoucherFormDataLoaded formData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Select Router',
            'Choose the router for generating vouchers',
            Icons.router_rounded,
          ),
          const SizedBox(height: 24),
          if (formData.routers.isEmpty)
            _buildEmptyRoutersState()
          else
            ...formData.routers.map((router) => _buildRouterCard(
                  router,
                  formData.selectedRouterId == router['id'],
                  formData,
                )),
          const SizedBox(height: 32),
          _buildContinueButton(
            enabled: formData.selectedRouterId != null,
            onPressed: _nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRoutersState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.router_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No routers found',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a router first to generate vouchers',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRouterCard(
    Map<String, dynamic> router,
    bool isSelected,
    VoucherFormDataLoaded formData,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<VoucherBloc>().add(SelectRouter(router['id']));
        _selectedProfileId = null;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.cardElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.router_rounded,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    router['name'] ?? 'Unknown Router',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    router['ipAddress'] ?? 'No IP',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? AppColors.primaryGradient : null,
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2ConfigurePlan(VoucherFormDataLoaded formData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Configure Plan',
              'Set up the voucher details',
              Icons.tune_rounded,
            ),
            const SizedBox(height: 24),

            // Profile Selection
            Text('Select Profile', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            if (formData.isLoadingProfiles)
              _buildProfileLoadingState()
            else if (formData.profiles.isEmpty)
              _buildNoProfilesState()
            else
              _buildProfileGrid(formData),

            const SizedBox(height: 24),

            // Price and Quantity
            Row(
              children: [
                Expanded(child: _buildPriceField()),
                const SizedBox(width: 16),
                Expanded(child: _buildQuantityField()),
              ],
            ),

            const SizedBox(height: 24),

            // Limit Type
            Text('Limit Type', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            _buildLimitTypeSelector(),

            const SizedBox(height: 16),
            _buildLimitValueField(),

            const SizedBox(height: 24),

            // Advanced Options
            _buildAdvancedOptions(),

            const SizedBox(height: 32),
            _buildContinueButton(
              enabled: _selectedProfileId != null,
              onPressed: () {
                if (_formKey.currentState!.validate() && _selectedProfileId != null) {
                  _nextStep();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text('Loading profiles...', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProfilesState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No profiles found on this router',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid(VoucherFormDataLoaded formData) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: formData.profiles.map((profile) {
        final isSelected = _selectedProfileId == profile.id;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedProfileId = profile.id;
              _selectedPlanName = profile.name;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.primaryGradient : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.border,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_rounded,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  profile.name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Price', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            hintText: '0.00',
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quantity', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyLarge,
          decoration: const InputDecoration(
            hintText: '1',
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildLimitTypeSelector() {
    return Row(
      children: [
        _buildLimitTypeChip('Time', Icons.access_time_rounded),
        const SizedBox(width: 12),
        _buildLimitTypeChip('Data', Icons.data_usage_rounded),
      ],
    );
  }

  Widget _buildLimitTypeChip(String type, IconData icon) {
    final isSelected = _limitType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _limitType = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '$type Limit',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitValueField() {
    final units = _limitType == 'Time'
        ? ['Minutes', 'Hours', 'Days']
        : ['MB', 'GB'];
    final currentUnit = _limitType == 'Time' ? _timeUnit : _dataUnit;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _limitValueController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Value',
            ),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentUnit,
                isExpanded: true,
                icon: const Icon(Icons.expand_more_rounded),
                style: AppTextStyles.bodyMedium,
                items: units.map((u) => DropdownMenuItem(
                  value: u,
                  child: Text(u),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    if (_limitType == 'Time') {
                      _timeUnit = value!;
                    } else {
                      _dataUnit = value!;
                    }
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: Text('Advanced Options', style: AppTextStyles.labelLarge),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 8),
      children: [
        _buildDropdownField(
          'Code Format',
          _charset,
          {
            'NUMERIC': 'Numbers Only (e.g., 12345678)',
            'ALPHANUMERIC': 'Numbers & Letters (e.g., AB12CD34)',
            'ALPHA': 'Letters Only (e.g., ABCDEFGH)',
          },
          (v) => setState(() => _charset = v!),
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Voucher Mode',
          _authType,
          {
            'USER_SAME_PASS': 'Code Only (User = Password)',
            'USERNAME_ONLY': 'Username Only',
            'USER_PASS': 'Username & Password',
          },
          (v) => setState(() => _authType = v!),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded),
              style: AppTextStyles.bodyMedium,
              items: options.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Confirm(VoucherFormDataLoaded formData) {
    final selectedRouter = formData.routers.firstWhere(
      (r) => r['id'] == formData.selectedRouterId,
      orElse: () => {'name': 'Unknown'},
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Confirm & Generate',
            'Review your voucher settings',
            Icons.check_circle_outline_rounded,
          ),
          const SizedBox(height: 24),

          // Preview Card
          _buildPreviewCard(selectedRouter),

          const SizedBox(height: 24),

          // Summary
          _buildSummarySection(selectedRouter),

          const SizedBox(height: 32),

          // Generate Button
          _buildGenerateButton(formData),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, dynamic> selectedRouter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WASSAL HOTSPOT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '\$${_priceController.text}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '••••••••',
                  style: AppTextStyles.voucherCode.copyWith(
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
                  ),
                  Text(
                    _selectedPlanName ?? 'Standard',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Duration',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
                  ),
                  Text(
                    '${_limitValueController.text} ${_limitType == "Time" ? _timeUnit : _dataUnit}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Map<String, dynamic> selectedRouter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Router', selectedRouter['name'] ?? 'Unknown'),
          _buildSummaryRow('Profile', _selectedPlanName ?? '-'),
          _buildSummaryRow('Quantity', '${_quantityController.text} voucher(s)'),
          _buildSummaryRow('Price Each', '\$${_priceController.text}'),
          _buildSummaryRow(
            'Total',
            '\$${(double.tryParse(_priceController.text) ?? 0) * (int.tryParse(_quantityController.text) ?? 1)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.titleMedium
                : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
                : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton({
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.primaryGradient : null,
          color: enabled ? null : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                'Continue',
                style: AppTextStyles.button.copyWith(
                  color: enabled ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(VoucherFormDataLoaded formData) {
    return BlocBuilder<VoucherBloc, VoucherState>(
      builder: (context, state) {
        final isLoading = state is VoucherGenerating;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : () => _generateVouchers(formData),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Generate ${_quantityController.text} Voucher(s)',
                              style: AppTextStyles.button,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _generateVouchers(VoucherFormDataLoaded formData) {
    HapticFeedback.mediumImpact();

    int? duration;
    int? dataLimit;
    final limitVal = int.parse(_limitValueController.text);

    if (_limitType == 'Time') {
      if (_timeUnit == 'Minutes') duration = limitVal;
      else if (_timeUnit == 'Hours') duration = limitVal * 60;
      else if (_timeUnit == 'Days') duration = limitVal * 60 * 24;
    } else {
      if (_dataUnit == 'MB') dataLimit = limitVal * 1024 * 1024;
      else if (_dataUnit == 'GB') dataLimit = limitVal * 1024 * 1024 * 1024;
    }

    context.read<VoucherBloc>().add(GenerateVoucherEvent(
      routerId: formData.selectedRouterId!,
      profileId: null,
      mikrotikProfile: _selectedPlanName,
      planName: _selectedPlanName ?? 'Standard',
      price: double.parse(_priceController.text),
      quantity: int.parse(_quantityController.text),
      duration: duration,
      dataLimit: dataLimit,
      charset: _charset,
      authType: _authType,
    ));
  }
}
