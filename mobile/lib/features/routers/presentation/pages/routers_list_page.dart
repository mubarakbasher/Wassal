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

class RoutersListPage extends StatefulWidget {
  const RoutersListPage({super.key});

  @override
  State<RoutersListPage> createState() => _RoutersListPageState();
}

class _RoutersListPageState extends State<RoutersListPage> {
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
          if (state is RouterError && !SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
            SnackBarUtils.showError(
              context,
              state.message,
              onRetry: () {
                context.read<RouterBloc>().add(const LoadRoutersEvent());
              },
            );
          } else if (state is RouterOperationSuccess) {
            SnackBarUtils.showSuccess(
              context,
              state.message,
            );
            // Reload routers after successful operation
            context.read<RouterBloc>().add(const LoadRoutersEvent());
          }
        },
        builder: (context, state) {
          if (state is RouterLoading) {
            return const RouterListShimmer(itemCount: 5);
          }

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

          if (state is RouterLoaded) {
            if (state.routers.isEmpty) {
              return EmptyRoutersState(
                onAddRouter: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddRouterPage()),
                  );
                },
              );
            }

            return CustomRefreshIndicator(
              onRefresh: () async {
                context.read<RouterBloc>().add(const LoadRoutersEvent());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.routers.length,
                itemBuilder: (context, index) {
                  final router = state.routers[index];
                  return FadeInWidget(
                    delay: Duration(milliseconds: index * 50),
                    child: _RouterCard(router: router),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddRouterPage()),
          );
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
                    child: Text(
                      router.status,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _getStatusColor(router.status),
                      ),
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
