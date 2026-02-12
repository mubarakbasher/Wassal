import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../domain/entities/router.dart' as entity;
import 'router_logs_page.dart';

class RouterDetailsPage extends StatefulWidget {
  final entity.Router router;

  const RouterDetailsPage({super.key, required this.router});

  @override
  State<RouterDetailsPage> createState() => _RouterDetailsPageState();
}

class _RouterDetailsPageState extends State<RouterDetailsPage> {
  final ApiClient _apiClient = ApiClient();
  
  bool _isLoading = true;
  bool _isRefreshing = false;
  Map<String, dynamic>? _systemInfo;
  Map<String, dynamic>? _stats;
  List<dynamic> _activeUsers = [];
  List<dynamic> _interfaces = [];
  List<dynamic> _hotspotProfiles = [];
  bool? _isOnline;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!_isRefreshing) {
      setState(() => _isLoading = true);
    }

    // Load stats first (most important for summary cards) - wait for it
    await _loadStats();
    
    // Show UI immediately after stats are loaded
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
      });
    }
    
    // Load other data in background - UI will update as each completes
    _loadSystemInfo();
    _loadActiveUsers();
    _loadInterfaces();
    _loadProfiles();
  }

  Future<void> _loadStats() async {
    try {
      final response = await _apiClient.get('/routers/${widget.router.id}/stats');
      if (mounted && response.statusCode == 200) {
        final data = response.data;
        debugPrint('Stats loaded: $data');
        setState(() {
          _stats = data is Map<String, dynamic> ? data : null;
          _isOnline = _stats?['isOnline'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Stats error: $e');
    }
  }

  Future<void> _loadSystemInfo() async {
    try {
      final response = await _apiClient.get('/routers/${widget.router.id}/system-info');
      if (mounted && response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _systemInfo = data is List && data.isNotEmpty ? data[0] : (data is Map ? data : null);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadActiveUsers() async {
    try {
      final response = await _apiClient.get('/routers/${widget.router.id}/active-users');
      if (mounted && response.statusCode == 200) {
        setState(() {
          _activeUsers = response.data ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _loadInterfaces() async {
    try {
      final response = await _apiClient.get('/routers/${widget.router.id}/interfaces');
      if (mounted && response.statusCode == 200) {
        setState(() {
          _interfaces = response.data ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProfiles() async {
    try {
      final response = await _apiClient.get('/routers/${widget.router.id}/profiles/mikrotik');
      if (mounted && response.statusCode == 200) {
        setState(() {
          _hotspotProfiles = response.data ?? [];
        });
      }
    } catch (_) {}
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    _showSnackBar('🔄 Refreshing...', Colors.blue);
    await _loadAllData();
    if (mounted) {
      _showSnackBar('✅ Data refreshed', Colors.green);
    }
  }

  Future<void> _disconnectUser(String sessionId) async {
    try {
      await _apiClient.post('/routers/${widget.router.id}/disconnect-user', data: {'sessionId': sessionId});
      _showSnackBar('User disconnected', Colors.green);
      _refresh();
    } catch (e) {
      _showSnackBar('Failed to disconnect user', Colors.red);
    }
  }

  Future<void> _restartRouter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restart Router'),
        content: const Text('Are you sure you want to restart this router? All active sessions will be disconnected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _apiClient.post('/routers/${widget.router.id}/restart');
        _showSnackBar('Router restart initiated', Colors.orange);
      } catch (e) {
        _showSnackBar('Failed to restart router', Colors.red);
      }
    }
  }

  Future<void> _testConnection() async {
    try {
      final response = await _apiClient.get('/routers/${widget.router.id}/health');
      final online = response.data?['isOnline'] ?? false;
      setState(() => _isOnline = online);
      _showSnackBar(online ? '✅ Router is online' : '❌ Router is offline', online ? Colors.green : Colors.red);
    } catch (e) {
      _showSnackBar('Connection test failed', Colors.red);
    }
  }

  void _viewLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouterLogsPage(
          routerId: widget.router.id,
          routerName: widget.router.name,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _isOnline ?? widget.router.status.toUpperCase() == 'ONLINE';
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.router.name,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
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
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                  tooltip: 'Refresh',
                ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'restart') {
                _restartRouter();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restart',
                child: Row(children: [
                  Icon(Icons.restart_alt, size: 20),
                  SizedBox(width: 8),
                  Text('Restart Router'),
                ]),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Router Info Header
                    _buildRouterInfoCard(isOnline),
                    const SizedBox(height: 16),
                    
                    // Stats Cards
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    
                    // Active Users Card
                    _buildActiveUsersCard(),
                    const SizedBox(height: 16),
                    
                    // Interfaces Card
                    _buildInterfacesCard(),
                    const SizedBox(height: 16),
                    
                    // System Info Card
                    _buildSystemInfoCard(),
                    const SizedBox(height: 16),
                    
                    // Quick Actions
                    _buildActionsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRouterInfoCard(bool isOnline) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.router, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.router.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.router.ipAddress,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOnline ? 'Online' : 'Offline',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final activeUsers = _stats?['activeUsers'] ?? _activeUsers.length;
    final totalUsers = _stats?['totalUsers'] ?? 0;
    final totalVouchers = _stats?['totalVouchers'] ?? 0;
    final uptime = _stats?['uptime'] ?? _systemInfo?['uptime'] ?? 'N/A';
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Active', '$activeUsers', Icons.people, Colors.green)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Total', '$totalUsers', Icons.group, Colors.blue)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard('Vouchers', '$totalVouchers', Icons.confirmation_number, Colors.orange)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard('Uptime', '$uptime', Icons.timer, Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUsersCard() {
    return _buildCard(
      title: 'Active Hotspot Users',
      icon: Icons.people,
      child: _activeUsers.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No active users', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : Column(
              children: _activeUsers.take(5).map((user) => _buildUserTile(user)).toList(),
            ),
    );
  }

  Widget _buildUserTile(dynamic user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(Icons.person, color: Colors.green.shade700),
      ),
      title: Text(user['username'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${user['macAddress'] ?? 'N/A'} • ${user['uptime'] ?? '0s'}'),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.red),
        onPressed: () => _disconnectUser(user['id']),
        tooltip: 'Disconnect',
      ),
    );
  }

  Widget _buildInterfacesCard() {
    return _buildCard(
      title: 'Router Interfaces',
      icon: Icons.settings_ethernet,
      child: _interfaces.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No interfaces found', style: TextStyle(color: Colors.grey))),
            )
          : Column(
              children: _interfaces.take(6).map((iface) => _buildInterfaceTile(iface)).toList(),
            ),
    );
  }

  Widget _buildInterfaceTile(dynamic iface) {
    final isUp = iface['status'] == 'up';
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: isUp ? Colors.green : Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(iface['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(iface['type'] ?? ''),
      trailing: Text(
        'TX: ${_formatBytes(iface['txBytes'] ?? 0)} • RX: ${_formatBytes(iface['rxBytes'] ?? 0)}',
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildSystemInfoCard() {
    final uptime = _stats?['uptime'] ?? _systemInfo?['uptime'] ?? 'N/A';
    
    return _buildCard(
      title: 'System Information',
      icon: Icons.computer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Platform', _systemInfo?['platform'] ?? 'N/A'),
            _buildInfoRow('Version', _systemInfo?['version'] ?? 'N/A'),
            _buildInfoRow('CPU Load', '${_systemInfo?['cpu-load'] ?? 0}%'),
            _buildInfoRow('Uptime', '$uptime'),
            _buildInfoRow('Board', _systemInfo?['board-name'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return _buildCard(
      title: 'Quick Actions',
      icon: Icons.flash_on,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildActionButton('Test Connection', Icons.wifi_tethering, Colors.green, _testConnection)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton('Restart', Icons.restart_alt, Colors.orange, _restartRouter)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildActionButton('Sync', Icons.sync, Colors.blue, _refresh)),
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton('Logs', Icons.article, Colors.purple, _viewLogs)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
