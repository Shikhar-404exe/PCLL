/*
 * PCLL Controlled Vocabulary
 * ===========================
 * 
 * This file defines the ONLY allowed terminology for the PCLL system.
 * Using controlled vocabulary protects long-term integrity and ensures
 * the system is NOT confused with clinical/mental health tools.
 * 
 * ============================================================================
 * ALLOWED TERMS (Use These)
 * ============================================================================
 * 
 * BANKING METAPHOR:
 * - Balance        → Current cognitive resource level
 * - Withdrawal     → Cognitive resource consumption
 * - Deposit        → Cognitive resource restoration
 * - Deficit        → Negative balance (withdrawals > deposits)
 * - Surplus        → Positive balance (deposits > withdrawals)
 * - Capacity       → Maximum daily cognitive resources (100 CU)
 * - Carryover      → Balance transfer between days
 * 
 * LOAD TYPES:
 * - Immediate Load → Same-day cognitive costs (context, decisions, focus)
 * - Persistent Load → Multi-day costs (unresolved items, deferred decisions)
 * - Accumulated Debt → Carried forward from previous days
 * 
 * ACTIVITIES:
 * - Context Switch → Changing between different work areas
 * - Decision       → Choice requiring cognitive evaluation
 * - Focus Work     → Concentrated effort (meetings, deep work)
 * - Open Loop      → Unresolved item consuming background resources
 * - Recovery       → Activities that restore balance
 * 
 * STATES:
 * - High Balance   → Abundant resources available
 * - Moderate       → Adequate resources
 * - Low Balance    → Limited resources remaining
 * - In Deficit     → Negative balance, reduced capacity
 * - Critical       → Severe deficit, significantly impaired
 * 
 * PATTERNS:
 * - High Withdrawal Day   → Day with above-normal resource consumption
 * - Low Recovery Pattern  → Insufficient restoration relative to consumption
 * - Consecutive Deficit   → Multiple days ending in negative balance
 * - Reduced Capacity      → Starting day below full 100 CU
 * - Impaired Recovery     → Recovery effectiveness reduced due to deficit
 * 
 * ============================================================================
 * FORBIDDEN TERMS (Never Use)
 * ============================================================================
 * 
 * These terms are PROHIBITED because they imply clinical assessment:
 * 
 * - Fatigue          → Use: "high withdrawal" or "low balance"
 * - Stress           → Use: "high load" or "accumulated deficit"
 * - Burnout          → Use: "sustained deficit" or "critical balance"
 * - Mental health    → Use: "cognitive resources" or just "balance"
 * - Anxiety          → NEVER use
 * - Depression       → NEVER use
 * - Exhaustion       → Use: "deep deficit" or "severely reduced capacity"
 * - Overwhelmed      → Use: "high load" or "capacity exceeded"
 * - Tired            → Use: "low balance" or "reduced recovery"
 * 
 * WHY THIS MATTERS:
 * - PCLL is a resource tracking tool, NOT a health assessment
 * - Clinical terms could be misinterpreted as diagnosis
 * - Banking metaphor is neutral and empowering
 * - Users track patterns, not pathologies
 * 
 * ============================================================================
 */

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
