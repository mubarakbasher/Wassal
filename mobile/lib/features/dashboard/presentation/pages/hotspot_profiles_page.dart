import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../routers/presentation/bloc/router_bloc.dart';
import '../../../routers/presentation/bloc/router_event.dart';
import '../../../routers/presentation/bloc/router_state.dart';
import '../../../routers/domain/entities/router.dart' as router_model;
import 'create_hotspot_profile_page.dart';

class HotspotProfilesPage extends StatefulWidget {
  const HotspotProfilesPage({super.key});

  @override
  State<HotspotProfilesPage> createState() => _HotspotProfilesPageState();
}

class _HotspotProfilesPageState extends State<HotspotProfilesPage> {
  router_model.Router? _selectedRouter;
  List<router_model.Router> _routers = [];
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<RouterBloc>().add(LoadRoutersEvent());
  }

  Future<void> _fetchProfiles() async {
    if (_selectedRouter == null) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiClient().get(
        ApiEndpoints.routerHotspotProfiles(_selectedRouter!.id),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        setState(() {
          _profiles = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load profiles';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = ErrorHandler.mapDioErrorToMessage(e);
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateHotspotProfilePage()),
    );
    
    // If profile was created, refresh the list
    if (result == true) {
      _fetchProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hotspot Profiles', style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_selectedRouter != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchProfiles,
            ),
        ],
      ),
      floatingActionButton: _selectedRouter != null
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateProfile,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Profile', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: BlocListener<RouterBloc, RouterState>(
        listener: (context, state) {
          if (state is RouterLoaded) {
            // Deduplicate routers by ID
            final Map<String, router_model.Router> uniqueRouters = {};
            for (var router in state.routers) {
              uniqueRouters[router.id] = router;
            }
            setState(() {
              _routers = uniqueRouters.values.toList();
              if (_routers.isNotEmpty && _selectedRouter == null) {
                _selectedRouter = _routers.first;
                _fetchProfiles();
              }
            });
          }
        },
        child: RefreshIndicator(
          onRefresh: _fetchProfiles,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildRouterSelector(),
              const SizedBox(height: 20),
              
              if (_isLoading)
                _buildLoadingState()
              else if (_error != null)
                _buildErrorState()
              else if (_profiles.isEmpty)
                _buildEmptyState()
              else
                ..._profiles.map((profile) => _buildProfileCard(profile)),
              
              // Add bottom padding for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouterSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.router, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedRouter?.id,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: AppColors.primary,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: _routers.map((router) {
                  return DropdownMenuItem<String>(
                    value: router.id,
                    child: Text(
                      '${router.name} [${router.ipAddress}]',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newId) {
                  if (newId != null) {
                    setState(() {
                      _selectedRouter = _routers.firstWhere((r) => r.id == newId);
                    });
                    _fetchProfiles();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profiles...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    if (_error != null && SubscriptionRequiredWidget.isSubscriptionError(_error!)) {
      return SubscriptionRequiredWidget(
        message: SubscriptionRequiredWidget.cleanMessage(_error!),
      );
    }
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, size: 48, color: Colors.red),
          ),
          const SizedBox(height: 16),
          Text('Failed to Load Profiles', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchProfiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text('No Profiles Found', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first profile',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    final name = profile['name'] ?? 'Unknown';
    final rateLimit = profile['rate-limit'] ?? 'No limit';
    final sessionTimeout = profile['session-timeout'] ?? 'No timeout';
    final sharedUsers = profile['shared-users'] ?? '1';
    final idleTimeout = profile['idle-timeout'] ?? 'No timeout';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Properties
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPropertyRow(Icons.speed, 'Rate Limit', rateLimit.toString()),
                _buildPropertyRow(Icons.timer, 'Session Timeout', sessionTimeout.toString()),
                _buildPropertyRow(Icons.people, 'Shared Users', sharedUsers.toString()),
                _buildPropertyRow(Icons.hourglass_empty, 'Idle Timeout', idleTimeout.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
