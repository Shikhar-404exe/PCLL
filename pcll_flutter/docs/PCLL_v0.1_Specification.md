# PCLL v0.1 Specification

## Personal Cognitive Load Ledger - Technical Specification

**Version:** 0.1  
**Date:** December 16, 2025  
**Status:** Implementation Complete

---

## 1. Cognitive Unit (CU) Definition

### 1.1 Core Definition

A **Cognitive Unit (CU)** is an arbitrary metaphorical unit representing a standardized measure of cognitive resource expenditure. CUs are:

- **Not medical or clinical measurements**
- **Not validated for diagnostic purposes**
- **Self-reported estimates** based on user input
- **Relative measures** useful only for personal pattern observation

### 1.2 Daily Capacity

| Parameter          | Value  | Description                              |
| ------------------ | ------ | ---------------------------------------- |
| `maxDailyCapacity` | 100 CU | Maximum cognitive capacity per day       |
| Opening Balance    | 100 CU | Fresh start each morning (if no deficit) |

### 1.3 Base Costs (Reference Values)

| Activity Type                   | Base Cost | Notes                    |
| ------------------------------- | --------- | ------------------------ |
| Low-stakes decision             | 0.5 CU    | Routine choices          |
| Medium-stakes decision          | 2.0 CU    | Requires consideration   |
| High-stakes decision            | 5.0 CU    | Significant consequences |
| Context switch                  | 3.0 CU    | Per switch between tasks |
| Focus work (per hour)           | 8.0 CU    | Deep concentration       |
| Unresolved item (passive drain) | 2.0 CU    | Per open loop            |
| Avoided decision                | 3.0 CU    | Deferred choice          |

---

## 2. Load Categories

### 2.1 Immediate Load

Withdrawals that are **consumed and cleared within the same day**. These do not carry forward.

| Component              | Calculation                                   | Clears At  |
| ---------------------- | --------------------------------------------- | ---------- |
| Decision Cost          | `decisions × baseCost × complexityMultiplier` | End of day |
| Context Switching Cost | `switches × 3.0 CU`                           | End of day |
| Focus Work Cost        | `hours × 8.0 CU`                              | End of day |

**Formula:**

```
immediateLoad = decisionCost + contextCost + focusWorkCost
```

### 2.2 Persistent Load

Withdrawals that **create ongoing cognitive debt** and carry forward to subsequent days.

| Component                        | Calculation                | Behavior                   |
| -------------------------------- | -------------------------- | -------------------------- |
| Passive Drain (Unresolved Items) | `unresolvedItems × 2.0 CU` | Accumulates daily          |
| Avoided Decisions                | `avoidedCount × 3.0 CU`    | Accumulates until resolved |

**Formula:**

```
persistentDebt = passiveDrain + avoidedDecisionsCost
carryForwardDebt = persistentDebt × deficitCarryoverRate
```

### 2.3 Component Breakdown Structure

```dart
class ComponentBreakdown {
  final double decisionCost;      // Immediate
  final double contextCost;       // Immediate
  final double focusWorkCost;     // Immediate
  final double passiveDrain;      // Persistent
  final double avoidedDecisions;  // Persistent (accumulated debt)
  final double recoveryDeposit;   // Restoration
}
```

---

## 3. Carryover Rules

### 3.1 Daily Reset Rules

| Rule                    | Value      | Description                              |
| ----------------------- | ---------- | ---------------------------------------- |
| `surplusCarriesForward` | `false`    | Unused capacity is lost at day end       |
| `deficitCarryoverRate`  | 0.40 (40%) | Fraction of deficit that carries forward |
| `maxDeficitCarryover`   | -50 CU     | Maximum deficit that can carry forward   |

### 3.2 Opening Balance Calculation

```
If previousClosingBalance >= 0:
    openingBalance = maxDailyCapacity (100 CU)
Else:
    carryForward = previousClosingBalance × deficitCarryoverRate
    carryForward = max(carryForward, maxDeficitCarryover)  // Cap at -50
    openingBalance = maxDailyCapacity + carryForward
```

### 3.3 Examples

| Previous Close    | Carryover Calculation | Opening Balance |
| ----------------- | --------------------- | --------------- |
| +20 CU (surplus)  | Surplus lost          | 100 CU          |
| -30 CU (deficit)  | -30 × 0.40 = -12 CU   | 88 CU           |
| -80 CU (severe)   | -80 × 0.40 = -32 CU   | 68 CU           |
| -150 CU (extreme) | Capped at -50 CU      | 50 CU           |

---

## 4. Recovery Rules

### 4.1 Asymmetric Recovery Principle

Recovery effectiveness **depends on current balance state**. Deeper deficits impair recovery efficiency.

### 4.2 Recovery Efficiency Table

| Balance State    | Base Efficiency | Rationale                    |
| ---------------- | --------------- | ---------------------------- |
| Positive (≥0 CU) | 100%            | Full recovery capacity       |
| Deficit (<0 CU)  | 50%             | Impaired restoration         |
| Per 20 CU deeper | -10% additional | Cumulative impairment        |
| Floor            | 30% minimum     | Recovery never fully blocked |

### 4.3 Recovery Calculation

```
function calculateAsymmetricRecovery(rawRecovery, currentBalance):
    if currentBalance >= 0:
        efficiency = 1.0  // 100%
    else:
        efficiency = 0.5  // 50% base for deficit
        deficitTiers = floor(abs(currentBalance) / 20)
        efficiency -= deficitTiers × 0.10
        efficiency = max(efficiency, 0.30)  // Floor at 30%

    effectiveRecovery = rawRecovery × efficiency
    effectiveRecovery = min(effectiveRecovery, maxDailyRecovery)
    return effectiveRecovery
```

### 4.4 Recovery Constants

| Parameter                       | Value | Description                |
| ------------------------------- | ----- | -------------------------- |
| `recoveryEfficiencyPositive`    | 1.0   | 100% when balance positive |
| `recoveryEfficiencyDeficit`     | 0.5   | 50% when in deficit        |
| `recoveryPenaltyPerDeficitTier` | 0.10  | -10% per 20 CU tier        |
| `deficitTierSize`               | 20 CU | Tier threshold             |
| `recoveryEfficiencyFloor`       | 0.30  | Minimum 30% efficiency     |
| `maxDailyRecovery`              | 60 CU | Maximum recovery per day   |

### 4.5 Recovery Examples

| Current Balance | Raw Recovery | Efficiency  | Effective Recovery |
| --------------- | ------------ | ----------- | ------------------ |
| +10 CU          | 40 CU        | 100%        | 40 CU              |
| -10 CU          | 40 CU        | 50%         | 20 CU              |
| -30 CU          | 40 CU        | 40%         | 16 CU              |
| -50 CU          | 40 CU        | 30%         | 12 CU              |
| -70 CU          | 40 CU        | 30% (floor) | 12 CU              |

---

## 5. Calibration Logic

### 5.1 Calibration Period

| Parameter         | Value  | Description                     |
| ----------------- | ------ | ------------------------------- |
| `calibrationDays` | 7 days | Minimum entries for calibration |
| `adjustmentRange` | ±20%   | Maximum factor adjustment       |
| `minAdjustment`   | 0.80   | Lower bound (1 - 0.20)          |
| `maxAdjustment`   | 1.20   | Upper bound (1 + 0.20)          |

### 5.2 Reference Baselines

```dart
static const double _referenceDecisionLoad = 30.0;  // CU
static const double _referenceContextLoad = 15.0;   // CU
static const double _referenceRecoveryRatio = 0.5;  // 50% of withdrawals
```

### 5.3 Calibration Factors

| Factor               | Purpose                       | Adjustment Logic                                     |
| -------------------- | ----------------------------- | ---------------------------------------------------- |
| `decisionCostFactor` | Adjust decision costs         | Higher if user handles fewer decisions for same load |
| `contextCostFactor`  | Adjust context switch costs   | Higher if user handles fewer switches for same load  |
| `recoveryFactor`     | Adjust recovery effectiveness | Higher if user recovers better than reference        |

### 5.4 Factor Calculation

```
function calculateFactor(userAverage, reference):
    if userAverage == 0:
        return 1.0

    ratio = reference / userAverage
    factor = clamp(ratio, minAdjustment, maxAdjustment)
    return factor
```

### 5.5 Calibration Status

| Status       | Condition   | Description          |
| ------------ | ----------- | -------------------- |
| `notStarted` | 0 entries   | No data collected    |
| `inProgress` | 1-6 entries | Collecting baseline  |
| `calibrated` | ≥7 entries  | Calibration complete |

### 5.6 Calibration Profile Structure

```dart
class CalibrationProfile {
  final double decisionCostFactor;   // 0.80 - 1.20
  final double contextCostFactor;    // 0.80 - 1.20
  final double recoveryFactor;       // 0.80 - 1.20
  final CalibrationStatus status;
  final int entriesUsed;
  final DateTime? lastCalibrated;
}
```

---

## 6. Explicit Exclusions

### 6.1 Medical & Clinical Exclusions

PCLL explicitly **does NOT**:

| Exclusion                        | Reason                             |
| -------------------------------- | ---------------------------------- |
| Diagnose conditions              | Not a medical device               |
| Detect ADHD, anxiety, depression | Not clinically validated           |
| Provide medical advice           | Not a substitute for professionals |
| Monitor physiological states     | No biometric integration           |
| Track physical health            | Outside scope                      |

### 6.2 Measurement Exclusions

PCLL **cannot and does not**:

| Exclusion                        | Limitation                                   |
| -------------------------------- | -------------------------------------------- |
| Measure objective cognitive load | Self-reported estimates only                 |
| Distinguish load from illness    | No physiological data                        |
| Account for external factors     | Only tracks logged activities                |
| Provide validated assessments    | Arbitrary units, not calibrated to standards |

### 6.3 Vocabulary Exclusions (Controlled Vocabulary)

The following terms are **forbidden** in PCLL to prevent clinical confusion:

| Forbidden Term | Approved Alternative                |
| -------------- | ----------------------------------- |
| Fatigue        | High withdrawal, Low balance        |
| Stress         | High load, Accumulated deficit      |
| Burnout        | Sustained deficit, Critical balance |
| Mental health  | (N/A - not discussed)               |
| Anxiety        | (N/A - not discussed)               |
| Depression     | (N/A - not discussed)               |
| Energy         | Capacity, Balance                   |
| Exhaustion     | Deep deficit                        |

### 6.4 Approved Vocabulary

| Category     | Approved Terms                                               |
| ------------ | ------------------------------------------------------------ |
| Resources    | Balance, Capacity, Cognitive Units (CU)                      |
| Transactions | Withdrawal, Deposit, Entry                                   |
| States       | Deficit, Surplus, Neutral                                    |
| Load Types   | Immediate Load, Persistent Load, Carryover Debt              |
| Patterns     | High Decision Load, Context Overload, Open Loop Accumulation |
| Recovery     | Recovery Deposit, Impaired Recovery, Reduced Capacity        |

---

## 7. Ledger Entry Structure

### 7.1 Complete Entry Schema

```dart
class LedgerEntry {
  final String id;
  final DateTime date;
  final double openingBalance;      // Start of day (max 100)
  final double closingBalance;      // End of day
  final double totalWithdrawals;    // All costs
  final double totalDeposits;       // All recovery
  final ComponentBreakdown components;

  // Load split
  final double immediateLoad;       // Same-day costs
  final double persistentDebt;      // Accumulating costs
  final double carryForwardDebt;    // What carries to next day

  // Tracking
  final int unresolvedItems;        // Open loops count
  final int avoidedDecisions;       // Deferred decisions count
}
```

### 7.2 Balance Calculation

```
closingBalance = openingBalance
                 - totalWithdrawals
                 + effectiveRecovery
```

---

## 8. Insight System

### 8.1 Insight Types (Priority Order)

| Priority | Type                         | Trigger Condition                 |
| -------- | ---------------------------- | --------------------------------- |
| 1        | `highWithdrawalDay`          | Total withdrawals > 80 CU         |
| 2        | `reducedCapacity`            | Opening balance < 100 CU          |
| 3        | `persistentDebtAccumulating` | carryForwardDebt > 10 CU          |
| 4        | `consecutiveDeficit`         | 3+ days with closing < 0          |
| 5        | `contextOverload`            | Context cost > 40 CU              |
| 6        | `highDecisionLoad`           | Decision cost > 60 CU             |
| 7        | `openLoopAccumulation`       | Passive drain > 20 CU             |
| 8        | `recoverySuccess`            | Recovery from deficit to positive |
| 9        | `impairedRecovery`           | Recovery efficiency < 50%         |
| 10       | `deficitRecovery`            | Full recovery to 100 CU capacity  |

---

## 9. Implementation Notes

### 9.1 Technology Stack

- **Platform:** Flutter 3.38.x (Windows desktop)
- **Database:** SQLite (sqflite + sqflite_common_ffi)
- **State Management:** Provider
- **Persistence:** SharedPreferences (calibration, auth)

### 9.2 Offline-First Design

- All calculations performed locally
- No network dependencies
- Data stored on device only

### 9.3 Key Files

| File                                                 | Purpose               |
| ---------------------------------------------------- | --------------------- |
| `lib/core/models/models.dart`                        | Data structures       |
| `lib/core/providers/ledger_provider.dart`            | State & calculations  |
| `lib/core/services/calibration_service.dart`         | Personal calibration  |
| `lib/core/services/insight_service.dart`             | Pattern detection     |
| `lib/core/constants/vocabulary.dart`                 | Controlled vocabulary |
| `lib/core/services/pattern_observation_service.dart` | Period analysis       |
| `lib/features/patterns/pattern_report_screen.dart`   | Pattern UI            |

---

## 10. Pattern Observation System

### 10.1 Design Principles

The pattern observation system provides **observations, not suggestions**:

| Principle                  | Implementation                               |
| -------------------------- | -------------------------------------------- |
| No prescriptive language   | Shows data comparisons only                  |
| Correlation, not causation | Uses "associated with" not "caused by"       |
| User interprets            | System presents data, user draws conclusions |
| Delayed activation         | Full analysis only after 30 days             |

### 10.2 Availability Thresholds

| Threshold         | Days Required | Features Available                                 |
| ----------------- | ------------- | -------------------------------------------------- |
| Minimum           | 7 days        | Week-over-week comparison                          |
| Weekly comparison | 14 days       | Current vs previous week, best week identification |
| Full analysis     | 30 days       | Complete pattern detection, month comparison       |
| Month-over-month  | 60 days       | Previous month comparison                          |

### 10.3 Period Metrics Calculated

For each period (week/month), the following are calculated:

| Metric               | Description                         |
| -------------------- | ----------------------------------- |
| `avgClosingBalance`  | Average end-of-day balance          |
| `avgWithdrawals`     | Average daily withdrawals           |
| `avgDeposits`        | Average daily recovery              |
| `avgDecisionCost`    | Average decision-related load       |
| `avgContextCost`     | Average context switching cost      |
| `avgPassiveDrain`    | Average unresolved item drain       |
| `avgRecoveryDeposit` | Average recovery logged             |
| `positiveDays`       | Count of days with closing ≥ 0      |
| `deficitDays`        | Count of days with closing < 0      |
| `positiveRatio`      | Percentage of positive-balance days |
| `recoveryRatio`      | Ratio of deposits to withdrawals    |

### 10.4 Pattern Types Detected

After 30 days, the system identifies correlations:

| Pattern ID                   | What It Observes                                     |
| ---------------------------- | ---------------------------------------------------- |
| `RECOVERY_ASSOCIATION`       | Difference in recovery between positive/deficit days |
| `DECISION_LOAD_ASSOCIATION`  | Difference in decision costs between periods         |
| `CONTEXT_SWITCH_ASSOCIATION` | Difference in context switching patterns             |
| `PASSIVE_DRAIN_ASSOCIATION`  | Difference in unresolved item accumulation           |
| `RECOVERY_RATIO_ASSOCIATION` | Difference in recovery-to-withdrawal ratios          |

### 10.5 Association Strength

Each pattern has an association strength (0.0 - 1.0):

| Range      | Label    | Meaning                   |
| ---------- | -------- | ------------------------- |
| ≥ 0.7      | Strong   | Clear correlation in data |
| 0.4 - 0.69 | Moderate | Noticeable pattern        |
| < 0.4      | Weak     | Minor difference observed |

### 10.6 Comparisons Available

| Comparison          | Description                                  |
| ------------------- | -------------------------------------------- |
| Week over Week      | This week vs previous week                   |
| Current vs Best     | This week vs best 7-day period               |
| Positive vs Deficit | All positive days vs all deficit days        |
| Month over Month    | This month vs previous month (after 60 days) |

### 10.7 What the System Does NOT Do

| Forbidden         | Why                                |
| ----------------- | ---------------------------------- |
| Suggest actions   | User must interpret their own data |
| Predict outcomes  | No predictive validity claimed     |
| Recommend changes | Would imply clinical authority     |
| Guarantee results | Correlations are not prescriptions |

---

## Appendix A: Formula Reference

### A.1 Daily Entry Calculation

```
1. Calculate opening balance (with carryover if applicable)
2. Calculate immediate load (decisions + context + focus)
3. Calculate persistent load (unresolved + avoided)
4. Calculate total withdrawals
5. Apply asymmetric recovery
6. Calculate closing balance
7. Calculate carryforward debt for next day
```

### A.2 Complete Balance Formula

```
openingBalance = min(100, 100 + (prevClosing × 0.40))  // if prevClosing < 0
immediateLoad = decisionCost + contextCost + focusWorkCost
persistentDebt = passiveDrain + avoidedDecisionsCost
totalWithdrawals = immediateLoad + persistentDebt
effectiveRecovery = rawRecovery × recoveryEfficiency
closingBalance = openingBalance - totalWithdrawals + effectiveRecovery
carryForwardDebt = persistentDebt × 0.40  // if closing < 0
```

---

**End of Specification**
