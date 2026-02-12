import 'package:flutter/material.dart';
import '../../domain/entities/session.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Active status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: session.isActive ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Username
                  Expanded(
                    child: Text(
                      session.username,
                      style: AppTextStyles.labelLarge,
                    ),
                  ),
                  
                  // Uptime
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatUptime(session.uptime),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // IP Address and MAC Address
              Row(
                children: [
                  Icon(
                    Icons.computer,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.ipAddress ?? 'No IP',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (session.macAddress != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.router,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.macAddress!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              
              // Bandwidth usage
              Row(
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatBytes(session.bytesIn),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatBytes(session.bytesOut),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.orange),
                  ),
                  const Spacer(),
                  if (session.routerName != null)
                    Text(
                      session.routerName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
