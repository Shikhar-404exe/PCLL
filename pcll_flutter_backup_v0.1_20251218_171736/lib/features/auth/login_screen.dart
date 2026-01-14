/*
 * Login Screen
 * ============
 * 
 * Authentication entry point with multiple login options:
 * - Email/Password
 * - Google
 * - Microsoft
 * - Guest access
 * 
 * Design: Minimalist, professional, ledger-inspired
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/background_patterns.dart';
import '../disclaimer/disclaimer_screen.dart';
import '../home/home_screen.dart';
import 'create_account_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  void _navigateToHome() {
    final settings = context.read<SettingsProvider>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => settings.disclaimerAccepted
            ? const HomeScreen()
            : const DisclaimerScreen(),
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();

    if (success && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _signInWithMicrosoft() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithMicrosoft();

    if (success && mounted) {
      _navigateToHome();
    }
  }

  Future<void> _continueAsGuest() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.continueAsGuest();

    if (success && mounted) {
      _navigateToHome();
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PCLLColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        title: Text(
          'Reset Password',
          style: PCLLTypography.headlineSmall.copyWith(
            color: PCLLColors.woodDark,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: PCLLTypography.bodyMedium.copyWith(
                  color: PCLLColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: PCLLTypography.labelMedium.copyWith(
                color: PCLLColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(dialogContext);

              final auth = context.read<AuthProvider>();
              final success = await auth.sendPasswordResetEmail(
                emailController.text.trim(),
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent! Check your inbox.'
                          : auth.errorMessage ?? 'Failed to send reset email',
                      style: PCLLTypography.bodySmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor:
                        success ? PCLLColors.wood : PCLLColors.negative,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LeafPatternBackground(
        gradientColors: [
          PCLLColors.accentLight, // Light mint green
          PCLLColors.accentLight, // Same color for uniform background
        ],
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SingleChildScrollView(
                padding: PCLLSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo/Title
                    _buildHeader(),
                    const SizedBox(height: 48),

                    // Error message
                    if (auth.errorMessage != null) ...[
                      _buildErrorBanner(auth.errorMessage!),
                      const SizedBox(height: 16),
                    ],

                    // Login form
                    _buildLoginForm(auth.status == AuthStatus.loading),
                    const SizedBox(height: 24),

                    // Divider
                    _buildDivider(),
                    const SizedBox(height: 24),

                    // Social logins
                    _buildSocialLogins(auth.status == AuthStatus.loading),
                    const SizedBox(height: 32),

                    // Guest login
                    _buildGuestLogin(auth.status == AuthStatus.loading),
                    const SizedBox(height: 24),

                    // Create account link
                    _buildCreateAccountLink(),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'PCLL',
          style: PCLLTypography.displayLarge.copyWith(
            letterSpacing: 4,
            color: PCLLColors.woodDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personal Cognitive Load Ledger',
          style: PCLLTypography.bodyMedium.copyWith(
            color: PCLLColors.wood,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to track your cognitive balance',
          style: PCLLTypography.bodySmall.copyWith(
            color: PCLLColors.textSecondary,
          ),
        ),
      ],
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

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

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
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: PCLLColors.textTertiary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
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
          const SizedBox(height: 8),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed:
                  isLoading ? null : () => _showForgotPasswordDialog(context),
              child: Text(
                'Forgot password?',
                style: PCLLTypography.labelMedium.copyWith(
                  color: PCLLColors.wood,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sign in button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : _signInWithEmail,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: PCLLColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: PCLLTypography.labelSmall.copyWith(
              color: PCLLColors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Divider(color: PCLLColors.border)),
      ],
    );
  }

  Widget _buildSocialLogins(bool isLoading) {
    return Column(
      children: [
        // Google Sign In
        _SocialLoginButton(
          icon: _GoogleIcon(),
          label: 'Continue with Google',
          onPressed: isLoading ? null : _signInWithGoogle,
        ),
        const SizedBox(height: 12),

        // Microsoft Sign In
        _SocialLoginButton(
          icon: _MicrosoftIcon(),
          label: 'Continue with Microsoft',
          onPressed: isLoading ? null : _signInWithMicrosoft,
        ),
      ],
    );
  }

  Widget _buildGuestLogin(bool isLoading) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: isLoading ? null : _continueAsGuest,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: PCLLColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline,
                  size: 20, color: PCLLColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                'Continue as Guest',
                style: PCLLTypography.labelLarge.copyWith(
                  color: PCLLColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Data stored locally only. No sync across devices.',
          style: PCLLTypography.labelSmall.copyWith(
            color: PCLLColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCreateAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: PCLLTypography.bodyMedium.copyWith(
            color: PCLLColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _navigateToCreateAccount,
          child: Text(
            'Create Account',
            style: PCLLTypography.labelLarge.copyWith(
              color: PCLLColors.wood,
            ),
          ),
        ),
      ],
    );
  }
}

// Social Login Button
class _SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: PCLLColors.surface,
          side: BorderSide(color: PCLLColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: PCLLTypography.labelLarge.copyWith(
                color: PCLLColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Google Icon
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.95, size.height * 0.5)
        ..lineTo(size.width * 0.95, size.height * 0.42)
        ..lineTo(size.width * 0.5, size.height * 0.42)
        ..lineTo(size.width * 0.5, size.height * 0.58)
        ..lineTo(size.width * 0.78, size.height * 0.58)
        ..cubicTo(
          size.width * 0.72,
          size.height * 0.75,
          size.width * 0.62,
          size.height * 0.85,
          size.width * 0.5,
          size.height * 0.85,
        )
        ..cubicTo(
          size.width * 0.3,
          size.height * 0.85,
          size.width * 0.15,
          size.height * 0.7,
          size.width * 0.15,
          size.height * 0.5,
        )
        ..cubicTo(
          size.width * 0.15,
          size.height * 0.3,
          size.width * 0.3,
          size.height * 0.15,
          size.width * 0.5,
          size.height * 0.15,
        )
        ..cubicTo(
          size.width * 0.62,
          size.height * 0.15,
          size.width * 0.72,
          size.height * 0.22,
          size.width * 0.78,
          size.height * 0.32,
        )
        ..lineTo(size.width * 0.9, size.height * 0.22)
        ..cubicTo(
          size.width * 0.82,
          size.height * 0.1,
          size.width * 0.67,
          size.height * 0.02,
          size.width * 0.5,
          size.height * 0.02,
        )
        ..cubicTo(
          size.width * 0.22,
          size.height * 0.02,
          size.width * 0.02,
          size.height * 0.22,
          size.width * 0.02,
          size.height * 0.5,
        )
        ..cubicTo(
          size.width * 0.02,
          size.height * 0.78,
          size.width * 0.22,
          size.height * 0.98,
          size.width * 0.5,
          size.height * 0.98,
        )
        ..cubicTo(
          size.width * 0.78,
          size.height * 0.98,
          size.width * 0.98,
          size.height * 0.78,
          size.width * 0.95,
          size.height * 0.5,
        )
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Microsoft Icon
class _MicrosoftIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 1, bottom: 1),
                    color: const Color(0xFFF25022), // Red
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 1, top: 1),
                    color: const Color(0xFF00A4EF), // Blue
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 1, bottom: 1),
                    color: const Color(0xFF7FBA00), // Green
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 1, top: 1),
                    color: const Color(0xFFFFB900), // Yellow
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
