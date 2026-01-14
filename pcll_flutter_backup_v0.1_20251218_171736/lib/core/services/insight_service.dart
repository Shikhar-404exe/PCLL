/*
 * Insight Service - Pattern Detection Engine
 * ==========================================
 * 
 * Generates actionable insights from ledger data using rule-based analysis.
 * Ported from Python backend (src/insights.py).
 * 
 * Rules (by priority):
 * 1. HIGH_WITHDRAWAL_DAY - High cognitive load detected
 * 2. LOW_RECOVERY_PATTERN - Insufficient recovery
 * 3. DEFICIT_DETECTED - Negative closing balance
 * 4. CONSECUTIVE_DEFICIT - Multiple deficit days
 * 5. CONTEXT_OVERLOAD - High context switching
 * 6. HIGH_DECISION_LOAD - High decision volume
 * 7. OPEN_LOOP_ACCUMULATION - High passive drain
 * 8. RECOVERY_SUCCESS - Successful recovery from deficit
 * 9. STABLE_PATTERN - Consistent balanced patterns
 * 10. TREND_CHANGE - Significant trend changes
 */

import '../models/models.dart';

/// Context passed to rule check functions
class InsightContext {
  final LedgerEntry currentEntry;
  final List<LedgerEntry> recentEntries;
  final WeeklyTrends? trends;

  const InsightContext({
    required this.currentEntry,
    required this.recentEntries,
    this.trends,
  });
}

/// Insight Generator - Main service class
class InsightService {
  // Singleton pattern
  static final InsightService _instance = InsightService._internal();
  factory InsightService() => _instance;
  InsightService._internal();

  /// All rules sorted by priority
  final List<InsightRule> _rules = [
    const InsightRule(
      type: InsightType.highWithdrawalDay,
      priority: 1,
      description: 'Detect unusually high cognitive withdrawals',
    ),
    const InsightRule(
      type: InsightType.lowRecoveryPattern,
      priority: 2,
      description: 'Insufficient recovery relative to withdrawals',
    ),
    const InsightRule(
      type: InsightType.deficitDetected,
      priority: 3,
      description: 'Closing balance is negative',
    ),
    const InsightRule(
      type: InsightType.consecutiveDeficit,
      priority: 4,
      description: 'Multiple days ending in deficit',
    ),
    const InsightRule(
      type: InsightType.contextOverload,
      priority: 5,
      description: 'High context switching patterns',
    ),
    const InsightRule(
      type: InsightType.highDecisionLoad,
      priority: 6,
      description: 'High decision volume',
    ),
    const InsightRule(
      type: InsightType.openLoopAccumulation,
      priority: 7,
      description: 'High unresolved task count',
    ),
    const InsightRule(
      type: InsightType.recoverySuccess,
      priority: 8,
      description: 'Successful recovery from deficit',
    ),
    const InsightRule(
      type: InsightType.stablePattern,
      priority: 9,
      description: 'Consistent balanced patterns',
    ),
    const InsightRule(
      type: InsightType.trendChange,
      priority: 10,
      description: 'Significant changes in balance trends',
    ),
    // NEW: Persistent debt insights
    const InsightRule(
      type: InsightType.persistentDebtAccumulating,
      priority: 3, // High priority - explains sustained deficit
      description: 'Unresolved items creating accumulating cognitive debt',
    ),
    const InsightRule(
      type: InsightType.highDebtRatio,
      priority: 5,
      description: 'Persistent load exceeds immediate load (debt building)',
    ),
    // Daily reset insights
    const InsightRule(
      type: InsightType.reducedCapacity,
      priority: 2, // High priority - starting day impaired
      description:
          'Starting day with reduced capacity due to deficit carryover',
    ),
    const InsightRule(
      type: InsightType.deficitRecovery,
      priority: 8,
      description: 'Successfully recovered from deficit to full capacity',
    ),
    // Asymmetric recovery insights
    const InsightRule(
      type: InsightType.impairedRecovery,
      priority: 3, // High priority - explains why recovery isn't helping
      description: 'Recovery effectiveness reduced due to deficit state',
    ),
  ];

  /// Generate insight for a single day entry
  Insight? generateDailyInsight({
    required LedgerEntry entry,
    List<LedgerEntry>? recentEntries,
    WeeklyTrends? trends,
  }) {
    final context = InsightContext(
      currentEntry: entry,
      recentEntries: recentEntries ?? [],
      trends: trends,
    );

    // Check all rules and collect matches
    final List<(InsightRule, Insight)> matches = [];

    for (final rule in _rules) {
      final insight = _checkRule(rule, context);
      if (insight != null) {
        matches.add((rule, insight));
      }
    }

    if (matches.isEmpty) return null;

    // Return highest priority (lowest number) insight
    matches.sort((a, b) => a.$1.priority.compareTo(b.$1.priority));
    return matches.first.$2;
  }

  /// Generate insights for a week of data
  List<Insight> generateWeeklyInsights({
    required List<LedgerEntry> entries,
    required WeeklyTrends trends,
  }) {
    if (entries.isEmpty) return [];

    final insights = <Insight>[];

    // Generate insight for most recent day with full context
    final dailyInsight = generateDailyInsight(
      entry: entries.last,
      recentEntries:
          entries.length > 1 ? entries.sublist(0, entries.length - 1) : [],
      trends: trends,
    );
    if (dailyInsight != null) {
      insights.add(dailyInsight);
    }

    // Add trend-based insights
    final trendInsights = _generateTrendInsights(trends, entries.last.date);
    insights.addAll(trendInsights);

    // Limit to max 3 insights
    return insights.take(3).toList();
  }

  /// Check a single rule against context
  Insight? _checkRule(InsightRule rule, InsightContext context) {
    switch (rule.type) {
      case InsightType.highWithdrawalDay:
        return _checkHighWithdrawal(context);
      case InsightType.lowRecoveryPattern:
        return _checkLowRecovery(context);
      case InsightType.deficitDetected:
        return _checkDeficit(context);
      case InsightType.consecutiveDeficit:
        return _checkConsecutiveDeficit(context);
      case InsightType.contextOverload:
        return _checkContextOverload(context);
      case InsightType.highDecisionLoad:
        return _checkHighDecisionLoad(context);
      case InsightType.openLoopAccumulation:
        return _checkOpenLoops(context);
      case InsightType.recoverySuccess:
        return _checkRecoverySuccess(context);
      case InsightType.stablePattern:
        return _checkStablePattern(context);
      case InsightType.trendChange:
        return _checkTrendChange(context);
      // Persistent debt insights
      case InsightType.persistentDebtAccumulating:
        return _checkPersistentDebt(context);
      case InsightType.highDebtRatio:
        return _checkHighDebtRatio(context);
      // Daily reset insights
      case InsightType.reducedCapacity:
        return _checkReducedCapacity(context);
      case InsightType.deficitRecovery:
        return _checkDeficitRecovery(context);
      // Asymmetric recovery insights
      case InsightType.impairedRecovery:
        return _checkImpairedRecovery(context);
      default:
        return null;
    }
  }

  // =========================================================================
  // RULE CHECK FUNCTIONS
  // =========================================================================

  /// Rule 1: Detect unusually high withdrawal days
  Insight? _checkHighWithdrawal(InsightContext context) {
    final entry = context.currentEntry;

    // High withdrawal threshold: >120 CU (above baseline capacity)
    if (entry.totalWithdrawals > 120) {
      return Insight(
        date: entry.date,
        ruleId: 1,
        ruleName: 'HIGH_WITHDRAWAL_DAY',
        message:
            "Today's logged activities totaled ${entry.totalWithdrawals.toStringAsFixed(0)} CU "
            "in estimated cognitive demand, which exceeds the typical daily "
            "capacity of 100 CU.",
        confidence: 85,
        dataPoints: {
          'total_withdrawals': entry.totalWithdrawals,
          'threshold': 120,
        },
      );
    }
    return null;
  }

  /// Rule 2: Detect insufficient recovery patterns
  Insight? _checkLowRecovery(InsightContext context) {
    final entry = context.currentEntry;

    // Low recovery: deposits < 25% of withdrawals
    if (entry.totalWithdrawals > 0) {
      final ratio = entry.totalDeposits / entry.totalWithdrawals;
      if (ratio < 0.25) {
        return Insight(
          date: entry.date,
          ruleId: 2,
          ruleName: 'LOW_RECOVERY_PATTERN',
          message:
              "Recovery activities (${entry.totalDeposits.toStringAsFixed(0)} CU) "
              "were ${(ratio * 100).toStringAsFixed(0)}% of withdrawal activities "
              "(${entry.totalWithdrawals.toStringAsFixed(0)} CU) today.",
          confidence: 80,
          dataPoints: {
            'deposits': entry.totalDeposits,
            'withdrawals': entry.totalWithdrawals,
            'ratio': ratio,
          },
        );
      }
    }
    return null;
  }

  /// Rule 3: Detect negative closing balance
  Insight? _checkDeficit(InsightContext context) {
    final entry = context.currentEntry;

    if (entry.closingBalance < 0) {
      final severity = entry.closingBalance < -50 ? 'significantly ' : '';
      return Insight(
        date: entry.date,
        ruleId: 3,
        ruleName: 'DEFICIT_DETECTED',
        message:
            "Today's ledger closed at ${entry.closingBalance.toStringAsFixed(0)} CU, "
            "indicating logged withdrawals ${severity}exceeded "
            "available capacity plus recovery.",
        confidence: 90,
        dataPoints: {
          'closing_balance': entry.closingBalance,
          'opening_balance': entry.openingBalance,
        },
      );
    }
    return null;
  }

  /// Rule 4: Detect multiple consecutive deficit days
  Insight? _checkConsecutiveDeficit(InsightContext context) {
    if (context.recentEntries.isEmpty) return null;

    // Count recent deficit days
    int deficitDays =
        context.recentEntries.where((e) => e.closingBalance < 0).length;

    // Also check current day
    if (context.currentEntry.closingBalance < 0) {
      deficitDays++;
    }

    if (deficitDays >= 3) {
      return Insight(
        date: context.currentEntry.date,
        ruleId: 4,
        ruleName: 'CONSECUTIVE_DEFICIT',
        message: "The ledger shows $deficitDays days ending in deficit "
            "within the recent tracking period. This pattern indicates "
            "logged withdrawals have consistently exceeded recovery.",
        confidence: 85,
        dataPoints: {
          'deficit_days': deficitDays,
          'period_days': context.recentEntries.length + 1,
        },
      );
    }
    return null;
  }

  /// Rule 5: Detect high context switching
  Insight? _checkContextOverload(InsightContext context) {
    final entry = context.currentEntry;

    // Check if context cost is a major contributor (>40% of withdrawals)
    if (entry.totalWithdrawals > 0) {
      final contextRatio =
          entry.components.contextCost / entry.totalWithdrawals;
      if (contextRatio > 0.4 && entry.components.contextCost > 30) {
        return Insight(
          date: entry.date,
          ruleId: 5,
          ruleName: 'CONTEXT_OVERLOAD',
          message:
              "Context switching accounted for ${(contextRatio * 100).toStringAsFixed(0)}% "
              "of today's logged cognitive demand "
              "(${entry.components.contextCost.toStringAsFixed(0)} CU).",
          confidence: 75,
          dataPoints: {
            'context_cost': entry.components.contextCost,
            'ratio': contextRatio,
          },
        );
      }
    }
    return null;
  }

  /// Rule 6: Detect high decision volume
  Insight? _checkHighDecisionLoad(InsightContext context) {
    final entry = context.currentEntry;

    // High decision cost: >60 CU from decisions alone
    if (entry.components.decisionCost > 60) {
      return Insight(
        date: entry.date,
        ruleId: 6,
        ruleName: 'HIGH_DECISION_LOAD',
        message: "Decision-making activities contributed "
            "${entry.components.decisionCost.toStringAsFixed(0)} CU to today's ledger, "
            "indicating a high volume of deliberative choices were logged.",
        confidence: 75,
        dataPoints: {
          'decision_cost': entry.components.decisionCost,
        },
      );
    }
    return null;
  }

  /// Rule 7: Detect high passive drain from unresolved items
  Insight? _checkOpenLoops(InsightContext context) {
    final entry = context.currentEntry;

    // High passive drain: >20 CU
    if (entry.components.passiveDrain > 20) {
      return Insight(
        date: entry.date,
        ruleId: 7,
        ruleName: 'OPEN_LOOP_ACCUMULATION',
        message:
            "Unresolved items contributed ${entry.components.passiveDrain.toStringAsFixed(0)} CU "
            "of passive drain to today's ledger balance.",
        confidence: 70,
        dataPoints: {
          'passive_drain': entry.components.passiveDrain,
        },
      );
    }
    return null;
  }

  /// Rule 8: Detect successful recovery from deficit
  Insight? _checkRecoverySuccess(InsightContext context) {
    if (context.recentEntries.isEmpty) return null;

    final entry = context.currentEntry;

    // Check if previous day was deficit and today is positive
    final prevEntry = context.recentEntries.last;
    if (prevEntry.closingBalance < 0 && entry.closingBalance >= 30) {
      return Insight(
        date: entry.date,
        ruleId: 8,
        ruleName: 'RECOVERY_SUCCESS',
        message:
            "Today's balance (${entry.closingBalance.toStringAsFixed(0)} CU) shows recovery "
            "from yesterday's deficit (${prevEntry.closingBalance.toStringAsFixed(0)} CU).",
        confidence: 85,
        dataPoints: {
          'today_balance': entry.closingBalance,
          'yesterday_balance': prevEntry.closingBalance,
        },
      );
    }
    return null;
  }

  /// Rule 9: Detect consistent balanced patterns
  Insight? _checkStablePattern(InsightContext context) {
    if (context.trends == null) return null;

    final trends = context.trends!;

    // Stable: no deficit days, positive average
    // Note: We don't have volatility in our WeeklyTrends model yet, so simplified check
    if (trends.deficitDays == 0 && trends.avgClosingBalance >= 40) {
      return Insight(
        date: context.currentEntry.date,
        ruleId: 9,
        ruleName: 'STABLE_PATTERN',
        message:
            "The past ${trends.daysAnalyzed} days show a consistent pattern "
            "with average closing balance of ${trends.avgClosingBalance.toStringAsFixed(0)} CU "
            "and no deficit days.",
        confidence: 80,
        dataPoints: {
          'avg_balance': trends.avgClosingBalance,
          'deficit_days': trends.deficitDays,
          'days': trends.daysAnalyzed,
        },
      );
    }
    return null;
  }

  /// Rule 10: Detect significant trend changes
  Insight? _checkTrendChange(InsightContext context) {
    if (context.trends == null) return null;

    final trends = context.trends!;

    // Significant improving trend
    if (trends.trendDirection == TrendDirection.rapidlyImproving) {
      return Insight(
        date: context.currentEntry.date,
        ruleId: 10,
        ruleName: 'TREND_CHANGE',
        message: "Balance trend over ${trends.daysAnalyzed} days shows "
            "improvement (slope: +${trends.balanceSlope.toStringAsFixed(1)} CU/day).",
        confidence: 75,
        dataPoints: {
          'slope': trends.balanceSlope,
          'trend': trends.trendDirection.code,
        },
      );
    }

    // Significant deteriorating trend
    if (trends.trendDirection == TrendDirection.deteriorating) {
      return Insight(
        date: context.currentEntry.date,
        ruleId: 10,
        ruleName: 'TREND_CHANGE',
        message: "Balance trend over ${trends.daysAnalyzed} days shows "
            "decline (slope: ${trends.balanceSlope.toStringAsFixed(1)} CU/day).",
        confidence: 75,
        dataPoints: {
          'slope': trends.balanceSlope,
          'trend': trends.trendDirection.code,
        },
      );
    }

    return null;
  }

  // =========================================================================
  // PERSISTENT DEBT INSIGHTS (NEW)
  // =========================================================================

  /// Rule: Detect accumulating persistent debt
  Insight? _checkPersistentDebt(InsightContext context) {
    final entry = context.currentEntry;

    // Check if carry-forward debt is significant (>5 CU)
    if (entry.carryForwardDebt > 5) {
      final hasMultipleDaysDebt =
          context.recentEntries.where((e) => e.carryForwardDebt > 3).length >=
              2;

      if (hasMultipleDaysDebt) {
        // Calculate total accumulated debt over recent days
        final totalAccumulated = context.recentEntries
            .take(5)
            .map((e) => e.carryForwardDebt)
            .fold(0.0, (sum, debt) => sum + debt);

        return Insight(
          date: entry.date,
          ruleId: 13,
          ruleName: 'PERSISTENT_DEBT_ACCUMULATING',
          message: "Unresolved items are creating cognitive debt that carries "
              "forward each day. ${entry.carryForwardDebt.toStringAsFixed(1)} CU "
              "will carry to tomorrow. This accumulating load is a key "
              "contributor to sustained deficit over time.",
          confidence: 90,
          dataPoints: {
            'today_carry_forward': entry.carryForwardDebt,
            'total_accumulated': totalAccumulated,
            'unresolved_count': entry.unresolvedItems,
            'avoided_count': entry.avoidedDecisions,
          },
        );
      }
    }
    return null;
  }

  /// Rule: Detect when persistent load exceeds immediate load
  Insight? _checkHighDebtRatio(InsightContext context) {
    final entry = context.currentEntry;

    // Skip if there's no immediate load to compare
    if (entry.immediateLoad < 10) return null;

    // Debt ratio > 0.75 means persistent load is 75% of immediate
    final ratio = entry.persistentDebt / entry.immediateLoad;

    if (ratio > 0.75) {
      return Insight(
        date: entry.date,
        ruleId: 14,
        ruleName: 'HIGH_DEBT_RATIO',
        message:
            "Persistent cognitive load (${entry.persistentDebt.toStringAsFixed(0)} CU) "
            "is ${(ratio * 100).toStringAsFixed(0)}% of immediate load "
            "(${entry.immediateLoad.toStringAsFixed(0)} CU). "
            "Consider closing open loops or resolving deferred decisions to reduce ongoing drain.",
        confidence: 85,
        dataPoints: {
          'persistent_load': entry.persistentDebt,
          'immediate_load': entry.immediateLoad,
          'ratio': ratio,
        },
      );
    }
    return null;
  }

  // =========================================================================
  // DAILY RESET INSIGHTS
  // =========================================================================

  /// Rule: Detect when starting day with reduced capacity due to deficit carryover
  Insight? _checkReducedCapacity(InsightContext context) {
    final entry = context.currentEntry;

    // Check if opening balance is below 100 (max capacity)
    // This means yesterday's deficit carried forward
    if (entry.openingBalance < 100) {
      final reduction = 100 - entry.openingBalance;
      final severity = reduction > 20 ? 'significantly ' : '';

      return Insight(
        date: entry.date,
        ruleId: 15,
        ruleName: 'REDUCED_CAPACITY',
        message:
            "Today started with ${entry.openingBalance.toStringAsFixed(0)} CU "
            "(${severity}reduced from full 100 CU capacity). "
            "Yesterday's deficit of ${(reduction / 0.4).toStringAsFixed(0)} CU "
            "carried forward at 40%, reducing today's starting resources.",
        confidence: 95,
        dataPoints: {
          'opening_balance': entry.openingBalance,
          'reduction': reduction,
          'estimated_previous_deficit': reduction / 0.4,
        },
      );
    }
    return null;
  }

  /// Rule: Detect successful recovery from deficit to full capacity
  Insight? _checkDeficitRecovery(InsightContext context) {
    final entry = context.currentEntry;

    // Need at least 2 days of history
    if (context.recentEntries.length < 2) return null;

    // Get yesterday's entry
    final yesterday = context.recentEntries.length > 1
        ? context.recentEntries[context.recentEntries.length - 2]
        : null;

    if (yesterday == null) return null;

    // Check if yesterday was in deficit but today opens at full capacity
    // This means recovery was successful
    if (yesterday.closingBalance < 0 &&
        entry.openingBalance >= 100 &&
        entry.closingBalance >= 0) {
      return Insight(
        date: entry.date,
        ruleId: 16,
        ruleName: 'DEFICIT_RECOVERY',
        message: "Successfully recovered from yesterday's deficit! "
            "Despite ending at ${yesterday.closingBalance.toStringAsFixed(0)} CU, "
            "effective recovery reset today to full capacity. "
            "Current balance: ${entry.closingBalance.toStringAsFixed(0)} CU.",
        confidence: 90,
        dataPoints: {
          'yesterday_closing': yesterday.closingBalance,
          'today_opening': entry.openingBalance,
          'today_closing': entry.closingBalance,
        },
      );
    }
    return null;
  }

  // =========================================================================
  // ASYMMETRIC RECOVERY INSIGHTS
  // =========================================================================

  /// Rule: Detect when recovery effectiveness is impaired due to deficit
  Insight? _checkImpairedRecovery(InsightContext context) {
    final entry = context.currentEntry;

    // Check if ending in deficit with decent recovery quality input
    // The asymmetry means recovery wasn't as effective as it would be normally
    if (entry.closingBalance < 0 && entry.components.recoveryDeposit > 0) {
      // Calculate how much recovery was impaired
      // Normal recovery at 100% effectiveness would be higher
      final preRecoveryBalance =
          entry.closingBalance - entry.components.recoveryDeposit;

      // Only trigger if still in significant deficit despite recovery
      if (preRecoveryBalance < -20) {
        // Estimate the effectiveness penalty
        // Deep deficit = more impaired
        final deficitDepth = preRecoveryBalance.abs();
        final estimatedEfficiency = deficitDepth > 60
            ? 30
            : deficitDepth > 40
                ? 40
                : deficitDepth > 20
                    ? 50
                    : 60;

        return Insight(
          date: entry.date,
          ruleId: 17,
          ruleName: 'IMPAIRED_RECOVERY',
          message:
              "Recovery activities today were only ~$estimatedEfficiency% effective "
              "due to deficit state. When in cognitive deficit, recovery is harder - "
              "this is why prevention matters more than cure. "
              "Sustained recovery over multiple days is needed.",
          confidence: 85,
          dataPoints: {
            'closing_balance': entry.closingBalance,
            'recovery_deposit': entry.components.recoveryDeposit,
            'pre_recovery_balance': preRecoveryBalance,
            'estimated_efficiency': estimatedEfficiency,
          },
        );
      }
    }
    return null;
  }

  // =========================================================================
  // TREND INSIGHTS
  // =========================================================================

  /// Generate insights from weekly trends
  List<Insight> _generateTrendInsights(WeeklyTrends trends, String date) {
    final insights = <Insight>[];

    // Low recovery ratio insight
    if (trends.recoveryRatio < 0.3) {
      insights.add(Insight(
        date: date,
        ruleId: 11,
        ruleName: 'WEEKLY_LOW_RECOVERY',
        message: "Over ${trends.daysAnalyzed} days, recovery activities "
            "(${trends.avgDeposits.toStringAsFixed(0)} CU/day avg) were ${(trends.recoveryRatio * 100).toStringAsFixed(0)}% "
            "of withdrawal activities (${trends.avgWithdrawals.toStringAsFixed(0)} CU/day avg).",
        confidence: 80,
        dataPoints: {
          'recovery_ratio': trends.recoveryRatio,
          'avg_deposits': trends.avgDeposits,
          'avg_withdrawals': trends.avgWithdrawals,
        },
      ));
    }

    return insights;
  }
}
