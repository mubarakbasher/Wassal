import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../routers/presentation/bloc/router_bloc.dart';
import '../../../routers/presentation/bloc/router_event.dart';
import '../../../routers/presentation/bloc/router_state.dart';
import '../../../routers/domain/entities/router.dart' as router_model;

class CreateHotspotProfilePage extends StatefulWidget {
  const CreateHotspotProfilePage({super.key});

  @override
  State<CreateHotspotProfilePage> createState() => _CreateHotspotProfilePageState();
}

class _CreateHotspotProfilePageState extends State<CreateHotspotProfilePage> {
  // Router selection
  router_model.Router? _selectedRouter;
  List<router_model.Router> _routers = [];
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timeValueController = TextEditingController(text: '1');
  final _downloadSpeedController = TextEditingController();
  final _uploadSpeedController = TextEditingController();
  final _sharedUsersController = TextEditingController(text: '1');
  final _idleTimeoutController = TextEditingController();
  
  // Time settings
  String _timeUnit = 'days'; // 'minutes', 'hours', 'days'
  bool _useSchedulerTime = true; // Use scheduler-based control (recommended)
  
  // State
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<RouterBloc>().add(LoadRoutersEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeValueController.dispose();
    _downloadSpeedController.dispose();
    _uploadSpeedController.dispose();
    _sharedUsersController.dispose();
    _idleTimeoutController.dispose();
    super.dispose();
  }

  // Convert time to MikroTik interval format
  String _generateTimeInterval() {
    final value = int.tryParse(_timeValueController.text) ?? 0;
    if (value <= 0) return '';
    
    switch (_timeUnit) {
      case 'minutes':
        return '${value}m';
      case 'hours':
        return '${value}h';
      case 'days':
        return '${value}d';
      default:
        return '${value}d';
    }
  }

  // Generate MikroTik rate-limit format
  String _generateRateLimit() {
    final download = _downloadSpeedController.text.trim();
    final upload = _uploadSpeedController.text.trim();
    
    if (download.isEmpty && upload.isEmpty) return '';
    
    final dlSpeed = download.isNotEmpty ? '${download}M' : '0M';
    final ulSpeed = upload.isNotEmpty ? '${upload}M' : '0M';
    
    return '$ulSpeed/$dlSpeed'; // MikroTik format: upload/download
  }

  // Get shared users value
  int _getSharedUsers() {
    return int.tryParse(_sharedUsersController.text) ?? 1;
  }

  // Generate profile data for API
  Map<String, dynamic> _generateProfileData() {
    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
    };

    final timeInterval = _generateTimeInterval();
    if (timeInterval.isNotEmpty) {
      if (_useSchedulerTime) {
        // Use scheduler-based time control (recommended)
        data['useSchedulerTime'] = true;
        data['schedulerInterval'] = timeInterval;
      } else {
        // Use limit-uptime (less reliable)
        data['limitUptime'] = timeInterval;
      }
    }

    final rateLimit = _generateRateLimit();
    if (rateLimit.isNotEmpty) {
      data['rateLimit'] = rateLimit;
    }

    final sharedUsers = _getSharedUsers();
    if (sharedUsers > 0) {
      data['sharedUsers'] = sharedUsers;
    }

    final idleTimeout = _idleTimeoutController.text.trim();
    if (idleTimeout.isNotEmpty) {
      data['idleTimeout'] = '${idleTimeout}m';
    }

    return data;
  }

  // Set time preset
  void _setTimePreset(int value, String unit) {
    setState(() {
      _timeValueController.text = value.toString();
      _timeUnit = unit;
    });
  }

  // Generate the on-login script preview (RouterOS 7 compatible)
  String _generateScriptPreview() {
    final interval = _generateTimeInterval();
    if (interval.isEmpty) return '';
    
    return '''{
:local voucher \$user;
:if ([/system/scheduler find name=\$voucher]="") do={
/system/scheduler add comment=\$voucher name=\$voucher interval=$interval on-event="/ip/hotspot/active remove [find user=\$voucher]\\r\\n/ip/hotspot/user remove [find name=\$voucher]\\r\\n/system/scheduler remove [find name=\$voucher]"
}
}''';
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRouter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a router'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final profileData = _generateProfileData();
      
      final response = await ApiClient().post(
        ApiEndpoints.routerHotspotProfiles(_selectedRouter!.id),
        data: profileData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return success
        }
      } else {
        throw Exception('Failed to create profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Profile', style: AppTextStyles.headlineMedium),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocListener<RouterBloc, RouterState>(
        listener: (context, state) {
          if (state is RouterLoaded) {
            final Map<String, router_model.Router> uniqueRouters = {};
            for (var router in state.routers) {
              uniqueRouters[router.id] = router;
            }
            setState(() {
              _routers = uniqueRouters.values.toList();
              if (_routers.isNotEmpty && _selectedRouter == null) {
                _selectedRouter = _routers.first;
              }
            });
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Router Selector
                _buildRouterSelector(),
                const SizedBox(height: 24),
                
                // Profile Name
                _buildSectionCard(
                  title: 'Profile Name',
                  icon: Icons.badge,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Profile Name *',
                        hintText: 'e.g., 1day, premium, basic',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                        helperText: 'No spaces allowed',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Profile name is required';
                        }
                        if (value.contains(' ')) {
                          return 'No spaces allowed';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Time Control
                _buildSectionCard(
                  title: 'Time Control',
                  icon: Icons.timer,
                  important: true,
                  children: [
                    // Time Method Switch
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.green, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Scheduler-Based Time',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                Text(
                                  'Time counts from first login until expiry (even when disconnected)',
                                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _useSchedulerTime,
                            onChanged: (value) => setState(() => _useSchedulerTime = value),
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Time presets
                    Text('Quick Presets', style: AppTextStyles.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('30 Min', () => _setTimePreset(30, 'minutes')),
                        _buildPresetChip('1 Hour', () => _setTimePreset(1, 'hours')),
                        _buildPresetChip('3 Hours', () => _setTimePreset(3, 'hours')),
                        _buildPresetChip('1 Day', () => _setTimePreset(1, 'days')),
                        _buildPresetChip('7 Days', () => _setTimePreset(7, 'days')),
                        _buildPresetChip('30 Days', () => _setTimePreset(30, 'days')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Time input
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _timeValueController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.schedule),
                            ),
                            validator: (value) {
                              final v = int.tryParse(value ?? '') ?? 0;
                              if (v <= 0) return 'Must be > 0';
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _timeUnit,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                              DropdownMenuItem(value: 'hours', child: Text('Hours')),
                              DropdownMenuItem(value: 'days', child: Text('Days')),
                            ],
                            onChanged: (value) {
                              setState(() => _timeUnit = value ?? 'days');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Speed Control
                _buildSectionCard(
                  title: 'Speed Control',
                  icon: Icons.speed,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _downloadSpeedController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Download (Mbps)',
                              hintText: 'e.g., 5',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.download),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _uploadSpeedController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Upload (Mbps)',
                              hintText: 'e.g., 2',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.upload),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Leave empty for unlimited speed',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Device Control
                _buildSectionCard(
                  title: 'Device Control',
                  icon: Icons.devices,
                  children: [
                    TextFormField(
                      controller: _sharedUsersController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Max Devices',
                        hintText: 'Simultaneous connections allowed',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.smartphone),
                      ),
                      validator: (value) {
                        final v = int.tryParse(value ?? '') ?? 0;
                        if (v < 1) return 'Must be at least 1';
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Number of devices that can use this voucher simultaneously',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Idle Timeout (Optional)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Text('Advanced Options', style: AppTextStyles.titleMedium),
                    ],
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        controller: _idleTimeoutController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Idle Timeout (minutes)',
                          hintText: 'Disconnect after idle time',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.hourglass_empty),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Preview Section
                _buildPreviewSection(),
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle),
                              SizedBox(width: 8),
                              Text('Create Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouterSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.router, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedRouter?.id,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: AppColors.primary,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                hint: const Text('Select Router', style: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: _routers.map((router) {
                  return DropdownMenuItem<String>(
                    value: router.id,
                    child: Text(
                      '${router.name} [${router.ipAddress}]',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newId) {
                  if (newId != null) {
                    setState(() {
                      _selectedRouter = _routers.firstWhere((r) => r.id == newId);
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    bool important = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: important ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 2) : null,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (important ? AppColors.primary : Colors.grey).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: important ? AppColors.primary : Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.titleMedium),
              if (important) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('IMPORTANT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      backgroundColor: AppColors.primary.withOpacity(0.1),
      labelStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
      onPressed: onTap,
    );
  }

  Widget _buildPreviewSection() {
    final interval = _generateTimeInterval();
    final rateLimit = _generateRateLimit();
    final sharedUsers = _getSharedUsers();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'MikroTik Configuration Preview',
                style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Profile settings
          _buildConfigLine('name', _nameController.text.isEmpty ? '(required)' : _nameController.text),
          if (rateLimit.isNotEmpty) _buildConfigLine('rate-limit', rateLimit),
          _buildConfigLine('shared-users', sharedUsers.toString()),
          if (_idleTimeoutController.text.isNotEmpty)
            _buildConfigLine('idle-timeout', '${_idleTimeoutController.text}m'),
          
          // Time control method
          if (interval.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _useSchedulerTime ? Icons.schedule : Icons.timer,
                    color: Colors.green[400],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _useSchedulerTime ? 'Scheduler: $interval' : 'Session Timeout: $interval',
                    style: TextStyle(color: Colors.green[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          
          // Show On Login script preview if using scheduler
          if (_useSchedulerTime && interval.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'On Login Script:',
              style: TextStyle(color: Colors.blue[300], fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  _generateScriptPreview(),
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigLine(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$key=',
            style: TextStyle(color: Colors.blue[300], fontFamily: 'monospace'),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.amber[300], fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
