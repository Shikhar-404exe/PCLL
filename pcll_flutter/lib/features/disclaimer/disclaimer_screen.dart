// Disclaimer Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/background_patterns.dart';
import '../home/home_screen.dart';

class DisclaimerScreen extends StatefulWidget {
  const DisclaimerScreen({super.key});

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _acknowledged = false;

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
          child: Padding(
            padding: PCLLSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: PCLLSpacing.lg),

                // Header
                Text(
                  'Before You Begin',
                  style: PCLLTypography.headlineLarge.copyWith(
                    color: PCLLColors.woodDark,
                  ),
                ),
                const SizedBox(height: PCLLSpacing.lg),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          'WHAT THIS IS',
                          'PCLL is a personal productivity tracking tool that uses a banking '
                              'metaphor to help you observe patterns in your daily cognitive workload. '
                              'It tracks self-reported data about tasks, decisions, and recovery activities.',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          'WHAT THIS IS NOT',
                          '• NOT a medical device or health monitoring tool\n'
                              '• NOT a mental health assessment or diagnostic tool\n'
                              '• NOT a substitute for professional medical advice\n'
                              '• NOT validated for clinical use',
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          'IMPORTANT LIMITATIONS',
                          '• All calculations are estimates based on self-reported data\n'
                              '• "Cognitive Units" (CU) are an arbitrary metaphorical unit\n'
                              '• Results reflect only what you report, not objective measurements\n'
                              '• This tool cannot detect, diagnose, or treat any condition',
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: PCLLColors.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: PCLLColors.wood.withOpacity(0.3)),
                          ),
                          child: Text(
                            'If you are experiencing distress, please contact a healthcare '
                            'professional or crisis helpline in your area.',
                            style: PCLLTypography.bodyMedium.copyWith(
                              color: PCLLColors.wood,
                            ),
                          ),
                        ),
                        const SizedBox(height: PCLLSpacing.xl),
                      ],
                    ),
                  ),
                ),

                // Acknowledgment checkbox
                InkWell(
                  onTap: () => setState(() => _acknowledged = !_acknowledged),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acknowledged,
                        onChanged: (v) =>
                            setState(() => _acknowledged = v ?? false),
                        activeColor: PCLLColors.wood,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(color: PCLLColors.wood),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I understand this is a productivity observation tool only and '
                            'will not use it to make health-related decisions.',
                            style: PCLLTypography.bodyMedium.copyWith(
                              color: PCLLColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PCLLSpacing.md),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _acknowledged ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PCLLColors.wood,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: PCLLColors.woodLight,
                    ),
                    child: const Text('Continue'),
                  ),
                ),
                const SizedBox(height: PCLLSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PCLLTypography.labelLarge.copyWith(
            color: PCLLColors.wood,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: PCLLSpacing.sm),
        Text(
          content,
          style: PCLLTypography.bodyMedium.copyWith(
            color: PCLLColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _onContinue() {
    context.read<SettingsProvider>().acceptDisclaimer();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }
}
