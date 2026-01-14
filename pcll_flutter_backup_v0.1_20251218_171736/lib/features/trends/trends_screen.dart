/*
 * Trends Screen
 * =============
 * 
 * Weekly trends and data visualization.
 * Uses fl_chart for minimalist charts.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/providers/tutorial_provider.dart';
import '../../shared/widgets/tutorial_overlay.dart';
import '../../shared/widgets/background_patterns.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  // Tutorial target keys
  final _chartKey = GlobalKey();
  final _componentsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start tutorial after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TutorialProvider>()
          .startTutorialIfNeeded(TutorialType.trends);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TutorialOverlay(
      targetKeys: {
        'chart': _chartKey,
        'components': _componentsKey,
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ThemedPatternBackground(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  'Trends',
                  style: TextStyle(
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.woodDark,
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
                    final entries = ledger.entries;

                    if (entries.length < 3) {
                      return const _InsufficientData();
                    }

                    return SingleChildScrollView(
                      padding: PCLLSpacing.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekly summary
                          _WeeklySummarySection(entries: entries),
                          const SizedBox(height: 32),

                          // Balance trend chart - Tutorial target
                          Container(
                            key: _chartKey,
                            child: _BalanceChartSection(entries: entries),
                          ),
                          const SizedBox(height: 32),

                          // Component comparison - Tutorial target
                          Container(
                            key: _componentsKey,
                            child:
                                _ComponentComparisonSection(entries: entries),
                          ),
                          const SizedBox(height: 32),

                          // Recovery ratio
                          _RecoveryRatioSection(entries: entries),
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
      ),
    );
  }
}

// Weekly Summary Section
class _WeeklySummarySection extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _WeeklySummarySection({required this.entries});

  @override
  Widget build(BuildContext context) {
    // Calculate weekly stats
    final recent =
        entries.length > 7 ? entries.sublist(entries.length - 7) : entries;

    final avgWithdrawals =
        recent.map((e) => e.totalWithdrawals).reduce((a, b) => a + b) /
            recent.length;
    final avgDeposits =
        recent.map((e) => e.totalDeposits).reduce((a, b) => a + b) /
            recent.length;
    final avgBalance =
        recent.map((e) => e.closingBalance).reduce((a, b) => a + b) /
            recent.length;
    final deficitDays = recent.where((e) => e.closingBalance < 0).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: PCLLSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark
            ? PCLLColors.surfaceDark.withOpacity(0.9)
            : PCLLColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
        border: Border.all(
          color: isDark ? PCLLColors.borderDark : PCLLColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY SUMMARY',
            style: PCLLTypography.labelMedium.copyWith(
              letterSpacing: 1,
              color: isDark
                  ? PCLLColors.textTertiaryDark
                  : PCLLColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Avg Daily W/D',
                  value: avgWithdrawals.toStringAsFixed(1),
                  unit: 'CU',
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Avg Recovery',
                  value: avgDeposits.toStringAsFixed(1),
                  unit: 'CU',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Avg Balance',
                  value: avgBalance.toStringAsFixed(1),
                  unit: 'CU',
                  isNegative: avgBalance < 0,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Deficit Days',
                  value: deficitDays.toString(),
                  unit: '/ ${recent.length}',
                  isNegative: deficitDays > 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isNegative;

  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PCLLTypography.labelSmall.copyWith(
            color:
                isDark ? PCLLColors.textTertiaryDark : PCLLColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: PCLLTypography.dataLarge.copyWith(
                color: isNegative
                    ? PCLLColors.negative
                    : (isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.textPrimary),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: PCLLTypography.labelSmall.copyWith(
                color: isDark
                    ? PCLLColors.textTertiaryDark
                    : PCLLColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Balance Chart Section
class _BalanceChartSection extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _BalanceChartSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent =
        entries.length > 14 ? entries.sublist(entries.length - 14) : entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BALANCE TREND',
          style: PCLLTypography.labelMedium.copyWith(
            letterSpacing: 1,
            color:
                isDark ? PCLLColors.textTertiaryDark : PCLLColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
          decoration: BoxDecoration(
            color: isDark
                ? PCLLColors.surfaceDark.withOpacity(0.9)
                : PCLLColors.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
            border: Border.all(
              color: isDark ? PCLLColors.borderDark : PCLLColors.border,
            ),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? PCLLColors.dividerDark : PCLLColors.divider,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: PCLLTypography.dataSmall.copyWith(
                        color: isDark
                            ? PCLLColors.textTertiaryDark
                            : PCLLColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= recent.length) return const Text('');
                      return Text(
                        'D${value.toInt() + 1}',
                        style: PCLLTypography.labelSmall.copyWith(
                          fontSize: 9,
                          color: isDark
                              ? PCLLColors.textTertiaryDark
                              : PCLLColors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: PCLLColors.negative.withOpacity(0.5),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: recent.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.closingBalance);
                  }).toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: PCLLColors.positive,
                  barWidth: 2,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      final isNegative = spot.y < 0;
                      return FlDotCirclePainter(
                        radius: 3,
                        color: isNegative
                            ? PCLLColors.negative
                            : PCLLColors.positive,
                        strokeWidth: 0,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: PCLLColors.positive.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Component Comparison Section
class _ComponentComparisonSection extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _ComponentComparisonSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent =
        entries.length > 7 ? entries.sublist(entries.length - 7) : entries;

    final avgContext =
        recent.map((e) => e.components.contextCost).reduce((a, b) => a + b) /
            recent.length;
    final avgDecision =
        recent.map((e) => e.components.decisionCost).reduce((a, b) => a + b) /
            recent.length;
    final avgPassive =
        recent.map((e) => e.components.passiveDrain).reduce((a, b) => a + b) /
            recent.length;
    final maxComponent = [
      avgContext,
      avgDecision,
      avgPassive,
    ].reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVG WITHDRAWAL BY COMPONENT',
          style: PCLLTypography.labelMedium.copyWith(
            letterSpacing: 1,
            color:
                isDark ? PCLLColors.textTertiaryDark : PCLLColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: PCLLSpacing.cardPadding,
          decoration: BoxDecoration(
            color: isDark
                ? PCLLColors.surfaceDark.withOpacity(0.9)
                : PCLLColors.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
            border: Border.all(
              color: isDark ? PCLLColors.borderDark : PCLLColors.border,
            ),
          ),
          child: Column(
            children: [
              _ComponentBar(
                label: 'Context Switching',
                value: avgContext,
                maxValue: maxComponent,
              ),
              const SizedBox(height: 16),
              _ComponentBar(
                label: 'Decision Making',
                value: avgDecision,
                maxValue: maxComponent,
              ),
              const SizedBox(height: 16),
              _ComponentBar(
                label: 'Passive Drain',
                value: avgPassive,
                maxValue: maxComponent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComponentBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;

  const _ComponentBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = maxValue > 0 ? value / maxValue : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: PCLLTypography.labelMedium.copyWith(
                color: isDark
                    ? PCLLColors.textPrimaryDark
                    : PCLLColors.textPrimary,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} CU',
              style: PCLLTypography.dataMedium.copyWith(
                color: isDark
                    ? PCLLColors.textPrimaryDark
                    : PCLLColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? PCLLColors.textSecondaryDark
                    : PCLLColors.textSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Recovery Ratio Section
class _RecoveryRatioSection extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _RecoveryRatioSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recent =
        entries.length > 7 ? entries.sublist(entries.length - 7) : entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY RECOVERY RATIO',
          style: PCLLTypography.labelMedium.copyWith(
            letterSpacing: 1,
            color:
                isDark ? PCLLColors.textTertiaryDark : PCLLColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recovery ÷ Withdrawals (1.0 = break-even)',
          style: PCLLTypography.bodySmall.copyWith(
            color:
                isDark ? PCLLColors.textTertiaryDark : PCLLColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
          decoration: BoxDecoration(
            color: isDark
                ? PCLLColors.surfaceDark.withOpacity(0.9)
                : PCLLColors.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
            border: Border.all(
              color: isDark ? PCLLColors.borderDark : PCLLColors.border,
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? PCLLColors.dividerDark : PCLLColors.divider,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 0.5,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style: PCLLTypography.dataSmall.copyWith(
                        color: PCLLColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= recent.length) return const Text('');
                      return Text(
                        'D${value.toInt() + 1}',
                        style: PCLLTypography.labelSmall.copyWith(
                          fontSize: 9,
                          color: PCLLColors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 1.0,
                    color: PCLLColors.positive.withOpacity(0.5),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ],
              ),
              barGroups: recent.asMap().entries.map((e) {
                final ratio = e.value.totalWithdrawals > 0
                    ? e.value.totalDeposits / e.value.totalWithdrawals
                    : 0.0;
                final isAboveTarget = ratio >= 1.0;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: ratio.clamp(0, 2),
                      color: isAboveTarget
                          ? PCLLColors.positive
                          : PCLLColors.negative,
                      width: 12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

// Insufficient Data
class _InsufficientData extends StatelessWidget {
  const _InsufficientData();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: PCLLSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 64, color: PCLLColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Insufficient Data',
              style: PCLLTypography.headlineSmall.copyWith(
                color: PCLLColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'At least 3 days of entries are required\nto generate meaningful trends.',
              style: PCLLTypography.bodyMedium.copyWith(
                color: PCLLColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
