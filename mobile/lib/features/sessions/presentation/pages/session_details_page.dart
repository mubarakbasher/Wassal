import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/session.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/snackbar_utils.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';

class SessionDetailsPage extends StatefulWidget {
  final Session session;

  const SessionDetailsPage({super.key, required this.session});

  @override
  State<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage> {
  bool _isTerminating = false;

  Future<void> _terminateSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminate Session'),
        content: Text(
          'Are you sure you want to terminate the session for ${widget.session.username}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isTerminating = true);
      
      try {
        context.read<SessionBloc>().add(TerminateSessionEvent(widget.session.id));
        
        // Wait for state update
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          SnackBarUtils.showError(context, 'Failed to terminate session');
        }
      } finally {
        if (mounted) {
          setState(() => _isTerminating = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isTerminating,
      message: 'Terminating session...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Session Details',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.card,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Card
              _buildCard(
                title: 'User Information',
                icon: Icons.person,
                children: [
                  _buildDetailRow('Username', widget.session.username),
                  _buildDetailRow(
                    'Status',
                    widget.session.isActive ? 'Active' : 'Inactive',
                    valueColor: widget.session.isActive ? Colors.green : Colors.grey,
                  ),
                  if (widget.session.routerName != null)
                    _buildDetailRow('Router', widget.session.routerName!),
                ],
              ),
              const SizedBox(height: 16),

              // Connection Details Card
              _buildCard(
                title: 'Connection Details',
                icon: Icons.network_check,
                children: [
                  _buildDetailRow('IP Address', widget.session.ipAddress ?? 'N/A'),
                  _buildDetailRow('MAC Address', widget.session.macAddress ?? 'N/A'),
                  _buildDetailRow(
                    'Connected Since',
                    _formatDateTime(widget.session.startTime),
                  ),
                  if (widget.session.endTime != null)
                    _buildDetailRow(
                      'Disconnected At',
                      _formatDateTime(widget.session.endTime!),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Session Duration Card
              _buildCard(
                title: 'Session Duration',
                icon: Icons.access_time,
                children: [
                  _buildDetailRow('Uptime', _formatUptime(widget.session.uptime)),
                  _buildDetailRow(
                    'Duration',
                    '${(widget.session.uptime / 60).toStringAsFixed(0)} minutes',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bandwidth Usage Card
              _buildCard(
                title: 'Bandwidth Usage',
                icon: Icons.data_usage,
                children: [
                  _buildDetailRow(
                    'Downloaded',
                    _formatBytes(widget.session.bytesIn),
                    valueColor: Colors.green,
                  ),
                  _buildDetailRow(
                    'Uploaded',
                    _formatBytes(widget.session.bytesOut),
                    valueColor: Colors.orange,
                  ),
                  _buildDetailRow(
                    'Total',
                    _formatBytes(widget.session.bytesIn + widget.session.bytesOut),
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Terminate Button
              if (widget.session.isActive)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isTerminating ? null : _terminateSession,
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text('Terminate Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatUptime(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '$minutes minutes $secs seconds';
    } else if (seconds < 86400) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours hours $minutes minutes';
    } else {
      final days = seconds ~/ 86400;
      final hours = (seconds % 86400) ~/ 3600;
      return '$days days $hours hours';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
