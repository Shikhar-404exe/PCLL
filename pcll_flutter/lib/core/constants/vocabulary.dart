// PCLL Controlled Vocabulary

/// Vocabulary constants for consistent messaging
class PCLLVocabulary {
  PCLLVocabulary._();

  // === BANKING TERMS ===
  static const String balance = 'Balance';
  static const String withdrawal = 'Withdrawal';
  static const String deposit = 'Deposit';
  static const String deficit = 'Deficit';
  static const String surplus = 'Surplus';
  static const String capacity = 'Capacity';
  static const String carryover = 'Carryover';

  // === LOAD TYPES ===
  static const String immediateLoad = 'Immediate Load';
  static const String persistentLoad = 'Persistent Load';
  static const String accumulatedDebt = 'Accumulated Debt';

  // === STATES (for CognitiveState labels) ===
  static const String stateOptimal = 'Optimal';
  static const String stateGood = 'Good';
  static const String stateModerate = 'Moderate';
  static const String stateLowBalance = 'Low Balance';
  static const String stateCritical = 'Critical';

  // === INSIGHT NAMES (approved) ===
  static const String highWithdrawalDay = 'HIGH_WITHDRAWAL_DAY';
  static const String lowRecoveryPattern = 'LOW_RECOVERY_PATTERN';
  static const String deficitDetected = 'DEFICIT_DETECTED';
  static const String consecutiveDeficit = 'CONSECUTIVE_DEFICIT';
  static const String contextOverload = 'CONTEXT_OVERLOAD';
  static const String highDecisionLoad = 'HIGH_DECISION_LOAD'; // NOT "fatigue"
  static const String openLoopAccumulation = 'OPEN_LOOP_ACCUMULATION';
  static const String recoverySuccess = 'RECOVERY_SUCCESS';
  static const String stablePattern = 'STABLE_PATTERN';
  static const String persistentDebtAccumulating =
      'PERSISTENT_DEBT_ACCUMULATING';
  static const String reducedCapacity = 'REDUCED_CAPACITY';
  static const String impairedRecovery = 'IMPAIRED_RECOVERY';

  // === PATTERN OBSERVATION TERMS (approved) ===
  // These are observations, NOT suggestions or prescriptions
  static const String patternReport = 'Pattern Report';
  static const String observedPattern = 'Observed Pattern';
  static const String periodComparison = 'Period Comparison';
  static const String weekOverWeek = 'Week Over Week';
  static const String monthOverMonth = 'Month Over Month';
  static const String associatedWith = 'Associated with'; // NOT "caused by"
  static const String positiveDays = 'Positive-balance days';
  static const String deficitDays = 'Deficit days';
  static const String retrospective = 'Retrospective';
  static const String correlation = 'Correlation'; // NOT "prediction"
}
