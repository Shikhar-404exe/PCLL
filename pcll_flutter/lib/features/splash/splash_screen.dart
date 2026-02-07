// Splash Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../auth/login_screen.dart';
import '../disclaimer/disclaimer_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule initialization after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    // Initialize auth state (check for existing session)
    await context.read<AuthProvider>().initialize();

    // Load profile from storage
    await context.read<ProfileProvider>().loadProfile();

    // Initialize ledger data
    await context.read<LedgerProvider>().initialize();

    if (!mounted) return;

    // Check auth status and settings
    final auth = context.read<AuthProvider>();
    final settings = context.read<SettingsProvider>();

    // Navigate after brief delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Determine which screen to navigate to
    Widget destination;
    if (!auth.isAuthenticated) {
      destination = const LoginScreen();
    } else if (!settings.disclaimerAccepted) {
      destination = const DisclaimerScreen();
    } else {
      destination = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PCLLColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'logo.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: PCLLColors.accent,
              ),
            ),
            const SizedBox(height: PCLLSpacing.md),
            // App Name
            Text(
              'CogniVault',
              style: PCLLTypography.displayLarge.copyWith(letterSpacing: 2),
            ),
            const SizedBox(height: PCLLSpacing.xs),
            Text(
              'Personal Cognitive Load Ledger',
              style: PCLLTypography.bodyMedium.copyWith(
                color: PCLLColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: PCLLSpacing.xxl),
            // Minimal loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  PCLLColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
