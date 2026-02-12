import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/snackbar_utils.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/ticket_card_widget.dart';
import '../../domain/entities/voucher.dart';
import '../utils/voucher_image_generator.dart';
import '../bloc/voucher_bloc.dart';
import '../bloc/voucher_event.dart';
import '../bloc/voucher_state.dart';
import 'generate_voucher_page.dart';

import 'dart:async';
import 'print_voucher_page.dart';

class VoucherManagementPage extends StatefulWidget {
  const VoucherManagementPage({super.key});

  @override
  State<VoucherManagementPage> createState() => VoucherManagementPageState();
}

class VoucherManagementPageState extends State<VoucherManagementPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  Timer? _statsTimer;
  Timer? _debounceTimer;

  // Selection Mode State
  final Set<String> _selectedVouchers = {};
  bool get _isSelectionMode => _selectedVouchers.isNotEmpty;

  /// Public method to enter selection mode from external widgets (e.g., app bar menu)
  void enterSelectionModeFromOutside() {
    // Select the first voucher to activate selection mode
    final state = context.read<VoucherBloc>().state;
    if (state is VouchersListLoaded && state.vouchers.isNotEmpty) {
      setState(() {
        _selectedVouchers.add(state.vouchers.first.id);
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherBloc>().add(const LoadVouchersEvent());
      _startStatsPolling();
    });
  }

  void _startStatsPolling() {
    _statsTimer?.cancel();
    _statsTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        context.read<VoucherBloc>().add(const LoadVoucherStats());
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<VoucherBloc>().add(LoadVouchersEvent(search: query));
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_isSelectionMode) {
          _exitSelectionMode();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _isSelectionMode ? _buildSelectionHeader() : _buildHeader(),
              Expanded(
                child: BlocConsumer<VoucherBloc, VoucherState>(
                  listener: (context, state) {
                    if (state is VoucherError && !SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
                      SnackBarUtils.showError(
                        context,
                        state.message,
                        onRetry: () {
                          context.read<VoucherBloc>().add(const LoadVouchersEvent());
                        },
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is VoucherLoading) {
                      return const VoucherListShimmer(itemCount: 5);
                    }

                    if (state is VouchersListLoaded) {
                      return Column(
                        children: [
                          _buildStatsRow(state.stats),
                          Expanded(child: _buildVoucherList(context, state.vouchers)),
                        ],
                      );
                    }

                    if (state is VoucherError) {
                      if (SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
                        return const SubscriptionRequiredWidget();
                      }
                      return ErrorStateWidget(
                        message: state.message,
                        onRetry: () {
                          context.read<VoucherBloc>().add(const LoadVouchersEvent());
                        },
                      );
                    }

                    return const LoadingIndicator(message: 'Loading vouchers...');
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _isSelectionMode ? null : _buildFAB(),
        bottomNavigationBar: _isSelectionMode ? SafeArea(child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildPrintFAB(), // This returns the bulk actions bar
        )) : null,
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _exitSelectionMode,
            ),
            const SizedBox(width: 8),
            Text(
              "${_selectedVouchers.length} Selected",
              style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
            ),
            const Spacer(),
            const Spacer(),
            TextButton(
              onPressed: _selectAll,
              child: Text(
                _selectedVouchers.length == (context.read<VoucherBloc>().state is VouchersListLoaded ? (context.read<VoucherBloc>().state as VouchersListLoaded).vouchers.length : 0)
                    ? "Deselect All"
                    : "Select All",
                style: AppTextStyles.buttonSmall.copyWith(color: Colors.white),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Vouchers",
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: "Search by code or plan...",
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textTertiary,
                        size: 22,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: _selectedFilter != 'All'
            ? AppColors.primaryGradient
            : null,
        color: _selectedFilter == 'All' ? AppColors.cardElevated : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _selectedFilter == 'All'
              ? AppColors.border.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            _showFilterBottomSheet();
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(
              Icons.tune_rounded,
              color: _selectedFilter != 'All' ? Colors.white : AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Filter Vouchers', style: AppTextStyles.titleLarge),
            const SizedBox(height: 20),
            _buildFilterOption('All', Icons.grid_view_rounded),
            _buildFilterOption('Active', Icons.play_circle_outline_rounded),
            _buildFilterOption('Unused', Icons.fiber_new_rounded),
            _buildFilterOption('Expired', Icons.timer_off_outlined),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String filter, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        filter,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() => _selectedFilter = filter);
        Navigator.pop(context);
        context.read<VoucherBloc>().add(LoadVouchersEvent(
          status: filter == 'All' ? null : filter.toLowerCase(),
        ));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _buildGradientStatCard(
            "Total",
            "${stats['total'] ?? 0}",
            Icons.confirmation_number_outlined,
            AppColors.blueGradient,
          ),
          const SizedBox(width: 12),
          _buildGradientStatCard(
            "Active",
            "${stats['active'] ?? 0}",
            Icons.bolt_rounded,
            AppColors.greenGradient,
          ),
          const SizedBox(width: 12),
          _buildGradientStatCard(
            "Revenue",
            "\$${stats['totalRevenue'] ?? 0}",
            Icons.attach_money_rounded,
            AppColors.orangeGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientStatCard(
    String label,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: Colors.white70, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList(BuildContext context, List<Voucher> vouchers) {
    if (vouchers.isEmpty) {
      return EmptyVouchersState(
        onCreateVoucher: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GenerateVoucherPage()),
          );
        },
      );
    }

    return BlocBuilder<VoucherBloc, VoucherState>(
      buildWhen: (previous, current) => 
        current is VouchersListLoaded && previous is VouchersListLoaded &&
        (previous.isLoadingMore != current.isLoadingMore ||
         previous.hasReachedMax != current.hasReachedMax),
      builder: (context, state) {
        final listState = state is VouchersListLoaded ? state : null;
        
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              // Load more when near bottom
              final bloc = context.read<VoucherBloc>();
              // Don't load more during selection mode to verify stability of list
              if (!_isSelectionMode && bloc.state is VouchersListLoaded) {
                final s = bloc.state as VouchersListLoaded;
                if (!s.isLoadingMore && !s.hasReachedMax) {
                  bloc.add(LoadMoreVouchersEvent(
                    search: _searchController.text.isNotEmpty ? _searchController.text : null,
                    status: _selectedFilter == 'All' ? null : _selectedFilter.toLowerCase(),
                  ));
                }
              }
            }
            return false;
          },
          child: CustomRefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              context.read<VoucherBloc>().add(const LoadVouchersEvent());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: vouchers.length + (listState?.isLoadingMore == true || !(listState?.hasReachedMax ?? true) ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the end
                if (index >= vouchers.length) {
                  return _buildLoadMoreIndicator(listState?.isLoadingMore ?? false);
                }
                
                final voucher = vouchers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: StaggeredListItem(
                    index: index,
                    child: TicketCardWidget(
                      code: voucher.username,
                      planName: voucher.planName,
                      status: voucher.status,
                      price: voucher.price,
                      duration: _formatDuration(voucher.duration),
                      onPrint: () => _handlePrint(voucher),
                      onShare: () => _handleShare(voucher),
                      onMore: () => _showVoucherOptions(voucher),
                      onTap: () {
                         if (_isSelectionMode) {
                           _toggleSelection(voucher);
                         } else {
                           _showVoucherDetails(voucher);
                         }
                      },
                      onLongPress: () => _enterSelectionMode(voucher),
                      isSelected: _selectedVouchers.contains(voucher.id),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : Text(
                'Scroll for more',
                style: AppTextStyles.bodySmall,
              ),
      ),
    );
  }

  String? _formatDuration(int? minutes) {
    if (minutes == null) return null;
    if (minutes < 60) return '${minutes}m';
    if (minutes < 1440) return '${(minutes / 60).round()}h';
    return '${(minutes / 1440).round()}d';
  }

  void _handlePrint(Voucher voucher) {
    HapticFeedback.lightImpact();
    // Navigate to Print Page with single voucher
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintVoucherPage(vouchers: [voucher]),
      ),
    );
  }

  // --- Selection Mode Logic ---

  void _enterSelectionMode(Voucher voucher) {
    setState(() {
      _selectedVouchers.add(voucher.id);
    });
    HapticFeedback.selectionClick();
  }

  void _toggleSelection(Voucher voucher) {
    setState(() {
      if (_selectedVouchers.contains(voucher.id)) {
        _selectedVouchers.remove(voucher.id);
      } else {
        _selectedVouchers.add(voucher.id);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedVouchers.clear();
    });
  }


  void _selectAll() {
    final state = context.read<VoucherBloc>().state;
    if (state is VouchersListLoaded) {
      setState(() {
        if (_selectedVouchers.length == state.vouchers.length) {
          _selectedVouchers.clear();
        } else {
          _selectedVouchers.addAll(state.vouchers.map((v) => v.id));
        }
      });
      HapticFeedback.selectionClick();
    }
  }

  void _handleBulkPrint() {
     // Retrieve full voucher objects from the Bloc state
     final state = context.read<VoucherBloc>().state;
     if (state is VouchersListLoaded) {
       final selectedVouchers = state.vouchers.where((v) => _selectedVouchers.contains(v.id)).toList();
       if (selectedVouchers.isNotEmpty) {
         Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrintVoucherPage(vouchers: selectedVouchers),
            ),
         ).then((_) => _exitSelectionMode());
       }
     }
  }

  void _handleBulkShare() {
    // Collect voucher details and share as text
    final state = context.read<VoucherBloc>().state;
    if (state is VouchersListLoaded) {
       final selected = state.vouchers.where((v) => _selectedVouchers.contains(v.id)).toList();
       if (selected.isEmpty) return;

       final buffer = StringBuffer();
       buffer.writeln('═══════════════════════');
       buffer.writeln('    WASSAL HOTSPOT VOUCHERS');
       buffer.writeln('═══════════════════════\n');

       for (var voucher in selected) {
         buffer.writeln('Username: ${voucher.username}');
         if (voucher.password.isNotEmpty && voucher.password != voucher.username) {
           buffer.writeln('Password: ${voucher.password}');
         }
         buffer.writeln('Plan: ${voucher.planName}');
         buffer.writeln('Price: \$${voucher.price.toStringAsFixed(2)}');
         buffer.writeln('-----------------------');
       }
       
       buffer.writeln('\nConnect to WiFi and login at:');
       buffer.writeln('http://mikrotik');

       Share.share(buffer.toString());
       _exitSelectionMode();
    }
  }

  void _handleBulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vouchers'),
        content: Text('Are you sure you want to delete ${_selectedVouchers.length} vouchers? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<VoucherBloc>().add(DeleteVouchersEvent(
                 _selectedVouchers.toList(),
              ));
              _exitSelectionMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Deleting vouchers...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _handleShare(Voucher voucher) {
    HapticFeedback.lightImpact();
    _showShareOptions(voucher);
  }

  void _showShareOptions(Voucher voucher) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share Voucher', style: AppTextStyles.titleLarge),
            const SizedBox(height: 20),
            _buildShareOptionTile(
              Icons.image_outlined,
              'Share as Image',
              'Beautiful styled voucher card',
              () {
                Navigator.pop(context);
                VoucherImageGenerator.shareAsImage(context, voucher);
              },
            ),
            _buildShareOptionTile(
              Icons.text_fields_rounded,
              'Share as Text',
              'Plain text format',
              () {
                Navigator.pop(context);
                _shareAsText(voucher);
              },
            ),
            _buildShareOptionTile(
              Icons.qr_code_rounded,
              'Share QR Code',
              'Scannable QR image',
              () {
                Navigator.pop(context);
                _shareQRCode(voucher);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOptionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _shareAsText(Voucher voucher) {
    final text = '''
═══════════════════════
    WASSAL HOTSPOT
═══════════════════════

Username: ${voucher.username}
${voucher.password.isNotEmpty && voucher.password != voucher.username ? 'Password: ${voucher.password}\n' : ''}Plan: ${voucher.planName}
Price: \$${voucher.price.toStringAsFixed(2)}

───────────────────────
Connect to WiFi and login at:
http://mikrotik
''';
    Share.share(text);
  }

  void _shareQRCode(Voucher voucher) {
    // For now, share as image with QR code
    VoucherImageGenerator.shareAsImage(context, voucher);
  }

  void _showVoucherOptions(Voucher voucher) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              Icons.print_rounded,
              'Print Voucher',
              () => _handlePrint(voucher),
            ),
            _buildOptionTile(
              Icons.share_rounded,
              'Share Voucher',
              () => _handleShare(voucher),
            ),
            _buildOptionTile(
              Icons.copy_rounded,
              'Copy Code',
              () {
                Clipboard.setData(ClipboardData(text: voucher.username));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Code copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            _buildOptionTile(
              Icons.qr_code_rounded,
              'Show QR Code',
              () {
                Navigator.pop(context);
                _showQRCode(voucher);
              },
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              Icons.delete_outline_rounded,
              'Delete Voucher',
              () {
                Navigator.pop(context);
                // TODO: Implement delete
              },
              isDestructive: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : AppColors.cardElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showVoucherDetails(Voucher voucher) {
    HapticFeedback.lightImpact();
    // TODO: Navigate to voucher details page
  }

  void _showQRCode(Voucher voucher) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan to Connect', style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                voucher.username,
                style: AppTextStyles.voucherCode.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 180,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GenerateVoucherPage()),
            ).then((_) {
              if (mounted) {
                context.read<VoucherBloc>().add(const LoadVouchersEvent());
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Generate', style: AppTextStyles.button),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrintFAB() {
    // Replaced by _buildBulkActionsBar
    // To minimize changes we call it here but it returns the bulk bar
    return _buildBulkActionsBar();
  }

  Widget _buildBulkActionsBar() {
    return Container(
      margin: const EdgeInsets.only(left: 32, bottom: 0), // Adjust for FAB placement if used in floatingActionButton
      // Using floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat would be better but standard FAB is bottom right.
      // We will make this look like a floating bar.
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.15),
             blurRadius: 16,
             offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBulkAction(
             Icons.print_rounded, 
             "Print", 
             _handleBulkPrint,
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: AppColors.divider),
          const SizedBox(width: 16),
          _buildBulkAction(
             Icons.share_rounded, 
             "Share", 
             _handleBulkShare,
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: AppColors.divider),
          const SizedBox(width: 16),
          _buildBulkAction(
             Icons.delete_outline_rounded, 
             "Delete", 
             _handleBulkDelete,
             isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBulkAction(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isDestructive ? AppColors.error : AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                 color: isDestructive ? AppColors.error : AppColors.textPrimary,
                 fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
