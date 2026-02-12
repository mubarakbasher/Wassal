import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../routers/domain/entities/router.dart' as router_model;
import '../../../routers/presentation/bloc/router_bloc.dart';
import '../../../routers/presentation/bloc/router_event.dart';
import '../../../routers/presentation/bloc/router_state.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  router_model.Router? _selectedRouter;
  List<router_model.Router> _routers = [];

  @override
  void initState() {
    super.initState();
    context.read<RouterBloc>().add(const LoadRoutersEvent());
  }

  void _fetchStats() {
    if (_selectedRouter != null) {
      context.read<RouterBloc>().add(GetRouterStatsEvent(_selectedRouter!.id));
    }
  }

  String _formatBytes(String? bytesStr) {
    if (bytesStr == null) return '0 B';
    double bytes = double.tryParse(bytesStr) ?? 0;
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    while (bytes >= 1024 && i < suffixes.length - 1) {
      bytes /= 1024;
      i++;
    }
    return '${bytes.toStringAsFixed(2)} ${suffixes[i]}';
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
              child: BlocConsumer<RouterBloc, RouterState>(
                listener: (context, state) {
                  if (state is RouterLoaded && state.routers.isNotEmpty && _selectedRouter == null) {
                    // Deduplicate routers
                    final Map<String, router_model.Router> uniqueRouters = {};
                    for (var router in state.routers) {
                      uniqueRouters[router.id] = router;
                    }
                    _routers = uniqueRouters.values.toList();
                    setState(() {
                      _selectedRouter = _routers.first;
                    });
                    _fetchStats();
                  }
                },
                builder: (context, state) {
                  // Update routers list when loaded
                  if (state is RouterLoaded) {
                    final Map<String, router_model.Router> uniqueRouters = {};
                    for (var router in state.routers) {
                      uniqueRouters[router.id] = router;
                    }
                    _routers = uniqueRouters.values.toList();
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<RouterBloc>().add(const LoadRoutersEvent());
                      await Future.delayed(const Duration(milliseconds: 500));
                      _fetchStats();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildRouterSelector(state),
                        const SizedBox(height: 20),
                        if (state is RouterLoading)
                          _buildLoadingState()
                        else if (state is RouterError)
                          _buildErrorState(state.message)
                        else if (state is RouterStatsLoaded)
                          _buildStatsContent(state.stats)
                        else if (_selectedRouter != null)
                          _buildEmptyStats()
                        else
                          _buildNoRouterState(),
                      ],
                    ),
                  );
                },
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
            child: Text(
              "Monitoring & Analytics",
              style: AppTextStyles.headlineMedium,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
              onPressed: _fetchStats,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouterSelector(RouterState state) {
    if (_routers.isEmpty && state is! RouterLoading) {
      return const SizedBox.shrink();
    }

    // Ensure selected router is in the list
    if (_selectedRouter != null && !_routers.any((r) => r.id == _selectedRouter!.id)) {
      _selectedRouter = _routers.isNotEmpty ? _routers.first : null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.router_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _routers.isEmpty
                ? const Text(
                    'Loading routers...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRouter?.id,
                      isExpanded: true,
                      dropdownColor: AppColors.primary,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      items: _routers.map((router) {
                        return DropdownMenuItem<String>(
                          value: router.id,
                          child: Text(router.name, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newId) {
                        if (newId != null) {
                          setState(() {
                            _selectedRouter = _routers.firstWhere((r) => r.id == newId);
                          });
                          _fetchStats();
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Loading stats...',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    // Show subscription required widget if it's a subscription error
    if (SubscriptionRequiredWidget.isSubscriptionError(message)) {
      return const SubscriptionRequiredWidget();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.error,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Connection Failed',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchStats,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoRouterState() {
    return const Center(
      child: EmptyStateWidget(
        icon: Icons.router_outlined,
        title: 'No Routers Found',
        message: 'Add a router to start monitoring',
      ),
    );
  }

  Widget _buildEmptyStats() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.analytics_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Tap refresh to load stats',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats) {
    final isOnline = stats['isOnline'] == true;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOnline ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOnline ? Icons.check_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'Router Online' : 'Router Offline',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOnline ? AppColors.success : AppColors.error,
                      ),
                    ),
                    if (stats['uptime'] != null)
                      Text(
                        'Uptime: ${stats['uptime']}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Stats Grid
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'Active Users',
              '${stats['activeUsers'] ?? 0}',
              Icons.people_outline_rounded,
              AppColors.primary,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              'Bandwidth',
              _formatBytes(stats['totalBandwidth']?.toString()),
              Icons.speed_rounded,
              Colors.orange,
            )),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'CPU Load',
              '${stats['cpuLoad'] ?? 0}%',
              Icons.memory_rounded,
              Colors.purple,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              'Memory',
              '${stats['memoryUsage'] ?? 0}%',
              Icons.storage_rounded,
              Colors.teal,
            )),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Router Info
        Text('Router Details', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildInfoRow('Router Name', _selectedRouter?.name ?? '-'),
              const Divider(height: 24),
              _buildInfoRow('IP Address', _selectedRouter?.ipAddress ?? '-'),
              const Divider(height: 24),
              _buildInfoRow('API Port', '${_selectedRouter?.apiPort ?? '-'}'),
              const Divider(height: 24),
              _buildInfoRow('Model', stats['model']?.toString() ?? '-'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
