// How This Works Screen

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HowThisWorksScreen extends StatelessWidget {
  const HowThisWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HOW THIS WORKS'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: PCLLSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'The Ledger Metaphor',
              children: [
                _Paragraph(
                  'PCLL models cognitive resources using a banking ledger. '
                  'You start each day with a balance of cognitive units (CU). '
                  'Activities consume resources (withdrawals), rest restores them (deposits).',
                ),
                const SizedBox(height: PCLLSpacing.smd),
                _FormulaCard(
                  formula:
                      'Opening Balance + Deposits - Withdrawals = Closing Balance',
                  isDark: isDark,
                ),
                const SizedBox(height: PCLLSpacing.smd),
                _Paragraph(
                  'The numbers are estimates based on your self-reported activities. '
                  'They are meaningful relative to your own history, not as absolute measurements.',
                ),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'Withdrawals (What Spends CU)',
              children: [
                _BulletPoint(
                    'Context Switching: Changing between different tasks or projects'),
                _BulletPoint(
                    'Decision Making: Choices requiring thought or evaluation'),
                _BulletPoint(
                    'Focus Work: Meetings, deep concentration, intensive effort'),
                _BulletPoint(
                    'Unresolved Items: Open loops that drain resources until completed'),
                _BulletPoint(
                    'Avoided Decisions: Choices deferred that keep cycling in your mind'),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'Deposits (What Restores CU)',
              children: [
                _Paragraph(
                  'Recovery activities restore cognitive resources. The quality of your rest, '
                  'breaks, and downtime determines how much you recover.',
                ),
                const SizedBox(height: PCLLSpacing.smd),
                _Paragraph(
                  'Recovery effectiveness varies based on your current state. When in deficit, '
                  'recovery is less effective—prevention matters more than cure.',
                ),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'Daily Reset',
              children: [
                _Paragraph(
                  'Each day, you start fresh—but not always at 100 CU. If you ended yesterday '
                  'in deficit, 40% of that deficit carries forward, reducing your starting capacity.',
                ),
                const SizedBox(height: PCLLSpacing.smd),
                _FormulaCard(
                  formula:
                      'Today\'s Opening = 100 CU - (Yesterday\'s Deficit × 0.4)',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'Why Trends Matter More Than Single Days',
              children: [
                _Paragraph(
                  'One bad day doesn\'t mean much. A pattern of bad days does. '
                  'PCLL requires 30+ days to identify your personal patterns because:',
                ),
                const SizedBox(height: PCLLSpacing.smd),
                _BulletPoint('Everyone has different baselines'),
                _BulletPoint('Context matters (busy season vs. normal)'),
                _BulletPoint('Day-to-day variation is normal'),
                _BulletPoint('Patterns emerge from repetition, not snapshots'),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            const Divider(),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'What CogniVault Is',
              color: PCLLColors.positive,
              children: [
                _BulletPoint('✓ A self-tracking tool for workload patterns',
                    positive: true),
                _BulletPoint('✓ A structured reflection system',
                    positive: true),
                _BulletPoint(
                    '✓ A deterministic calculator (same inputs = same outputs)',
                    positive: true),
                _BulletPoint('✓ A personal instrument panel for cognitive load',
                    positive: true),
                _BulletPoint(
                    '✓ Fully local and private (your data stays on your device)',
                    positive: true),
              ],
            ),
            const SizedBox(height: PCLLSpacing.lg),
            _Section(
              title: 'What CogniVault Is NOT',
              color: PCLLColors.negative,
              children: [
                _BulletPoint('✗ A medical or diagnostic tool', negative: true),
                _BulletPoint('✗ A burnout detector or mental health assessment',
                    negative: true),
                _BulletPoint('✗ A scientific measurement device',
                    negative: true),
                _BulletPoint('✗ A productivity optimizer or time tracker',
                    negative: true),
                _BulletPoint(
                    '✗ A substitute for professional mental health support',
                    negative: true),
                _BulletPoint(
                    '✗ An objective measurement (it reflects your subjective reports)',
                    negative: true),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            _DisclaimerCard(isDark: isDark),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'The Math is Transparent',
              children: [
                _Paragraph(
                  'All calculations are deterministic and documented. You can see exactly '
                  'how each number is derived. No AI, no black boxes, no hidden algorithms.',
                ),
                const SizedBox(height: PCLLSpacing.smd),
                _Paragraph(
                  'The formulas are research-inspired but not validated. They provide '
                  'consistent structure for your self-reports, nothing more.',
                ),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xl),
            _Section(
              title: 'Your Control',
              children: [
                _BulletPoint('You decide what to log and when'),
                _BulletPoint('You can edit or delete any entry'),
                _BulletPoint('You own your data completely'),
                _BulletPoint('No cloud sync means no data exposure'),
                _BulletPoint('Uninstall = all data deleted'),
              ],
            ),
            const SizedBox(height: PCLLSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? color;

  const _Section({
    required this.title,
    required this.children,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        color ?? (isDark ? PCLLColors.textPrimaryDark : PCLLColors.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: PCLLTypography.headlineSmall.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: PCLLSpacing.md),
        ...children,
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;

  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: PCLLTypography.bodyLarge.copyWith(
        height: 1.6,
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final bool positive;
  final bool negative;

  const _BulletPoint(
    this.text, {
    this.positive = false,
    this.negative = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (positive) color = PCLLColors.positive;
    if (negative) color = PCLLColors.negative;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: PCLLTypography.bodyLarge.copyWith(
              color: color,
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: PCLLTypography.bodyLarge.copyWith(
                color: color,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaCard extends StatelessWidget {
  final String formula;
  final bool isDark;

  const _FormulaCard({
    required this.formula,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? PCLLColors.borderDark : PCLLColors.border,
        ),
      ),
      child: Text(
        formula,
        style: TextStyle(
          fontFamily: PCLLTypography.monoFamily,
          fontSize: 14,
          color: isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  final bool isDark;

  const _DisclaimerCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PCLLColors.negative.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PCLLColors.negative.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: PCLLColors.negative,
                size: 24,
              ),
              const SizedBox(width: PCLLSpacing.smd),
              Text(
                'IMPORTANT DISCLAIMER',
                style: PCLLTypography.labelLarge.copyWith(
                  color: PCLLColors.negative,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.smd),
          Text(
            'PCLL is a productivity tracking tool, not a health assessment. '
            'If you\'re experiencing burnout, depression, anxiety, or other '
            'mental health concerns, please seek support from qualified professionals. '
            'This tool cannot diagnose, treat, or replace professional care.',
            style: PCLLTypography.bodyMedium.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
