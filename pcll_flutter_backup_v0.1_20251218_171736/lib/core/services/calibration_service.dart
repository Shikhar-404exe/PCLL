/*
 * Calibration Service
 * ====================
 * 
 * Adapts the PCLL model to individual patterns through calibration.
 * 
 * How it works:
 * - First 7 days = calibration period
 * - System learns typical patterns (decision load, context switches, recovery)
 * - Adjusts CU weights slightly (±20%) based on personal baseline
 * - Keeps the system personal WITHOUT comparing users
 * 
 * This is NOT about making it "easier" or "harder" - it's about
 * accurately reflecting each individual's cognitive patterns.
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Calibration status
enum CalibrationStatus {
  notStarted, // No entries yet
  inProgress, // 1-6 days of data
  complete, // 7+ days, calibration calculated
}

/// Personal calibration factors learned from user's patterns
@immutable
class CalibrationProfile {
  /// Number of days used for calibration
  final int daysCalibrated;

  /// User's typical daily decision count (average)
  final double typicalDecisionLoad;

  /// User's typical daily context switches (average)
  final double typicalContextLoad;

  /// User's typical focus hours (average)
  final double typicalFocusHours;

  /// User's typical unresolved items (average)
  final double typicalUnresolvedCount;

  /// User's typical recovery quality (average 1-10)
  final double typicalRecoveryQuality;

  /// User's typical recovery effectiveness (deposit/withdrawal ratio)
  final double typicalRecoveryRatio;

  // Derived adjustment factors (±20% range, centered at 1.0)

  /// Decision cost adjustment (1.0 = baseline, <1.0 = user handles more, >1.0 = fewer)
  final double decisionCostFactor;

  /// Context cost adjustment
  final double contextCostFactor;

  /// Recovery effectiveness adjustment
  final double recoveryFactor;

  /// When calibration was completed
  final DateTime? calibratedAt;

  const CalibrationProfile({
    this.daysCalibrated = 0,
    this.typicalDecisionLoad = 10.0,
    this.typicalContextLoad = 5.0,
    this.typicalFocusHours = 4.0,
    this.typicalUnresolvedCount = 3.0,
    this.typicalRecoveryQuality = 5.0,
    this.typicalRecoveryRatio = 0.5,
    this.decisionCostFactor = 1.0,
    this.contextCostFactor = 1.0,
    this.recoveryFactor = 1.0,
    this.calibratedAt,
  });

  CalibrationStatus get status {
    if (daysCalibrated == 0) return CalibrationStatus.notStarted;
    if (daysCalibrated < 7) return CalibrationStatus.inProgress;
    return CalibrationStatus.complete;
  }

  int get daysRemaining =>
      status == CalibrationStatus.inProgress ? 7 - daysCalibrated : 0;

  Map<String, dynamic> toJson() => {
        'days_calibrated': daysCalibrated,
        'typical_decision_load': typicalDecisionLoad,
        'typical_context_load': typicalContextLoad,
        'typical_focus_hours': typicalFocusHours,
        'typical_unresolved_count': typicalUnresolvedCount,
        'typical_recovery_quality': typicalRecoveryQuality,
        'typical_recovery_ratio': typicalRecoveryRatio,
        'decision_cost_factor': decisionCostFactor,
        'context_cost_factor': contextCostFactor,
        'recovery_factor': recoveryFactor,
        'calibrated_at': calibratedAt?.toIso8601String(),
      };

  factory CalibrationProfile.fromJson(Map<String, dynamic> json) {
    return CalibrationProfile(
      daysCalibrated: json['days_calibrated'] as int? ?? 0,
      typicalDecisionLoad:
          (json['typical_decision_load'] as num?)?.toDouble() ?? 10.0,
      typicalContextLoad:
          (json['typical_context_load'] as num?)?.toDouble() ?? 5.0,
      typicalFocusHours:
          (json['typical_focus_hours'] as num?)?.toDouble() ?? 4.0,
      typicalUnresolvedCount:
          (json['typical_unresolved_count'] as num?)?.toDouble() ?? 3.0,
      typicalRecoveryQuality:
          (json['typical_recovery_quality'] as num?)?.toDouble() ?? 5.0,
      typicalRecoveryRatio:
          (json['typical_recovery_ratio'] as num?)?.toDouble() ?? 0.5,
      decisionCostFactor:
          (json['decision_cost_factor'] as num?)?.toDouble() ?? 1.0,
      contextCostFactor:
          (json['context_cost_factor'] as num?)?.toDouble() ?? 1.0,
      recoveryFactor: (json['recovery_factor'] as num?)?.toDouble() ?? 1.0,
      calibratedAt: json['calibrated_at'] != null
          ? DateTime.parse(json['calibrated_at'] as String)
          : null,
    );
  }
}

/// Service for managing calibration
class CalibrationService {
  static const String _calibrationKey = 'pcll_calibration_profile';

  // Reference values (population baseline assumptions)
  // These are the "average" values we compare user's patterns against
  static const double _referenceDecisionLoad = 10.0;
  static const double _referenceContextLoad = 5.0;
  static const double _referenceFocusHours = 4.0;
  static const double _referenceRecoveryRatio = 0.5;

  // Adjustment limits (±20% from baseline)
  static const double _minFactor = 0.8;
  static const double _maxFactor = 1.2;

  // Minimum days required for calibration
  static const int calibrationDays = 7;

  CalibrationProfile? _cachedProfile;

  /// Load calibration profile from storage
  Future<CalibrationProfile> loadProfile() async {
    if (_cachedProfile != null) return _cachedProfile!;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_calibrationKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _cachedProfile = CalibrationProfile.fromJson(json);
        return _cachedProfile!;
      }
    } catch (e) {
      debugPrint('Error loading calibration profile: $e');
    }

    return const CalibrationProfile();
  }

  /// Save calibration profile to storage
  Future<void> saveProfile(CalibrationProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile.toJson());
      await prefs.setString(_calibrationKey, jsonString);
      _cachedProfile = profile;
      debugPrint('Calibration profile saved: ${profile.status.name}');
    } catch (e) {
      debugPrint('Error saving calibration profile: $e');
    }
  }

  /// Calculate calibration from entries
  /// Call this after adding new entries to update calibration
  Future<CalibrationProfile> calibrateFromEntries(
      List<LedgerEntry> entries) async {
    if (entries.isEmpty) {
      return const CalibrationProfile();
    }

    final daysCount = entries.length;

    // Calculate averages from all entries
    double totalDecisions = 0;
    double totalContexts = 0;
    double totalFocusHours = 0;
    double totalUnresolved = 0;
    double totalRecoveryQuality = 0;
    double totalWithdrawals = 0;
    double totalDeposits = 0;

    for (final entry in entries) {
      // Extract from components
      final components = entry.components;

      // Estimate original inputs from costs (reverse engineering)
      // This is approximate but good enough for calibration
      totalDecisions += components.decisionCost / 8.0; // Base cost per decision
      totalContexts += components.contextCost / 3.5; // Approximate per context
      totalFocusHours += components.focusWorkCost / 5.0; // Per hour
      totalUnresolved += entry.unresolvedItems.toDouble();

      // Recovery quality estimate (reverse from deposit)
      final estimatedQuality =
          (components.recoveryDeposit / 8.0).clamp(1.0, 10.0);
      totalRecoveryQuality += estimatedQuality;

      totalWithdrawals += entry.totalWithdrawals;
      totalDeposits += entry.totalDeposits;
    }

    // Calculate averages
    final avgDecisions = totalDecisions / daysCount;
    final avgContexts = totalContexts / daysCount;
    final avgFocusHours = totalFocusHours / daysCount;
    final avgUnresolved = totalUnresolved / daysCount;
    final avgRecoveryQuality = totalRecoveryQuality / daysCount;
    final avgRecoveryRatio =
        totalWithdrawals > 0 ? totalDeposits / totalWithdrawals : 0.5;

    // Calculate adjustment factors (only if we have enough data)
    double decisionFactor = 1.0;
    double contextFactor = 1.0;
    double recoveryFactor = 1.0;

    if (daysCount >= calibrationDays) {
      // Decision factor: If user makes MORE decisions than reference but
      // maintains balance, they're more efficient -> lower cost per decision
      // If user makes FEWER decisions but still shows deficit -> higher cost
      decisionFactor = _calculateFactor(avgDecisions, _referenceDecisionLoad);

      // Context factor: Similar logic
      contextFactor = _calculateFactor(avgContexts, _referenceContextLoad);

      // Recovery factor: If user recovers better than reference -> boost recovery
      // If user recovers worse -> reduce recovery effectiveness
      recoveryFactor =
          _calculateRecoveryFactor(avgRecoveryRatio, _referenceRecoveryRatio);
    }

    final profile = CalibrationProfile(
      daysCalibrated: daysCount,
      typicalDecisionLoad: avgDecisions,
      typicalContextLoad: avgContexts,
      typicalFocusHours: avgFocusHours,
      typicalUnresolvedCount: avgUnresolved,
      typicalRecoveryQuality: avgRecoveryQuality,
      typicalRecoveryRatio: avgRecoveryRatio,
      decisionCostFactor: decisionFactor,
      contextCostFactor: contextFactor,
      recoveryFactor: recoveryFactor,
      calibratedAt: daysCount >= calibrationDays ? DateTime.now() : null,
    );

    await saveProfile(profile);
    return profile;
  }

  /// Calculate adjustment factor for load metrics
  /// Higher user load than reference = more resilient = lower cost factor
  double _calculateFactor(double userAvg, double reference) {
    if (userAvg <= 0 || reference <= 0) return 1.0;

    // Ratio: how does user compare to reference?
    final ratio = userAvg / reference;

    // Invert: if user handles more load, reduce their cost per unit
    // If user handles less, increase their cost per unit
    // Using inverse square root for smooth adjustment
    double factor = 1.0 / (ratio.clamp(0.5, 2.0));

    // Normalize to center at 1.0 and limit to ±20%
    factor = ((factor - 1.0) * 0.4) + 1.0; // Dampen the effect

    return factor.clamp(_minFactor, _maxFactor);
  }

  /// Calculate recovery factor
  /// Better recovery than reference = boost, worse = reduce
  double _calculateRecoveryFactor(double userRatio, double referenceRatio) {
    if (referenceRatio <= 0) return 1.0;

    // Direct ratio comparison
    final comparison = userRatio / referenceRatio;

    // Scale to ±20% range
    double factor = ((comparison - 1.0) * 0.4) + 1.0;

    return factor.clamp(_minFactor, _maxFactor);
  }

  /// Reset calibration (for testing or user request)
  Future<void> resetCalibration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_calibrationKey);
      _cachedProfile = null;
      debugPrint('Calibration reset');
    } catch (e) {
      debugPrint('Error resetting calibration: $e');
    }
  }
}
