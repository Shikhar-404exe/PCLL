/*
 * PCLL Data Models
 * ================
 * 
 * Core data structures for the ledger system.
 * Mirrors the Python backend models for consistency.
 */

import 'package:flutter/foundation.dart';

export 'user_profile.dart';

// =============================================================================
// ENUMS
// =============================================================================

enum CognitiveState {
  wellRested('WELL_RESTED', 'Well Rested', '≥70 CU'),
  moderate('MODERATE', 'Moderate', '40-69 CU'),
  depleted('DEPLETED', 'Depleted', '1-39 CU'),
  deficit('DEFICIT', 'Deficit', '-49 to 0 CU'),
  severeDeficit('SEVERE_DEFICIT', 'Severe Deficit', '≤-50 CU');

  final String code;
  final String label;
  final String range;

  const CognitiveState(this.code, this.label, this.range);

  static CognitiveState fromBalance(double balance) {
    if (balance >= 70) return CognitiveState.wellRested;
    if (balance >= 40) return CognitiveState.moderate;
    if (balance >= 1) return CognitiveState.depleted;
    if (balance > -50) return CognitiveState.deficit;
    return CognitiveState.severeDeficit;
  }
}

enum TrendDirection {
  deteriorating('DETERIORATING', '↓↓', -1),
  declining('DECLINING', '↓', -0.5),
  stable('STABLE', '→', 0),
  improving('IMPROVING', '↑', 0.5),
  rapidlyImproving('RAPIDLY_IMPROVING', '↑↑', 1);

  final String code;
  final String symbol;
  final double factor;

  const TrendDirection(this.code, this.symbol, this.factor);
}

// =============================================================================
// DAILY INPUT
// =============================================================================

@immutable
class DailyInput {
  final String date;

  // IMMEDIATE LOAD inputs (same-day only)
  final int contextCount; // Number of context switches
  final int decisionCount; // Decisions made today
  final int focusHours; // Hours of deep work / meetings

  // PERSISTENT LOAD inputs (carry forward until resolved)
  final int unresolvedCount; // Open loops / unfinished tasks
  final int avoidedCount; // Decisions deferred / avoided

  // RECOVERY
  final int recoveryQuality; // 1-10 scale
  final String? textNote;

  const DailyInput({
    required this.date,
    // Immediate
    required this.contextCount,
    required this.decisionCount,
    this.focusHours = 0,
    // Persistent
    required this.unresolvedCount,
    this.avoidedCount = 0,
    // Recovery
    required this.recoveryQuality,
    this.textNote,
  });

  Map<String, dynamic> toMap() => {
        'date': date,
        'context_count': contextCount,
        'decision_count': decisionCount,
        'focus_hours': focusHours,
        'unresolved_count': unresolvedCount,
        'avoided_count': avoidedCount,
        'recovery_quality': recoveryQuality,
        'text_note': textNote,
      };

  factory DailyInput.fromMap(Map<String, dynamic> map) => DailyInput(
        date: map['date'] as String,
        contextCount: map['context_count'] as int,
        decisionCount: map['decision_count'] as int,
        focusHours: map['focus_hours'] as int? ?? 0,
        unresolvedCount: map['unresolved_count'] as int,
        avoidedCount: map['avoided_count'] as int? ?? 0,
        recoveryQuality: map['recovery_quality'] as int,
        textNote: map['text_note'] as String?,
      );
}

// =============================================================================
// COMPONENT BREAKDOWN
// =============================================================================

/// Withdrawal types:
/// - IMMEDIATE LOAD: Costs CU on the day only (deep work, meetings, focus)
/// - PERSISTENT LOAD: Costs CU every day until resolved (open loops, cognitive debt)
@immutable
class ComponentBreakdown {
  // IMMEDIATE LOAD - same-day costs only
  final double contextCost; // Context switching cost (immediate)
  final double decisionCost; // Decision-making cost (immediate)
  final double focusWorkCost; // Deep work / meetings cost (immediate)

  // PERSISTENT LOAD - carries forward until resolved
  final double unresolvedDrain; // Unresolved tasks / open loops (persistent)
  final double avoidedDecisions; // Deferred decisions drain (persistent)
  final double accumulatedDebt; // Carried from previous days (persistent)

  // DEPOSITS
  final double recoveryDeposit;

  const ComponentBreakdown({
    // Immediate
    this.contextCost = 0,
    this.decisionCost = 0,
    this.focusWorkCost = 0,
    // Persistent
    this.unresolvedDrain = 0,
    this.avoidedDecisions = 0,
    this.accumulatedDebt = 0,
    // Deposits
    this.recoveryDeposit = 0,
  });

  /// Immediate load - consumed today, does NOT carry forward
  double get immediateLoad => contextCost + decisionCost + focusWorkCost;

  /// Persistent load - costs CU every day until resolved
  double get persistentLoad =>
      unresolvedDrain + avoidedDecisions + accumulatedDebt;

  /// Total withdrawals (both types combined)
  double get totalWithdrawals => immediateLoad + persistentLoad;

  /// Total deposits
  double get totalDeposits => recoveryDeposit;

  /// Legacy getter for backward compatibility
  double get passiveDrain => unresolvedDrain;

  Map<String, dynamic> toMap() => {
        // Immediate
        'context_cost': contextCost,
        'decision_cost': decisionCost,
        'focus_work_cost': focusWorkCost,
        // Persistent
        'unresolved_drain': unresolvedDrain,
        'avoided_decisions': avoidedDecisions,
        'accumulated_debt': accumulatedDebt,
        // Deposits
        'recovery_deposit': recoveryDeposit,
        // Computed
        'immediate_load': immediateLoad,
        'persistent_load': persistentLoad,
      };

  factory ComponentBreakdown.fromMap(Map<String, dynamic> map) =>
      ComponentBreakdown(
        // Immediate
        contextCost: (map['context_cost'] as num?)?.toDouble() ?? 0,
        decisionCost: (map['decision_cost'] as num?)?.toDouble() ?? 0,
        focusWorkCost: (map['focus_work_cost'] as num?)?.toDouble() ?? 0,
        // Persistent (with fallback to legacy passive_drain)
        unresolvedDrain: (map['unresolved_drain'] as num?)?.toDouble() ??
            (map['passive_drain'] as num?)?.toDouble() ??
            0,
        avoidedDecisions: (map['avoided_decisions'] as num?)?.toDouble() ?? 0,
        accumulatedDebt: (map['accumulated_debt'] as num?)?.toDouble() ?? 0,
        // Deposits
        recoveryDeposit: (map['recovery_deposit'] as num?)?.toDouble() ?? 0,
      );
}

// =============================================================================
// LEDGER ENTRY
// =============================================================================

/// Tracks daily cognitive resource accounting with PCLL banking model.
///
/// Key concepts:
/// - immediateLoad: Today's cognitive costs that don't carry forward
/// - persistentDebt: Unresolved items that cost CU every day until resolved
/// - carryForwardDebt: Persistent debt passed to next day (THIS is how sustained deficit develops)
@immutable
class LedgerEntry {
  final String date;
  final double openingBalance;
  final double closingBalance;
  final double totalWithdrawals;
  final double totalDeposits;
  final double netChange;
  final CognitiveState cognitiveState;
  final ComponentBreakdown components;
  final DateTime createdAt;

  // NEW: Track load types separately
  final double immediateLoad; // Same-day costs only
  final double persistentDebt; // Costs that carry forward
  final double carryForwardDebt; // Debt passed to tomorrow

  // Track unresolved items (for debt calculation)
  final int unresolvedItems; // Open loops still draining resources
  final int avoidedDecisions; // Deferred decisions still pending

  const LedgerEntry({
    required this.date,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalWithdrawals,
    required this.totalDeposits,
    required this.netChange,
    required this.cognitiveState,
    required this.components,
    required this.createdAt,
    // Load types
    this.immediateLoad = 0,
    this.persistentDebt = 0,
    this.carryForwardDebt = 0,
    // Unresolved tracking
    this.unresolvedItems = 0,
    this.avoidedDecisions = 0,
  });

  bool get isDeficit => closingBalance < 0;
  bool get isPositive => closingBalance > 0;

  /// True if there are unresolved items creating ongoing debt
  bool get hasActiveDebt => unresolvedItems > 0 || avoidedDecisions > 0;

  /// The ratio of persistent to immediate load (higher = more debt accumulation)
  double get debtRatio =>
      immediateLoad > 0 ? persistentDebt / immediateLoad : 0;

  Map<String, dynamic> toMap() => {
        'date': date,
        'opening_balance': openingBalance,
        'closing_balance': closingBalance,
        'total_withdrawals': totalWithdrawals,
        'total_deposits': totalDeposits,
        'net_change': netChange,
        'cognitive_state': cognitiveState.code,
        'components': components.toMap(),
        'created_at': createdAt.toIso8601String(),
        // Load types
        'immediate_load': immediateLoad,
        'persistent_debt': persistentDebt,
        'carry_forward_debt': carryForwardDebt,
        // Unresolved tracking
        'unresolved_items': unresolvedItems,
        'avoided_decisions': avoidedDecisions,
      };

  factory LedgerEntry.fromMap(Map<String, dynamic> map) => LedgerEntry(
        date: map['date'] as String,
        openingBalance: (map['opening_balance'] as num).toDouble(),
        closingBalance: (map['closing_balance'] as num).toDouble(),
        totalWithdrawals: (map['total_withdrawals'] as num).toDouble(),
        totalDeposits: (map['total_deposits'] as num).toDouble(),
        netChange: (map['net_change'] as num).toDouble(),
        cognitiveState: CognitiveState.values.firstWhere(
          (e) => e.code == map['cognitive_state'],
          orElse: () => CognitiveState.moderate,
        ),
        components: map['components'] is Map
            ? ComponentBreakdown.fromMap(
                map['components'] as Map<String, dynamic>)
            : const ComponentBreakdown(),
        createdAt: DateTime.parse(map['created_at'] as String),
        // Load types
        immediateLoad: (map['immediate_load'] as num?)?.toDouble() ?? 0,
        persistentDebt: (map['persistent_debt'] as num?)?.toDouble() ?? 0,
        carryForwardDebt: (map['carry_forward_debt'] as num?)?.toDouble() ?? 0,
        // Unresolved tracking
        unresolvedItems: (map['unresolved_items'] as int?) ?? 0,
        avoidedDecisions: (map['avoided_decisions'] as int?) ?? 0,
      );
}

// =============================================================================
// WEEKLY TRENDS
// =============================================================================

@immutable
class WeeklyTrends {
  final double avgOpeningBalance;
  final double avgClosingBalance;
  final double avgWithdrawals;
  final double avgDeposits;
  final int deficitDays;
  final double recoveryRatio;
  final TrendDirection trendDirection;
  final double balanceSlope;
  final int daysAnalyzed;
  final String startDate;
  final String endDate;

  const WeeklyTrends({
    required this.avgOpeningBalance,
    required this.avgClosingBalance,
    required this.avgWithdrawals,
    required this.avgDeposits,
    required this.deficitDays,
    required this.recoveryRatio,
    required this.trendDirection,
    required this.balanceSlope,
    required this.daysAnalyzed,
    required this.startDate,
    required this.endDate,
  });
}

// =============================================================================
// INSIGHT TYPES AND CATEGORIES
// =============================================================================

/// Types of insights that can be generated
enum InsightType {
  highWithdrawalDay(
      1, 'HIGH_WITHDRAWAL_DAY', '📊', InsightCategory.observation),
  lowRecoveryPattern(
      2, 'LOW_RECOVERY_PATTERN', '⚖️', InsightCategory.observation),
  deficitDetected(3, 'DEFICIT_DETECTED', '📉', InsightCategory.observation),
  consecutiveDeficit(
      4, 'CONSECUTIVE_DEFICIT', '⚠️', InsightCategory.observation),
  contextOverload(5, 'CONTEXT_OVERLOAD', '🔀', InsightCategory.observation),
  highDecisionLoad(6, 'HIGH_DECISION_LOAD', '🤔', InsightCategory.observation),
  openLoopAccumulation(
      7, 'OPEN_LOOP_ACCUMULATION', '📋', InsightCategory.observation),
  recoverySuccess(8, 'RECOVERY_SUCCESS', '✅', InsightCategory.pattern),
  stablePattern(9, 'STABLE_PATTERN', '📈', InsightCategory.pattern),
  trendChange(10, 'TREND_CHANGE', '📊', InsightCategory.trend),
  weeklyLowRecovery(11, 'WEEKLY_LOW_RECOVERY', '⚖️', InsightCategory.trend),
  highVolatility(12, 'HIGH_VOLATILITY', '📊', InsightCategory.trend),
  // Persistent debt insights
  persistentDebtAccumulating(
      13, 'PERSISTENT_DEBT_ACCUMULATING', '🔄', InsightCategory.observation),
  highDebtRatio(14, 'HIGH_DEBT_RATIO', '⚠️', InsightCategory.trend),
  // Daily reset insights
  reducedCapacity(15, 'REDUCED_CAPACITY', '🔋', InsightCategory.observation),
  deficitRecovery(16, 'DEFICIT_RECOVERY', '🌅', InsightCategory.pattern),
  // Asymmetric recovery insights
  impairedRecovery(17, 'IMPAIRED_RECOVERY', '🩹', InsightCategory.observation),
  // Calibration insights
  calibrationComplete(
      18, 'CALIBRATION_COMPLETE', '🎯', InsightCategory.pattern),
  calibrationProgress(
      19, 'CALIBRATION_PROGRESS', '📊', InsightCategory.observation);

  final int id;
  final String code;
  final String icon;
  final InsightCategory category;

  const InsightType(this.id, this.code, this.icon, this.category);

  static InsightType? fromCode(String code) {
    return InsightType.values.where((t) => t.code == code).firstOrNull;
  }
}

/// Categories for grouping insights
enum InsightCategory {
  observation('OBSERVATION', 'Observations'),
  pattern('PATTERN', 'Patterns'),
  trend('TREND', 'Trends');

  final String code;
  final String label;

  const InsightCategory(this.code, this.label);
}

// =============================================================================
// INSIGHT RULE (Used by InsightService)
// =============================================================================

/// Definition of an insight rule
@immutable
class InsightRule {
  final InsightType type;
  final int priority; // Lower = higher priority (checked first)
  final String description;

  const InsightRule({
    required this.type,
    required this.priority,
    required this.description,
  });
}

// =============================================================================
// INSIGHT
// =============================================================================

@immutable
class Insight {
  final String date;
  final int ruleId;
  final String ruleName;
  final String message;
  final int confidence;
  final Map<String, dynamic>? dataPoints;

  const Insight({
    required this.date,
    required this.ruleId,
    required this.ruleName,
    required this.message,
    required this.confidence,
    this.dataPoints,
  });

  /// Get the insight type enum
  InsightType? get type => InsightType.fromCode(ruleName);

  /// Get the icon for this insight
  String get icon => type?.icon ?? 'ℹ️';

  /// Get the category for this insight
  InsightCategory get category => type?.category ?? InsightCategory.observation;

  /// Whether this is a positive/good insight
  bool get isPositive => ruleId == 8 || ruleId == 9;

  /// Whether this is a warning insight
  bool get isWarning => ruleId >= 1 && ruleId <= 7;

  Map<String, dynamic> toMap() => {
        'date': date,
        'rule_id': ruleId,
        'rule_name': ruleName,
        'message': message,
        'confidence': confidence,
        'data_points': dataPoints,
      };

  factory Insight.fromMap(Map<String, dynamic> map) => Insight(
        date: map['date'] as String,
        ruleId: map['rule_id'] as int,
        ruleName: map['rule_name'] as String,
        message: map['message'] as String,
        confidence: map['confidence'] as int,
        dataPoints: map['data_points'] as Map<String, dynamic>?,
      );

  @override
  String toString() => '$icon $message';
}

// =============================================================================
// PATTERN OBSERVATION MODELS
// =============================================================================

/// Minimum days required before pattern analysis is available
const int patternMinimumDays = 30;

/// Minimum days for weekly comparison
const int weeklyComparisonDays = 7;

/// Represents averaged metrics for a time period
@immutable
class PeriodMetrics {
  final int dayCount;
  final double avgClosingBalance;
  final double avgWithdrawals;
  final double avgDeposits;
  final double avgDecisionCost;
  final double avgContextCost;
  final double avgPassiveDrain;
  final double avgRecoveryDeposit;
  final int positiveDays; // Days with closing >= 0
  final int deficitDays; // Days with closing < 0

  const PeriodMetrics({
    required this.dayCount,
    required this.avgClosingBalance,
    required this.avgWithdrawals,
    required this.avgDeposits,
    required this.avgDecisionCost,
    required this.avgContextCost,
    required this.avgPassiveDrain,
    required this.avgRecoveryDeposit,
    required this.positiveDays,
    required this.deficitDays,
  });

  /// Percentage of days with positive balance
  double get positiveRatio =>
      dayCount > 0 ? (positiveDays / dayCount) * 100 : 0;

  /// Percentage of days with deficit
  double get deficitRatio => dayCount > 0 ? (deficitDays / dayCount) * 100 : 0;

  /// Recovery to withdrawal ratio
  double get recoveryRatio =>
      avgWithdrawals > 0 ? avgDeposits / avgWithdrawals : 0;

  static const PeriodMetrics empty = PeriodMetrics(
    dayCount: 0,
    avgClosingBalance: 0,
    avgWithdrawals: 0,
    avgDeposits: 0,
    avgDecisionCost: 0,
    avgContextCost: 0,
    avgPassiveDrain: 0,
    avgRecoveryDeposit: 0,
    positiveDays: 0,
    deficitDays: 0,
  );
}

/// A single observed pattern with correlation data
@immutable
class ObservedPattern {
  final String patternId;
  final String observation; // What was observed (user interprets)
  final double associationStrength; // 0.0 - 1.0 (correlation strength)
  final String context; // When this pattern was observed
  final Map<String, double>? metrics; // Supporting data

  const ObservedPattern({
    required this.patternId,
    required this.observation,
    required this.associationStrength,
    required this.context,
    this.metrics,
  });

  /// Human-readable strength label
  String get strengthLabel {
    if (associationStrength >= 0.8) return 'Strong';
    if (associationStrength >= 0.5) return 'Moderate';
    return 'Weak';
  }
}

/// Comparison between two time periods
@immutable
class PeriodComparison {
  final String periodALabel; // e.g., "This Week"
  final String periodBLabel; // e.g., "Best Week"
  final PeriodMetrics periodA;
  final PeriodMetrics periodB;

  const PeriodComparison({
    required this.periodALabel,
    required this.periodBLabel,
    required this.periodA,
    required this.periodB,
  });

  /// Balance difference (positive = A is better)
  double get balanceDelta =>
      periodA.avgClosingBalance - periodB.avgClosingBalance;

  /// Decision cost difference (negative = A is lower/better)
  double get decisionDelta => periodA.avgDecisionCost - periodB.avgDecisionCost;

  /// Context cost difference (negative = A is lower/better)
  double get contextDelta => periodA.avgContextCost - periodB.avgContextCost;

  /// Recovery difference (positive = A recovers more)
  double get recoveryDelta =>
      periodA.avgRecoveryDeposit - periodB.avgRecoveryDeposit;

  /// Passive drain difference (negative = A has less drain)
  double get drainDelta => periodA.avgPassiveDrain - periodB.avgPassiveDrain;
}

/// Complete pattern report for a user
@immutable
class PatternReport {
  final DateTime generatedAt;
  final int totalDaysAnalyzed;
  final bool isComplete; // Has 30+ days of data

  // Period metrics
  final PeriodMetrics currentWeek;
  final PeriodMetrics previousWeek;
  final PeriodMetrics bestWeek;
  final PeriodMetrics currentMonth;
  final PeriodMetrics? previousMonth; // Null if not enough data

  // Comparisons
  final PeriodComparison weekOverWeek;
  final PeriodComparison currentVsBest;
  final PeriodComparison? monthOverMonth; // Null if not enough data

  // Observed patterns (correlations, not suggestions)
  final List<ObservedPattern> patterns;

  // What was different in positive-balance days vs deficit days
  final PeriodMetrics? positiveDayMetrics;
  final PeriodMetrics? deficitDayMetrics;

  const PatternReport({
    required this.generatedAt,
    required this.totalDaysAnalyzed,
    required this.isComplete,
    required this.currentWeek,
    required this.previousWeek,
    required this.bestWeek,
    required this.currentMonth,
    this.previousMonth,
    required this.weekOverWeek,
    required this.currentVsBest,
    this.monthOverMonth,
    required this.patterns,
    this.positiveDayMetrics,
    this.deficitDayMetrics,
  });

  /// Days until full pattern analysis is available
  int get daysUntilComplete =>
      isComplete ? 0 : patternMinimumDays - totalDaysAnalyzed;

  /// Whether week-over-week comparison is available
  bool get hasWeeklyComparison => totalDaysAnalyzed >= 14;

  /// Whether month-over-month comparison is available
  bool get hasMonthlyComparison => previousMonth != null;
}
