import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/constants/app_constants.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/add_router_bloc.dart';
import '../bloc/add_router_event.dart';
import '../bloc/add_router_state.dart';

class AddRouterPage extends StatelessWidget {
  const AddRouterPage({super.key});

  bool _hasActiveSubscription(AuthState state) {
    if (state is AuthAuthenticated) {
      final sub = state.user.subscription;
      if (sub != null &&
          sub.status == 'ACTIVE' &&
          sub.expiresAt.isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!_hasActiveSubscription(authState)) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Add Router', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const SubscriptionRequiredWidget(
              message: 'You need an active subscription to add routers. Please subscribe to a plan to continue.',
            ),
          );
        }

        final dio = ApiClient().dio;

        return BlocProvider(
          create: (context) => AddRouterBloc(dio: dio),
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Add Router', style: TextStyle(color: Colors.black)),
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                bottom: const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: "Manual"),
                    Tab(text: "By Script"),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [
                  AddRouterForm(),
                  ScriptAddRouterView(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ScriptAddRouterView extends StatefulWidget {
  const ScriptAddRouterView({super.key});

  @override
  State<ScriptAddRouterView> createState() => _ScriptAddRouterViewState();
}

class _ScriptAddRouterViewState extends State<ScriptAddRouterView> {
  List<Map<String, dynamic>>? _steps;
  String? _vpnIp;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchWireguardSetup();
  }

  Future<void> _fetchWireguardSetup() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = ApiClient().dio;
      final response = await dio.post('/routers/wireguard-setup');
      final data = response.data;
      setState(() {
        _vpnIp = data['vpnIp'];
        _steps = List<Map<String, dynamic>>.from(data['steps']);
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message'] ?? 'Failed to generate setup. Try again.';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _fetchWireguardSetup, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    if (_steps == null || _steps!.isEmpty) {
      return const Center(child: Text("No setup steps available."));
    }

    return _buildStepsList();
  }

  Widget _buildStepsList() {
    final allCommands = _steps!.map((s) => s['command'] as String).join('\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_vpnIp != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.vpn_lock, color: Colors.green[700], size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "VPN IP assigned: $_vpnIp",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green[800]),
                    ),
                  ),
                ],
              ),
            ),
          const Text(
            "Run these commands on your MikroTik Terminal (RouterOS v7):",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ...List.generate(_steps!.length, (i) {
            final step = _steps![i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildStepCard(
                context,
                number: i + 1,
                title: step['title'] as String,
                command: step['command'] as String,
                description: step['description'] as String? ?? '',
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text("Important Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
                SizedBox(height: 8),
                Text(
                  "• Requires RouterOS v7 or later (WireGuard support)\n"
                  "• Run each command in order in the MikroTik terminal\n"
                  "• The VPN tunnel connects your router to Wassal securely",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: allCommands));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All commands copied!")),
              );
            },
            icon: const Icon(Icons.copy_all),
            label: const Text("Copy All Commands"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildStepCard(
    BuildContext context, {
    required int number,
    required String title,
    required String command,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$number",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: command));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Step $number copied!")),
                  );
                },
                tooltip: "Copy",
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              command,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddRouterForm extends StatefulWidget {
  const AddRouterForm({super.key});

  @override
  State<AddRouterForm> createState() => _AddRouterFormState();
}

class _AddRouterFormState extends State<AddRouterForm> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiPortController = TextEditingController(text: '8728');
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ipController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _apiPortController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AddRouterBloc>().add(
        SubmitAddRouterForm(
          name: _nameController.text,
          ipAddress: _ipController.text,
          apiPort: int.parse(_apiPortController.text),
          username: _usernameController.text,
          password: _passwordController.text,
          location: _locationController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddRouterBloc, AddRouterState>(
      listener: (context, state) {
        if (state is AddRouterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Router added successfully!')),
          );
          Navigator.pop(context, true); // Go back to dashboard with success result
        } else if (state is AddRouterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Router Name',
                icon: Icons.router,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ipController,
                label: 'IP Address',
                icon: Icons.wifi,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _apiPortController,
                label: 'API Port',
                icon: Icons.settings_ethernet,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                isPassword: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location (Optional)',
                icon: Icons.map,
              ),
              const SizedBox(height: 32),
              
              BlocBuilder<AddRouterBloc, AddRouterState>(
                builder: (context, state) {
                   if (state is AddRouterLoading) {
                     return const CircularProgressIndicator();
                   }
                   
                   return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Router', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
