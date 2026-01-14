/*
 * Pattern Report Screen
 * =====================
 * 
 * Displays pattern observations from ledger data.
 * Shows correlations, not suggestions. User interprets.
 * 
 * Available after 7 days, complete after 30 days.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/ledger_provider.dart';
import '../../shared/widgets/background_patterns.dart';

class PatternReportScreen extends StatelessWidget {
  const PatternReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ThemedPatternBackground(
        child: Column(
          children: [
            AppBar(
              title: Text(
                'Pattern Report',
                style: TextStyle(
                  color:
                      isDark ? PCLLColors.textPrimaryDark : PCLLColors.woodDark,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color:
                    isDark ? PCLLColors.textPrimaryDark : PCLLColors.woodDark,
              ),
            ),
            Expanded(
              child: Consumer<LedgerProvider>(
                builder: (context, ledger, _) {
                  final report = ledger.patternReport;

                  if (report == null) {
                    return _NotEnoughData(
                      daysNeeded: weeklyComparisonDays,
                      daysLogged: ledger.entries.length,
                    );
                  }

                  return SingleChildScrollView(
                    padding: PCLLSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status header
                        _ReportStatusHeader(report: report),
                        const SizedBox(height: 24),

                        // Disclaimer
                        _ObservationDisclaimer(),
                        const SizedBox(height: 24),

                        // Week over week comparison
                        _PeriodComparisonCard(
                          title: 'Week Over Week',
                          comparison: report.weekOverWeek,
                        ),
                        const SizedBox(height: 16),

                        // Current vs best week
                        if (report.totalDaysAnalyzed >= 14) ...[
                          _PeriodComparisonCard(
                            title: 'This Week vs Your Best Week',
                            comparison: report.currentVsBest,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Month over month (if available)
                        if (report.monthOverMonth != null) ...[
                          _PeriodComparisonCard(
                            title: 'Month Over Month',
                            comparison: report.monthOverMonth!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Positive vs Deficit day analysis
                        if (report.positiveDayMetrics != null &&
                            report.deficitDayMetrics != null) ...[
                          const SizedBox(height: 8),
                          _PositiveVsDeficitSection(
                            positiveMetrics: report.positiveDayMetrics!,
                            deficitMetrics: report.deficitDayMetrics!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Observed patterns (only if complete)
                        if (report.isComplete &&
                            report.patterns.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _ObservedPatternsSection(patterns: report.patterns),
                        ],

                        // Waiting for more data
                        if (!report.isComplete) ...[
                          const SizedBox(height: 24),
                          _WaitingForData(
                              daysRemaining: report.daysUntilComplete),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows when not enough data is available
class _NotEnoughData extends StatelessWidget {
  final int daysNeeded;
  final int daysLogged;

  const _NotEnoughData({
    required this.daysNeeded,
    required this.daysLogged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 64,
              color: isDark
                  ? PCLLColors.textSecondaryDark
                  : PCLLColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Collecting Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pattern analysis requires at least $daysNeeded days of entries.\n'
              'You have logged $daysLogged ${daysLogged == 1 ? 'day' : 'days'} so far.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: daysLogged / daysNeeded,
              backgroundColor: isDark
                  ? PCLLColors.surfaceDark.withOpacity(0.5)
                  : PCLLColors.wood.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? PCLLColors.accentDark : PCLLColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${daysNeeded - daysLogged} more ${daysNeeded - daysLogged == 1 ? 'day' : 'days'} needed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status header showing report completeness
class _ReportStatusHeader extends StatelessWidget {
  final PatternReport report;

  const _ReportStatusHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? PCLLColors.surfaceDark.withOpacity(0.7)
            : PCLLColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? PCLLColors.wood.withOpacity(0.3)
              : PCLLColors.wood.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            report.isComplete ? Icons.analytics : Icons.pending,
            color: report.isComplete
                ? (isDark ? PCLLColors.accentDark : PCLLColors.accent)
                : (isDark
                    ? PCLLColors.textSecondaryDark
                    : PCLLColors.textSecondary),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.isComplete
                      ? 'Full Pattern Analysis'
                      : 'Preliminary Analysis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? PCLLColors.textPrimaryDark
                            : PCLLColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.totalDaysAnalyzed} days analyzed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary,
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

/// Important disclaimer about observations vs suggestions
class _ObservationDisclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withOpacity(0.1)
            : Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.amber[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'These are observations, not suggestions. '
              'Correlations shown do not imply causation.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Period comparison card (week over week, etc.)
class _PeriodComparisonCard extends StatelessWidget {
  final String title;
  final PeriodComparison comparison;

  const _PeriodComparisonCard({
    required this.title,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? PCLLColors.surfaceDark.withOpacity(0.7)
            : PCLLColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? PCLLColors.wood.withOpacity(0.3)
              : PCLLColors.wood.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? PCLLColors.textPrimaryDark
                      : PCLLColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${comparison.periodALabel} vs ${comparison.periodBLabel}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),

          // Comparison metrics
          _ComparisonRow(
            label: 'Avg Closing Balance',
            valueA: comparison.periodA.avgClosingBalance,
            valueB: comparison.periodB.avgClosingBalance,
            unit: 'CU',
            higherIsBetter: true,
          ),
          const SizedBox(height: 8),
          _ComparisonRow(
            label: 'Avg Decision Load',
            valueA: comparison.periodA.avgDecisionCost,
            valueB: comparison.periodB.avgDecisionCost,
            unit: 'CU',
            higherIsBetter: false,
          ),
          const SizedBox(height: 8),
          _ComparisonRow(
            label: 'Avg Recovery',
            valueA: comparison.periodA.avgRecoveryDeposit,
            valueB: comparison.periodB.avgRecoveryDeposit,
            unit: 'CU',
            higherIsBetter: true,
          ),
          const SizedBox(height: 8),
          _ComparisonRow(
            label: 'Positive Balance Days',
            valueA: comparison.periodA.positiveRatio,
            valueB: comparison.periodB.positiveRatio,
            unit: '%',
            higherIsBetter: true,
          ),
        ],
      ),
    );
  }
}

/// Single comparison row
class _ComparisonRow extends StatelessWidget {
  final String label;
  final double valueA;
  final double valueB;
  final String unit;
  final bool higherIsBetter;

  const _ComparisonRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.unit,
    required this.higherIsBetter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diff = valueA - valueB;
    final isBetter = higherIsBetter ? diff > 0 : diff < 0;
    final isWorse = higherIsBetter ? diff < 0 : diff > 0;

    Color diffColor;
    if (diff.abs() < 1) {
      diffColor =
          isDark ? PCLLColors.textSecondaryDark : PCLLColors.textSecondary;
    } else if (isBetter) {
      diffColor = Colors.green;
    } else if (isWorse) {
      diffColor = Colors.orange;
    } else {
      diffColor =
          isDark ? PCLLColors.textSecondaryDark : PCLLColors.textSecondary;
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${valueA.toStringAsFixed(1)} $unit',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? PCLLColors.textPrimaryDark
                      : PCLLColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 60,
          child: Text(
            diff >= 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: diffColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

/// Section comparing positive vs deficit days
class _PositiveVsDeficitSection extends StatelessWidget {
  final PeriodMetrics positiveMetrics;
  final PeriodMetrics deficitMetrics;

  const _PositiveVsDeficitSection({
    required this.positiveMetrics,
    required this.deficitMetrics,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? PCLLColors.surfaceDark.withOpacity(0.7)
            : PCLLColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? PCLLColors.wood.withOpacity(0.3)
              : PCLLColors.wood.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Positive vs Deficit Days',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDark
                      ? PCLLColors.textPrimaryDark
                      : PCLLColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'What was different between your positive and deficit days?',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),

          // Header row
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Text(
                  'Positive\n(${positiveMetrics.dayCount} days)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Deficit\n(${deficitMetrics.dayCount} days)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          _MetricCompareRow(
            label: 'Avg Decision Cost',
            positive: positiveMetrics.avgDecisionCost,
            deficit: deficitMetrics.avgDecisionCost,
          ),
          _MetricCompareRow(
            label: 'Avg Context Cost',
            positive: positiveMetrics.avgContextCost,
            deficit: deficitMetrics.avgContextCost,
          ),
          _MetricCompareRow(
            label: 'Avg Passive Drain',
            positive: positiveMetrics.avgPassiveDrain,
            deficit: deficitMetrics.avgPassiveDrain,
          ),
          _MetricCompareRow(
            label: 'Avg Recovery',
            positive: positiveMetrics.avgRecoveryDeposit,
            deficit: deficitMetrics.avgRecoveryDeposit,
          ),
          _MetricCompareRow(
            label: 'Recovery Ratio',
            positive: positiveMetrics.recoveryRatio * 100,
            deficit: deficitMetrics.recoveryRatio * 100,
            unit: '%',
          ),
        ],
      ),
    );
  }
}

/// Metric comparison row for positive vs deficit
class _MetricCompareRow extends StatelessWidget {
  final String label;
  final double positive;
  final double deficit;
  final String unit;

  const _MetricCompareRow({
    required this.label,
    required this.positive,
    required this.deficit,
    this.unit = 'CU',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${positive.toStringAsFixed(1)} $unit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.textPrimary,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${deficit.toStringAsFixed(1)} $unit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section showing observed patterns
class _ObservedPatternsSection extends StatelessWidget {
  final List<ObservedPattern> patterns;

  const _ObservedPatternsSection({required this.patterns});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observed Patterns',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark
                    ? PCLLColors.textPrimaryDark
                    : PCLLColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Correlations identified in your data',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? PCLLColors.textSecondaryDark
                    : PCLLColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        ...patterns.map((p) => _PatternCard(pattern: p)),
      ],
    );
  }
}

/// Single pattern observation card
class _PatternCard extends StatelessWidget {
  final ObservedPattern pattern;

  const _PatternCard({required this.pattern});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color strengthColor;
    if (pattern.associationStrength >= 0.7) {
      strengthColor = Colors.green;
    } else if (pattern.associationStrength >= 0.4) {
      strengthColor = Colors.amber;
    } else {
      strengthColor =
          isDark ? PCLLColors.textSecondaryDark : PCLLColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? PCLLColors.surfaceDark.withOpacity(0.7)
            : PCLLColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? PCLLColors.wood.withOpacity(0.3)
              : PCLLColors.wood.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: strengthColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pattern.strengthLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: strengthColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                'Association: ${(pattern.associationStrength * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? PCLLColors.textSecondaryDark
                          : PCLLColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pattern.observation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? PCLLColors.textPrimaryDark
                      : PCLLColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            pattern.context,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}

/// Shown when waiting for more data
class _WaitingForData extends StatelessWidget {
  final int daysRemaining;

  const _WaitingForData({required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.blue.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Analysis Coming Soon',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark
                            ? PCLLColors.textPrimaryDark
                            : PCLLColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$daysRemaining more ${daysRemaining == 1 ? 'day' : 'days'} of data needed '
                  'for complete pattern analysis.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary,
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
