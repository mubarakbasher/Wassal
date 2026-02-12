import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              // Parse and display user-friendly error messages
              String errorMessage = _parseErrorMessage(state.message);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    
                    // Logo/Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.router,
                          size: 40,
                          color: AppColors.card,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.headlineLarge,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Sign in to manage your MikroTik hotspots',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: isLoading ? null : _onLogin,
                      isLoading: isLoading,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _parseErrorMessage(String message) {
    // Handle connection errors
    if (message.toLowerCase().contains('connection') || 
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('failed host lookup')) {
      return 'Cannot connect to server. Please check your internet connection.';
    }
    
    // Handle timeout errors
    if (message.toLowerCase().contains('timeout')) {
      return 'Connection timeout. Please try again.';
    }
    
    // Handle authentication errors
    if (message.toLowerCase().contains('unauthorized') || 
        message.toLowerCase().contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    
    // Handle validation errors
    if (message.toLowerCase().contains('validation')) {
      return 'Please check your input and try again.';
    }
    
    // Handle server errors
    if (message.toLowerCase().contains('500') || 
        message.toLowerCase().contains('server error')) {
      return 'Server error. Please try again later.';
    }
    
    // Return original message if no specific case matches
    return message;
  }
}
