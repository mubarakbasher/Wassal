import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/router_bloc.dart';
import '../bloc/router_event.dart';
import '../bloc/router_state.dart';
import '../widgets/router_list_item.dart';
import 'add_router_page.dart';

class RoutersManagementPage extends StatefulWidget {
  const RoutersManagementPage({super.key});

  @override
  State<RoutersManagementPage> createState() => _RoutersManagementPageState();
}

class _RoutersManagementPageState extends State<RoutersManagementPage> {
  @override
  void initState() {
    super.initState();
    // Load routers when entering this page
    context.read<RouterBloc>().add(const LoadRoutersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Routers Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RouterBloc>().add(const LoadRoutersEvent());
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<RouterBloc, RouterState>(
        listener: (context, state) {
          if (state is RouterError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
             );
          } else if (state is RouterOperationSuccess) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message), backgroundColor: Colors.green),
             );
          }
        },
        builder: (context, state) {
          if (state is RouterLoading) {
             return const Center(child: CircularProgressIndicator());
          }

          if (state is RouterLoaded) {
             if (state.routers.isEmpty) {
               return const Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.router, size: 64, color: Colors.grey),
                     SizedBox(height: 16),
                     Text("No routers found", style: TextStyle(color: Colors.grey)),
                   ],
                 ),
               );
             }

             return ListView.builder(
               itemCount: state.routers.length,
               padding: const EdgeInsets.only(top: 8, bottom: 80),
               itemBuilder: (context, index) {
                 final router = state.routers[index];
                 return RouterListItem(
                   router: router,
                   onTap: () {
                      // Navigate to details if needed, or just refresh stats
                      // For now, selecting it could just set it as active
                      context.read<RouterBloc>().add(SelectRouterEvent(router));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Router Selected")));
                   },
                   onCheckStatus: () {
                     context.read<RouterBloc>().add(CheckRouterHealthEvent(router.id));
                   },
                   onDelete: () {
                     _showDeleteConfirmation(context, router.id, router.name);
                   },
                 );
               },
             );
          }

          if (state is RouterError) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.error_outline, size: 48, color: Colors.red),
                   const SizedBox(height: 16),
                   Text("Error: ${state.message}"),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => context.read<RouterBloc>().add(const LoadRoutersEvent()),
                     child: const Text("Retry"),
                   ),
                 ],
               ),
             );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRouterPage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String routerId, String routerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Router"),
        content: Text("Are you sure you want to delete '$routerName'? This action cannot be undone."),
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
