import 'package:flutter/material.dart';
import '../widgets/time_range_selector_widget.dart';
import '../widgets/activity_chart_widget.dart';
import '../widgets/summary_card_widget.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          // Title
          const Text(
            'Activities',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Time Range Selector
          const TimeRangeSelectorWidget(),
          
          const SizedBox(height: 24),
          
          // Chart
          const ActivityChartWidget(),
          
          const SizedBox(height: 30),
          
          // Summary Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text(
                      '1 - 30 JUN',
                       style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.close, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: const [
               SummaryCardWidget(
                title: 'Duration',
                value: '39h 54m',
                subtitle: '2h 29m',
                icon: Icons.timer,
                isActive: false,
              ),
              SummaryCardWidget(
                title: 'Active Energy',
                value: '12 200',
                subtitle: 'kcal',
                icon: Icons.local_fire_department,
                isActive: true, // Highlighted
              ),
              SummaryCardWidget(
                title: 'Distance',
                value: '234,13',
                subtitle: 'km',
                icon: Icons.directions_run,
                isActive: false,
              ),
              SummaryCardWidget(
                title: 'Elevation Gain',
                value: '428',
                subtitle: 'm',
                icon: Icons.landscape,
                isActive: false,
              ),
            ],
          ),
           const SizedBox(height: 30),
        ],
      ),
    );
  }
}
