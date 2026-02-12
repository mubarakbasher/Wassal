import 'package:flutter/material.dart';
import '../../domain/entities/session_statistics.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SessionStatisticsCard extends StatelessWidget {
  final SessionStatistics statistics;

  const SessionStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Statistics',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  'Total',
                  statistics.totalSessions.toString(),
                  Colors.blue,
                  Icons.people_outline,
                ),
                const SizedBox(width: 12),
                _buildStatItem(
                  'Active',
                  statistics.activeSessions.toString(),
                  Colors.green,
                  Icons.person,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(
                  'Download',
                  _formatBytes(statistics.totalBandwidthIn),
                  Colors.green,
                  Icons.arrow_downward,
                ),
                const SizedBox(width: 12),
                _buildStatItem(
                  'Upload',
                  _formatBytes(statistics.totalBandwidthOut),
                  Colors.orange,
                  Icons.arrow_upward,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              'Avg. Duration',
              _formatUptime(statistics.averageUptime),
              AppColors.primary,
              Icons.access_time,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon, {
    bool fullWidth = false,
  }) {
    final widget = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return fullWidth ? widget : Expanded(child: widget);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';
    }
  }

  String _formatUptime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '${minutes}m';
    } else if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    } else {
      final days = seconds ~/ 86400;
      final hours = (seconds % 86400) ~/ 3600;
      return '${days}d ${hours}h';
    }
  }
}
