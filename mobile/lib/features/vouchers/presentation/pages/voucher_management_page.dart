import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dashboard/presentation/pages/home_routers_page.dart';
import '../../data/datasources/voucher_remote_data_source.dart';
import '../../data/repositories/voucher_repository_impl.dart';
import '../../domain/entities/voucher.dart';
import '../bloc/voucher_bloc.dart';
import '../bloc/voucher_event.dart';
import '../bloc/voucher_state.dart';
import 'generate_voucher_page.dart';

class VoucherManagementPage extends StatefulWidget {
  const VoucherManagementPage({super.key});

  @override
  State<VoucherManagementPage> createState() => _VoucherManagementPageState();
}

class _VoucherManagementPageState extends State<VoucherManagementPage> {
  String _selectedFilter = 'All'; // All, Active, Unused
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoucherBloc(
        repository: VoucherRepositoryImpl(
          remoteDataSource: VoucherRemoteDataSourceImpl(apiClient: ApiClient()),
        ),
      )..add(const LoadVouchersEvent()),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocBuilder<VoucherBloc, VoucherState>(
                  builder: (context, state) {
                    if (state is VoucherLoading) {
                      return const Center(child: CircularProgressIndicator());
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
                      return Center(child: Text('Error: ${state.message}'));
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const GenerateVoucherPage()),
             ).then((_) {
                 // Refresh list on return (if needed, or handle via proper stream)
                 // Ideally Bloc would be scoped higher or we reload here:
                 // context.read<VoucherBloc>().add(const LoadVouchersEvent());
                 // Since we are creating a NEW BlocProvider here, we can't easily access it from outside unless we move Provider up.
                 // For this MVP, let's just assume we might need to manually refresh or the user pulls to refresh.
             });
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add),
          label: const Text("Generate"),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vouchers",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Search & Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by code or plan...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (val) {
                      // Trigger search
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button (Simplified for now)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                     // Show filter dialog
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> stats) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
             _buildStatCard("Total", "${stats['total'] ?? 0}", Colors.blue),
             const SizedBox(width: 12),
             _buildStatCard("Active", "${stats['active'] ?? 0}", Colors.green),
             const SizedBox(width: 12),
             _buildStatCard("Revenue", "\$0", Colors.orange), // detailed aggregation needed
          ],
        ),
      );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList(BuildContext context, List<Voucher> vouchers) {
    if (vouchers.isEmpty) {
      return const Center(child: Text("No vouchers found"));
    }

    return RefreshIndicator(
      onRefresh: () async {
         context.read<VoucherBloc>().add(const LoadVouchersEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: vouchers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
           final voucher = vouchers[index];
           return _buildVoucherCard(voucher);
        },
      ),
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
      final isUsed = voucher.status == 'used' || voucher.status == 'active'; // dummy status check
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                         voucher.username,
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         voucher.planName,
                         style: TextStyle(color: Colors.grey[600], fontSize: 13),
                       ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUsed ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      voucher.status.toUpperCase(), // Assuming status is 'unused', 'active'
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUsed ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
               ],
             ),
             const SizedBox(height: 12),
             const Divider(),
             const SizedBox(height: 12),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  Text("\$${voucher.price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                       IconButton(icon: const Icon(Icons.print, size: 20, color: Colors.grey), onPressed: () {}),
                       IconButton(icon: const Icon(Icons.share, size: 20, color: Colors.grey), onPressed: () {}),
                       IconButton(icon: const Icon(Icons.more_horiz, size: 20, color: Colors.grey), onPressed: () {}),
                    ],
                  )
               ],
             )
          ],
        ),
      );
  }
}
