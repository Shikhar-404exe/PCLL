// Settings Screen

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/profile_provider.dart';

enum ExportFormat { csv, json }

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? PCLLColors.backgroundDark : PCLLColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: PCLLSpacing.screenPadding,
        children: [
          // Data section
          _SectionHeader(title: 'DATA'),
          const SizedBox(height: PCLLSpacing.sm),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Export Ledger',
            subtitle: 'Download as CSV',
            onTap: () => _exportData(context),
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear All Data',
            subtitle: 'Remove all entries',
            onTap: () => _confirmClearData(context),
            isDestructive: true,
          ),

          const SizedBox(height: PCLLSpacing.lg),

          // Display section
          _SectionHeader(title: 'DISPLAY'),
          const SizedBox(height: PCLLSpacing.sm),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                children: [
                  _ThemeTile(
                    currentMode: settings.themeMode,
                    onChanged: (mode) => settings.setThemeMode(mode),
                  ),
                  _SettingsToggle(
                    title: 'Show Decimals',
                    subtitle: 'Display precise CU values',
                    value: settings.showDecimals,
                    onChanged: (v) => settings.setShowDecimals(v),
                  ),
                  _SettingsToggle(
                    title: 'Show Opening Balance',
                    subtitle: 'Include in daily summary',
                    value: settings.showOpeningBalance,
                    onChanged: (v) => settings.setShowOpeningBalance(v),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: PCLLSpacing.lg),

          // Accessibility section
          _SectionHeader(title: 'ACCESSIBILITY'),
          const SizedBox(height: PCLLSpacing.sm),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                children: [
                  _SettingsToggle(
                    title: 'High Contrast Mode',
                    subtitle: 'Enhance visual contrast',
                    value: settings.highContrastMode,
                    onChanged: (v) => settings.setHighContrastMode(v),
                  ),
                  _SettingsToggle(
                    title: 'Larger Touch Targets',
                    subtitle: 'Increase button sizes',
                    value: settings.largerTouchTargets,
                    onChanged: (v) => settings.setLargerTouchTargets(v),
                  ),
                  _TextScaleTile(
                    value: settings.textScaleFactor,
                    onChanged: (v) => settings.setTextScaleFactor(v),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: PCLLSpacing.lg),

          // About section
          _SectionHeader(title: 'ABOUT'),
          const SizedBox(height: PCLLSpacing.sm),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About CogniVault',
            subtitle: 'Version 0.1.0 (prototype)',
            onTap: () => _showAbout(context),
          ),
          _SettingsTile(
            icon: Icons.article_outlined,
            title: 'View Disclaimer',
            subtitle: 'Usage limitations',
            onTap: () => _showDisclaimer(context),
          ),

          const SizedBox(height: PCLLSpacing.xl),

          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  'PCLL',
                  style: PCLLTypography.headlineSmall.copyWith(
                    color: PCLLColors.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: PCLLSpacing.xs),
                Text(
                  'Personal Cognitive Load Ledger',
                  style: PCLLTypography.bodySmall.copyWith(
                    color: PCLLColors.textTertiary,
                  ),
                ),
                const SizedBox(height: PCLLSpacing.xs),
                Text(
                  'For informational tracking only',
                  style: PCLLTypography.labelSmall.copyWith(
                    color: PCLLColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: PCLLSpacing.xl),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: PCLLColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        title: Text('Export Data', style: PCLLTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose export format:',
              style: PCLLTypography.bodyMedium.copyWith(
                color: PCLLColors.textSecondary,
              ),
            ),
            const SizedBox(height: PCLLSpacing.md),
            _ExportOption(
              icon: Icons.table_chart,
              title: 'CSV (Spreadsheet)',
              subtitle: 'Compatible with Excel, Google Sheets',
              onTap: () {
                Navigator.pop(dialogContext);
                _performExport(context, ExportFormat.csv);
              },
            ),
            const SizedBox(height: PCLLSpacing.sm),
            _ExportOption(
              icon: Icons.code,
              title: 'JSON (Raw Data)',
              subtitle: 'For backup or data analysis',
              onTap: () {
                Navigator.pop(dialogContext);
                _performExport(context, ExportFormat.json);
              },
            ),
          ],
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
        ],
      ),
    );
  }

  Future<void> _performExport(BuildContext context, ExportFormat format) async {
    final ledger = context.read<LedgerProvider>();
    final profile = context.read<ProfileProvider>();

    if (ledger.entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No data to export',
            style: PCLLTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: PCLLColors.textSecondary,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final String content;
      final String extension;
      final String mimeType;

      if (format == ExportFormat.csv) {
        content = _generateCsv(ledger.entries);
        extension = 'csv';
        mimeType = 'text/csv';
      } else {
        content = _generateJson(ledger.entries, profile.profile);
        extension = 'json';
        mimeType = 'application/json';
      }

      // Create temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'pcll_export_$timestamp.$extension';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content);

      // Close loading dialog
      Navigator.of(context).pop();

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: 'PCLL Data Export',
        text: 'Exported on ${DateFormat.yMMMd().format(DateTime.now())}',
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export failed: $e',
            style: PCLLTypography.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: PCLLColors.negative,
        ),
      );
    }
  }

  String _generateCsv(List<dynamic> entries) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'Date,Opening Balance,Closing Balance,Total Withdrawals,Total Deposits,Net Change,Cognitive State,Context Cost,Decision Cost,Passive Drain,Recovery Deposit');

    // Data rows
    for (final entry in entries) {
      buffer.writeln('${entry.date},'
          '${entry.openingBalance.toStringAsFixed(1)},'
          '${entry.closingBalance.toStringAsFixed(1)},'
          '${entry.totalWithdrawals.toStringAsFixed(1)},'
          '${entry.totalDeposits.toStringAsFixed(1)},'
          '${entry.netChange.toStringAsFixed(1)},'
          '${entry.cognitiveState.label},'
          '${entry.components.contextCost.toStringAsFixed(1)},'
          '${entry.components.decisionCost.toStringAsFixed(1)},'
          '${entry.components.passiveDrain.toStringAsFixed(1)},'
          '${entry.components.recoveryDeposit.toStringAsFixed(1)}');
    }

    return buffer.toString();
  }

  String _generateJson(List<dynamic> entries, dynamic profile) {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'profile': profile.toJson(),
      'entries': entries
          .map((e) => {
                'date': e.date,
                'openingBalance': e.openingBalance,
                'closingBalance': e.closingBalance,
                'totalWithdrawals': e.totalWithdrawals,
                'totalDeposits': e.totalDeposits,
                'netChange': e.netChange,
                'cognitiveState': e.cognitiveState.code,
                'components': {
                  'contextCost': e.components.contextCost,
                  'decisionCost': e.components.decisionCost,
                  'passiveDrain': e.components.passiveDrain,
                  'recoveryDeposit': e.components.recoveryDeposit,
                },
                'createdAt': e.createdAt.toIso8601String(),
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PCLLColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        title: Text('Clear All Data?', style: PCLLTypography.headlineSmall),
        content: Text(
          'This will permanently delete all ledger entries. This action cannot be undone.',
          style: PCLLTypography.bodyMedium.copyWith(
            color: PCLLColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: PCLLTypography.labelMedium.copyWith(
                color: PCLLColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<LedgerProvider>().clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All data cleared',
                    style: PCLLTypography.bodySmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: PCLLColors.negative,
                ),
              );
            },
            child: Text(
              'Clear',
              style: PCLLTypography.labelMedium.copyWith(
                color: PCLLColors.negative,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PCLLColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        title: Text('About CogniVault', style: PCLLTypography.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CogniVault - Personal Cognitive Load Ledger',
              style: PCLLTypography.labelMedium,
            ),
            const SizedBox(height: PCLLSpacing.md),
            Text(
              'A self-tracking tool that models cognitive capacity using ledger-style accounting. Track your mental resource allocation across tasks and recovery periods.',
              style: PCLLTypography.bodyMedium.copyWith(
                color: PCLLColors.textSecondary,
              ),
            ),
            const SizedBox(height: PCLLSpacing.md),
            Text(
              'This tool is for personal informational purposes only. It does not provide medical, psychological, or therapeutic advice.',
              style: PCLLTypography.bodySmall.copyWith(
                color: PCLLColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: PCLLTypography.labelMedium.copyWith(
                color: PCLLColors.positive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PCLLColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        ),
        title: Text('Disclaimer', style: PCLLTypography.headlineSmall),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DisclaimerItem(
                icon: Icons.info_outline,
                text: 'PCLL is an informational self-tracking tool only.',
              ),
              _DisclaimerItem(
                icon: Icons.medical_services_outlined,
                text: 'This is not a medical device or diagnostic tool.',
              ),
              _DisclaimerItem(
                icon: Icons.psychology_outlined,
                text: 'Does not provide psychological assessments.',
              ),
              _DisclaimerItem(
                icon: Icons.local_hospital_outlined,
                text: 'Should not replace professional health advice.',
              ),
              _DisclaimerItem(
                icon: Icons.person_outline,
                text: 'All data stays on your device.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'I Understand',
              style: PCLLTypography.labelMedium.copyWith(
                color: PCLLColors.positive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Section header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: PCLLTypography.labelSmall.copyWith(
        letterSpacing: 1,
        color: PCLLColors.textTertiary,
      ),
    );
  }
}

// Settings tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PCLLColors.surface,
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          border: Border.all(color: PCLLColors.border),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? PCLLColors.negative
                  : PCLLColors.textSecondary,
            ),
            const SizedBox(width: PCLLSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PCLLTypography.labelMedium.copyWith(
                      color: isDestructive
                          ? PCLLColors.negative
                          : PCLLColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: PCLLTypography.bodySmall.copyWith(
                      color: PCLLColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: PCLLColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// Settings toggle
class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PCLLColors.surface,
        borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        border: Border.all(color: PCLLColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PCLLTypography.labelMedium),
                Text(
                  subtitle,
                  style: PCLLTypography.bodySmall.copyWith(
                    color: PCLLColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: PCLLColors.positive,
            inactiveThumbColor: PCLLColors.textTertiary,
            inactiveTrackColor: PCLLColors.surfaceAlt,
          ),
        ],
      ),
    );
  }
}

// Disclaimer item
class _DisclaimerItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DisclaimerItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: PCLLColors.textTertiary),
          const SizedBox(width: PCLLSpacing.smd),
          Expanded(
            child: Text(
              text,
              style: PCLLTypography.bodySmall.copyWith(
                color: PCLLColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Theme selection tile
class _ThemeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PCLLColors.surfaceDark : PCLLColors.surface,
        borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        border: Border.all(
          color: isDark ? PCLLColors.borderDark : PCLLColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 20,
                color: isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
              ),
              const SizedBox(width: PCLLSpacing.smd),
              Text(
                'Theme',
                style: PCLLTypography.labelMedium.copyWith(
                  color: isDark
                      ? PCLLColors.textPrimaryDark
                      : PCLLColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.smd),
          Row(
            children: [
              _ThemeOption(
                icon: Icons.light_mode_outlined,
                label: 'Light',
                isSelected: currentMode == ThemeMode.light,
                onTap: () => onChanged(ThemeMode.light),
              ),
              const SizedBox(width: PCLLSpacing.sm),
              _ThemeOption(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isSelected: currentMode == ThemeMode.dark,
                onTap: () => onChanged(ThemeMode.dark),
              ),
              const SizedBox(width: PCLLSpacing.sm),
              _ThemeOption(
                icon: Icons.settings_suggest_outlined,
                label: 'System',
                isSelected: currentMode == ThemeMode.system,
                onTap: () => onChanged(ThemeMode.system),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? PCLLColors.accentDarkMode : PCLLColors.accent;
    final bgColor = isSelected
        ? (isDark ? PCLLColors.accentLightDarkMode : PCLLColors.accentLight)
        : (isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt);
    final textColor = isSelected
        ? accentColor
        : (isDark ? PCLLColors.textSecondaryDark : PCLLColors.textSecondary);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: textColor),
              const SizedBox(height: PCLLSpacing.xs),
              Text(
                label,
                style: PCLLTypography.labelSmall.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Export option tile
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt,
      borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? PCLLColors.accentLightDarkMode
                      : PCLLColors.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
                ),
              ),
              const SizedBox(width: PCLLSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PCLLTypography.labelMedium.copyWith(
                        color: isDark
                            ? PCLLColors.textPrimaryDark
                            : PCLLColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: PCLLTypography.bodySmall.copyWith(
                        color: isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? PCLLColors.textTertiaryDark
                    : PCLLColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Text scale slider tile
class _TextScaleTile extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _TextScaleTile({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (value * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt,
        borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Text Size',
                      style: PCLLTypography.labelMedium.copyWith(
                        color: isDark
                            ? PCLLColors.textPrimaryDark
                            : PCLLColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Scale: $percentage%',
                      style: PCLLTypography.bodySmall.copyWith(
                        color: isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? PCLLColors.accentLightDarkMode
                      : PCLLColors.accentLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$percentage%',
                  style: PCLLTypography.labelSmall.copyWith(
                    color:
                        isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.smd),
          Slider(
            value: value,
            min: 1.0,
            max: 2.0,
            divisions: 10,
            activeColor: isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '100%',
                style: PCLLTypography.labelSmall.copyWith(
                  color: isDark
                      ? PCLLColors.textTertiaryDark
                      : PCLLColors.textTertiary,
                ),
              ),
              Text(
                '200%',
                style: PCLLTypography.labelSmall.copyWith(
                  color: isDark
                      ? PCLLColors.textTertiaryDark
                      : PCLLColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
