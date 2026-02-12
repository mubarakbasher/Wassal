import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../sales/presentation/bloc/sales_bloc.dart';
import '../../../sales/presentation/bloc/sales_event.dart';
import '../../../sales/presentation/bloc/sales_state.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _range = 'DAILY';

  @override
  void initState() {
    super.initState();
    context.read<SalesBloc>().add(LoadSalesChartEvent(range: _range));
  }

  Future<void> _generatePdf(SalesState state) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Sales Report - $_range\n\n(Chart Data would go here)"),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  String _formatDate(String dateStr) {
    try {
      // Try to parse and format the date nicely
      if (dateStr.length >= 10) {
        // Format: 2024-01-15 -> Jan 15
        final parts = dateStr.substring(0, 10).split('-');
        if (parts.length == 3) {
          final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final month = int.tryParse(parts[1]) ?? 1;
          final day = parts[2];
          return '${months[month]} $day';
        }
      }
      return dateStr.length > 5 ? dateStr.substring(5, 10) : dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sales & Reports', style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              final state = context.read<SalesBloc>().state;
              _generatePdf(state);
            },
          ),
        ],
      ),
      body: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          if (state is SalesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesError) {
            return _buildErrorState(state.message);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SalesBloc>().add(LoadSalesChartEvent(range: _range));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Range Selector
                _buildRangeSelector(),
                const SizedBox(height: 20),
                
                // Chart
                if (state is SalesLoaded)
                  _buildChart(state.sales),
                  
                const SizedBox(height: 24),
                
                // Recent Sales Section
                _buildRecentSalesSection(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRangeButton('Daily', 'DAILY'),
          const SizedBox(width: 4),
          _buildRangeButton('Monthly', 'MONTHLY'),
        ],
      ),
    );
  }

  Widget _buildRangeButton(String label, String value) {
    final isSelected = _range == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _range = value;
        });
        context.read<SalesBloc>().add(LoadSalesChartEvent(range: value));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<dynamic> sales) {
    if (sales.isEmpty) {
      return _buildEmptyChartState();
    }

    // Calculate max value for Y axis
    double maxY = 0;
    for (var sale in sales) {
      if (sale.amount > maxY) maxY = sale.amount;
    }
    maxY = maxY == 0 ? 100 : maxY * 1.2; // Add 20% padding

    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            _range == 'DAILY' ? 'Daily Sales' : 'Monthly Sales',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${sales.length} data points',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final sale = sales[group.x.toInt()];
                      return BarTooltipItem(
                        '${_formatDate(sale.date)}\n\$${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < sales.length) {
                          // Only show every nth label to avoid crowding
                          final step = (sales.length / 6).ceil().clamp(1, 10);
                          if (index % step == 0 || index == sales.length - 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatDate(sales[index].date),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '\$${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: sales.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.amount,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: sales.length > 15 ? 8 : 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Sales Data',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Sales will appear here when you make your first sale',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    // Show subscription required widget if it's a subscription error
    if (SubscriptionRequiredWidget.isSubscriptionError(message)) {
      return const SubscriptionRequiredWidget();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Error', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<SalesBloc>().add(LoadSalesChartEvent(range: _range));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSalesSection(SalesState state) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Recent Sales', style: AppTextStyles.titleLarge),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.history, color: AppColors.primary),
            ),
            title: const Text('View Sales History'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.read<SalesBloc>().add(LoadSalesHistoryEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loading sales history...')),
              );
            },
          ),
          
          if (state is SalesHistoryLoaded && state.history.isNotEmpty) ...[
            const Divider(height: 1),
            ...state.history.take(5).map((item) => ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.attach_money, color: Colors.white),
              ),
              title: Text('\$${item.amount} - ${item.planName}'),
              subtitle: Text(item.soldAt),
            )),
          ],
        ],
      ),
    );
  }
}
