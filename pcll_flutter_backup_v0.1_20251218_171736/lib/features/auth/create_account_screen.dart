/*
 * Create Account Screen
 * =====================
 * 
 * User registration with email/password.
 * Minimalist design matching the app theme.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../disclaimer/disclaimer_screen.dart';
import '../home/home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    final settings = context.read<SettingsProvider>();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => settings.disclaimerAccepted
            ? const HomeScreen()
            : const DisclaimerScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the terms and conditions',
            style: PCLLTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: PCLLColors.negative,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
    );

    if (success && mounted) {
      _navigateToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PCLLColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final isLoading = auth.status == AuthStatus.loading;

            return SingleChildScrollView(
              padding: PCLLSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Header
                    Text(
                      'Join PCLL',
                      style: PCLLTypography.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to sync your cognitive balance across devices.',
                      style: PCLLTypography.bodyMedium.copyWith(
                        color: PCLLColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Error message
                    if (auth.errorMessage != null) ...[
                      _buildErrorBanner(auth.errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    // Name field (optional)
                    Text(
                      'DISPLAY NAME (OPTIONAL)',
                      style: PCLLTypography.labelSmall.copyWith(
                        letterSpacing: 1,
                        color: PCLLColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      style: PCLLTypography.bodyMedium,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email field
                    Text(
                      'EMAIL',
                      style: PCLLTypography.labelSmall.copyWith(
                        letterSpacing: 1,
                        color: PCLLColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      style: PCLLTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    Text(
                      'PASSWORD',
                      style: PCLLTypography.labelSmall.copyWith(
                        letterSpacing: 1,
                        color: PCLLColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      style: PCLLTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Create a password',
                        prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: PCLLColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password field
                    Text(
                      'CONFIRM PASSWORD',
                      style: PCLLTypography.labelSmall.copyWith(
                        letterSpacing: 1,
                        color: PCLLColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      enabled: !isLoading,
                      style: PCLLTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        prefixIcon: const Icon(Icons.lock_outlined, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                            color: PCLLColors.textTertiary,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword =
                                !_obscureConfirmPassword);
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Terms checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(
                                        () => _agreeToTerms = value ?? false);
                                  },
                            activeColor: PCLLColors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    setState(
                                        () => _agreeToTerms = !_agreeToTerms);
                                  },
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: PCLLTypography.bodySmall.copyWith(
                                  color: PCLLColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: PCLLTypography.bodySmall.copyWith(
                                      color: PCLLColors.accent,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: PCLLTypography.bodySmall.copyWith(
                                      color: PCLLColors.accent,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Create account button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createAccount,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: PCLLTypography.bodyMedium.copyWith(
                            color: PCLLColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Sign In',
                            style: PCLLTypography.labelLarge.copyWith(
                              color: PCLLColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PCLLColors.negative.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        border: Border.all(color: PCLLColors.negative.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: PCLLColors.negative, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: PCLLTypography.bodySmall.copyWith(
                color: PCLLColors.negative,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: PCLLColors.negative),
            onPressed: () => context.read<AuthProvider>().clearError(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
