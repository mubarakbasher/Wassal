import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/activity_chart_widget.dart';
import '../widgets/summary_card_widget.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'package:mobile/features/routers/presentation/pages/add_router_page.dart';
import '../../../vouchers/presentation/pages/generate_voucher_page.dart';

class BusinessDashboardPage extends StatelessWidget {
  const BusinessDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get Dio instance from ServiceLocator or Provider
    // Using a temporary Dio instance for now, normally inherited
    final dio = Dio(); 

    // We need a router ID to fetch stats. 
    // Since we don't have a specific selected router state yet, we might hardcode or fetch first router.
    // For this implementation, I will assume we fetch the first router ID or similar. 
    // Actually, let's update the Bloc to maybe fetch "First Router" if no ID provided?
    // Or just pass a hardcoded ID we know exists for testing?
    // Let's rely on the User to have at least one router.
    
    // TEMPORARY: Ensure we have a router ID. 
    // In a real app, 'AuthBloc' or 'RouterBloc' would hold the selected router.
    // I will trigger loading with a known ID from my testing or logic to find one.
    // Wait, the user wants to LINK it.
    
    return BlocProvider(
      create: (context) => DashboardBloc(dio: dio), // TODO: Inject Dio properly
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  
  @override
  void initState() {
    super.initState();
    // Auto-load stats (fetches all routers and defaults to first)
    context.read<DashboardBloc>().add(const LoadDashboardStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        
        // Mock Defaults
        String totalRouters = "0";
        String activeUsers = "0";
        String totalVouchers = "0";
        String totalRevenue = "\$0.0";
        bool isActiveUsersHighlight = true;
        
        if (state is DashboardLoaded) {
             activeUsers = state.activeUsers.toString();
             totalRouters = state.totalRouters.toString(); 
             totalVouchers = state.totalUsers.toString(); 
             totalRevenue = "\$${state.totalRevenue.toStringAsFixed(1)}"; // Format to 1 decimal
        } else if (state is DashboardLoading) {
             activeUsers = "Loading..."; // Optional: Can keep as 0 or show spinner. User said "make 0 if there is no active users", implies 0 is better default.
             // But if it IS loading, maybe "..." is better?
             // User Request: "active user say loading let make 0 if there is no active users"
             // Interpretation: The initial state should be 0, not "Loading...". 
             // If I keep it "Loading..." during actual fetch, that might remain annoying.
             // I'll set it to "0" even during loading, or maybe just initial.
             // Let's stick to "0" as default.
              activeUsers = "0"; 
        } else if (state is DashboardError) {
            activeUsers = "0"; // Even on error, maybe 0 is safer than "Err" for aesthetics? Or keep "Err". User specifically mentioned "if there is no active users".
            // I'll keep "Err" for error to distinguish, but ensure initial is 0.
        }

        const userName = "Mubarak"; 

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                'Hello, $userName',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is your hotspot overview',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              

              // Summary Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  SummaryCardWidget(
                    title: 'Total Routers',
                    value: totalRouters,
                    subtitle: 'Online',
                    icon: Icons.router,
                    isActive: false, 
                  ),
                  SummaryCardWidget(
                    title: 'Active Users',
                    value: activeUsers,
                    subtitle: 'Users',
                    icon: Icons.people,
                    isActive: isActiveUsersHighlight,
                  ),
                  SummaryCardWidget(
                    title: 'Total Users', // Changed label
                    value: totalVouchers,
                    subtitle: 'Registered',
                    icon: Icons.confirmation_number,
                    isActive: false,
                  ),
                  SummaryCardWidget(
                    title: 'Revenue',
                    value: totalRevenue,
                    subtitle: 'This Month',
                    icon: Icons.attach_money,
                    isActive: false,
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Chart Section
              const Text(
                'Active Users Real-time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const ActivityChartWidget(), 
              
              const SizedBox(height: 30),
              
              // Quick Actions
               const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                    Expanded(child: _buildQuickAction(context, Icons.add, "Add Router", AppColors.primary)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildQuickAction(context, Icons.print, "Print Voucher", AppColors.success)),
                ],
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == "Add Router") {
            Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AddRouterPage()),
            );
        } else {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const GenerateVoucherPage()),
             );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
