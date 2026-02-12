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

class ScriptAddRouterView extends StatelessWidget {
  const ScriptAddRouterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final backendUrl = AppConstants.apiBaseUrl;
        
        // Get the current user's ID from AuthBloc
        String? userId;
        if (authState is AuthAuthenticated) {
          userId = authState.user.id;
        }
        
        // Show error if userId is null
        if (userId == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "Unable to get user information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please log out and log back in, then try again.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ),
          );
        }
        
        return _buildScriptContent(context, backendUrl, userId);
      },
    );
  }
  
  Widget _buildScriptContent(BuildContext context, String backendUrl, String userId) {
      // Step 1: Enable advanced device mode (required for fetch tool)
      const step1 = '/system/device-mode/update mode=advanced';
      // Step 2: Remove existing user if present, then create new one
      const step2 = ':do { /user remove wassal_auto } on-error={}; /user add name=wassal_auto group=full password=Wassal@123 comment="Wassal Auto-Connect"';
      const step3 = '/ip service set api disabled=no';
      // Step 4: Auto-detect IP from router interface and send with userId
      // Try multiple interface names that are commonly used
      final step4 = ':local ip ""; :do { :set ip [/ip address get [find interface=ether1] address] } on-error={ :do { :set ip [/ip address get [find interface=bridge] address] } on-error={ :set ip [/ip address get [find interface~"ether"] address] } }; :set ip [:pick \$ip 0 [:find \$ip "/"]]; /tool fetch url="$backendUrl/public/routers/script-callback?ip=\$ip&userId=$userId" mode=http keep-result=no';

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Run these commands on your MikroTik Terminal:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            
            // Step 1
            _buildStepCard(
              context,
              number: 1,
              title: "Enable Advanced Mode",
              command: step1,
              description: "Enables advanced features (may require reboot)",
            ),
            const SizedBox(height: 16),
            
            // Step 2
            _buildStepCard(
              context,
              number: 2,
              title: "Create API User",
              command: step2,
              description: "Creates a user for Wassal to connect",
            ),
            const SizedBox(height: 16),
            
            // Step 3
            _buildStepCard(
              context,
              number: 3,
              title: "Enable API Service",
              command: step3,
              description: "Enables the MikroTik API",
            ),
            const SizedBox(height: 16),
            
            // Step 4
            _buildStepCard(
              context,
              number: 4,
              title: "Register Router",
              command: step4,
              description: "Sends your router info to Wassal",
            ),
            
            const SizedBox(height: 24),
            
            // Warning box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Important Notes:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "• Step 1 may require pressing a button on the router\\n"
                    "• If step 4 fails, use the Manual tab instead\\n"
                    "• Make sure your MikroTik can reach $backendUrl",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Copy all button
            ElevatedButton.icon(
              onPressed: () {
                 final allCommands = "$step1\n$step2\n$step3\n$step4";
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
            Text(
              "Backend URL: $backendUrl",
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
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
