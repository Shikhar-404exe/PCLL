// Ledger Provider - State Management

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/insight_service.dart';
import '../services/calibration_service.dart';
import '../services/pattern_observation_service.dart';

class LedgerProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final InsightService _insightService = InsightService();
  final CalibrationService _calibrationService = CalibrationService();
  final PatternObservationService _patternService = PatternObservationService();

  // Current state
  List<LedgerEntry> _entries = [];
  LedgerEntry? _todayEntry;
  WeeklyTrends? _weeklyTrends;
  Insight? _todayInsight;
  List<Insight> _weeklyInsights = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Pattern observation state
  PatternReport? _patternReport;

  // Calibration state
  CalibrationProfile _calibration = const CalibrationProfile();

  // Profile modifiers (set by ProfileProvider integration)
  double _baselineLoadModifier = 1.0;
  double _recoveryModifier = 1.0;

  // Getters
  List<LedgerEntry> get entries => _entries;
  LedgerEntry? get todayEntry => _todayEntry;
  WeeklyTrends? get weeklyTrends => _weeklyTrends;
  Insight? get todayInsight => _todayInsight;
  List<Insight> get weeklyInsights => _weeklyInsights;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Pattern observation getters
  PatternReport? get patternReport => _patternReport;
  bool get hasPatternReport => _patternReport != null;
  bool get isPatternReportComplete => _patternReport?.isComplete ?? false;
  int get daysUntilPatternReport =>
      _patternReport?.daysUntilComplete ??
      (patternMinimumDays - _entries.length);

  // Calibration getters
  CalibrationProfile get calibration => _calibration;
  CalibrationStatus get calibrationStatus => _calibration.status;
  bool get isCalibrated => _calibration.status == CalibrationStatus.complete;
  int get calibrationDaysRemaining => _calibration.daysRemaining;

  double get currentBalance => _todayEntry?.closingBalance ?? 100.0;
  CognitiveState get currentState => CognitiveState.fromBalance(currentBalance);

  // Profile modifier setters
  void setProfileModifiers({
    required double baselineLoadModifier,
    required double recoveryModifier,
  }) {
    _baselineLoadModifier = baselineLoadModifier;
    _recoveryModifier = recoveryModifier;
    notifyListeners();
  }

  double get baselineLoadModifier => _baselineLoadModifier;
  double get recoveryModifier => _recoveryModifier;

  // ==========================================================================
  // DAILY RESET RULES (Core PCLL Model Constants)
  // ==========================================================================

  /// Maximum daily cognitive capacity - you start each day with at most this
  static const double maxDailyCapacity = 100.0;

  /// Unused CU does NOT carry forward (surplus is lost)
  /// This prevents "banking" energy and mirrors real biology
  static const bool surplusCarriesForward = false;

  /// Deficits PARTIALLY carry forward (40% = middle of 30-50% range)
  /// This models how cognitive deficit accumulates but partially recovers
  static const double deficitCarryoverRate = 0.40;

  /// Maximum deficit that can carry forward (prevents runaway debt)
  static const double maxDeficitCarryover = -50.0;

  // ==========================================================================
  // COST CONSTANTS
  // ==========================================================================
  static const double contextBaseCost = 2.0;
  static const double contextSwitchCost = 1.5;
  static const double decisionBaseCost = 8.0;
  static const double focusWorkCostPerHour = 5.0;
  static const double unresolvedDrainRate = 1.5;
  static const double avoidedDecisionRate = 2.0;
  static const double recoveryBase = 40.0;
  static const double persistentDebtCarryRate = 0.75;

  // ==========================================================================
  // ASYMMETRIC RECOVERY RULES
  // ==========================================================================
  // Recovery is NOT symmetric with load - this is what makes the model realistic
  //
  // When balance > 0: Recovery is efficient (100% effectiveness)
  // When balance < 0: Recovery effectiveness is reduced (harder to climb out)
  // Recovery cannot instantly erase multi-day debt
  //
  // This models:
  // - It's easier to maintain balance than to recover from deficit
  // - Deep deficits require sustained recovery, not a single good day
  // - Prevention is more effective than cure

  /// Recovery effectiveness when in positive balance (100%)
  static const double recoveryEfficiencyPositive = 1.0;

  /// Recovery effectiveness when in deficit (50% - much harder to recover)
  static const double recoveryEfficiencyDeficit = 0.5;

  /// Additional penalty per 20 CU of deficit depth (deeper = harder)
  static const double recoveryPenaltyPerDeficitTier = 0.1;

  /// Minimum recovery effectiveness (floor at 30%, never completely useless)
  static const double recoveryEfficiencyFloor = 0.3;

  /// Maximum CU that can be recovered in a single day (prevents instant cure)
  static const double maxDailyRecovery = 60.0;

  // Initialize - load from database or generate demo data
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Load entries from database
      _entries = await _db.getAllEntries();

      if (_entries.isEmpty) {
        // First time - generate demo week for new users
        debugPrint('No entries found, generating demo data');
        final demoEntries = _generateDemoWeek();
        for (final entry in demoEntries) {
          await _db.insertEntry(entry);
        }
        _entries = demoEntries;
      } else {
        debugPrint('Loaded ${_entries.length} entries from database');
      }

      // Load and update calibration
      await _updateCalibration();

      // Find today's entry
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _todayEntry = _entries.where((e) => e.date == today).firstOrNull;

      // If no entry today, use the latest
      if (_todayEntry == null && _entries.isNotEmpty) {
        _todayEntry = _entries.last;
      }

      _weeklyTrends = _calculateWeeklyTrends();

      // Generate insights
      _generateInsights();

      // Generate pattern report (if enough data)
      _updatePatternReport();
    } catch (e) {
      debugPrint('Error initializing ledger: $e');
      // Fallback to demo data in memory
      _entries = _generateDemoWeek();
      _todayEntry = _entries.isNotEmpty ? _entries.last : null;
      _weeklyTrends = _calculateWeeklyTrends();
      _generateInsights();
      _updatePatternReport();
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // Add new daily entry
  Future<LedgerEntry> addDailyEntry(DailyInput input) async {
    final previousClosing =
        _entries.isNotEmpty ? _entries.last.closingBalance : null;

    final entry = _calculateEntry(input, previousClosing);

    // Save to database
    try {
      await _db.insertEntry(entry);
      await _db.insertDailyInput(input);
      debugPrint('Entry saved to database: ${entry.date}');

      // Update calibration with new entry
      await _updateCalibration();
    } catch (e) {
      debugPrint('Error saving entry: $e');
    }

    // Update in-memory state
    // Check if entry for this date already exists
    final existingIndex = _entries.indexWhere((e) => e.date == entry.date);
    if (existingIndex >= 0) {
      _entries[existingIndex] = entry;
    } else {
      _entries.add(entry);
      // Keep sorted by date
      _entries.sort((a, b) => a.date.compareTo(b.date));
    }

    _todayEntry = entry;
    _weeklyTrends = _calculateWeeklyTrends();

    // Generate insights for the new entry
    _generateInsights();

    // Update pattern report
    _updatePatternReport();

    notifyListeners();
    return entry;
  }

  // Update existing daily entry
  Future<LedgerEntry> updateEntry(String date, DailyInput newInput) async {
    // Find the entry index
    final entryIndex = _entries.indexWhere((e) => e.date == date);
    if (entryIndex == -1) {
      throw Exception('Entry not found for date: $date');
    }

    // Get previous day's closing balance
    double? previousClosing;
    if (entryIndex > 0) {
      previousClosing = _entries[entryIndex - 1].closingBalance;
    }

    // Recalculate the entry with new input
    final updatedEntry = _calculateEntry(newInput, previousClosing);

    // Update in database
    try {
      await _db.updateEntry(updatedEntry);
      await _db.updateDailyInput(newInput);
      debugPrint('Entry updated in database: $date');

      // Update calibration
      await _updateCalibration();
    } catch (e) {
      debugPrint('Error updating entry: $e');
      rethrow;
    }

    // Update in-memory list
    _entries[entryIndex] = updatedEntry;

    // Recalculate all subsequent entries (chain reaction)
    for (int i = entryIndex + 1; i < _entries.length; i++) {
      final previousEntry = _entries[i - 1];
      // Get input from database for this entry
      final input = await _db.getDailyInputByDate(_entries[i].date);
      if (input != null) {
        _entries[i] = _calculateEntry(input, previousEntry.closingBalance);

        // Update in database
        try {
          await _db.updateEntry(_entries[i]);
        } catch (e) {
          debugPrint('Error updating subsequent entry: $e');
        }
      }
    }

    // Update current state if editing today
    if (date == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      _todayEntry = updatedEntry;
    }

    // Recalculate insights and trends
    _weeklyTrends = _calculateWeeklyTrends();
    _generateInsights();
    _updatePatternReport();

    notifyListeners();
    return updatedEntry;
  }

  // Get daily input by date
  Future<DailyInput?> getDailyInputByDate(String date) async {
    return await _db.getDailyInputByDate(date);
  }

  // Calculate ledger entry from input with Immediate vs Persistent load split
  LedgerEntry _calculateEntry(DailyInput input, double? previousClosing) {
    // Get previous entry to calculate carried debt
    final previousEntry = _entries.isNotEmpty ? _entries.last : null;
    final previousDebt = previousEntry?.carryForwardDebt ?? 0;

    // Opening balance (deficit still carries over)
    final opening = _calculateOpeningBalance(previousClosing);

    // === IMMEDIATE LOAD (same-day costs only) ===
    final contextCost = _calculateContextCost(input.contextCount);
    final decisionCost = _calculateDecisionCost(input.decisionCount);
    final focusWorkCost = _calculateFocusWorkCost(input.focusHours);
    final immediateLoad = contextCost + decisionCost + focusWorkCost;

    // === PERSISTENT LOAD (costs every day until resolved) ===
    final unresolvedDrain = _calculateUnresolvedDrain(input.unresolvedCount);
    final avoidedDecisions = _calculateAvoidedDecisions(input.avoidedCount);
    final accumulatedDebt = previousDebt; // Carried from yesterday
    final persistentLoad = unresolvedDrain + avoidedDecisions + accumulatedDebt;

    // Calculate pre-recovery balance to determine recovery effectiveness
    final totalWithdrawals = immediateLoad + persistentLoad;
    final preRecoveryBalance = opening - totalWithdrawals;

    // === ASYMMETRIC RECOVERY ===
    // Recovery effectiveness depends on current balance state
    final recoveryDeposit = _calculateAsymmetricRecovery(
      quality: input.recoveryQuality,
      currentBalance: preRecoveryBalance,
    );

    // Build component breakdown
    final components = ComponentBreakdown(
      // Immediate
      contextCost: contextCost,
      decisionCost: decisionCost,
      focusWorkCost: focusWorkCost,
      // Persistent
      unresolvedDrain: unresolvedDrain,
      avoidedDecisions: avoidedDecisions,
      accumulatedDebt: accumulatedDebt,
      // Recovery
      recoveryDeposit: recoveryDeposit,
    );

    final totalDeposits = recoveryDeposit;
    final closing = opening - totalWithdrawals + totalDeposits;

    // Calculate debt that carries to tomorrow
    // Only TODAY's unresolved items carry forward (not already accumulated)
    final todayNewDebt = unresolvedDrain + avoidedDecisions;
    final carryForward = todayNewDebt * persistentDebtCarryRate;

    return LedgerEntry(
      date: input.date,
      openingBalance: opening,
      closingBalance: closing,
      totalWithdrawals: totalWithdrawals,
      totalDeposits: totalDeposits,
      netChange: totalDeposits - totalWithdrawals,
      cognitiveState: CognitiveState.fromBalance(closing),
      components: components,
      createdAt: DateTime.now(),
      // NEW: Load type tracking
      immediateLoad: immediateLoad,
      persistentDebt: persistentLoad,
      carryForwardDebt: carryForward,
      unresolvedItems: input.unresolvedCount,
      avoidedDecisions: input.avoidedCount,
    );
  }

  /// Calculate opening balance with PCLL daily reset rules:
  ///
  /// 1. Max capacity = 100 CU (you can't start above this)
  /// 2. Surplus does NOT carry (if you ended at +120, you still start at 100)
  /// 3. Deficits PARTIALLY carry (40% of negative balance reduces tomorrow's start)
  ///
  /// Examples:
  /// - Previous: +50  → Opens at 100 (surplus lost, fresh start)
  /// - Previous: +120 → Opens at 100 (surplus lost, can't bank energy)
  /// - Previous: -20  → Opens at 92  (100 + (-20 * 0.40) = 92)
  /// - Previous: -80  → Opens at 68  (100 + (-80 * 0.40) = 68)
  /// - Previous: -150 → Opens at 80  (capped at maxDeficitCarryover of -50)
  double _calculateOpeningBalance(double? previousClosing) {
    // First day or no previous data - start at full capacity
    if (previousClosing == null) return maxDailyCapacity;

    // RULE: Surplus does NOT carry forward
    // This prevents gaming and mirrors real cognitive recovery
    if (previousClosing >= 0) return maxDailyCapacity;

    // RULE: Deficits PARTIALLY carry forward
    // Cap the deficit to prevent runaway debt spiral
    final cappedDeficit = previousClosing < maxDeficitCarryover
        ? maxDeficitCarryover
        : previousClosing;

    // Apply partial carryover (e.g., 40% of deficit reduces opening)
    final deficitPenalty = cappedDeficit * deficitCarryoverRate;

    return maxDailyCapacity + deficitPenalty;
  }

  // === IMMEDIATE LOAD CALCULATIONS ===
  // These now apply both profile modifiers AND calibration factors

  double _calculateContextCost(int count) {
    if (count <= 0) return 0;
    final base = count * contextBaseCost;
    final switches = (count - 1) * contextSwitchCost;
    var total = base + switches;
    if (count >= 10) total *= 1.2; // High load penalty
    // Apply profile baseline load modifier
    total *= _baselineLoadModifier;
    // Apply calibration factor (±20% based on personal patterns)
    total *= _calibration.contextCostFactor;
    return double.parse(total.toStringAsFixed(1));
  }

  double _calculateDecisionCost(int count) {
    if (count <= 0) return 0;
    var cost = count * decisionBaseCost;
    if (count > 20) {
      cost *= 1.3;
    } else if (count > 10) {
      cost *= 1.15;
    }
    // Apply profile baseline load modifier
    cost *= _baselineLoadModifier;
    // Apply calibration factor (±20% based on personal patterns)
    cost *= _calibration.decisionCostFactor;
    return double.parse(cost.toStringAsFixed(1));
  }

  double _calculateFocusWorkCost(int hours) {
    if (hours <= 0) return 0;
    var cost = hours * focusWorkCostPerHour;
    // Long focus sessions have diminishing returns on effort
    if (hours > 6) cost *= 1.3; // Overtime penalty
    cost *= _baselineLoadModifier;
    return double.parse(cost.toStringAsFixed(1));
  }

  // === PERSISTENT LOAD CALCULATIONS ===

  double _calculateUnresolvedDrain(int count) {
    if (count <= 0) return 0;
    // Persistent items cost MORE than immediate because they linger
    var drain = count * unresolvedDrainRate * _baselineLoadModifier;
    // Stacking penalty: many open loops compound persistent load
    if (count > 5) drain *= 1.2;
    if (count > 10) drain *= 1.3;
    return double.parse(drain.toStringAsFixed(1));
  }

  double _calculateAvoidedDecisions(int count) {
    if (count <= 0) return 0;
    // Avoided decisions are costly because they keep cycling in your mind
    var drain = count * avoidedDecisionRate * _baselineLoadModifier;
    return double.parse(drain.toStringAsFixed(1));
  }

  // === LEGACY ===

  @Deprecated('Use _calculateUnresolvedDrain instead')
  double _calculatePassiveDrain(int count) {
    return _calculateUnresolvedDrain(count);
  }

  // === RECOVERY (ASYMMETRIC) ===

  /// Calculate recovery with asymmetric effectiveness based on balance state.
  ///
  /// Key insight: Recovery is NOT symmetric with load.
  /// - When healthy (balance > 0): Recovery is efficient
  /// - When in deficit (balance < 0): Recovery is impaired
  /// - Deeper deficits = even harder to recover
  /// - Cannot instantly erase multi-day debt
  ///
  /// This models real cognitive load patterns where:
  /// - Prevention is easier than cure
  /// - Sustained deficit requires sustained recovery, not a quick fix
  double _calculateAsymmetricRecovery({
    required int quality,
    required double currentBalance,
  }) {
    // Base recovery calculation
    final factor = quality / 5.0;
    var baseRecovery = recoveryBase * factor * _recoveryModifier;

    // Determine recovery effectiveness based on balance state
    double effectiveness;

    if (currentBalance >= 0) {
      // POSITIVE BALANCE: Full recovery effectiveness
      effectiveness = recoveryEfficiencyPositive;
    } else {
      // DEFICIT: Reduced recovery effectiveness
      // Start at 50% efficiency when in any deficit
      effectiveness = recoveryEfficiencyDeficit;

      // Additional penalty for deeper deficits (per 20 CU tier)
      // -20 CU = -10% more, -40 CU = -20% more, etc.
      final deficitDepth = currentBalance.abs();
      final deficitTiers = (deficitDepth / 20).floor();
      effectiveness -= deficitTiers * recoveryPenaltyPerDeficitTier;

      // Floor at minimum effectiveness (never completely useless)
      if (effectiveness < recoveryEfficiencyFloor) {
        effectiveness = recoveryEfficiencyFloor;
      }
    }

    // Apply effectiveness modifier
    var actualRecovery = baseRecovery * effectiveness;

    // Apply calibration factor (±20% based on personal recovery patterns)
    actualRecovery *= _calibration.recoveryFactor;

    // Cap maximum daily recovery (prevents instant cure of multi-day debt)
    if (actualRecovery > maxDailyRecovery) {
      actualRecovery = maxDailyRecovery;
    }

    return double.parse(actualRecovery.toStringAsFixed(1));
  }

  /// Legacy recovery calculation (for backwards compatibility)
  @Deprecated('Use _calculateAsymmetricRecovery instead')
  double _calculateRecoveryDeposit(int quality) {
    final factor = quality / 5.0;
    // Apply profile recovery modifier
    var recovery = recoveryBase * factor * _recoveryModifier;
    return double.parse(recovery.toStringAsFixed(1));
  }

  // ==========================================================================
  // CALIBRATION
  // ==========================================================================

  /// Update calibration based on current entries
  /// Called after loading entries and after adding new entries
  Future<void> _updateCalibration() async {
    try {
      _calibration = await _calibrationService.calibrateFromEntries(_entries);

      if (_calibration.status == CalibrationStatus.complete) {
        debugPrint('Calibration complete: '
            'decision=${_calibration.decisionCostFactor.toStringAsFixed(2)}, '
            'context=${_calibration.contextCostFactor.toStringAsFixed(2)}, '
            'recovery=${_calibration.recoveryFactor.toStringAsFixed(2)}');
      } else if (_calibration.status == CalibrationStatus.inProgress) {
        debugPrint('Calibration in progress: '
            '${_calibration.daysCalibrated}/7 days '
            '(${_calibration.daysRemaining} remaining)');
      }
    } catch (e) {
      debugPrint('Error updating calibration: $e');
    }
  }

  /// Reset calibration (for testing or user request)
  Future<void> resetCalibration() async {
    await _calibrationService.resetCalibration();
    _calibration = const CalibrationProfile();
    notifyListeners();
  }

  // ==========================================================================
  // WEEKLY TRENDS
  // ==========================================================================

  WeeklyTrends? _calculateWeeklyTrends() {
    if (_entries.length < 3) return null;

    final recent =
        _entries.length > 7 ? _entries.sublist(_entries.length - 7) : _entries;

    final avgOpening =
        recent.map((e) => e.openingBalance).reduce((a, b) => a + b) /
            recent.length;
    final avgClosing =
        recent.map((e) => e.closingBalance).reduce((a, b) => a + b) /
            recent.length;
    final avgWithdrawals =
        recent.map((e) => e.totalWithdrawals).reduce((a, b) => a + b) /
            recent.length;
    final avgDeposits =
        recent.map((e) => e.totalDeposits).reduce((a, b) => a + b) /
            recent.length;
    final deficitDays = recent.where((e) => e.closingBalance < 0).length;
    final recoveryRatio =
        avgWithdrawals > 0 ? avgDeposits / avgWithdrawals : 1.0;

    // Calculate slope
    final balances = recent.map((e) => e.closingBalance).toList();
    final slope = _calculateSlope(balances);

    return WeeklyTrends(
      avgOpeningBalance: avgOpening,
      avgClosingBalance: avgClosing,
      avgWithdrawals: avgWithdrawals,
      avgDeposits: avgDeposits,
      deficitDays: deficitDays,
      recoveryRatio: recoveryRatio,
      trendDirection: _determineTrend(slope),
      balanceSlope: slope,
      daysAnalyzed: recent.length,
      startDate: recent.first.date,
      endDate: recent.last.date,
    );
  }

  double _calculateSlope(List<double> values) {
    if (values.length < 2) return 0;
    final n = values.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }
    final denominator = n * sumXX - sumX * sumX;
    if (denominator == 0) return 0;
    return (n * sumXY - sumX * sumY) / denominator;
  }

  TrendDirection _determineTrend(double slope) {
    if (slope <= -5) return TrendDirection.deteriorating;
    if (slope < -1) return TrendDirection.declining;
    if (slope <= 1) return TrendDirection.stable;
    if (slope < 5) return TrendDirection.improving;
    return TrendDirection.rapidlyImproving;
  }

  /// Generate insights based on current entries and trends
  void _generateInsights() {
    if (_todayEntry == null) {
      _todayInsight = null;
      _weeklyInsights = [];
      return;
    }

    // Get recent entries for context (excluding today)
    final recentEntries = _entries.length > 1
        ? _entries.sublist(0, _entries.length - 1)
        : <LedgerEntry>[];

    // Generate today's insight
    _todayInsight = _insightService.generateDailyInsight(
      entry: _todayEntry!,
      recentEntries: recentEntries,
      trends: _weeklyTrends,
    );

    // Generate weekly insights if we have trends
    if (_weeklyTrends != null && _entries.isNotEmpty) {
      final recent = _entries.length > 7
          ? _entries.sublist(_entries.length - 7)
          : _entries;
      _weeklyInsights = _insightService.generateWeeklyInsights(
        entries: recent,
        trends: _weeklyTrends!,
      );
    } else {
      _weeklyInsights = [];
    }

    debugPrint(
        'Generated ${_weeklyInsights.length} insights, today: ${_todayInsight?.ruleName}');
  }

  List<LedgerEntry> _generateDemoWeek() {
    // Demo data showing a realistic week with PCLL patterns
    // Includes: progressive load buildup, debt accumulation, then recovery
    final inputs = [
      // Monday: Normal start
      DailyInput(
        date: '2025-12-09',
        contextCount: 5,
        decisionCount: 8,
        focusHours: 4,
        unresolvedCount: 3,
        avoidedCount: 1,
        recoveryQuality: 6,
      ),
      // Tuesday: Load increasing
      DailyInput(
        date: '2025-12-10',
        contextCount: 7,
        decisionCount: 12,
        focusHours: 6,
        unresolvedCount: 5,
        avoidedCount: 2,
        recoveryQuality: 5,
      ),
      // Wednesday: Heavy day, open loops accumulating
      DailyInput(
        date: '2025-12-11',
        contextCount: 10,
        decisionCount: 15,
        focusHours: 8,
        unresolvedCount: 8,
        avoidedCount: 3,
        recoveryQuality: 4,
      ),
      // Thursday: Deep deficit territory - high persistent load
      DailyInput(
        date: '2025-12-12',
        contextCount: 12,
        decisionCount: 20,
        focusHours: 9,
        unresolvedCount: 12,
        avoidedCount: 5,
        recoveryQuality: 3,
      ),
      // Friday: Slightly lighter but debt still accumulating
      DailyInput(
        date: '2025-12-13',
        contextCount: 6,
        decisionCount: 8,
        focusHours: 5,
        unresolvedCount: 10,
        avoidedCount: 4,
        recoveryQuality: 5,
      ),
      // Saturday: Recovery day - closing loops
      DailyInput(
        date: '2025-12-14',
        contextCount: 2,
        decisionCount: 3,
        focusHours: 2,
        unresolvedCount: 5,
        avoidedCount: 1,
        recoveryQuality: 8,
      ),
      // Sunday: Full recovery
      DailyInput(
        date: '2025-12-15',
        contextCount: 1,
        decisionCount: 2,
        focusHours: 0,
        unresolvedCount: 2,
        avoidedCount: 0,
        recoveryQuality: 9,
      ),
    ];

    final entries = <LedgerEntry>[];
    double? previousClosing;

    for (final input in inputs) {
      final entry = _calculateEntry(input, previousClosing);
      entries.add(entry);
      previousClosing = entry.closingBalance;
    }

    return entries;
  }

  // Get entries for a date range
  List<LedgerEntry> getEntriesInRange(DateTime start, DateTime end) {
    return _entries.where((e) {
      final date = DateTime.parse(e.date);
      return date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Clear all data from memory and database
  Future<void> clearAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.clearAllData();
      debugPrint('Database cleared');
    } catch (e) {
      debugPrint('Error clearing database: $e');
    }

    _entries = [];
    _todayEntry = null;
    _weeklyTrends = null;
    _todayInsight = null;
    _weeklyInsights = [];
    _patternReport = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Reload entries from database
  Future<void> reload() async {
    _isInitialized = false;
    await initialize();
  }

  // ==========================================================================
  // PATTERN OBSERVATION
  // ==========================================================================

  /// Update pattern report from current entries
  void _updatePatternReport() {
    _patternReport = _patternService.generateReport(_entries);

    if (_patternReport != null) {
      if (_patternReport!.isComplete) {
        debugPrint(
          'Pattern report complete: ${_patternReport!.patterns.length} patterns found',
        );
      } else {
        debugPrint(
          'Pattern report partial: ${_patternReport!.daysUntilComplete} days until complete',
        );
      }
    }
  }

  /// Force regenerate pattern report
  void refreshPatternReport() {
    _updatePatternReport();
    notifyListeners();
  }
}
