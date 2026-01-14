// PCLL Flutter App - Main Entry Point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// Firebase temporarily disabled for Windows build
// import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/config/env_config.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/ledger_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/tutorial_provider.dart';
import 'core/providers/profile_provider.dart';
import 'core/services/database_service.dart';
import 'core/services/sync_service.dart';
import 'features/features.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  await EnvConfig.initialize();

  // Initialize SQLite FFI for desktop platforms
  DatabaseService.initializeFfi();

  // Initialize sync service
  await SyncService().initialize();

  // Firebase temporarily disabled for Windows build
  debugPrint('Running in offline mode (Firebase disabled for Windows)');

  // Lock to portrait mode for focused experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: PCLLColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PCLLApp());
}

class PCLLApp extends StatelessWidget {
  const PCLLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => TutorialProvider()),
        // LedgerProvider depends on ProfileProvider for load modifiers
        ChangeNotifierProxyProvider<ProfileProvider, LedgerProvider>(
          create: (_) => LedgerProvider(),
          update: (_, profile, ledger) {
            ledger?.setProfileModifiers(
              baselineLoadModifier: profile.baselineLoadModifier,
              recoveryModifier: profile.recoveryModifier,
            );
            return ledger ?? LedgerProvider();
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'PCLL',
            debugShowCheckedModeBanner: false,
            theme: PCLLTheme.lightTheme.copyWith(
              textTheme: PCLLTheme.lightTheme.textTheme.apply(
                fontSizeFactor: settings.textScaleFactor,
              ),
            ),
            darkTheme: PCLLTheme.darkTheme.copyWith(
              textTheme: PCLLTheme.darkTheme.textTheme.apply(
                fontSizeFactor: settings.textScaleFactor,
              ),
            ),
            themeMode: settings.themeMode,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/create-account': (context) => const CreateAccountScreen(),
              '/disclaimer': (context) => const DisclaimerScreen(),
              '/home': (context) => const HomeScreen(),
              '/entry': (context) => const DailyEntryScreen(),
              '/history': (context) => const HistoryScreen(),
              '/trends': (context) => const TrendsScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
