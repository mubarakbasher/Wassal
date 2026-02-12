import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_colors.dart';

class RouterLogsPage extends StatefulWidget {
  final String routerId;
  final String routerName;

  const RouterLogsPage({
    super.key,
    required this.routerId,
    required this.routerName,
  });

  @override
  State<RouterLogsPage> createState() => _RouterLogsPageState();
}

class _RouterLogsPageState extends State<RouterLogsPage> {
  final ApiClient _apiClient = ApiClient();
  
  List<dynamic> _logs = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    try {
      final response = await _apiClient
          .get('/routers/${widget.routerId}/logs?limit=50')
          .timeout(const Duration(seconds: 45)); // Longer timeout for logs
      
      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            _logs = response.data ?? [];
            _isLoading = false;
            _isRefreshing = false;
            _error = _logs.isEmpty ? null : null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _isRefreshing = false;
            _error = 'Server error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _error = e.toString().contains('TimeoutException') 
              ? 'Request timed out - router may be slow to respond'
              : 'Failed to load logs';
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _loadLogs();
  }

  Color _getTopicColor(String topics) {
    if (topics.contains('error') || topics.contains('critical')) {
      return AppColors.error;
    } else if (topics.contains('warning')) {
      return AppColors.warning;
    } else if (topics.contains('info')) {
      return AppColors.info;
    } else if (topics.contains('system')) {
      return AppColors.primary;
    } else if (topics.contains('hotspot') || topics.contains('dhcp')) {
      return AppColors.success;
    }
    return Colors.grey;
  }

  IconData _getTopicIcon(String topics) {
    if (topics.contains('error') || topics.contains('critical')) {
      return Icons.error_outline;
    } else if (topics.contains('warning')) {
      return Icons.warning_amber_outlined;
    } else if (topics.contains('hotspot')) {
      return Icons.wifi;
    } else if (topics.contains('dhcp')) {
      return Icons.router;
    } else if (topics.contains('system')) {
      return Icons.settings;
    } else if (topics.contains('interface')) {
      return Icons.cable;
    } else if (topics.contains('firewall')) {
      return Icons.security;
    }
    return Icons.article_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              widget.routerName,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _refresh,
                ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No logs found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _logs.length,
        itemBuilder: (context, index) => _buildLogItem(_logs[index]),
      ),
    );
  }

  Widget _buildLogItem(dynamic log) {
    final topics = log['topics'] ?? '';
    final message = log['message'] ?? '';
    final time = log['time'] ?? '';
    final color = _getTopicColor(topics);
    final icon = _getTopicIcon(topics);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          topics.isNotEmpty ? topics : 'system',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
