import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../routers/presentation/bloc/router_bloc.dart';
import '../../../routers/presentation/bloc/router_event.dart';
import '../../../routers/presentation/bloc/router_state.dart';
import '../../../routers/presentation/widgets/router_list_item.dart';
import '../../../routers/presentation/pages/add_router_page.dart';
import '../../../routers/presentation/pages/router_details_page.dart';

class HomeRoutersPage extends StatefulWidget {
  const HomeRoutersPage({super.key});

  @override
  State<HomeRoutersPage> createState() => _HomeRoutersPageState();
}

class _HomeRoutersPageState extends State<HomeRoutersPage> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    context.read<RouterBloc>().add(const LoadRoutersEvent());
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        context.read<RouterBloc>().add(const LoadRoutersEvent(statusOnly: true));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: BlocConsumer<RouterBloc, RouterState>(
        listener: (context, state) {
           if (state is RouterOperationSuccess) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message), backgroundColor: Colors.green),
             );
           } else if (state is RouterError && !SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
             );
           }
        },
        builder: (context, state) {
          if (state is RouterLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RouterLoaded) {
            if (state.routers.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RouterBloc>().add(const LoadRoutersEvent());
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    AppLocalizations.of(context)!.myRouters,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // List
                  ...state.routers.map((router) => RouterListItem(
                    router: router, 
                    onTap: () {
                       // Navigate to router details page
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (_) => RouterDetailsPage(router: router),
                         ),
                       );
                    }, 
                    onCheckStatus: () {
                      context.read<RouterBloc>().add(CheckRouterHealthEvent(router.id));
                    }, 
                    onDelete: () {
                      _showDeleteConfirmation(context, router.id, router.name);
                    }
                  )),

                  const SizedBox(height: 80), // Space for FAB or BottomNav
                ],
              ),
            );
          }

          if (state is RouterError) {
             if (SubscriptionRequiredWidget.isSubscriptionError(state.message)) {
               return const SubscriptionRequiredWidget();
             }
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.error_outline, size: 48, color: Colors.red),
                   const SizedBox(height: 16),
                   Text("${AppLocalizations.of(context)!.errorLoadingRouters}: ${state.message}"),
                   TextButton(
                     onPressed: () => context.read<RouterBloc>().add(const LoadRoutersEvent()),
                     child: Text(AppLocalizations.of(context)!.retry),
                   )
                 ],
               ),
             );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRouterPage()),
          ).then((result) {
            if (result == true && mounted) {
              context.read<RouterBloc>().add(const LoadRoutersEvent());
            }
          });
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addRouter),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.router, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noRoutersYet,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstRouterHint,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
             onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddRouterPage()),
                ).then((result) {
                  if (result == true && mounted) {
                    context.read<RouterBloc>().add(const LoadRoutersEvent());
                  }
                });
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.primary,
               foregroundColor: Colors.white,
               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
             ),
             icon: const Icon(Icons.add),
             label: Text(l10n.addRouter),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String routerId, String routerName) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRouterTitle),
        content: Text(l10n.deleteRouterMsg(routerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
               Navigator.pop(context);
               context.read<RouterBloc>().add(DeleteRouterEvent(routerId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
