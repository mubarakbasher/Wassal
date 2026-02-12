import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _networkNameController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoadingProfile = true;
  bool _wasUpdateTriggered = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _networkNameController = TextEditingController();
    _passwordController = TextEditingController();
    
    // Load current user data from AuthBloc state first
    _loadUserFromState();
    
    // Fetch fresh profile data from database
    context.read<AuthBloc>().add(const GetProfileEvent());
  }

  void _loadUserFromState() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _populateFields(state.user);
      setState(() => _isLoadingProfile = false);
    }
  }

  void _populateFields(dynamic user) {
    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _networkNameController.text = user.networkName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _networkNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      _wasUpdateTriggered = true;
      context.read<AuthBloc>().add(UpdateProfileEvent(
        name: _nameController.text,
        email: _emailController.text,
        networkName: _networkNameController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      ));
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to log out of your account?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() => _isLoadingProfile = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          } else if (state is AuthAuthenticated) {
            // Update form fields with fresh data from backend
            _populateFields(state.user);
            setState(() => _isLoadingProfile = false);
            
            // Only show success message if password field has content (means update was triggered)
            if (_passwordController.text.isNotEmpty || _wasUpdateTriggered) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Profile updated successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              _passwordController.clear();
              _wasUpdateTriggered = false;
            }
          } else if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return CustomScrollView(
            slivers: [
              // Gradient Header with Avatar
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                              const Expanded(
                                child: Text(
                                  'My Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 48), // Balance the back button
                            ],
                          ),
                        ),
                        // Avatar Section
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 40),
                          child: Column(
                            children: [
                              // Avatar with initials from state
                              Builder(
                                builder: (context) {
                                  final authState = context.watch<AuthBloc>().state;
                                  String displayName = _nameController.text;
                                  if (authState is AuthAuthenticated) {
                                    displayName = authState.user.name;
                                  }
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(displayName),
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Get name from state if available, otherwise from controller
                              Builder(
                                builder: (context) {
                                  final authState = context.watch<AuthBloc>().state;
                                  String displayName = _nameController.text;
                                  if (authState is AuthAuthenticated) {
                                    displayName = authState.user.name;
                                  }
                                  return Text(
                                    displayName.isNotEmpty ? displayName : 'Loading...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              // Get email from state if available
                              Builder(
                                builder: (context) {
                                  final authState = context.watch<AuthBloc>().state;
                                  String displayEmail = _emailController.text;
                                  if (authState is AuthAuthenticated) {
                                    displayEmail = authState.user.email;
                                  }
                                  return Text(
                                    displayEmail.isNotEmpty ? displayEmail : 'Loading...',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Form Content
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            

                            // Personal Information Card
                            _buildSectionCard(
                              title: 'Personal Information',
                              icon: Icons.person,
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.badge_outlined,
                                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Network Settings Card
                            _buildSectionCard(
                              title: 'Network Settings',
                              icon: Icons.wifi,
                              children: [
                                _buildTextField(
                                  controller: _networkNameController,
                                  label: 'Network Name',
                                  icon: Icons.router_outlined,
                                  helperText: 'This name appears on printed vouchers',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Security Card
                            _buildSectionCard(
                              title: 'Security',
                              icon: Icons.security,
                              children: [
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'New Password',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  helperText: 'Leave empty to keep current password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            
                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.save),
                                          SizedBox(width: 8),
                                          Text(
                                            'Save Changes',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: () => _showLogoutConfirmation(context),
                                icon: const Icon(Icons.logout, color: Colors.red),
                                label: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    String? helperText,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
