import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TimeRangeSelectorWidget extends StatefulWidget {
  const TimeRangeSelectorWidget({super.key});

  @override
  State<TimeRangeSelectorWidget> createState() => _TimeRangeSelectorWidgetState();
}

class _TimeRangeSelectorWidgetState extends State<TimeRangeSelectorWidget> {
  int _selectedIndex = 2; // Default to 'Year'
  final List<String> _ranges = ['Week', 'Month', 'Year', 'All Time'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_ranges.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _ranges[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
