// Pattern Observation Service

import 'dart:math' as math;

import '../models/models.dart';

/// Service for analyzing ledger patterns
class PatternObservationService {
  /// Generate a complete pattern report from ledger entries
  /// Returns null if not enough data (< 7 days)
  PatternReport? generateReport(List<LedgerEntry> entries) {
    if (entries.isEmpty) return null;

    // Sort by date (oldest first)
    final sorted = List<LedgerEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalDays = sorted.length;
    if (totalDays < weeklyComparisonDays) return null;

    final now = DateTime.now();
    final isComplete = totalDays >= patternMinimumDays;

    // Calculate period metrics
    final currentWeek = _calculatePeriodMetrics(_getLastNDays(sorted, 7));
    final previousWeek = _calculatePeriodMetrics(
      _getDaysInRange(sorted, 7, 14),
    );
    final bestWeek = _findBestWeek(sorted);
    final currentMonth = _calculatePeriodMetrics(_getLastNDays(sorted, 30));

    // Previous month (only if we have 60+ days)
    PeriodMetrics? previousMonth;
    if (totalDays >= 60) {
      previousMonth = _calculatePeriodMetrics(
        _getDaysInRange(sorted, 30, 60),
      );
    }

    // Build comparisons
    final weekOverWeek = PeriodComparison(
      periodALabel: 'This Week',
      periodBLabel: 'Previous Week',
      periodA: currentWeek,
      periodB: previousWeek,
    );

    final currentVsBest = PeriodComparison(
      periodALabel: 'This Week',
      periodBLabel: 'Best Week',
      periodA: currentWeek,
      periodB: bestWeek,
    );

    PeriodComparison? monthOverMonth;
    if (previousMonth != null) {
      monthOverMonth = PeriodComparison(
        periodALabel: 'This Month',
        periodBLabel: 'Previous Month',
        periodA: currentMonth,
        periodB: previousMonth,
      );
    }

    // Analyze positive vs deficit days
    final positiveDays = sorted.where((e) => e.closingBalance >= 0).toList();
    final deficitDays = sorted.where((e) => e.closingBalance < 0).toList();

    final positiveDayMetrics =
        positiveDays.isNotEmpty ? _calculatePeriodMetrics(positiveDays) : null;
    final deficitDayMetrics =
        deficitDays.isNotEmpty ? _calculatePeriodMetrics(deficitDays) : null;

    // Generate observed patterns (only if complete)
    final patterns = isComplete
        ? _generatePatterns(
            sorted,
            positiveDayMetrics,
            deficitDayMetrics,
          )
        : <ObservedPattern>[];

    return PatternReport(
      generatedAt: now,
      totalDaysAnalyzed: totalDays,
      isComplete: isComplete,
      currentWeek: currentWeek,
      previousWeek: previousWeek,
      bestWeek: bestWeek,
      currentMonth: currentMonth,
      previousMonth: previousMonth,
      weekOverWeek: weekOverWeek,
      currentVsBest: currentVsBest,
      monthOverMonth: monthOverMonth,
      patterns: patterns,
      positiveDayMetrics: positiveDayMetrics,
      deficitDayMetrics: deficitDayMetrics,
    );
  }

  /// Calculate metrics for a period of entries
  PeriodMetrics _calculatePeriodMetrics(List<LedgerEntry> entries) {
    if (entries.isEmpty) return PeriodMetrics.empty;

    final count = entries.length;

    double totalBalance = 0;
    double totalWithdrawals = 0;
    double totalDeposits = 0;
    double totalDecisionCost = 0;
    double totalContextCost = 0;
    double totalPassiveDrain = 0;
    double totalRecovery = 0;
    int positiveDays = 0;
    int deficitDays = 0;

    for (final entry in entries) {
      totalBalance += entry.closingBalance;
      totalWithdrawals += entry.totalWithdrawals;
      totalDeposits += entry.totalDeposits;
      totalDecisionCost += entry.components.decisionCost;
      totalContextCost += entry.components.contextCost;
      totalPassiveDrain += entry.components.passiveDrain;
      totalRecovery += entry.components.recoveryDeposit;

      if (entry.closingBalance >= 0) {
        positiveDays++;
      } else {
        deficitDays++;
      }
    }

    return PeriodMetrics(
      dayCount: count,
      avgClosingBalance: totalBalance / count,
      avgWithdrawals: totalWithdrawals / count,
      avgDeposits: totalDeposits / count,
      avgDecisionCost: totalDecisionCost / count,
      avgContextCost: totalContextCost / count,
      avgPassiveDrain: totalPassiveDrain / count,
      avgRecoveryDeposit: totalRecovery / count,
      positiveDays: positiveDays,
      deficitDays: deficitDays,
    );
  }

  /// Get the last N days of entries
  List<LedgerEntry> _getLastNDays(List<LedgerEntry> sorted, int days) {
    if (sorted.length <= days) return sorted;
    return sorted.sublist(sorted.length - days);
  }

  /// Get entries in a day range (e.g., days 7-14 for previous week)
  List<LedgerEntry> _getDaysInRange(
    List<LedgerEntry> sorted,
    int startDaysAgo,
    int endDaysAgo,
  ) {
    if (sorted.length < startDaysAgo) return [];
    final endIndex = sorted.length - startDaysAgo;
    final startIndex = math.max(0, sorted.length - endDaysAgo);
    if (startIndex >= endIndex) return [];
    return sorted.sublist(startIndex, endIndex);
  }

  /// Find the best 7-day period by average closing balance
  PeriodMetrics _findBestWeek(List<LedgerEntry> sorted) {
    if (sorted.length < 7) {
      return _calculatePeriodMetrics(sorted);
    }

    PeriodMetrics bestMetrics = PeriodMetrics.empty;
    double bestBalance = double.negativeInfinity;

    // Slide a 7-day window to find best week
    for (int i = 0; i <= sorted.length - 7; i++) {
      final weekEntries = sorted.sublist(i, i + 7);
      final metrics = _calculatePeriodMetrics(weekEntries);

      if (metrics.avgClosingBalance > bestBalance) {
        bestBalance = metrics.avgClosingBalance;
        bestMetrics = metrics;
      }
    }

    return bestMetrics;
  }

  /// Generate observed patterns by comparing positive vs deficit days
  List<ObservedPattern> _generatePatterns(
    List<LedgerEntry> allEntries,
    PeriodMetrics? positiveMetrics,
    PeriodMetrics? deficitMetrics,
  ) {
    final patterns = <ObservedPattern>[];

    if (positiveMetrics == null || deficitMetrics == null) {
      return patterns;
    }

    // Pattern 1: Recovery difference
    final recoveryDiff =
        positiveMetrics.avgRecoveryDeposit - deficitMetrics.avgRecoveryDeposit;
    if (recoveryDiff.abs() > 5) {
      final pct =
          (recoveryDiff / deficitMetrics.avgRecoveryDeposit * 100).abs();
      final strength = _calculateStrength(pct, 50);

      patterns.add(ObservedPattern(
        patternId: 'RECOVERY_ASSOCIATION',
        observation: recoveryDiff > 0
            ? 'Positive-balance days had ${pct.toStringAsFixed(0)}% higher recovery deposits on average'
            : 'Deficit days had ${pct.toStringAsFixed(0)}% lower recovery deposits on average',
        associationStrength: strength,
        context:
            'Comparing ${positiveMetrics.dayCount} positive days to ${deficitMetrics.dayCount} deficit days',
        metrics: {
          'positive_avg_recovery': positiveMetrics.avgRecoveryDeposit,
          'deficit_avg_recovery': deficitMetrics.avgRecoveryDeposit,
        },
      ));
    }

    // Pattern 2: Decision load difference
    final decisionDiff =
        deficitMetrics.avgDecisionCost - positiveMetrics.avgDecisionCost;
    if (decisionDiff.abs() > 5) {
      final pct = (decisionDiff / positiveMetrics.avgDecisionCost * 100).abs();
      final strength = _calculateStrength(pct, 40);

      patterns.add(ObservedPattern(
        patternId: 'DECISION_LOAD_ASSOCIATION',
        observation: decisionDiff > 0
            ? 'Deficit days had ${pct.toStringAsFixed(0)}% higher decision load on average'
            : 'Positive-balance days had ${pct.toStringAsFixed(0)}% higher decision load but maintained balance',
        associationStrength: strength,
        context: 'Decision cost comparison across all logged days',
        metrics: {
          'positive_avg_decisions': positiveMetrics.avgDecisionCost,
          'deficit_avg_decisions': deficitMetrics.avgDecisionCost,
        },
      ));
    }

    // Pattern 3: Context switching difference
    final contextDiff =
        deficitMetrics.avgContextCost - positiveMetrics.avgContextCost;
    if (contextDiff.abs() > 3) {
      final pct = positiveMetrics.avgContextCost > 0
          ? (contextDiff / positiveMetrics.avgContextCost * 100).abs()
          : contextDiff.abs() * 10;
      final strength = _calculateStrength(pct, 30);

      patterns.add(ObservedPattern(
        patternId: 'CONTEXT_SWITCH_ASSOCIATION',
        observation: contextDiff > 0
            ? 'Deficit days had ${pct.toStringAsFixed(0)}% more context switching on average'
            : 'Positive-balance days had more context switching but recovered well',
        associationStrength: strength,
        context: 'Context cost comparison across all logged days',
        metrics: {
          'positive_avg_context': positiveMetrics.avgContextCost,
          'deficit_avg_context': deficitMetrics.avgContextCost,
        },
      ));
    }

    // Pattern 4: Passive drain (unresolved items)
    final drainDiff =
        deficitMetrics.avgPassiveDrain - positiveMetrics.avgPassiveDrain;
    if (drainDiff.abs() > 3) {
      final pct = positiveMetrics.avgPassiveDrain > 0
          ? (drainDiff / positiveMetrics.avgPassiveDrain * 100).abs()
          : drainDiff.abs() * 10;
      final strength = _calculateStrength(pct, 50);

      patterns.add(ObservedPattern(
        patternId: 'PASSIVE_DRAIN_ASSOCIATION',
        observation: drainDiff > 0
            ? 'Deficit days had ${pct.toStringAsFixed(0)}% higher passive drain from unresolved items'
            : 'Positive-balance days had higher passive drain but offset with recovery',
        associationStrength: strength,
        context: 'Unresolved items and open loops comparison',
        metrics: {
          'positive_avg_drain': positiveMetrics.avgPassiveDrain,
          'deficit_avg_drain': deficitMetrics.avgPassiveDrain,
        },
      ));
    }

    // Pattern 5: Overall load vs recovery ratio
    final positiveRatio = positiveMetrics.recoveryRatio;
    final deficitRatio = deficitMetrics.recoveryRatio;
    if ((positiveRatio - deficitRatio).abs() > 0.1) {
      final strength =
          _calculateStrength((positiveRatio - deficitRatio) * 100, 30);

      patterns.add(ObservedPattern(
        patternId: 'RECOVERY_RATIO_ASSOCIATION',
        observation: positiveRatio > deficitRatio
            ? 'Positive-balance days had ${((positiveRatio - deficitRatio) * 100).toStringAsFixed(0)}% better recovery-to-withdrawal ratio'
            : 'Deficit days showed lower recovery relative to withdrawals',
        associationStrength: strength,
        context: 'Recovery effectiveness comparison',
        metrics: {
          'positive_ratio': positiveRatio,
          'deficit_ratio': deficitRatio,
        },
      ));
    }

    // Sort by association strength (strongest first)
    patterns
        .sort((a, b) => b.associationStrength.compareTo(a.associationStrength));

    return patterns;
  }

  /// Calculate association strength (0.0 - 1.0) based on percentage difference
  double _calculateStrength(double percentDiff, double threshold) {
    // Normalize to 0-1 range based on threshold
    final normalized = (percentDiff / threshold).clamp(0.0, 1.5);
    return math.min(
        1.0, normalized * 0.7); // Cap at 1.0, scale to max 0.7 for "strong"
  }
}
