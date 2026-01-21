import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/constants/app_colors.dart';
import '../bloc/add_router_bloc.dart';
import '../bloc/add_router_event.dart';
import '../bloc/add_router_state.dart';

class AddRouterPage extends StatelessWidget {
  const AddRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Inject Dio properly
    final dio = Dio();

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
  }
}

class ScriptAddRouterView extends StatelessWidget {
  const ScriptAddRouterView({super.key});

  @override
  Widget build(BuildContext context) {
      // TODO: Replace with actual IP
      const backendUrl = "http://192.168.1.227:3000/public/routers/script-callback"; 
      const script = '/user add name=wassal_auto group=full password=Wassal@123 comment="Wassal Auto-Connect"\n'
                     '/ip service set api disabled=no\n'
                     '/tool fetch url="$backendUrl" keep-result=no';

      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Run this script on your MikroTik Terminal to auto-connect.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                script,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                 Clipboard.setData(ClipboardData(text: script));
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Script copied to clipboard!")));
              },
              icon: const Icon(Icons.copy),
              label: const Text("Copy Script"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
              ),
            ),
             const SizedBox(height: 20),
             const Text("After running the script, your router should appear in the dashboard automatically.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),
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
          Navigator.pop(context); // Go back to dashboard
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
