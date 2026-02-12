import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    // Load routers on init to ensure fresh data
    context.read<RouterBloc>().add(const LoadRoutersEvent());
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
                  // Title
                  const Text(
                    'My Routers',
                    style: TextStyle(
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
                   Text("Error loading routers: ${state.message}"),
                   TextButton(
                     onPressed: () => context.read<RouterBloc>().add(const LoadRoutersEvent()),
                     child: const Text("Retry"),
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
        label: const Text("Add Router"),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
          const Text(
            "No routers yet",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add your first MikroTik router to get started.",
            style: TextStyle(color: Colors.grey),
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
             label: const Text("Add Router"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String routerId, String routerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Router"),
        content: Text("Are you sure you want to delete '$routerName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
               Navigator.pop(context);
               context.read<RouterBloc>().add(DeleteRouterEvent(routerId));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
