// Calm Balance Chart Widget

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';

class CalmBalanceChart extends StatelessWidget {
  final List<LedgerEntry> entries;
  final double height;

  const CalmBalanceChart({
    super.key,
    required this.entries,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Take last 7 days
    final recent =
        entries.length > 7 ? entries.sublist(entries.length - 7) : entries;

    // Prepare data points
    final spots = <FlSpot>[];
    for (int i = 0; i < recent.length; i++) {
      spots.add(FlSpot(i.toDouble(), recent[i].closingBalance));
    }

    // Calculate y-axis range with padding
    final balances = recent.map((e) => e.closingBalance).toList();
    final minBalance = balances.reduce((a, b) => a < b ? a : b);
    final maxBalance = balances.reduce((a, b) => a > b ? a : b);
    final range = maxBalance - minBalance;
    final padding = range * 0.2; // 20% padding

    final minY = (minBalance - padding).roundToDouble();
    final maxY = (maxBalance + padding).roundToDouble();

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? PCLLColors.surfaceAltDark.withOpacity(0.5)
            : PCLLColors.surfaceAlt.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? PCLLColors.borderDark : PCLLColors.border)
              .withOpacity(0.5),
        ),
      ),
      child: LineChart(
        LineChartData(
          // Remove grid lines for calm appearance
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: (isDark ? PCLLColors.dividerDark : PCLLColors.divider)
                  .withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          // Remove borders
          borderData: FlBorderData(show: false),
          // Axis titles
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: (maxY - minY) / 4,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toInt().toString(),
                      style: PCLLTypography.labelSmall.copyWith(
                        color: isDark
                            ? PCLLColors.textTertiaryDark
                            : PCLLColors.textTertiary,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < recent.length) {
                    final entry = recent[value.toInt()];
                    final date = DateTime.parse(entry.date);
                    // Show day of week
                    final dayNames = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ];
                    final dayName = dayNames[(date.weekday - 1) % 7];

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        dayName,
                        style: PCLLTypography.labelSmall.copyWith(
                          color: isDark
                              ? PCLLColors.textTertiaryDark
                              : PCLLColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          // Set Y axis range
          minY: minY,
          maxY: maxY,
          // Line styling - calm, muted
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: isDark ? PCLLColors.accent : PCLLColors.woodDark,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final isNegative = spot.y < 0;
                  return FlDotCirclePainter(
                    radius: 3,
                    color: isNegative
                        ? PCLLColors.negative
                        : (isDark ? PCLLColors.accent : PCLLColors.woodDark),
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (isDark ? PCLLColors.accent : PCLLColors.woodDark)
                        .withOpacity(0.15),
                    (isDark ? PCLLColors.accent : PCLLColors.woodDark)
                        .withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
          // Touch interactions
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor:
                  isDark ? PCLLColors.surfaceDark : PCLLColors.surface,
              tooltipBorder: BorderSide(
                color: isDark ? PCLLColors.borderDark : PCLLColors.border,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final entry = recent[spot.x.toInt()];
                  final date = DateTime.parse(entry.date);
                  final dateStr = '${date.month}/${date.day}';

                  return LineTooltipItem(
                    '$dateStr\n${spot.y.toStringAsFixed(1)} CU',
                    PCLLTypography.labelSmall.copyWith(
                      color: isDark
                          ? PCLLColors.textPrimaryDark
                          : PCLLColors.textPrimary,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
