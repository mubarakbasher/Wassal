import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/snackbar_utils.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../bloc/router_bloc.dart';
import '../bloc/router_event.dart';
import '../bloc/router_state.dart';
import 'add_router_page.dart';
import 'router_details_page.dart';

/// Improved Routers List Page with UI/UX enhancements
/// 
/// Features:
/// - Shimmer loading states
/// - Empty state with illustration
/// - Error handling with snackbars
/// - Pull to refresh
/// - Fade-in animations for list items
class RoutersListPageImproved extends StatefulWidget {
  const RoutersListPageImproved({super.key});

  @override
  State<RoutersListPageImproved> createState() => _RoutersListPageImprovedState();
}

class _RoutersListPageImprovedState extends State<RoutersListPageImproved> {
  @override
  void initState() {
    super.initState();
    context.read<RouterBloc>().add(const LoadRoutersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Routers',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.card,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocConsumer<RouterBloc, RouterState>(
        listener: (context, state) {
          // Show error snackbar with retry option (skip for subscription errors)
          if (state is RouterError && !SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
            SnackBarUtils.showError(
              context,
              state.message,
              onRetry: () {
                context.read<RouterBloc>().add(const LoadRoutersEvent());
              },
            );
          }
          
          // Show success snackbar
          if (state is RouterOperationSuccess) {
            SnackBarUtils.showSuccess(
              context,
              state.message,
            );
            // Reload routers after successful operation
            context.read<RouterBloc>().add(const LoadRoutersEvent());
          }
        },
        builder: (context, state) {
          // Loading state - Show shimmer
          if (state is RouterLoading) {
            return const RouterListShimmer(itemCount: 5);
          }

          // Error state - Show subscription required or error widget
          if (state is RouterError) {
            if (SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
              return const SubscriptionRequiredWidget();
            }
            return ErrorStateWidget(
              message: state.message,
              onRetry: () {
                context.read<RouterBloc>().add(const LoadRoutersEvent());
              },
            );
          }

          // Loaded state
          if (state is RouterLoaded) {
            // Empty state - Show empty widget with action
            if (state.routers.isEmpty) {
              return EmptyRoutersState(
                onAddRouter: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddRouterPage()),
                  );
                },
              );
            }

            // Success state - Show list with pull to refresh
            return CustomRefreshIndicator(
              onRefresh: () async {
                context.read<RouterBloc>().add(const LoadRoutersEvent());
                // Wait a bit for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.routers.length,
                itemBuilder: (context, index) {
                  final router = state.routers[index];
                  
                  // Add fade-in animation with staggered delay
                  return FadeInWidget(
                    delay: Duration(milliseconds: index * 50),
                    child: _RouterCard(router: router),
                  );
                },
              ),
            );
          }

          // Default state
          return const LoadingIndicator(
            message: 'Loading routers...',
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddRouterPage()),
          );
          
          // Reload routers if a router was added
          if (result == true && mounted) {
            context.read<RouterBloc>().add(const LoadRoutersEvent());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Router'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _RouterCard extends StatelessWidget {
  final dynamic router;

  const _RouterCard({required this.router});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ONLINE':
        return AppColors.online;
      case 'OFFLINE':
        return AppColors.offline;
      case 'ERROR':
        return AppColors.errorStatus;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RouterDetailsPage(router: router),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.router,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          router.name,
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          router.ipAddress,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(router.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(router.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          router.status,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _getStatusColor(router.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    router.username,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    router.lastSeen != null
                        ? 'Last seen: ${_formatDateTime(router.lastSeen)}'
                        : 'Never connected',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
