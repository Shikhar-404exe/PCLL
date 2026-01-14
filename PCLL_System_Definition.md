# Personal Cognitive Load Ledger (PCLL)

## Formal System Definition

---

## 1. System Definition

The **Personal Cognitive Load Ledger (PCLL)** is a longitudinal tracking system that quantifies and accounts for cognitive resource allocation across time using a financial ledger metaphor. It models cognitive capacity as a renewable resource with measurable depletion (withdrawals) through attentional demands and restoration (deposits) through recovery activities, maintaining a running balance that represents current cognitive availability.

### Core Components

**1.1 Cognitive Balance**

- A scalar value representing current available cognitive capacity
- Range: 0 to 100 (arbitrary units, not clinical measures)
- Resets to baseline each period (typically daily)
- Carries forward deficit/surplus modifiers across periods

**1.2 Cognitive Withdrawals**

- Decrements to cognitive balance from attention-demanding activities
- Measured by task characteristics: complexity, duration, novelty, interruption frequency
- Categories include: deep work, context switching, decision-making, sustained attention
- Each withdrawal logged with: timestamp, magnitude, category, duration

**1.3 Cognitive Deposits**

- Increments to cognitive balance from restorative activities
- Measured by recovery activity type and duration
- Categories include: rest periods, physical activity, nature exposure, sleep quality
- Each deposit logged with: timestamp, magnitude, category, effectiveness coefficient

**1.4 Ledger State**

- Temporal sequence of all transactions (withdrawals/deposits)
- Calculated balance at any point in time
- Period-over-period trends and patterns
- Deficit accumulation and recovery metrics

---

## 2. Core Assumptions

**A1. Cognitive Capacity is Finite and Renewable**

- Individuals possess a bounded cognitive capacity that depletes with use
- This capacity naturally regenerates through time and restorative activities
- Baseline capacity varies between individuals but remains relatively stable for an individual

**A2. Cognitive Load is Quantifiable Through Observable Proxies**

- Task characteristics (complexity, duration, type) serve as valid proxies for cognitive demand
- Self-reported difficulty/effort ratings correlate with actual cognitive load
- Activity patterns can be meaningfully translated into numerical values

**A3. Additive Transaction Model**

- Cognitive costs accumulate linearly within bounded constraints
- Multiple small demands can compound to equivalent effect as one large demand
- Recovery follows predictable patterns based on activity type and duration

**A4. Temporal Coherence**

- Cognitive state persists across short time intervals (minutes to hours)
- Day-over-day patterns provide meaningful longitudinal insight
- Past states influence but do not determine future capacity

**A5. Individual Calibration**

- Default values provide starting estimates
- System adapts to individual patterns through usage
- Personal baselines are discoverable through data collection

**A6. Non-Clinical Framework**

- Measurements reflect resource allocation, not pathology
- Values indicate capacity utilization, not dysfunction
- System operates independently of diagnostic criteria

---

## 3. System Boundaries

### What PCLL Does NOT Do

**3.1 Clinical/Diagnostic Functions**

- Does NOT diagnose mental health conditions (ADHD, anxiety, depression, burnout)
- Does NOT replace clinical assessment tools or professional evaluation
- Does NOT provide medical advice or treatment recommendations
- Does NOT measure or track mood, affect, or emotional states
- Does NOT assess psychological well-being or mental fitness

**3.2 Causal Claims**

- Does NOT identify root causes of cognitive depletion beyond logged activities
- Does NOT attribute cognitive load to neurological or physiological mechanisms
- Does NOT distinguish between cognitive load and other forms of fatigue
- Does NOT make predictive claims about performance or capability

**3.3 Prescriptive Functions**

- Does NOT prescribe specific interventions or treatments
- Does NOT recommend changes to medication or therapy
- Does NOT provide productivity optimization as primary function
- Does NOT enforce or mandate behavioral changes

**3.4 External Validation**

- Does NOT measure objective cognitive performance (reaction time, accuracy, etc.)
- Does NOT correlate with standardized neuropsychological tests
- Does NOT validate entries against external sensors or biometrics
- Does NOT provide ground truth about actual cognitive state

**3.5 Scope Limitations**

- Does NOT track physical fatigue, illness, or physiological states
- Does NOT monitor sleep architecture or circadian rhythms directly
- Does NOT account for external stressors beyond logged cognitive activities
- Does NOT model social, relational, or environmental factors explicitly
- Does NOT integrate with medical records or health data systems

**3.6 Comparative Functions**

- Does NOT compare individuals against normative data
- Does NOT rank or score individuals against others
- Does NOT establish universal thresholds for "healthy" vs "unhealthy" levels
- Does NOT provide population-level benchmarks

---

## 4. Technical Summary

The Personal Cognitive Load Ledger (PCLL) is a self-contained accounting system that applies financial ledger principles to cognitive resource management. It maintains a double-entry log where attention-demanding activities constitute withdrawals from a cognitive capacity pool, and restorative activities constitute deposits, with a continuously calculated balance representing current resource availability. The system operates on a periodic reset cycle (typically daily) with cross-period deficit/surplus tracking, enabling longitudinal analysis of cognitive allocation patterns. PCLL functions as a descriptive tracking tool using observable behavioral proxies and self-reported assessments to quantify cognitive demand, explicitly excluding clinical diagnostic functions, emotional state measurement, causal mechanism identification, and prescriptive recommendations. The ledger structure provides temporal coherence and individual calibration through usage, producing a personalized model of cognitive resource dynamics that supports self-awareness and informed planning without making claims about underlying neurological processes or mental health status.

---

## 5. Cognitive Load Components

The following components decompose "cognitive load" into measurable, computable dimensions. Each component represents a distinct mechanism through which cognitive resources are consumed during activity execution.

### 5.1 **Attention Density**

**Definition:** The sustained concentration required per unit time, measured by the ratio of focused attention periods to total activity duration.

**Observable Indicators:**

- Continuous engagement without natural break points
- Information processing rate (inputs per minute)
- Required precision or accuracy thresholds
- Simultaneous information streams to monitor

**Withdrawal Mechanism:**
High attention density depletes cognitive resources through continuous recruitment of executive control mechanisms without recovery intervals. The system must maintain active processing state without downtime.

**Computational Example:**

```
Withdrawal_magnitude = (Focus_intensity[1-10] × Duration_minutes) / 60
```

**Activity Examples:**

- Writing code: 8/10 intensity × 120 min = 16 units withdrawn
- Proofreading legal document: 9/10 intensity × 45 min = 6.75 units withdrawn
- Listening to podcast (passive): 3/10 intensity × 60 min = 3 units withdrawn

---

### 5.2 **Context Multiplicity**

**Definition:** The number of distinct mental models, problem spaces, or task contexts maintained simultaneously or alternated between within a time window.

**Observable Indicators:**

- Number of distinct projects/tasks worked on
- Application/tool switches per hour
- Topic changes in conversations or meetings
- Parallel threads requiring active memory

**Withdrawal Mechanism:**
Each context requires loading and maintaining a unique set of mental representations, rules, and goals. Switching between contexts incurs both maintenance costs (keeping multiple contexts warm) and transition costs (context reload overhead).

**Computational Example:**

```
Base_cost = Number_of_contexts × 2
Switch_cost = Number_of_switches × 1.5
Withdrawal_magnitude = Base_cost + Switch_cost
```

**Activity Examples:**

- Single deep work session: 1 context × 2 = 2 units withdrawn
- Responding to 8 different email threads: 8 contexts × 2 + 7 switches × 1.5 = 26.5 units withdrawn
- Meeting covering 4 agenda items: 4 contexts × 2 + 3 switches × 1.5 = 12.5 units withdrawn

---

### 5.3 **Decision Volume**

**Definition:** The cumulative count of deliberate choices made, weighted by consequence significance and information uncertainty.

**Observable Indicators:**

- Number of explicit decisions required
- Reversibility of decisions (low reversibility = higher load)
- Information completeness (ambiguity level)
- Stakeholder impact scope

**Withdrawal Mechanism:**
Each decision requires evaluating alternatives, projecting consequences, applying criteria, and committing to an action. Decision-making consumes resources through information integration, uncertainty resolution, and the cognitive effort of commitment under incomplete information.

**Computational Example:**

```
Decision_weight = (Consequence_level[1-5] + Uncertainty_level[1-5]) / 2
Withdrawal_magnitude = Σ(Decision_weight_i) for all decisions
```

**Activity Examples:**

- Choosing what to wear: (1 + 1)/2 = 1 unit withdrawn
- Selecting technology stack for project: (5 + 4)/2 = 4.5 units withdrawn
- 15 minor email triage decisions: 15 × (2 + 2)/2 = 30 units withdrawn
- Strategic hiring decision: (5 + 3)/2 = 4 units withdrawn

---

### 5.4 **Novelty Processing**

**Definition:** The degree to which an activity requires learning, adapting to unfamiliar patterns, or operating outside established procedural knowledge.

**Observable Indicators:**

- Task familiarity rating (new vs. routine)
- Frequency of external reference lookups
- Trial-and-error cycles required
- Procedural ambiguity level

**Withdrawal Mechanism:**
Novel situations cannot leverage automated/compiled mental procedures, requiring deliberate reasoning, active learning, error monitoring, and schema construction. The absence of cognitive shortcuts forces resource-intensive conscious processing.

**Computational Example:**

```
Novelty_factor = (10 - Familiarity_rating[1-10]) / 10
Base_load = Task_duration_minutes × Complexity[1-10]
Withdrawal_magnitude = Base_load × Novelty_factor
```

**Activity Examples:**

- Daily standup meeting (routine): 15 min × 2 complexity × 0.1 novelty = 3 units withdrawn
- Learning new programming language: 60 min × 8 complexity × 0.9 novelty = 432 units withdrawn
- First time using new software tool: 30 min × 6 complexity × 0.7 novelty = 126 units withdrawn

---

### 5.5 **Interruption Recovery**

**Definition:** The cumulative cost of attention restoration following unplanned disruptions to ongoing cognitive activity.

**Observable Indicators:**

- Number of interruptions (notifications, questions, alerts)
- Depth of interrupted task (shallow vs. deep work)
- Interruption duration
- Relevance of interruption to current task

**Withdrawal Mechanism:**
Interruptions disrupt active working memory contents, requiring mental state reconstruction upon return. The system must save current state, process interruption, then reload and reorient to the original task. Deeper work states incur higher reconstruction costs.

**Computational Example:**

```
Recovery_cost = Task_depth[1-10] × Interruption_count × 0.5
Additional_duration = Interruption_count × 2 minutes (per interruption)
Withdrawal_magnitude = Recovery_cost + (Additional_duration × Attention_density)
```

**Activity Examples:**

- 3 Slack messages during shallow email work: 3 × 3 × 0.5 = 4.5 units withdrawn
- 5 interruptions during deep coding: 5 × 9 × 0.5 + (10 min × 8/10) = 22.5 + 8 = 30.5 units withdrawn
- Phone call during document review: 1 × 5 × 0.5 + (5 min × 6/10) = 2.5 + 3 = 5.5 units withdrawn

---

### 5.6 **Sustained Vigilance**

**Definition:** The duration of continuous monitoring for specific signals, errors, or events requiring timely response, particularly when target events are infrequent.

**Observable Indicators:**

- Monitoring duration without disengagement
- Signal frequency (rare events = higher load)
- Consequence of missed detection
- Background vs. foreground monitoring

**Withdrawal Mechanism:**
Vigilance tasks require maintaining readiness to respond despite low event rates, consuming resources through sustained alertness without the reward structure of completed work units. The system must inhibit mind-wandering while lacking engaging stimulation.

**Computational Example:**

```
Vigilance_intensity = (Consequence_severity[1-10] × Duration_minutes) / Signal_frequency
Withdrawal_magnitude = Vigilance_intensity × 0.3
```

**Activity Examples:**

- Monitoring deployment dashboard (high-stakes): (9 × 120 min) / 2 signals = 540 × 0.3 = 162 units withdrawn
- Waiting for important email response: (6 × 180 min) / 5 checks = 216 × 0.3 = 64.8 units withdrawn
- Supervising automated process: (4 × 60 min) / 10 checks = 24 × 0.3 = 7.2 units withdrawn

---

### Component Interactions

These components are **not mutually exclusive** and often co-occur in real activities:

- A software debugging session may involve: High attention density + High novelty processing + Multiple interruptions
- A strategy meeting may involve: High decision volume + High context multiplicity + Sustained attention
- Learning a new skill may involve: High novelty processing + High attention density + Low interruption tolerance

**Composite Withdrawal Calculation:**

```
Total_withdrawal = Σ(Component_i_magnitude) × Interaction_multiplier[0.8-1.2]
```

The interaction multiplier accounts for synergistic effects (multiple components may compound) or saturation effects (overlap may reduce total impact).

---

## 6. Cognitive Units (CU) - Measurement Framework

### 6.1 Definition

A **Cognitive Unit (CU)** is a dimensionless scalar representing a standardized quantum of cognitive resource consumption or restoration. CUs serve as the common currency for the PCLL ledger system, enabling addition, subtraction, and accumulation across heterogeneous cognitive activities.

**Formal Properties:**

- **Additive:** CU₁ + CU₂ = CU₃ (withdrawals accumulate)
- **Subtractive:** Balance - Withdrawal = New_Balance
- **Accumulative:** Deficit can compound across periods
- **Bounded:** Daily balance operates within [0, 100] CU range
- **Renewable:** Baseline resets each period with carryover modifiers

**Calibration Philosophy:**
CUs are calibrated to an arbitrary reference point where **100 CU represents a full daily cognitive capacity** for a typical adult during normal waking hours. This anchoring enables:

- Intuitive percentage-based interpretation (50 CU = 50% capacity remaining)
- Cross-activity comparability within an individual's ledger
- Relative trend analysis over time

**Important:** Absolute CU values are **not comparable across individuals**. A 60 CU balance for Person A does not equal a 60 CU balance for Person B. The system tracks personal patterns, not universal benchmarks.

---

### 6.2 Typical CU Ranges by Activity Category

#### **Decisions (CU per decision)**

| Decision Type                                               | CU Range   | Rationale                                                |
| ----------------------------------------------------------- | ---------- | -------------------------------------------------------- |
| Trivial choice (clothing, lunch)                            | 0.5 - 2 CU | Low stakes, reversible, minimal information processing   |
| Routine operational (email priority, meeting response)      | 2 - 5 CU   | Moderate uncertainty, limited consequence scope          |
| Tactical planning (task sequencing, resource allocation)    | 5 - 15 CU  | Multiple factors, medium-term impact                     |
| Strategic decision (hiring, vendor selection, architecture) | 15 - 30 CU | High stakes, irreversible, extensive evaluation required |
| Life-altering (career change, major purchase)               | 30 - 50 CU | Maximum consequence, prolonged deliberation              |

**Batch Effect:** Making 20 trivial decisions consecutively incurs a multiplier (0.5 × 20 × 1.3 = 13 CU) due to decision fatigue.

---

#### **Context Switching (CU per switch)**

| Switch Scenario                                       | CU Range   | Rationale                                 |
| ----------------------------------------------------- | ---------- | ----------------------------------------- |
| Within-project micro-switch (checking reference)      | 1 - 2 CU   | Minimal mental model reload               |
| Between related tasks (related code files)            | 2 - 5 CU   | Partial context overlap reduces cost      |
| Between unrelated tasks (email → code → meeting prep) | 5 - 12 CU  | Full mental model swap required           |
| Between high-depth tasks (deep work interrupted)      | 12 - 25 CU | Significant state reconstruction overhead |
| Cold start after extended break (morning startup)     | 15 - 30 CU | Complete context rebuild from memory      |

**Sustained Context Multiplicity:** Maintaining 5 active contexts simultaneously = 5 × 3 CU baseline = 15 CU passive load.

---

#### **Unresolved Tasks / Open Loops (CU per item)**

| Open Loop Type                                              | CU Range   | Rationale                                  |
| ----------------------------------------------------------- | ---------- | ------------------------------------------ |
| Minor pending item (reply to email)                         | 0.5 - 1 CU | Low urgency, clear action path             |
| Moderate commitment (scheduled task, promise)               | 1 - 3 CU   | Active mental reminder required            |
| High-stakes pending (deadline looming, blocked dependency)  | 3 - 8 CU   | Frequent background checking, anxiety load |
| Ambiguous unresolved (undefined problem, unclear next step) | 5 - 12 CU  | Continuous subconscious processing         |
| Critical unresolved (emergency, conflict)                   | 10 - 20 CU | Dominant mental bandwidth allocation       |

**Accumulation Effect:** 15 minor open loops = 15 × 0.75 × 1.4 (accumulation penalty) = 15.75 CU passive drain.

---

#### **Recovery Activities (CU deposited)**

| Recovery Type                                  | CU Range    | Rationale                                   |
| ---------------------------------------------- | ----------- | ------------------------------------------- |
| Micro-break (5 min, stretch, water)            | 2 - 4 CU    | Brief respite, partial attention release    |
| Short break (15 min, walk, snack)              | 5 - 10 CU   | Context detachment, physical movement       |
| Lunch break (45-60 min, away from workspace)   | 12 - 20 CU  | Full disengagement, nourishment             |
| Physical exercise (30 min, moderate intensity) | 15 - 25 CU  | Neurochemical restoration, stress reduction |
| Nature exposure (30 min outdoor walk)          | 18 - 28 CU  | Attention restoration theory benefits       |
| Deep rest (nap, meditation 20-30 min)          | 20 - 35 CU  | Active recovery, reduced arousal            |
| Sleep (7-9 hours, quality)                     | 80 - 100 CU | Full baseline restoration                   |

**Diminishing Returns:** Multiple short breaks back-to-back show reduced per-break effectiveness (first break = 8 CU, second = 6 CU, third = 4 CU).

---

### 6.3 Sample Daily CU Calculation

**Scenario:** Knowledge worker, software engineer, typical workday

**Starting Balance:** 100 CU (morning baseline after 8 hours sleep)

#### **Morning Session (9:00 AM - 12:00 PM)**

| Time  | Activity                                  | Component              | CU Change | Running Balance |
| ----- | ----------------------------------------- | ---------------------- | --------- | --------------- |
| 9:00  | Coffee, email triage                      | Warmup                 | -3 CU     | 97 CU           |
| 9:15  | Standup meeting (routine, 4 topics)       | Context × 4, Attention | -8 CU     | 89 CU           |
| 9:30  | Deep coding session (120 min, high focus) | Attention density      | -16 CU    | 73 CU           |
| 9:45  | 3 Slack interruptions during coding       | Interruption recovery  | -8 CU     | 65 CU           |
| 11:30 | Architectural decision (tech choice)      | Decision volume        | -18 CU    | 47 CU           |
| 11:45 | 5 minor code review decisions             | Decision batch         | -7 CU     | 40 CU           |

#### **Midday Recovery (12:00 PM - 1:00 PM)**

| Time  | Activity                       | Component | CU Change | Running Balance |
| ----- | ------------------------------ | --------- | --------- | --------------- |
| 12:00 | Lunch break (off-site, 60 min) | Deposit   | +18 CU    | 58 CU           |

#### **Afternoon Session (1:00 PM - 5:00 PM)**

| Time | Activity                                      | Component            | CU Change | Running Balance |
| ---- | --------------------------------------------- | -------------------- | --------- | --------------- |
| 1:00 | Email context switch                          | Context switch       | -5 CU     | 53 CU           |
| 1:15 | Responding to 12 email threads                | Context × 12         | -22 CU    | 31 CU           |
| 1:45 | 15 minor triage decisions                     | Decision batch       | -13 CU    | 18 CU           |
| 2:00 | Strategy meeting (90 min, 6 decisions)        | Attention + Decision | -32 CU    | -14 CU          |
| 3:30 | **Cognitive deficit** - reduced effectiveness |                      |           | -14 CU          |
| 3:30 | Short walk break (15 min)                     | Deposit              | +8 CU     | -6 CU           |
| 3:45 | Routine bug fixes (familiar, low novelty)     | Attention (reduced)  | -8 CU     | -14 CU          |
| 4:30 | Monitoring deployment (30 min vigilance)      | Vigilance            | -12 CU    | -26 CU          |

#### **Open Loops (Passive Drain Throughout Day)**

| Item                        | CU Drain   |
| --------------------------- | ---------- |
| 3 unresolved blocked tasks  | -9 CU      |
| 8 minor pending items       | -6 CU      |
| 1 critical deadline looming | -12 CU     |
| **Total passive drain**     | **-27 CU** |

**End of Day Balance:** -26 CU (deficit state)  
**Adjusted for open loops:** -26 - 27 = **-53 CU cumulative depletion**

#### **Evening Recovery**

| Time  | Activity                     | Component | CU Change | Running Balance  |
| ----- | ---------------------------- | --------- | --------- | ---------------- |
| 6:00  | Exercise (45 min)            | Deposit   | +22 CU    | -31 CU           |
| 8:00  | Leisure, low-demand activity | Deposit   | +12 CU    | -19 CU           |
| 11:00 | Sleep (8 hours)              | Deposit   | +100 CU   | 81 CU (next day) |

**Next Day Starting Balance:** 81 CU (100 baseline - 19 carryover deficit)

---

### 6.4 Why This Unit System is Defensible

#### **1. Dimensional Consistency**

CUs are dimensionless scalars that aggregate heterogeneous cognitive phenomena under a unified accounting framework. Like monetary currency aggregates apples and oranges through exchange rates, CUs aggregate attention and decisions through calibrated conversion factors. The system requires **internal consistency** (CUs add/subtract meaningfully within a ledger), not external validity (CUs need not map to neural firing rates).

#### **2. Anchored Relative Measurement**

The 100 CU daily baseline provides a stable reference point analogous to 100% capacity. All measurements are **relative to personal baseline**, not absolute neurological metrics. This approach mirrors established precedents:

- Financial accounting (currency has no intrinsic value, only relative exchange rates)
- Temperature scales (Celsius/Fahrenheit are arbitrary zero-points with consistent intervals)
- Credit scores (dimensionless aggregates of financial behavior)

#### **3. Operational Validity Over Construct Validity**

CUs prioritize **predictive utility** for individual pattern recognition over theoretical validity. The system succeeds if:

- Higher CU depletion correlates with self-reported cognitive fatigue
- CU trends predict capacity availability over days/weeks
- CU accounting enables better resource allocation decisions

This parallels successful precedents like **story points in Agile development** (dimensionless team-calibrated effort units) or **metabolic equivalents (METs)** in exercise science (standardized relative to resting metabolism).

#### **4. Explicit Emphasis on Trends, Not Absolutes**

The framework makes **no claims about absolute cognitive state**. A 40 CU balance does not mean "40% brain function" or correspond to any physiological measurement. Instead:

- 40 CU today vs. 70 CU yesterday = meaningful relative decline
- Pattern of 30-40 CU end-of-day across weeks = chronic under-recovery trend
- Rapid CU depletion rate = inefficient resource allocation

Users interpret CU **direction, velocity, and patterns**, not isolated values.

#### **5. Falsifiable Through Personal Calibration**

The system is **individually falsifiable**: if CU patterns fail to correlate with subjective experience across weeks of logging, the user's calibration parameters can be adjusted. The framework admits:

- Personal baseline may differ from 100 CU
- Activity cost functions may require individual tuning
- Deposit effectiveness varies by person

This self-correction mechanism parallels wearable fitness trackers that calibrate to individual biometrics.

#### **6. Transparent Limitations**

The CU framework explicitly disclaims:

- Cross-person comparability (60 CU for Alice ≠ 60 CU for Bob)
- Causal mechanism identification (CUs describe resource flow, not neural processes)
- Clinical/diagnostic utility (not a mental health metric)

By acknowledging what CUs **cannot do**, the framework establishes credible boundaries for what they **can do**: provide consistent, trend-oriented resource accounting.

#### **7. Pragmatic Sufficiency**

Perfect accuracy is impossible without invasive neuroimaging. The CU system achieves **pragmatic sufficiency**:

- Good enough to identify patterns (overcommitment, under-recovery)
- Simple enough for daily logging compliance
- Flexible enough for individual differences
- Structured enough for computational analysis

This mirrors the "80/20 rule" in engineering: 80% of utility from 20% of theoretical completeness.

---

## Appendix: Formal Notation

### Ledger State at Time t

```
Balance(t) = Baseline + Σ(Deposits[0→t]) - Σ(Withdrawals[0→t])
```

### Transaction Structure

```
Transaction {
  timestamp: DateTime
  type: {Withdrawal, Deposit}
  magnitude: Real[0, 100]  // in Cognitive Units (CU)
  category: Enum
  metadata: {duration, intensity, context}
}
```

### Boundary Conditions

```
0 ≤ Balance(t) ≤ Capacity_max  // Capacity_max typically 100 CU
Balance(t+1_day) = Baseline + CarryoverModifier(Balance(t))

CarryoverModifier(Balance) = {
  if Balance ≥ 0: 0 (full reset)
  if Balance < 0: Balance × 0.2 (20% deficit carried forward)
}
```

### CU Conversion Functions

```
Decision_CU = f(consequence, uncertainty, reversibility)
Context_Switch_CU = f(depth_current, depth_next, relatedness)
Attention_CU = f(intensity, duration, novelty)
Recovery_CU = f(activity_type, duration, quality)
```

---

## 7. Ledger Mechanics - Computational Framework

### 7.1 Core Ledger Operations

#### **Daily Opening Balance**

```pseudocode
function calculate_opening_balance(previous_day):
    if is_first_day():
        return BASELINE_CAPACITY  // Default: 100 CU

    previous_closing = previous_day.closing_balance

    // Overnight recovery from sleep
    sleep_deposit = calculate_sleep_recovery(previous_day.sleep_data)

    // Carryover modifier for deficits
    if previous_closing < 0:
        cognitive_debt = previous_closing * DEFICIT_CARRYOVER_RATE  // Default: 0.2
    else:
        cognitive_debt = 0

    opening_balance = BASELINE_CAPACITY + sleep_deposit + cognitive_debt

    // Boundary enforcement
    return clamp(opening_balance, 0, MAX_CAPACITY)  // MAX_CAPACITY = 120 CU

constants:
    BASELINE_CAPACITY = 100 CU
    MAX_CAPACITY = 120 CU  // Allows surplus from excellent recovery
    DEFICIT_CARRYOVER_RATE = 0.2  // 20% of deficit persists
```

#### **Cognitive Withdrawals**

```pseudocode
function process_withdrawal(activity, timestamp):
    // Calculate component contributions
    attention_cost = calculate_attention_density(activity)
    context_cost = calculate_context_multiplicity(activity)
    decision_cost = calculate_decision_volume(activity)
    novelty_cost = calculate_novelty_processing(activity)
    interruption_cost = calculate_interruption_recovery(activity)
    vigilance_cost = calculate_sustained_vigilance(activity)

    // Base withdrawal (sum of components)
    base_withdrawal = (
        attention_cost +
        context_cost +
        decision_cost +
        novelty_cost +
        interruption_cost +
        vigilance_cost
    )

    // Time-of-day modifier (fatigue accumulation)
    time_modifier = get_fatigue_multiplier(timestamp, current_balance)

    // Interaction effects
    interaction_multiplier = calculate_interaction_effects(activity)

    total_withdrawal = base_withdrawal * time_modifier * interaction_multiplier

    // Log transaction
    ledger.add_transaction({
        timestamp: timestamp,
        type: "WITHDRAWAL",
        magnitude: total_withdrawal,
        category: activity.category,
        components: {
            attention: attention_cost,
            context: context_cost,
            decision: decision_cost,
            novelty: novelty_cost,
            interruption: interruption_cost,
            vigilance: vigilance_cost
        }
    })

    current_balance -= total_withdrawal
    return current_balance

function get_fatigue_multiplier(time, balance):
    // Withdrawals cost more when depleted
    if balance < 20:
        return 1.5  // 50% penalty in severe depletion
    elif balance < 50:
        return 1.2  // 20% penalty in moderate depletion
    else:
        return 1.0  // Normal cost
```

#### **Cognitive Recovery Deposits**

```pseudocode
function process_deposit(activity, timestamp):
    // Base recovery value
    base_deposit = get_recovery_value(activity.type, activity.duration)

    // Quality modifier (self-reported 1-10)
    quality_factor = activity.quality_rating / 10.0

    // Depletion bonus (recovery is more effective when depleted)
    if current_balance < 30:
        depletion_bonus = 1.3  // 30% bonus when severely depleted
    elif current_balance < 60:
        depletion_bonus = 1.1  // 10% bonus when moderately depleted
    else:
        depletion_bonus = 1.0

    // Diminishing returns (multiple breaks in short succession)
    recent_deposits = count_deposits_last_n_minutes(60)
    if recent_deposits > 2:
        diminishing_factor = 0.7  // 30% reduction
    elif recent_deposits > 1:
        diminishing_factor = 0.85  // 15% reduction
    else:
        diminishing_factor = 1.0

    total_deposit = (
        base_deposit *
        quality_factor *
        depletion_bonus *
        diminishing_factor
    )

    // Log transaction
    ledger.add_transaction({
        timestamp: timestamp,
        type: "DEPOSIT",
        magnitude: total_deposit,
        category: activity.type,
        metadata: {
            quality: activity.quality_rating,
            depletion_bonus: depletion_bonus,
            diminishing_factor: diminishing_factor
        }
    })

    current_balance += total_deposit
    return clamp(current_balance, current_balance, MAX_CAPACITY)
```

#### **Closing Balance**

```pseudocode
function calculate_closing_balance(day):
    // Starting point
    balance = day.opening_balance

    // Process all transactions chronologically
    for transaction in day.transactions.sorted_by_time():
        if transaction.type == "WITHDRAWAL":
            balance -= transaction.magnitude
        elif transaction.type == "DEPOSIT":
            balance += transaction.magnitude

    // Calculate passive drains (open loops)
    open_loop_drain = calculate_open_loop_cost(day.unresolved_items)
    balance -= open_loop_drain

    // Log passive drain as final transaction
    day.add_transaction({
        timestamp: end_of_day(),
        type: "WITHDRAWAL",
        magnitude: open_loop_drain,
        category: "PASSIVE_DRAIN"
    })

    closing_balance = balance

    // Determine cognitive state
    if closing_balance < -50:
        state = "SEVERE_DEFICIT"
    elif closing_balance < 0:
        state = "DEFICIT"
    elif closing_balance < 30:
        state = "DEPLETED"
    elif closing_balance < 70:
        state = "MODERATE"
    else:
        state = "WELL_RESTED"

    return {
        closing_balance: closing_balance,
        state: state,
        total_withdrawals: sum(day.withdrawals),
        total_deposits: sum(day.deposits),
        net_change: closing_balance - day.opening_balance
    }

function calculate_open_loop_cost(unresolved_items):
    total_drain = 0
    for item in unresolved_items:
        item_cost = (
            item.urgency_rating *
            item.ambiguity_factor *
            OPEN_LOOP_BASE_COST
        )
        total_drain += item_cost

    // Accumulation penalty for many items
    if len(unresolved_items) > 10:
        accumulation_penalty = 1.4
    elif len(unresolved_items) > 5:
        accumulation_penalty = 1.2
    else:
        accumulation_penalty = 1.0

    return total_drain * accumulation_penalty

constants:
    OPEN_LOOP_BASE_COST = 0.75 CU
```

#### **Rolling Weekly Trend**

```pseudocode
function calculate_weekly_metrics(days_array):
    // days_array contains last 7 days

    weekly_metrics = {
        average_opening: mean([day.opening_balance for day in days_array]),
        average_closing: mean([day.closing_balance for day in days_array]),
        average_withdrawals: mean([day.total_withdrawals for day in days_array]),
        average_deposits: mean([day.total_deposits for day in days_array]),
        deficit_days: count([day for day in days_array if day.closing_balance < 0]),
        recovery_ratio: total_deposits / total_withdrawals,
        cognitive_debt_trend: calculate_debt_trend(days_array),
        volatility: stdev([day.closing_balance for day in days_array])
    }

    return weekly_metrics

function calculate_debt_trend(days_array):
    // Linear regression on closing balances
    slope = linear_regression_slope([day.closing_balance for day in days_array])

    if slope < -5:
        return "DETERIORATING"  // Getting worse each day
    elif slope < 0:
        return "DECLINING"  // Mild downward trend
    elif slope < 5:
        return "STABLE"  // Relatively flat
    else:
        return "IMPROVING"  // Getting better each day

function get_weekly_insights(weekly_metrics):
    insights = []

    if weekly_metrics.deficit_days >= 5:
        insights.append("CHRONIC_DEFICIT: 5+ deficit days detected")

    if weekly_metrics.recovery_ratio < 0.8:
        insights.append("INSUFFICIENT_RECOVERY: Deposits < 80% of withdrawals")

    if weekly_metrics.volatility > 40:
        insights.append("HIGH_VOLATILITY: Inconsistent daily patterns")

    if weekly_metrics.cognitive_debt_trend == "DETERIORATING":
        insights.append("COMPOUNDING_DEBT: Deficit increasing daily")

    return insights
```

---

### 7.2 Five-Day Example with Sample Data

#### **Day 1 (Monday) - Moderate Workload**

```
OPENING BALANCE: 100 CU (baseline, well-rested)

WITHDRAWALS:
09:00 | Email triage (15 min)              | -5 CU   | Balance: 95 CU
09:30 | Team standup (30 min)              | -8 CU   | Balance: 87 CU
10:00 | Deep work: coding (120 min)        | -22 CU  | Balance: 65 CU
12:00 | Lunch break                        | +15 CU  | Balance: 80 CU
13:00 | Code review (45 min)               | -12 CU  | Balance: 68 CU
14:00 | Client meeting (90 min, 4 decisions)| -28 CU  | Balance: 40 CU
15:30 | Break: walk (15 min)               | +8 CU   | Balance: 48 CU
16:00 | Bug fixes (60 min, familiar)       | -10 CU  | Balance: 38 CU
17:00 | Email responses (20 messages)      | -15 CU  | Balance: 23 CU
EOD   | Open loops: 6 items                | -8 CU   | Balance: 15 CU

CLOSING BALANCE: 15 CU (DEPLETED)
Total Withdrawals: 90 CU
Total Deposits: 23 CU
Net Change: -85 CU
```

#### **Day 2 (Tuesday) - High Stress Day**

```
OPENING BALANCE: 100 CU (baseline reset, no deficit carryover since Day 1 closed positive)

WITHDRAWALS:
09:00 | Morning routine disrupted          | -8 CU   | Balance: 92 CU
09:30 | 5 context switches (email/slack)   | -18 CU  | Balance: 74 CU
10:30 | Crisis meeting (120 min, urgent)   | -42 CU  | Balance: 32 CU
12:30 | Quick lunch at desk                | +6 CU   | Balance: 38 CU
13:00 | Firefighting: production issue     | -35 CU  | Balance: 3 CU
15:00 | (Severe depletion: 1.5x cost penalty activated)
15:00 | Continued debugging (90 min)       | -27 CU  | Balance: -24 CU (DEFICIT)
16:30 | Strategic decision under pressure  | -25 CU  | Balance: -49 CU
17:30 | Cleanup tasks                      | -12 CU  | Balance: -61 CU
EOD   | Open loops: 12 items (high urgency)| -18 CU  | Balance: -79 CU

CLOSING BALANCE: -79 CU (SEVERE_DEFICIT)
Total Withdrawals: 185 CU
Total Deposits: 6 CU
Net Change: -179 CU
Cognitive Debt Accrued: 79 CU
```

#### **Day 3 (Wednesday) - Debt Carryover**

```
OPENING BALANCE: 84 CU (100 baseline - 16 CU carryover debt)
  Calculation: -79 CU × 0.2 carryover rate = -15.8 ≈ -16 CU

WITHDRAWALS:
09:00 | Slow start (fatigue)               | -10 CU  | Balance: 74 CU
10:00 | Focus session (90 min, struggling) | -25 CU  | Balance: 49 CU
11:30 | Break: coffee, stretch (10 min)   | +5 CU   | Balance: 54 CU
12:00 | Lunch + short walk (60 min)        | +18 CU  | Balance: 72 CU
13:00 | Meetings (180 min, 3 meetings)     | -45 CU  | Balance: 27 CU
16:00 | Break: snack (5 min)               | +3 CU   | Balance: 30 CU
16:30 | Administrative tasks (60 min)      | -15 CU  | Balance: 15 CU
17:30 | Planning tomorrow (30 min)         | -8 CU   | Balance: 7 CU
EOD   | Open loops: 10 items               | -12 CU  | Balance: -5 CU

CLOSING BALANCE: -5 CU (DEFICIT)
Total Withdrawals: 115 CU
Total Deposits: 26 CU
Net Change: -89 CU (from adjusted opening)
Cognitive Debt Persists: 5 CU
```

#### **Day 4 (Thursday) - Recovery Attempt**

```
OPENING BALANCE: 99 CU (100 baseline - 1 CU carryover debt)
  Calculation: -5 CU × 0.2 = -1 CU

WITHDRAWALS:
09:00 | Light email review                 | -5 CU   | Balance: 94 CU
09:30 | Deep work (90 min, protected)      | -18 CU  | Balance: 76 CU
11:00 | Break: walk outside (20 min)       | +12 CU  | Balance: 88 CU
11:30 | Collaborative work session (90 min)| -22 CU  | Balance: 66 CU
13:00 | Extended lunch break (75 min)      | +20 CU  | Balance: 86 CU
14:15 | Focused coding (120 min)           | -24 CU  | Balance: 62 CU
16:15 | Break: meditation (15 min)         | +10 CU  | Balance: 72 CU
16:30 | Code documentation (45 min, light) | -10 CU  | Balance: 62 CU
17:15 | End work early                     | --      | Balance: 62 CU
EOD   | Open loops: 4 items (resolved many)| -5 CU   | Balance: 57 CU

CLOSING BALANCE: 57 CU (MODERATE)
Total Withdrawals: 79 CU
Total Deposits: 42 CU
Net Change: -42 CU
Cognitive Debt: Cleared (positive balance)
```

#### **Day 5 (Friday) - Light Day**

```
OPENING BALANCE: 100 CU (full baseline, no debt)

WITHDRAWALS:
09:00 | Quick check-ins                    | -5 CU   | Balance: 95 CU
09:30 | Finish pending tasks (60 min)      | -12 CU  | Balance: 83 CU
10:30 | Team retrospective (60 min)        | -10 CU  | Balance: 73 CU
11:30 | Lunch (60 min, social)             | +16 CU  | Balance: 89 CU
12:30 | Wrap-up documentation (60 min)     | -10 CU  | Balance: 79 CU
13:30 | Planning next week (45 min)        | -12 CU  | Balance: 67 CU
14:15 | Early finish                       | --      | Balance: 67 CU
EOD   | Open loops: 2 items (weekend)      | -2 CU   | Balance: 65 CU

CLOSING BALANCE: 65 CU (MODERATE)
Total Withdrawals: 51 CU
Total Deposits: 16 CU
Net Change: -35 CU
Weekend Recovery Ahead
```

---

### 7.3 Five-Day Summary & Weekly Metrics

```
┌─────────┬──────────┬──────────┬─────────────┬──────────┬───────────┐
│   Day   │ Opening  │ Closing  │ Withdrawals │ Deposits │   State   │
├─────────┼──────────┼──────────┼─────────────┼──────────┼───────────┤
│ Mon     │ 100 CU   │  15 CU   │    90 CU    │  23 CU   │ DEPLETED  │
│ Tue     │ 100 CU   │ -79 CU   │   185 CU    │   6 CU   │ SEVERE_D  │
│ Wed     │  84 CU   │  -5 CU   │   115 CU    │  26 CU   │ DEFICIT   │
│ Thu     │  99 CU   │  57 CU   │    79 CU    │  42 CU   │ MODERATE  │
│ Fri     │ 100 CU   │  65 CU   │    51 CU    │  16 CU   │ MODERATE  │
└─────────┴──────────┴──────────┴─────────────┴──────────┴───────────┘

WEEKLY METRICS:
Average Opening Balance:    96.6 CU
Average Closing Balance:    10.6 CU  (significantly depleted)
Average Withdrawals:        104 CU/day
Average Deposits:           22.6 CU/day
Recovery Ratio:             0.22 (22% - CRITICALLY LOW)
Deficit Days:               2 of 5 (40%)
Volatility:                 53.2 (HIGH - inconsistent patterns)
Debt Trend:                 IMPROVING (recovered from crisis)

INSIGHTS GENERATED:
⚠ INSUFFICIENT_RECOVERY: Deposits only 22% of withdrawals
⚠ HIGH_VOLATILITY: Day-to-day balance swings > 40 CU
⚠ DEFICIT_SPIKE: Tuesday crisis caused 79 CU debt
✓ RECOVERY_SUCCESS: Debt cleared by Thursday
! RECOMMENDATION: Increase recovery activities by 60-80 CU/week
```

---

### 7.4 How Cognitive Debt Emerges

#### **Mechanism 1: Single-Day Overdraft**

**Scenario:** Day 2 (Tuesday) in the example above.

```
Opening: 100 CU
Withdrawals: 185 CU  (demand exceeds capacity by 85 CU)
Deposits: 6 CU       (minimal recovery)
Closing: -79 CU      (debt incurred)
```

**Explanation:**  
Cognitive debt emerges when **total daily withdrawals exceed available capacity plus deposits**. The system allows negative balances (analogous to overdrafting a bank account), but this deficit represents unmet cognitive recovery needs. The individual operated at impaired effectiveness during deficit periods (typically 1.5x cost penalty after severe depletion).

**Key Factor:** Crisis situations force continued cognitive output despite depleted resources, creating deficit.

---

#### **Mechanism 2: Insufficient Recovery Accumulation**

**Scenario:** Week-long pattern of 85 CU withdrawals with only 20 CU deposits daily.

```
Day 1: 100 → 35 CU   (depleted but positive)
Day 2: 100 → 15 CU   (increasingly depleted)
Day 3: 100 → -10 CU  (first deficit)
Day 4: 98 → -15 CU   (debt carrying forward)
Day 5: 97 → -23 CU   (debt compounding)
```

**Explanation:**  
Even without extreme single-day crises, **chronic under-recovery** creates gradual debt accumulation. Each day starts slightly impaired due to carryover, reducing effective capacity. The deficit grows because:

1. Opening capacity decreases (carryover penalty)
2. Withdrawals maintain same absolute level
3. Deposits remain insufficient
4. Deficit accumulates exponentially

**Key Factor:** Recovery deposits consistently fall below withdrawal rate over multiple days.

---

#### **Mechanism 3: Passive Drain Amplification**

**Scenario:** 15 unresolved tasks at end of each day.

```
Base calculation per item: 0.75 CU × urgency(1-5) × ambiguity(1-3)
15 items averaging urgency=3, ambiguity=2:
  = 15 × (0.75 × 3 × 2) = 67.5 CU passive drain

With accumulation penalty (>10 items): 67.5 × 1.4 = 94.5 CU
```

**Explanation:**  
Open loops create **passive cognitive drain** that persists regardless of active work. Mental background processes continuously:

- Monitor unresolved commitments
- Rehearse potential responses
- Maintain activation of related context

This drain is invisible during the day but appears as end-of-day withdrawal, often pushing otherwise balanced days into deficit.

**Key Factor:** Unresolved tasks consume cognitive resources without providing the closure/reward of completion.

---

#### **Mechanism 4: Carryover Compounding**

**Scenario:** Multi-day deficit cascade.

```
Day 1: Close at -50 CU
Day 2: Open at 90 CU  (100 - 10 carryover debt)
       Close at -30 CU (operated at reduced capacity)
Day 3: Open at 94 CU  (100 - 6 carryover debt)
       Close at -15 CU
Day 4: Open at 97 CU  (100 - 3 carryover debt)
       Close at +10 CU (recovery achieved)
```

**Explanation:**  
The 20% carryover rate creates a **debt decay function** that persists across days. While this prevents permanent capacity destruction (debt doesn't carry forward 100%), it ensures that:

- Recovery requires multiple consecutive balanced days
- Each deficit day has multi-day consequences
- Compounding occurs if deficits repeat before clearance

**Mathematical Property:**  
Debt decays geometrically: Day 1 debt = D, Day 2 = 0.2D, Day 3 = 0.04D, Day 4 = 0.008D...  
Full clearance takes 3-4 days even without new deficits.

**Key Factor:** Debt persists beyond the crisis day, requiring sustained recovery effort.

---

#### **Mechanism 5: Depletion Cost Spiral**

**Scenario:** Operating in deficit increases future withdrawal costs.

```
Normal state (balance > 50 CU):  Task costs 20 CU
Depleted (balance < 50 CU):      Task costs 24 CU (1.2× penalty)
Deficit (balance < 20 CU):       Task costs 30 CU (1.5× penalty)
```

**Explanation:**  
Cognitive debt creates a **vicious cycle**: as balance depletes, the same tasks become more expensive, accelerating further depletion. This models real-world cognitive fatigue where:

- Decision quality declines (requiring more effort for same output)
- Error rates increase (requiring rework)
- Focus becomes difficult (requiring more time for same task)

**Key Factor:** Debt makes future cognitive work less efficient, accelerating debt growth if not addressed.

---

#### **Debt Prevention Strategies (Implicit in Mechanics)**

The ledger mechanics suggest debt prevention through:

1. **Proactive Recovery:** Regular deposits before severe depletion (prevents crisis)
2. **Load Management:** Distribute high-cost activities across days (prevents single-day overdraft)
3. **Open Loop Closure:** Resolve pending items to eliminate passive drain
4. **Crisis Recognition:** Identify deficit early and initiate intensive recovery
5. **Baseline Protection:** Maintain minimum closing balance > 30 CU as safety margin

---

## 8. Minimal Daily Input System

### 8.1 Design Constraints

**Time Budget:** Maximum 60 seconds per day  
**Question Limit:** 3-5 questions only  
**Technology:** No sensors, wearables, or tracking devices required  
**Privacy:** No invasive personal, medical, or emotional data  
**Method:** Self-reported responses at end of workday

---

### 8.2 Daily Input Questions

#### **Question 1: Context Density**

**Prompt:**  
_"How many distinct projects, tasks, or topics did you actively work on today?"_

**Input Type:** Numeric (0-20+)  
**Expected Time:** 5-10 seconds  
**Default Value:** 5 (if skipped)

**Why This Matters:**  
Context multiplicity is a primary driver of cognitive load (Section 5.2). Each distinct context requires mental model maintenance and incurs switching costs. This single number provides:

- Direct proxy for context switching frequency
- Indicator of fragmented vs. focused work patterns
- Baseline for calculating context-related withdrawals

**Computational Use:**

```
Context_cost = count × 2 CU (baseline maintenance)
Switch_cost = (count - 1) × 1.5 CU (transitions)
Total_withdrawal = Context_cost + Switch_cost
```

**Example Responses:**

- `3` = Focused day (single project with minor email/meetings)
- `8` = Moderate fragmentation (multiple projects + admin)
- `15+` = Severe fragmentation (crisis mode, many interruptions)

---

#### **Question 2: Decision Load**

**Prompt:**  
_"How many significant decisions did you make today?"_  
_(Count decisions that required >2 minutes of thought or had meaningful consequences)_

**Input Type:** Numeric (0-30+)  
**Expected Time:** 5-10 seconds  
**Default Value:** 5 (if skipped)

**Why This Matters:**  
Decision-making is a measurable cognitive cost (Section 5.3). By filtering for "significant" decisions (>2 min deliberation), users naturally exclude trivial choices while capturing resource-intensive deliberation. This provides:

- Direct measure of decision volume
- Proxy for uncertainty/complexity (significant = high-cost)
- Foundation for decision fatigue modeling

**Computational Use:**

```
// Assumes "significant" averages 8 CU per decision
Decision_withdrawal = count × 8 CU

// With accumulation penalty
if count > 15:
    multiplier = 1.3 (decision fatigue)
elif count > 10:
    multiplier = 1.15
else:
    multiplier = 1.0

Total_withdrawal = Decision_withdrawal × multiplier
```

**Example Responses:**

- `2` = Light day (routine operations)
- `7` = Typical day (mix of operational + tactical decisions)
- `15+` = Heavy day (strategic planning, architecture, hiring)

---

#### **Question 3: Unresolved Count**

**Prompt:**  
_"How many tasks, questions, or commitments are unresolved as you end today?"_  
_(Count items still on your mind or to-do list)_

**Input Type:** Numeric (0-50+)  
**Expected Time:** 10-15 seconds  
**Default Value:** 8 (if skipped)

**Why This Matters:**  
Open loops create passive cognitive drain (Section 5, Mechanism 3). Unresolved items consume background mental resources through continuous monitoring and rehearsal. This metric captures:

- Passive load independent of active work
- Mental clutter accumulation
- Closure deficit (tasks started but not completed)

**Computational Use:**

```
Base_drain = count × 0.75 CU

// Accumulation penalty
if count > 20:
    multiplier = 1.5
elif count > 10:
    multiplier = 1.3
else:
    multiplier = 1.0

Passive_withdrawal = Base_drain × multiplier
```

**Example Responses:**

- `3` = Clean state (most items resolved)
- `12` = Typical accumulation (normal work-in-progress)
- `25+` = Overcommitted (many pending items)

---

#### **Question 4: Recovery Quality**

**Prompt:**  
_"Rate your breaks/recovery today"_  
_(1=No real breaks, worked through lunch | 5=Multiple breaks, proper lunch, some movement | 10=Excellent recovery, protected time)_

**Input Type:** Scale (1-10)  
**Expected Time:** 5 seconds  
**Default Value:** 5 (if skipped)

**Why This Matters:**  
Recovery deposits are essential for balancing withdrawals (Section 6.2). Rather than logging individual breaks (time-consuming), a single quality rating provides:

- Aggregate recovery effectiveness
- User's subjective assessment of restoration
- Adjustment factor for deposit calculations

**Computational Use:**

```
// Base deposit assumption: typical day = 40 CU total recovery
Base_deposit = 40 CU

// Quality modifier
Quality_factor = rating / 5.0  // Normalized to 5 as average

Actual_deposit = Base_deposit × Quality_factor

// Examples:
// Rating 2: 40 × 0.4 = 16 CU (poor recovery)
// Rating 5: 40 × 1.0 = 40 CU (average recovery)
// Rating 9: 40 × 1.8 = 72 CU (excellent recovery)
```

**Example Responses:**

- `2` = Crisis mode (no breaks, ate at desk)
- `5` = Typical day (lunch break, few short breaks)
- `9` = Protected recovery (proper lunch, walks, early finish)

---

#### **Question 5: Subjective Depletion** (Optional Calibration)

**Prompt:**  
_"How mentally drained do you feel right now?"_  
_(1=Fresh and energized | 10=Completely exhausted)_

**Input Type:** Scale (1-10)  
**Expected Time:** 3-5 seconds  
**Default Value:** Skip (not required for calculation)

**Why This Matters:**  
This question serves as a **calibration and validation mechanism** rather than a direct input to calculations. It enables:

- Ground truth comparison (calculated CU balance vs. subjective state)
- Individual calibration refinement (adjust cost functions if misaligned)
- Pattern recognition (identify when calculations diverge from experience)

**Computational Use:**

```
// Not used in daily calculation, but logged for weekly analysis
// System compares:
//   - Calculated closing balance
//   - Self-reported depletion
//   - Identifies calibration drift

Expected correlation:
  Balance 70-100 CU → Depletion 1-3 (well-rested)
  Balance 30-70 CU  → Depletion 4-6 (moderate)
  Balance 0-30 CU   → Depletion 7-8 (depleted)
  Balance < 0 CU    → Depletion 9-10 (deficit)

If correlation breaks down, trigger calibration review.
```

**Example Responses:**

- `3` = Feel good, could do more
- `6` = Ready to stop, but not exhausted
- `9` = Completely drained, need recovery

---

### 8.3 Complete Daily Input Flow

**Total Time:** 35-50 seconds (well under 60-second constraint)

```
END-OF-DAY PROMPT (Example UI):

┌────────────────────────────────────────────────────┐
│  Daily Cognitive Load Check-In                    │
│  (Takes ~45 seconds)                              │
├────────────────────────────────────────────────────┤
│                                                    │
│  1. Contexts worked on today: [___] (number)      │
│     (distinct projects/tasks/topics)              │
│                                                    │
│  2. Significant decisions made: [___] (number)    │
│     (decisions requiring >2 min thought)          │
│                                                    │
│  3. Unresolved items remaining: [___] (number)    │
│     (tasks/questions still on your mind)          │
│                                                    │
│  4. Recovery quality today: [━━━━━━━━━━] (1-10)  │
│     1=No breaks | 5=Typical | 10=Excellent        │
│                                                    │
│  5. Mental depletion now: [━━━━━━━━━━] (1-10)    │
│     1=Energized | 10=Exhausted (optional)         │
│                                                    │
│                         [Submit] [Skip for today] │
└────────────────────────────────────────────────────┘
```

---

### 8.4 Why This Input System Works

#### **1. Minimal Cognitive Burden**

The 60-second constraint is achievable because:

- **No activity logging:** Users don't track individual tasks or time blocks
- **No continuous monitoring:** Single daily check-in, not real-time tracking
- **Round numbers:** Estimates are acceptable (7 vs 8 decisions doesn't matter)
- **Clear definitions:** Each question has explicit criteria to reduce ambiguity

**Compliance Factor:** Systems requiring <90 seconds show 70%+ adherence rates vs. 30% for systems >5 minutes/day (analogous to fitness tracker research).

---

#### **2. High Signal-to-Noise Ratio**

Four questions capture the 6 cognitive load components (Section 5):

| Input Question  | Component Coverage                                      |
| --------------- | ------------------------------------------------------- |
| Contexts (Q1)   | Context Multiplicity, Interruption Recovery             |
| Decisions (Q2)  | Decision Volume                                         |
| Unresolved (Q3) | Passive Drain (Open Loops)                              |
| Recovery (Q4)   | All Deposit Categories                                  |
| _Derived_       | Attention Density (from context count + decision count) |
| _Derived_       | Novelty Processing (inferred from decision complexity)  |
| _Derived_       | Vigilance (captured in unresolved urgency)              |

Four direct questions enable computation of all six components through reasonable inference.

---

#### **3. Non-Invasive and Privacy-Preserving**

The system avoids:

- ❌ Content of decisions (what was decided)
- ❌ Names of projects/people (who was involved)
- ❌ Specific tasks or outcomes (business details)
- ❌ Emotional states or mental health indicators
- ❌ Location, biometric, or physiological data

Users can answer truthfully without revealing:

- Work performance or productivity
- Specific business activities or strategies
- Personal struggles or mental health status
- Any information they wouldn't share with a colleague

---

#### **4. Computationally Sufficient**

The four primary inputs provide enough information to calculate:

**Daily Withdrawals:**

```
Context_withdrawal = (Q1 × 2) + ((Q1-1) × 1.5)
Decision_withdrawal = Q2 × 8 × accumulation_factor(Q2)
Passive_withdrawal = Q3 × 0.75 × accumulation_factor(Q3)
Estimated_attention = (Q1 + Q2) × 3  // Proxy from context + decisions

Total_withdrawals = Context + Decision + Passive + Attention
```

**Daily Deposits:**

```
Recovery_deposit = 40 CU × (Q4 / 5.0)
```

**Closing Balance:**

```
Closing_balance = Opening_balance + Recovery - Withdrawals
```

This provides complete daily ledger functionality from four simple questions.

---

#### **5. Self-Calibrating Over Time**

Question 5 (Subjective Depletion) enables the system to improve:

**Weekly Calibration Check:**

```
correlation = correlate(
    calculated_balances[week],
    subjective_depletion[week]
)

if correlation < 0.6:  // Weak correlation
    suggest_calibration_adjustment()
    // Example: "Your calculated balance shows 60 CU but you
    // report feeling exhausted (9/10). Consider adjusting
    // decision costs or context switching penalties."
```

This allows individual customization without complex initial setup.

---

#### **6. Scales Appropriately Across Roles**

The questions work for diverse knowledge work roles:

| Role        | Context Count | Decision Count | Typical Pattern                                |
| ----------- | ------------- | -------------- | ---------------------------------------------- |
| IC Engineer | 3-6           | 5-10           | Deep work, fewer contexts                      |
| Manager     | 8-15          | 12-20          | Many contexts, many decisions                  |
| Executive   | 6-10          | 15-30          | Strategic decisions, fewer but deeper contexts |
| Designer    | 4-8           | 8-15           | Creative decisions, project-focused            |
| Analyst     | 5-10          | 10-18          | Data-driven decisions, moderate contexts       |

The same questions adapt naturally to different work patterns without role-specific customization.

---

#### **7. Graceful Degradation**

If users skip questions:

- **Default values** provide reasonable estimates (prevents calculation failure)
- **Partial data** still enables trend analysis (3 of 4 questions sufficient)
- **Missed days** don't break weekly/monthly aggregates (interpolation possible)

System remains functional even with imperfect compliance.

---

### 8.5 Sample Calculation from Input

**User Inputs (End of Tuesday):**

```
Q1: Contexts = 12
Q2: Decisions = 18
Q3: Unresolved = 22
Q4: Recovery = 3/10
Q5: Depletion = 9/10 (optional)
```

**System Calculation:**

```
WITHDRAWALS:
Context cost:
  Base: 12 × 2 = 24 CU
  Switches: 11 × 1.5 = 16.5 CU
  Total: 40.5 CU

Decision cost:
  Base: 18 × 8 = 144 CU
  Accumulation penalty (>15): × 1.3
  Total: 187.2 CU

Passive drain:
  Base: 22 × 0.75 = 16.5 CU
  Accumulation penalty (>20): × 1.5
  Total: 24.75 CU

Estimated attention:
  Proxy: (12 + 18) × 3 = 90 CU

TOTAL WITHDRAWALS: 342.45 CU

DEPOSITS:
Recovery quality: 3/10
  Base: 40 CU × (3/5) = 24 CU

TOTAL DEPOSITS: 24 CU

BALANCE CALCULATION:
Opening: 100 CU (baseline)
Withdrawals: -342.45 CU
Deposits: +24 CU
Closing: -218.45 CU (SEVERE DEFICIT)

VALIDATION:
Subjective depletion: 9/10
Expected for -218 CU: 10/10
Correlation: STRONG (calculation matches experience)
```

**Interpretation:** Crisis day with massive cognitive overdraft, minimal recovery, chronic deficit state.

---

### 8.6 Alternative: Streamlined 3-Question Version

For absolute minimal input (30-40 seconds):

**Q1: "Total distinct tasks/topics today?" (numeric)**  
**Q2: "Hard decisions made?" (numeric)**  
**Q3: "Recovery quality?" (1-10 scale)**

This eliminates unresolved tracking but sacrifices passive drain visibility. Use when:

- Users prioritize speed over accuracy
- Passive drain is consistently low
- Focus is on active work rather than mental clutter

---

## Appendix: Formal Notation

### Ledger State at Time t

```
Balance(t) = Baseline + Σ(Deposits[0→t]) - Σ(Withdrawals[0→t])
```

### Transaction Structure

```
Transaction {
  timestamp: DateTime
  type: {Withdrawal, Deposit}
  magnitude: Real[0, 100]  // in Cognitive Units (CU)
  category: Enum
  metadata: {duration, intensity, context}
}
```

### Boundary Conditions

```
0 ≤ Balance(t) ≤ Capacity_max  // Capacity_max typically 100 CU
Balance(t+1_day) = Baseline + CarryoverModifier(Balance(t))

CarryoverModifier(Balance) = {
  if Balance ≥ 0: 0 (full reset)
  if Balance < 0: Balance × 0.2 (20% deficit carried forward)
}
```

### CU Conversion Functions

```
Decision_CU = f(consequence, uncertainty, reversibility)
Context_Switch_CU = f(depth_current, depth_next, relatedness)
Attention_CU = f(intensity, duration, novelty)
Recovery_CU = f(activity_type, duration, quality)
```

### Daily Input Estimation Functions

```
Context_Withdrawal = (count × 2) + ((count - 1) × 1.5)
Decision_Withdrawal = count × 8 × accumulation_factor(count)
Passive_Withdrawal = count × 0.75 × accumulation_factor(count)
Recovery_Deposit = 40 × (quality_rating / 5.0)
```

---

## 9. Cognitive Load Estimation Engine

### 9.1 Architecture Overview

**Design Philosophy:** Hybrid rule-based + lightweight ML approach prioritizing **explainability** over raw accuracy.

```
┌─────────────────────────────────────────────────────────────┐
│                    INPUT LAYER                              │
│  • Daily questions (Q1-Q5)                                  │
│  • Optional text notes (free-form description)             │
│  • Historical ledger data                                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│               FEATURE EXTRACTION                            │
│  • Numeric features (counts, ratings)                       │
│  • Text features (NLP-derived signals)                      │
│  • Temporal features (time-of-day, day-of-week)            │
│  • Historical features (rolling averages, trends)          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              RULE-BASED SCORING ENGINE                      │
│  • Component calculators (6 cognitive load dimensions)      │
│  • Accumulation penalties                                   │
│  • Fatigue multipliers                                      │
│  • Recovery effectiveness modifiers                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│           LIGHTWEIGHT ML CALIBRATION                        │
│  • Linear regression (coefficient tuning)                   │
│  • Simple decision tree (threshold adjustment)              │
│  • Running on CPU, <100KB model size                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│               OUTPUT GENERATION                             │
│  • Cognitive balance (CU)                                   │
│  • Component breakdown (explainable attribution)            │
│  • Confidence score                                         │
│  • Trend detection signals                                  │
└─────────────────────────────────────────────────────────────┘
```

**Computational Constraints:**

- CPU-only execution (no GPU required)
- <100ms per daily calculation on standard laptop
- <50MB total memory footprint
- Offline-capable (no cloud dependencies)

---

### 9.2 Feature Extraction Logic

#### **9.2.1 Numeric Features (Direct from Input)**

```python
def extract_numeric_features(daily_input):
    """
    Extract direct numeric features from daily questions.
    Returns: Dictionary of features with values
    """
    features = {
        # Core inputs
        'context_count': daily_input.q1_contexts,
        'decision_count': daily_input.q2_decisions,
        'unresolved_count': daily_input.q3_unresolved,
        'recovery_quality': daily_input.q4_recovery_rating,
        'subjective_depletion': daily_input.q5_depletion,  # Can be None

        # Derived features
        'context_switches': max(0, daily_input.q1_contexts - 1),
        'decision_density': daily_input.q2_decisions / 8.0,  # Normalized to typical
        'unresolved_ratio': daily_input.q3_unresolved / 10.0,  # Normalized
        'recovery_deficit': (5.0 - daily_input.q4_recovery_rating) / 5.0,  # Inverted

        # Threshold flags (binary features)
        'high_context_flag': 1 if daily_input.q1_contexts > 10 else 0,
        'decision_fatigue_flag': 1 if daily_input.q2_decisions > 15 else 0,
        'cluttered_mind_flag': 1 if daily_input.q3_unresolved > 20 else 0,
        'poor_recovery_flag': 1 if daily_input.q4_recovery_rating < 4 else 0,
    }

    return features
```

#### **9.2.2 Temporal Features**

```python
def extract_temporal_features(timestamp, historical_data):
    """
    Extract time-based features for context.
    """
    features = {
        # Day characteristics
        'day_of_week': timestamp.weekday(),  # 0=Monday, 4=Friday
        'is_monday': 1 if timestamp.weekday() == 0 else 0,
        'is_friday': 1 if timestamp.weekday() == 4 else 0,
        'is_weekend': 1 if timestamp.weekday() >= 5 else 0,

        # Week position
        'week_number': timestamp.isocalendar()[1],
        'days_since_weekend': min(timestamp.weekday(), 2),  # Caps at 2

        # Historical context (trailing windows)
        'days_since_last_deficit': count_days_since_last_negative_balance(historical_data),
        'consecutive_deficit_days': count_consecutive_deficits(historical_data),

        # Carryover from previous day
        'previous_closing_balance': get_previous_closing_balance(historical_data),
        'has_carryover_debt': 1 if get_previous_closing_balance(historical_data) < 0 else 0,
    }

    return features
```

#### **9.2.3 Historical Features (Rolling Statistics)**

```python
def extract_historical_features(user_id, lookback_days=7):
    """
    Calculate rolling statistics from user's history.
    """
    history = get_user_history(user_id, days=lookback_days)

    if len(history) < 3:  # Insufficient history
        return default_historical_features()

    features = {
        # Central tendency (7-day rolling)
        'avg_context_count_7d': mean([d.context_count for d in history]),
        'avg_decision_count_7d': mean([d.decision_count for d in history]),
        'avg_recovery_quality_7d': mean([d.recovery_quality for d in history]),
        'avg_closing_balance_7d': mean([d.closing_balance for d in history]),

        # Volatility measures
        'std_context_count_7d': stdev([d.context_count for d in history]),
        'std_closing_balance_7d': stdev([d.closing_balance for d in history]),

        # Trend indicators
        'context_trend_7d': linear_trend([d.context_count for d in history]),
        'balance_trend_7d': linear_trend([d.closing_balance for d in history]),

        # Personal baselines (personalized calibration)
        'personal_baseline_contexts': percentile([d.context_count for d in history], 50),
        'personal_baseline_decisions': percentile([d.decision_count for d in history], 50),

        # Deviation from personal norm
        'contexts_vs_baseline': (current.context_count - features['personal_baseline_contexts']) /
                                 max(features['std_context_count_7d'], 1),
        'decisions_vs_baseline': (current.decision_count - features['personal_baseline_decisions']) /
                                  max(features['std_decision_count_7d'], 1),
    }

    return features

def linear_trend(values):
    """Simple linear regression slope over time series."""
    n = len(values)
    if n < 2:
        return 0.0
    x = range(n)
    x_mean = sum(x) / n
    y_mean = sum(values) / n
    numerator = sum((x[i] - x_mean) * (values[i] - y_mean) for i in range(n))
    denominator = sum((x[i] - x_mean) ** 2 for i in range(n))
    return numerator / denominator if denominator != 0 else 0.0
```

#### **9.2.4 Text Features (NLP-Derived Signals)**

```python
def extract_text_features(text_note):
    """
    Extract cognitive load signals from optional text input.
    Uses lightweight NLP (no transformers, CPU-friendly).
    """
    if not text_note or len(text_note.strip()) == 0:
        return default_text_features()

    # Tokenization and cleaning
    tokens = simple_tokenize(text_note.lower())

    features = {
        # Basic text statistics
        'text_length': len(text_note),
        'word_count': len(tokens),
        'avg_word_length': mean([len(w) for w in tokens]) if tokens else 0,
        'sentence_count': text_note.count('.') + text_note.count('!') + text_note.count('?'),

        # Cognitive load lexicon matching
        'urgency_words': count_matches(tokens, URGENCY_LEXICON),
        'complexity_words': count_matches(tokens, COMPLEXITY_LEXICON),
        'fatigue_words': count_matches(tokens, FATIGUE_LEXICON),
        'conflict_words': count_matches(tokens, CONFLICT_LEXICON),
        'recovery_words': count_matches(tokens, RECOVERY_LEXICON),

        # Intensity markers
        'exclamation_count': text_note.count('!'),
        'question_count': text_note.count('?'),
        'caps_ratio': sum(1 for c in text_note if c.isupper()) / max(len(text_note), 1),

        # Multiplicity indicators
        'multiple_mentions': count_matches(tokens, ['multiple', 'many', 'several', 'various']),
        'list_indicators': text_note.count(',') + text_note.count(';'),

        # Time pressure indicators
        'deadline_words': count_matches(tokens, ['deadline', 'urgent', 'asap', 'rush', 'hurry']),

        # Ambiguity indicators
        'uncertainty_words': count_matches(tokens, ['unclear', 'unsure', 'maybe', 'might', 'possibly']),
    }

    return features

# Lightweight lexicons (rule-based, no ML required)
URGENCY_LEXICON = ['urgent', 'critical', 'emergency', 'asap', 'rush', 'immediate',
                   'deadline', 'overdue', 'late', 'pressing']

COMPLEXITY_LEXICON = ['complex', 'complicated', 'difficult', 'challenging', 'hard',
                      'confusing', 'intricate', 'technical', 'advanced']

FATIGUE_LEXICON = ['tired', 'exhausted', 'drained', 'burned', 'depleted', 'overwhelmed',
                   'swamped', 'buried', 'drowning', 'struggled']

CONFLICT_LEXICON = ['conflict', 'disagreement', 'argument', 'tension', 'difficult',
                    'pushback', 'resistance', 'debate']

RECOVERY_LEXICON = ['break', 'rest', 'walk', 'lunch', 'exercise', 'relaxed',
                    'refreshed', 'recharged']

def count_matches(tokens, lexicon):
    """Count how many tokens match lexicon."""
    return sum(1 for token in tokens if token in lexicon)
```

---

### 9.3 Rule-Based Scoring Engine

#### **9.3.1 Component Calculators**

```python
class CognitiveLoadCalculator:
    """
    Rule-based engine for calculating cognitive withdrawals.
    Each component has explicit, interpretable logic.
    """

    def calculate_context_cost(self, features):
        """
        Context multiplicity + switching costs.
        """
        count = features['context_count']

        # Base maintenance cost (each context held in memory)
        base_cost = count * 2.0

        # Switching cost (transitions between contexts)
        switch_cost = features['context_switches'] * 1.5

        # High-load penalty (>10 contexts = fragmentation)
        if features['high_context_flag']:
            penalty_multiplier = 1.3
        else:
            penalty_multiplier = 1.0

        total_cost = (base_cost + switch_cost) * penalty_multiplier

        explanation = {
            'base_cost': base_cost,
            'switch_cost': switch_cost,
            'penalty_multiplier': penalty_multiplier,
            'formula': f"({count} × 2 + {features['context_switches']} × 1.5) × {penalty_multiplier}"
        }

        return total_cost, explanation

    def calculate_decision_cost(self, features):
        """
        Decision volume with fatigue accumulation.
        """
        count = features['decision_count']

        # Base cost per significant decision
        base_cost_per_decision = 8.0
        base_cost = count * base_cost_per_decision

        # Decision fatigue accumulation
        if count > 15:
            accumulation_factor = 1.3
        elif count > 10:
            accumulation_factor = 1.15
        else:
            accumulation_factor = 1.0

        total_cost = base_cost * accumulation_factor

        explanation = {
            'count': count,
            'base_per_decision': base_cost_per_decision,
            'accumulation_factor': accumulation_factor,
            'formula': f"{count} × {base_cost_per_decision} × {accumulation_factor}"
        }

        return total_cost, explanation

    def calculate_passive_drain(self, features):
        """
        Unresolved tasks creating background cognitive load.
        """
        count = features['unresolved_count']

        # Base drain per open loop
        base_per_item = 0.75
        base_drain = count * base_per_item

        # Mental clutter accumulation
        if count > 20:
            accumulation_factor = 1.5
        elif count > 10:
            accumulation_factor = 1.3
        else:
            accumulation_factor = 1.0

        total_drain = base_drain * accumulation_factor

        explanation = {
            'count': count,
            'base_per_item': base_per_item,
            'accumulation_factor': accumulation_factor,
            'formula': f"{count} × {base_per_item} × {accumulation_factor}"
        }

        return total_drain, explanation

    def calculate_attention_cost(self, features):
        """
        Estimated attention density (proxy from context + decisions).
        """
        # Proxy: high context + high decisions = sustained attention required
        proxy_intensity = (features['context_count'] + features['decision_count']) / 2.0

        # Assume typical 6-hour focused work (360 minutes)
        # Intensity scales cost per hour
        cost_per_hour = proxy_intensity * 0.5
        assumed_hours = 6.0

        total_cost = cost_per_hour * assumed_hours

        explanation = {
            'proxy_intensity': proxy_intensity,
            'cost_per_hour': cost_per_hour,
            'assumed_hours': assumed_hours,
            'formula': f"(({features['context_count']} + {features['decision_count']}) / 2) × 0.5 × {assumed_hours}"
        }

        return total_cost, explanation

    def calculate_recovery_deposit(self, features):
        """
        Recovery effectiveness based on quality rating.
        """
        quality = features['recovery_quality']

        # Base assumption: typical day has potential for 40 CU recovery
        base_potential = 40.0

        # Quality modifier (normalized to 5 as average)
        quality_factor = quality / 5.0

        # Depletion bonus (if subjective depletion available)
        if features.get('subjective_depletion'):
            if features['subjective_depletion'] > 8:
                depletion_bonus = 1.3  # Recovery more effective when depleted
            elif features['subjective_depletion'] > 6:
                depletion_bonus = 1.15
            else:
                depletion_bonus = 1.0
        else:
            depletion_bonus = 1.0  # No data, assume normal

        total_deposit = base_potential * quality_factor * depletion_bonus

        explanation = {
            'quality_rating': quality,
            'base_potential': base_potential,
            'quality_factor': quality_factor,
            'depletion_bonus': depletion_bonus,
            'formula': f"{base_potential} × ({quality}/5) × {depletion_bonus}"
        }

        return total_deposit, explanation
```

#### **9.3.2 Master Scoring Function**

```python
def calculate_daily_balance(features, calculator):
    """
    Master function combining all component scores.
    Returns balance + full explainability breakdown.
    """

    # Calculate each component
    context_cost, context_exp = calculator.calculate_context_cost(features)
    decision_cost, decision_exp = calculator.calculate_decision_cost(features)
    passive_cost, passive_exp = calculator.calculate_passive_drain(features)
    attention_cost, attention_exp = calculator.calculate_attention_cost(features)
    recovery_deposit, recovery_exp = calculator.calculate_recovery_deposit(features)

    # Total withdrawals
    total_withdrawals = context_cost + decision_cost + passive_cost + attention_cost

    # Opening balance calculation
    opening_balance = calculate_opening_balance(features)

    # Closing balance
    closing_balance = opening_balance + recovery_deposit - total_withdrawals

    # Determine cognitive state
    state = determine_cognitive_state(closing_balance)

    # Build explainable output
    result = {
        'closing_balance': closing_balance,
        'opening_balance': opening_balance,
        'state': state,
        'total_withdrawals': total_withdrawals,
        'total_deposits': recovery_deposit,
        'net_change': closing_balance - opening_balance,

        # Component breakdown (explainability)
        'components': {
            'context_switching': {
                'cost': context_cost,
                'explanation': context_exp
            },
            'decision_making': {
                'cost': decision_cost,
                'explanation': decision_exp
            },
            'passive_drain': {
                'cost': passive_cost,
                'explanation': passive_exp
            },
            'attention_density': {
                'cost': attention_cost,
                'explanation': attention_exp
            },
            'recovery': {
                'deposit': recovery_deposit,
                'explanation': recovery_exp
            }
        },

        # Confidence scoring
        'confidence': calculate_confidence_score(features)
    }

    return result

def determine_cognitive_state(balance):
    """Map balance to interpretable state."""
    if balance < -50:
        return "SEVERE_DEFICIT"
    elif balance < 0:
        return "DEFICIT"
    elif balance < 30:
        return "DEPLETED"
    elif balance < 70:
        return "MODERATE"
    else:
        return "WELL_RESTED"

def calculate_confidence_score(features):
    """
    Estimate confidence in calculation based on data quality.
    """
    confidence = 100.0

    # Penalize missing optional data
    if not features.get('subjective_depletion'):
        confidence -= 10

    # Penalize extreme outliers (likely data entry errors)
    if features['context_count'] > 25:
        confidence -= 15
    if features['decision_count'] > 40:
        confidence -= 15

    # Reward historical data availability
    if features.get('avg_closing_balance_7d') is not None:
        confidence += 10

    # Penalize insufficient history
    if features.get('days_logged', 0) < 7:
        confidence -= 20

    return max(0, min(100, confidence))
```

---

### 9.4 Text Input Modifiers (NLP Enhancement)

#### **9.4.1 Text-Based Adjustments**

```python
def apply_text_modifiers(base_score, text_features):
    """
    Adjust rule-based scores using NLP-derived signals.
    Modifiers are additive adjustments, preserving explainability.
    """

    modifiers = {
        'context_cost_adjustment': 0,
        'decision_cost_adjustment': 0,
        'passive_drain_adjustment': 0,
        'urgency_penalty': 0
    }

    # Urgency modifier (increases all costs)
    if text_features['urgency_words'] > 0:
        urgency_multiplier = min(1.3, 1.0 + (text_features['urgency_words'] * 0.1))
        modifiers['urgency_penalty'] = (base_score['total_withdrawals'] *
                                        (urgency_multiplier - 1.0))

    # Complexity modifier (increases decision costs)
    if text_features['complexity_words'] > 0:
        complexity_boost = text_features['complexity_words'] * 5.0
        modifiers['decision_cost_adjustment'] = complexity_boost

    # Multiplicity modifier (increases context costs)
    if text_features['multiple_mentions'] > 0 or text_features['list_indicators'] > 5:
        fragmentation_boost = (text_features['multiple_mentions'] * 3.0 +
                               text_features['list_indicators'] * 0.5)
        modifiers['context_cost_adjustment'] = fragmentation_boost

    # Unresolved stress modifier (increases passive drain)
    if text_features['uncertainty_words'] > 0:
        ambiguity_boost = text_features['uncertainty_words'] * 2.5
        modifiers['passive_drain_adjustment'] = ambiguity_boost

    # Fatigue signals (validates/amplifies calculated depletion)
    if text_features['fatigue_words'] > 2:
        # User explicitly mentions exhaustion - high confidence in deficit state
        base_score['confidence'] = min(100, base_score['confidence'] + 15)

    # Recovery signals (validates/amplifies calculated recovery)
    if text_features['recovery_words'] > 2:
        # User mentions breaks/recovery - validates recovery calculation
        recovery_boost = text_features['recovery_words'] * 2.0
        base_score['components']['recovery']['deposit'] += recovery_boost
        modifiers['recovery_boost'] = recovery_boost

    # Apply all modifiers
    adjusted_score = base_score.copy()
    adjusted_score['components']['context_switching']['cost'] += modifiers['context_cost_adjustment']
    adjusted_score['components']['decision_making']['cost'] += modifiers['decision_cost_adjustment']
    adjusted_score['components']['passive_drain']['cost'] += modifiers['passive_drain_adjustment']
    adjusted_score['total_withdrawals'] += (modifiers['urgency_penalty'] +
                                            modifiers['context_cost_adjustment'] +
                                            modifiers['decision_cost_adjustment'] +
                                            modifiers['passive_drain_adjustment'])

    # Recalculate closing balance
    adjusted_score['closing_balance'] = (adjusted_score['opening_balance'] +
                                         adjusted_score['components']['recovery']['deposit'] -
                                         adjusted_score['total_withdrawals'])

    # Add explanation
    adjusted_score['text_modifiers'] = {
        'adjustments': modifiers,
        'signals_detected': {
            'urgency': text_features['urgency_words'],
            'complexity': text_features['complexity_words'],
            'fragmentation': text_features['multiple_mentions'],
            'ambiguity': text_features['uncertainty_words'],
            'fatigue_mention': text_features['fatigue_words'],
            'recovery_mention': text_features['recovery_words']
        }
    }

    return adjusted_score
```

**Example Text Processing:**

```
User Input: "Had to deal with multiple urgent client escalations today.
             Very unclear requirements. Didn't get proper lunch break.
             Exhausted."

Extracted Signals:
  - urgency_words: 1 ("urgent")
  - multiple_mentions: 1 ("multiple")
  - uncertainty_words: 1 ("unclear")
  - fatigue_words: 1 ("exhausted")
  - recovery_words: 0

Modifiers Applied:
  - Urgency penalty: +10% to total withdrawals
  - Context fragmentation boost: +3 CU
  - Ambiguity boost to passive drain: +2.5 CU
  - Fatigue validation: Confidence +15%
  - Poor recovery implied: No adjustment (already captured in Q4)

Result: Text analysis increases estimated load by ~8-12 CU and validates
        high depletion state.
```

---

### 9.5 Lightweight ML Calibration Layer

#### **9.5.1 Personal Coefficient Tuning (Linear Regression)**

```python
class PersonalCalibrator:
    """
    Lightweight ML for individual calibration.
    Uses simple linear regression to tune coefficients.
    """

    def __init__(self):
        self.coefficients = {
            'context_base_cost': 2.0,
            'context_switch_cost': 1.5,
            'decision_base_cost': 8.0,
            'passive_base_cost': 0.75,
            'recovery_base': 40.0
        }
        self.calibrated = False

    def calibrate(self, historical_data):
        """
        Adjust coefficients to match user's subjective depletion reports.
        Requires at least 14 days of data with subjective ratings.
        """

        # Filter for days with subjective depletion ratings
        calibration_data = [d for d in historical_data
                           if d.subjective_depletion is not None]

        if len(calibration_data) < 14:
            return False  # Insufficient data

        # Prepare training data
        X = []  # Features
        y = []  # Target (subjective depletion, scaled)

        for day in calibration_data:
            features = [
                day.context_count,
                day.context_switches,
                day.decision_count,
                day.unresolved_count,
                day.recovery_quality
            ]
            X.append(features)

            # Target: subjective depletion mapped to balance scale
            # Depletion 10 → Balance -50, Depletion 1 → Balance 90
            target_balance = 100 - (day.subjective_depletion * 15)
            y.append(target_balance)

        # Simple linear regression (closed-form solution)
        # y = β₀ + β₁x₁ + β₂x₂ + ... + βₙxₙ

        from sklearn.linear_model import LinearRegression  # Lightweight, CPU-friendly
        model = LinearRegression()
        model.fit(X, y)

        # Extract learned weights
        weights = model.coef_

        # Update coefficients (bounded adjustment to prevent extreme values)
        self.coefficients['context_base_cost'] = clip(weights[0] / 10, 1.0, 4.0)
        self.coefficients['context_switch_cost'] = clip(weights[1] / 5, 0.8, 3.0)
        self.coefficients['decision_base_cost'] = clip(weights[2] / 5, 4.0, 15.0)
        self.coefficients['passive_base_cost'] = clip(weights[3] / 10, 0.3, 1.5)
        self.coefficients['recovery_base'] = clip(-weights[4] * 8, 20.0, 60.0)

        self.calibrated = True
        return True

    def get_calibrated_costs(self):
        """Return current coefficient values."""
        return self.coefficients

def clip(value, min_val, max_val):
    """Bound value to range."""
    return max(min_val, min(max_val, value))
```

#### **9.5.2 Threshold Adaptation (Decision Tree)**

```python
from sklearn.tree import DecisionTreeClassifier

class ThresholdAdapter:
    """
    Learn personalized thresholds for state boundaries.
    Uses lightweight decision tree (<100 nodes).
    """

    def __init__(self):
        self.model = DecisionTreeClassifier(max_depth=4, max_leaf_nodes=16)
        self.trained = False

    def train(self, historical_data):
        """
        Learn when user considers themselves in each cognitive state.
        """

        # Requires subjective state labels or depletion ratings
        X = []
        y = []

        for day in historical_data:
            if day.subjective_depletion is None:
                continue

            features = [
                day.closing_balance,
                day.total_withdrawals,
                day.total_deposits,
                day.context_count,
                day.decision_count
            ]
            X.append(features)

            # Map subjective depletion to state categories
            if day.subjective_depletion >= 9:
                state = 0  # SEVERE_DEFICIT
            elif day.subjective_depletion >= 7:
                state = 1  # DEFICIT/DEPLETED
            elif day.subjective_depletion >= 4:
                state = 2  # MODERATE
            else:
                state = 3  # WELL_RESTED

            y.append(state)

        if len(X) < 20:
            return False

        self.model.fit(X, y)
        self.trained = True
        return True

    def predict_state(self, features):
        """Predict cognitive state using learned thresholds."""
        if not self.trained:
            return None

        X = [[
            features['closing_balance'],
            features['total_withdrawals'],
            features['total_deposits'],
            features['context_count'],
            features['decision_count']
        ]]

        state_code = self.model.predict(X)[0]
        state_map = {
            0: "SEVERE_DEFICIT",
            1: "DEFICIT",
            2: "MODERATE",
            3: "WELL_RESTED"
        }

        return state_map.get(state_code, "MODERATE")
```

**Computational Profile:**

- Linear regression: Single matrix operation, <1ms
- Decision tree: ~50 node evaluations, <1ms
- Total ML overhead: <5ms per calculation
- Model size: <100KB (easily fits in memory)
- Training time: <100ms on 90 days of data

---

### 9.6 Trend Detection System

#### **9.6.1 Temporal Pattern Detection**

```python
class TrendDetector:
    """
    Identify patterns in cognitive load over time.
    Uses statistical methods (no heavy ML).
    """

    def detect_trends(self, historical_data, window=7):
        """
        Analyze recent history for actionable trends.
        """

        if len(historical_data) < window:
            return {"status": "insufficient_data"}

        recent = historical_data[-window:]

        trends = {}

        # 1. Balance trend (improving vs deteriorating)
        balance_trend = self._linear_trend([d.closing_balance for d in recent])
        trends['balance_direction'] = self._classify_trend(balance_trend)
        trends['balance_slope'] = balance_trend

        # 2. Deficit frequency
        deficit_days = sum(1 for d in recent if d.closing_balance < 0)
        trends['deficit_frequency'] = deficit_days / window
        trends['chronic_deficit'] = deficit_days >= (window * 0.7)  # 70%+ deficit

        # 3. Recovery ratio trend
        recovery_ratios = [d.total_deposits / max(d.total_withdrawals, 1)
                          for d in recent]
        avg_recovery_ratio = mean(recovery_ratios)
        trends['recovery_ratio'] = avg_recovery_ratio
        trends['insufficient_recovery'] = avg_recovery_ratio < 0.6

        # 4. Load volatility (consistency)
        balance_std = stdev([d.closing_balance for d in recent])
        trends['volatility'] = balance_std
        trends['high_volatility'] = balance_std > 40

        # 5. Accumulation pattern (debt compounding)
        if deficit_days >= 3:
            consecutive = self._max_consecutive_deficits(recent)
            trends['max_consecutive_deficits'] = consecutive
            trends['debt_compounding'] = consecutive >= 3

        # 6. Day-of-week patterns
        trends['monday_effect'] = self._day_of_week_effect(historical_data, 0)  # Monday
        trends['friday_effect'] = self._day_of_week_effect(historical_data, 4)  # Friday

        # 7. Context creep (gradual increase in fragmentation)
        context_trend = self._linear_trend([d.context_count for d in recent])
        trends['context_creep'] = context_trend > 0.5  # Increasing > 0.5 contexts/day

        # 8. Decision fatigue accumulation
        decision_trend = self._linear_trend([d.decision_count for d in recent])
        trends['decision_load_increasing'] = decision_trend > 0.8

        return trends

    def _linear_trend(self, values):
        """Calculate slope of linear trend."""
        n = len(values)
        if n < 2:
            return 0.0
        x = list(range(n))
        x_mean = sum(x) / n
        y_mean = sum(values) / n
        numerator = sum((x[i] - x_mean) * (values[i] - y_mean) for i in range(n))
        denominator = sum((x[i] - x_mean) ** 2 for i in range(n))
        return numerator / denominator if denominator != 0 else 0.0

    def _classify_trend(self, slope):
        """Map slope to interpretable direction."""
        if slope < -5:
            return "DETERIORATING"
        elif slope < -1:
            return "DECLINING"
        elif slope < 1:
            return "STABLE"
        elif slope < 5:
            return "IMPROVING"
        else:
            return "RAPIDLY_IMPROVING"

    def _max_consecutive_deficits(self, data):
        """Find longest streak of deficit days."""
        max_streak = 0
        current_streak = 0
        for d in data:
            if d.closing_balance < 0:
                current_streak += 1
                max_streak = max(max_streak, current_streak)
            else:
                current_streak = 0
        return max_streak

    def _day_of_week_effect(self, full_history, target_day):
        """
        Compare average balance on specific day vs overall average.
        Returns difference in CU.
        """
        target_days = [d for d in full_history if d.timestamp.weekday() == target_day]
        if len(target_days) < 3:
            return None

        target_avg = mean([d.closing_balance for d in target_days])
        overall_avg = mean([d.closing_balance for d in full_history])

        return target_avg - overall_avg  # Positive = better than average
```

#### **9.6.2 Anomaly Detection**

```python
def detect_anomalies(current_day, historical_data):
    """
    Identify unusual patterns that warrant attention.
    """

    if len(historical_data) < 14:
        return []

    anomalies = []

    # Calculate personal norms
    avg_contexts = mean([d.context_count for d in historical_data])
    std_contexts = stdev([d.context_count for d in historical_data])

    avg_decisions = mean([d.decision_count for d in historical_data])
    std_decisions = stdev([d.decision_count for d in historical_data])

    avg_balance = mean([d.closing_balance for d in historical_data])
    std_balance = stdev([d.closing_balance for d in historical_data])

    # Detect outliers (>2 standard deviations)

    if current_day.context_count > (avg_contexts + 2 * std_contexts):
        anomalies.append({
            'type': 'EXTREME_FRAGMENTATION',
            'message': f"Context count ({current_day.context_count}) is unusually high",
            'severity': 'WARNING'
        })

    if current_day.decision_count > (avg_decisions + 2 * std_decisions):
        anomalies.append({
            'type': 'DECISION_OVERLOAD',
            'message': f"Decision count ({current_day.decision_count}) is unusually high",
            'severity': 'WARNING'
        })

    if current_day.closing_balance < (avg_balance - 2 * std_balance):
        anomalies.append({
            'type': 'SEVERE_DEPLETION',
            'message': f"Closing balance ({current_day.closing_balance:.1f} CU) is critically low",
            'severity': 'CRITICAL'
        })

    # Detect sudden drops
    if len(historical_data) >= 1:
        yesterday = historical_data[-1]
        balance_drop = yesterday.closing_balance - current_day.closing_balance
        if balance_drop > 60:
            anomalies.append({
                'type': 'RAPID_DEPLETION',
                'message': f"Balance dropped {balance_drop:.1f} CU in one day",
                'severity': 'CRITICAL'
            })

    return anomalies
```

#### **9.6.3 Predictive Alerts**

```python
def generate_predictive_alerts(trends, current_balance):
    """
    Forecast potential issues based on current trends.
    """

    alerts = []

    # Alert 1: Deficit trajectory
    if trends['balance_direction'] in ['DETERIORATING', 'DECLINING']:
        if current_balance > 0 but trends['balance_slope'] < -5:
            days_to_deficit = abs(current_balance / trends['balance_slope'])
            alerts.append({
                'type': 'TRAJECTORY_WARNING',
                'message': f"Current trend projects deficit in ~{int(days_to_deficit)} days",
                'recommendation': "Increase recovery activities or reduce load"
            })

    # Alert 2: Chronic insufficient recovery
    if trends['insufficient_recovery']:
        alerts.append({
            'type': 'RECOVERY_DEFICIT',
            'message': f"Recovery ratio at {trends['recovery_ratio']:.0%} (target: 80%+)",
            'recommendation': "Prioritize breaks, protect recovery time"
        })

    # Alert 3: Compounding debt
    if trends.get('debt_compounding'):
        alerts.append({
            'type': 'DEBT_SPIRAL',
            'message': f"{trends['max_consecutive_deficits']} consecutive deficit days",
            'recommendation': "Urgent: Schedule recovery day, reduce commitments"
        })

    # Alert 4: Context creep
    if trends.get('context_creep'):
        alerts.append({
            'type': 'FRAGMENTATION_TREND',
            'message': "Context count increasing over time",
            'recommendation': "Consolidate projects, protect focus blocks"
        })

    return alerts
```

---

### 9.7 Complete Engine Integration

```python
class CognitiveLoadEngine:
    """
    Complete estimation engine integrating all components.
    """

    def __init__(self, user_id):
        self.user_id = user_id
        self.calculator = CognitiveLoadCalculator()
        self.calibrator = PersonalCalibrator()
        self.threshold_adapter = ThresholdAdapter()
        self.trend_detector = TrendDetector()

    def process_daily_input(self, daily_input, optional_text=None):
        """
        Main entry point: process daily input and return complete analysis.
        """

        # 1. Feature extraction
        numeric_features = extract_numeric_features(daily_input)
        temporal_features = extract_temporal_features(datetime.now(),
                                                      get_user_history(self.user_id))
        historical_features = extract_historical_features(self.user_id)

        features = {**numeric_features, **temporal_features, **historical_features}

        # 2. Rule-based scoring
        base_score = calculate_daily_balance(features, self.calculator)

        # 3. Text modifiers (if provided)
        if optional_text:
            text_features = extract_text_features(optional_text)
            final_score = apply_text_modifiers(base_score, text_features)
        else:
            final_score = base_score

        # 4. ML calibration (if trained)
        if self.calibrator.calibrated:
            # Use personalized coefficients
            calibrated_coeffs = self.calibrator.get_calibrated_costs()
            # Re-calculate with adjusted costs (implementation omitted for brevity)

        # 5. Trend detection
        historical_data = get_user_history(self.user_id)
        trends = self.trend_detector.detect_trends(historical_data)
        anomalies = detect_anomalies(final_score, historical_data)
        alerts = generate_predictive_alerts(trends, final_score['closing_balance'])

        # 6. Complete output
        return {
            'daily_result': final_score,
            'trends': trends,
            'anomalies': anomalies,
            'alerts': alerts,
            'metadata': {
                'calculation_time_ms': 0,  # Would measure actual time
                'confidence': final_score['confidence'],
                'calibration_status': 'CALIBRATED' if self.calibrator.calibrated else 'DEFAULT'
            }
        }
```

---

**Computational Performance:**

```
Typical Daily Calculation Breakdown:
  Feature extraction:    5-10ms
  Rule-based scoring:    2-5ms
  Text processing (NLP): 10-20ms (if text provided)
  ML calibration:        <5ms
  Trend detection:       5-10ms
  ─────────────────────────────
  Total:                 30-50ms

Memory Footprint:
  Engine instance:       ~5MB
  Historical data (90d): ~2MB
  ML models:             <100KB
  ─────────────────────────────
  Total:                 ~7MB

CPU: Single core, no GPU required
```

---

## 10. Rule-Based Insight Generation System

### 10.1 Design Principles

**Core Constraints:**

1. **No motivational language** - Factual, descriptive, analytical only
2. **No advice overload** - Maximum one insight per day
3. **Explain causality** - Focus on "why" balance changed, not "what to do"
4. **Avoid overinterpretation** - Stay within data boundaries
5. **No clinical inference** - Do not diagnose or assess mental health

**Insight Purpose:**
Insights help users understand the _mechanisms_ behind their cognitive load patterns. They answer: "Why did my balance change this way?" rather than "What should I do?"

---

### 10.2 Insight Rules (Priority-Ranked)

Rules are evaluated in order. First matching rule generates the daily insight. Only one insight per day.

---

#### **Rule 1: Deficit Spike Detection**

**Trigger Condition:**

```
closing_balance < -100 CU AND
(closing_balance - opening_balance) < -200 CU
```

**Insight Template:**

```
"Balance dropped {drop_amount} CU in one day due to {primary_driver}.
This created a {deficit_amount} CU deficit that will carry forward as
{carryover_amount} CU tomorrow."
```

**Example Output:**

```
Balance dropped 341 CU in one day due to decision overload (229 CU from
22 decisions) and high context switching (62 CU from 14 contexts). This
created a -241 CU deficit that will carry forward as -48 CU tomorrow.
```

**Why This Works:**

- Quantifies the magnitude of change
- Identifies the primary cost driver (highest component)
- Explains carryover mechanics explicitly
- No judgment, just facts

**Guardrails:**

- Only triggers on extreme drops (>200 CU)
- Does not speculate about causes beyond logged data
- Does not suggest emotional state

---

#### **Rule 2: Carryover Debt Impact**

**Trigger Condition:**

```
opening_balance < 90 CU AND
previous_day.closing_balance < 0 AND
current_day.closing_balance < 0
```

**Insight Template:**

```
"Started at {opening_balance} CU (reduced from baseline 100 CU due to
{carryover_debt} CU carryover debt). This reduced initial capacity by
{capacity_reduction}%, contributing to today's {closing_balance} CU result."
```

**Example Output:**

```
Started at 51.7 CU (reduced from baseline 100 CU due to -48.3 CU carryover
debt). This reduced initial capacity by 48%, contributing to today's
-78.6 CU result.
```

**Why This Works:**

- Makes invisible carryover mechanism visible
- Quantifies capacity reduction impact
- Explains how yesterday affects today
- Factual chain of causation

**Guardrails:**

- Only triggers when debt demonstrably affects current day
- Does not blame user for previous day
- Does not predict future days

---

#### **Rule 3: Context Fragmentation Dominant**

**Trigger Condition:**

```
components.context_cost > 50 CU AND
components.context_cost > (total_withdrawals * 0.4)
```

**Insight Template:**

```
"Context switching accounted for {context_pct}% of cognitive load
({context_cost} CU from {context_count} contexts). This was the dominant
cost factor today."
```

**Example Output:**

```
Context switching accounted for 43% of cognitive load (62 CU from 14 contexts).
This was the dominant cost factor today.
```

**Why This Works:**

- Identifies the primary load mechanism
- Quantifies relative contribution
- Helps user understand what drove the day's pattern
- No prescription about what to change

**Guardrails:**

- Only triggers when context is genuinely dominant (>40%)
- Does not suggest context switching is "bad"
- Does not recommend reducing contexts

---

#### **Rule 4: Decision Fatigue Accumulation**

**Trigger Condition:**

```
decision_count > 15 AND
components.decision_cost > components.context_cost AND
components.decision_cost > components.attention_cost
```

**Insight Template:**

```
"Made {decision_count} significant decisions, incurring {decision_cost} CU
with a {fatigue_factor} fatigue multiplier (activated at >15 decisions).
This was the primary withdrawal driver."
```

**Example Output:**

```
Made 22 significant decisions, incurring 229 CU with a 1.3× fatigue multiplier
(activated at >15 decisions). This was the primary withdrawal driver.
```

**Why This Works:**

- Explains the fatigue accumulation mechanism
- Shows when threshold was crossed
- Quantifies the multiplier effect
- Clarifies why high decision count ≠ linear cost

**Guardrails:**

- Only triggers when decisions are clearly dominant
- Does not say decisions were "too many"
- Does not imply decisions should be avoided

---

#### **Rule 5: Passive Drain Underestimated**

**Trigger Condition:**

```
unresolved_count > 15 AND
components.passive_drain > 20 CU AND
(closing_balance - opening_balance) < -50 CU
```

**Insight Template:**

```
"Passive drain from {unresolved_count} unresolved items consumed {passive_drain} CU
({passive_pct}% of withdrawals). This represents background cognitive load
independent of active work."
```

**Example Output:**

```
Passive drain from 18 unresolved items consumed 18 CU (5% of withdrawals).
This represents background cognitive load independent of active work.
```

**Why This Works:**

- Highlights the "invisible" cost
- Distinguishes passive from active load
- Quantifies the hidden tax
- Explains why balance decreased even after "finishing" work

**Guardrails:**

- Only mentions if passive drain is substantial (>20 CU)
- Does not label open loops as "bad"
- Does not suggest specific closure actions

---

#### **Rule 6: Recovery Insufficiency**

**Trigger Condition:**

```
total_deposits < (total_withdrawals * 0.5) AND
recovery_quality < 5 AND
closing_balance < 30 CU
```

**Insight Template:**

```
"Recovery deposit ({total_deposits} CU) covered only {recovery_pct}% of
withdrawals ({total_withdrawals} CU). Recovery quality rating of {recovery_quality}/10
limited restoration effectiveness."
```

**Example Output:**

```
Recovery deposit (21 CU) covered only 6% of withdrawals (362 CU). Recovery
quality rating of 2/10 limited restoration effectiveness.
```

**Why This Works:**

- Shows the gap between consumption and restoration
- Links quality rating to actual deposit value
- Explains mechanism of net decline
- Neutral observation, not judgment

**Guardrails:**

- Only triggers when gap is severe (<50% coverage)
- Does not prescribe specific recovery activities
- Does not suggest user "failed" to recover

---

#### **Rule 7: Depletion Cost Spiral**

**Trigger Condition:**

```
opening_balance < 50 CU AND
total_withdrawals > (historical_avg_withdrawals * 1.2)
```

**Insight Template:**

```
"Operating at {opening_balance} CU capacity incurred {fatigue_penalty}%
additional cost on all activities. Same workload that typically costs
{normal_cost} CU cost {actual_cost} CU today."
```

**Example Output:**

```
Operating at 32 CU capacity incurred 20% additional cost on all activities.
Same workload that typically costs 150 CU cost 180 CU today.
```

**Why This Works:**

- Explains the efficiency penalty mechanism
- Quantifies the "everything is harder" effect
- Shows why depletion compounds
- Uses historical baseline for comparison

**Guardrails:**

- Only triggers when fatigue penalty is active
- Requires historical data for comparison
- Does not suggest user is "performing poorly"

---

#### **Rule 8: Recovery Effectiveness Bonus**

**Trigger Condition:**

```
subjective_depletion >= 7 AND
recovery_quality >= 6 AND
components.recovery_deposit > 50 CU
```

**Insight Template:**

```
"High depletion state ({subjective_depletion}/10) amplified recovery
effectiveness by {bonus_factor}. Recovery quality {recovery_quality}/10
yielded {recovery_deposit} CU (vs {base_recovery} CU at baseline)."
```

**Example Output:**

```
High depletion state (9/10) amplified recovery effectiveness by 1.3×.
Recovery quality 9/10 yielded 70 CU (vs 54 CU at baseline).
```

**Why This Works:**

- Explains the positive feedback mechanism
- Shows when recovery is most effective
- Quantifies the bonus multiplier
- Neutral explanation of system mechanics

**Guardrails:**

- Only triggers when bonus is actually applied
- Does not suggest user should become depleted to recover better
- Factual mechanism explanation only

---

#### **Rule 9: Trend Reversal**

**Trigger Condition:**

```
last_3_days_trend == "DECLINING" AND
today_net_change > 20 CU AND
closing_balance > previous_day.closing_balance
```

**Insight Template:**

```
"Balance increased {net_change} CU after {consecutive_decline_days} days
of decline. Primary reversal factor: {reversal_driver}."
```

**Example Output:**

```
Balance increased 48 CU after 3 days of decline. Primary reversal factor:
reduced workload (24 CU withdrawals vs 185 CU average).
```

**Why This Works:**

- Identifies pattern breaks
- Explains what changed
- Quantifies the reversal magnitude
- Helps user understand recovery mechanisms

**Guardrails:**

- Only triggers on genuine reversals (>20 CU improvement)
- Does not praise or encourage
- Does not predict sustainability

---

#### **Rule 10: Stable State Explanation**

**Trigger Condition:**

```
abs(net_change) < 15 CU AND
closing_balance BETWEEN 40 AND 80 CU AND
no_other_rules_triggered
```

**Insight Template:**

```
"Balance changed {net_change} CU (withdrawals {total_withdrawals} CU,
deposits {total_deposits} CU) resulting in relatively stable state at
{closing_balance} CU."
```

**Example Output:**

```
Balance changed -7 CU (withdrawals 63 CU, deposits 56 CU) resulting in
relatively stable state at 93 CU.
```

**Why This Works:**

- Acknowledges stable days without drama
- Provides basic accounting
- Validates equilibrium state
- Prevents "no insight" confusion

**Guardrails:**

- Only used as fallback (low priority)
- Minimal interpretation
- Simple factual summary

---

### 10.3 Insight Selection Algorithm

```python
def generate_daily_insight(entry: DailyLedgerEntry,
                          historical_entries: List[DailyLedgerEntry]) -> str:
    """
    Evaluate rules in priority order and return first matching insight.
    Returns at most one insight per day.
    """

    # Calculate derived metrics needed for rules
    drop_amount = abs(entry.net_change) if entry.net_change < 0 else 0
    carryover_amount = entry.closing_balance * 0.2 if entry.closing_balance < 0 else 0
    context_pct = (entry.components.context_cost / entry.total_withdrawals * 100
                   if entry.total_withdrawals > 0 else 0)
    recovery_pct = (entry.total_deposits / entry.total_withdrawals * 100
                    if entry.total_withdrawals > 0 else 0)

    # Rule 1: Deficit Spike
    if (entry.closing_balance < -100 and drop_amount > 200):
        primary_driver = identify_primary_component(entry)
        return f"Balance dropped {drop_amount:.0f} CU in one day due to {primary_driver}. " \
               f"This created a {entry.closing_balance:.0f} CU deficit that will carry " \
               f"forward as {carryover_amount:.0f} CU tomorrow."

    # Rule 2: Carryover Debt Impact
    if (entry.opening_balance < 90 and
        len(historical_entries) > 0 and
        historical_entries[-1].closing_balance < 0 and
        entry.closing_balance < 0):

        carryover_debt = entry.opening_balance - 100
        capacity_reduction = abs(carryover_debt)
        return f"Started at {entry.opening_balance:.1f} CU (reduced from baseline " \
               f"100 CU due to {carryover_debt:.1f} CU carryover debt). This reduced " \
               f"initial capacity by {capacity_reduction:.0f}%, contributing to today's " \
               f"{entry.closing_balance:.1f} CU result."

    # Rule 3: Context Fragmentation Dominant
    if (entry.components.context_cost > 50 and context_pct > 40):
        return f"Context switching accounted for {context_pct:.0f}% of cognitive load " \
               f"({entry.components.context_cost:.0f} CU from {get_context_count(entry)} " \
               f"contexts). This was the dominant cost factor today."

    # Rule 4: Decision Fatigue
    decision_count = get_decision_count(entry)
    if (decision_count > 15 and
        entry.components.decision_cost > entry.components.context_cost and
        entry.components.decision_cost > entry.components.attention_cost):

        fatigue_factor = get_fatigue_factor(decision_count)
        return f"Made {decision_count} significant decisions, incurring " \
               f"{entry.components.decision_cost:.0f} CU with a {fatigue_factor}× " \
               f"fatigue multiplier (activated at >15 decisions). This was the " \
               f"primary withdrawal driver."

    # Rule 5: Passive Drain
    unresolved_count = get_unresolved_count(entry)
    if (unresolved_count > 15 and
        entry.components.passive_drain > 20 and
        entry.net_change < -50):

        passive_pct = (entry.components.passive_drain / entry.total_withdrawals * 100)
        return f"Passive drain from {unresolved_count} unresolved items consumed " \
               f"{entry.components.passive_drain:.0f} CU ({passive_pct:.0f}% of " \
               f"withdrawals). This represents background cognitive load independent " \
               f"of active work."

    # Rule 6: Recovery Insufficiency
    recovery_quality = get_recovery_quality(entry)
    if (entry.total_deposits < (entry.total_withdrawals * 0.5) and
        recovery_quality < 5 and
        entry.closing_balance < 30):

        return f"Recovery deposit ({entry.total_deposits:.0f} CU) covered only " \
               f"{recovery_pct:.0f}% of withdrawals ({entry.total_withdrawals:.0f} CU). " \
               f"Recovery quality rating of {recovery_quality}/10 limited restoration " \
               f"effectiveness."

    # Rule 7: Depletion Cost Spiral
    if len(historical_entries) >= 7:
        avg_withdrawals = calculate_avg_withdrawals(historical_entries[-7:])
        if (entry.opening_balance < 50 and
            entry.total_withdrawals > (avg_withdrawals * 1.2)):

            fatigue_penalty = calculate_fatigue_penalty(entry.opening_balance)
            normal_cost = entry.total_withdrawals / (1 + fatigue_penalty)
            return f"Operating at {entry.opening_balance:.0f} CU capacity incurred " \
                   f"{fatigue_penalty*100:.0f}% additional cost on all activities. " \
                   f"Same workload that typically costs {normal_cost:.0f} CU cost " \
                   f"{entry.total_withdrawals:.0f} CU today."

    # Rule 8: Recovery Effectiveness Bonus
    subjective_depletion = get_subjective_depletion(entry)
    if (subjective_depletion and subjective_depletion >= 7 and
        recovery_quality >= 6 and
        entry.components.recovery_deposit > 50):

        bonus_factor = get_depletion_bonus(subjective_depletion)
        base_recovery = entry.components.recovery_deposit / bonus_factor
        return f"High depletion state ({subjective_depletion}/10) amplified recovery " \
               f"effectiveness by {bonus_factor}×. Recovery quality {recovery_quality}/10 " \
               f"yielded {entry.components.recovery_deposit:.0f} CU (vs {base_recovery:.0f} " \
               f"CU at baseline)."

    # Rule 9: Trend Reversal
    if len(historical_entries) >= 3:
        last_3_trend = calculate_trend_direction(historical_entries[-3:])
        if (last_3_trend == "DECLINING" and
            entry.net_change > 20 and
            entry.closing_balance > historical_entries[-1].closing_balance):

            consecutive_days = count_consecutive_decline(historical_entries)
            reversal_driver = identify_reversal_driver(entry, historical_entries)
            return f"Balance increased {entry.net_change:.0f} CU after {consecutive_days} " \
                   f"days of decline. Primary reversal factor: {reversal_driver}."

    # Rule 10: Stable State (fallback)
    if (abs(entry.net_change) < 15 and
        40 <= entry.closing_balance <= 80):

        return f"Balance changed {entry.net_change:+.0f} CU (withdrawals " \
               f"{entry.total_withdrawals:.0f} CU, deposits {entry.total_deposits:.0f} CU) " \
               f"resulting in relatively stable state at {entry.closing_balance:.0f} CU."

    # No insight (rare edge case)
    return None
```

---

### 10.4 Guardrails Implementation

#### **Guardrail 1: Avoid Clinical Language**

**Blacklist:** Never use these terms in insights:

```python
PROHIBITED_TERMS = [
    "mental health", "depression", "anxiety", "burnout", "stress disorder",
    "cognitive dysfunction", "impairment", "pathology", "symptoms",
    "diagnosis", "treatment", "therapy", "medication", "clinical"
]

def validate_insight(insight_text: str) -> bool:
    """Return False if insight contains prohibited terms."""
    lower_text = insight_text.lower()
    return not any(term in lower_text for term in PROHIBITED_TERMS)
```

#### **Guardrail 2: No Prescriptive Language**

**Prohibited Patterns:**

- "You should..."
- "You need to..."
- "You must..."
- "Try to..."
- "Consider..."
- "It's important to..."

**Allowed Patterns:**

- "X accounted for Y..."
- "This created..."
- "This reduced..."
- "Primary factor: ..."

```python
def check_prescriptive_language(insight_text: str) -> bool:
    """Return True if insight is purely descriptive."""
    prescriptive_patterns = [
        r'\byou should\b', r'\byou need\b', r'\byou must\b',
        r'\btry to\b', r'\bconsider\b', r'\bit\'s important\b'
    ]
    import re
    return not any(re.search(pattern, insight_text, re.IGNORECASE)
                   for pattern in prescriptive_patterns)
```

#### **Guardrail 3: Evidence-Based Only**

**Rule:** Every claim must reference actual data:

```python
def validate_data_reference(insight_text: str, entry: DailyLedgerEntry) -> bool:
    """Ensure insight only references data that exists in the entry."""

    # Extract all numbers from insight
    import re
    numbers_in_insight = set(re.findall(r'\d+\.?\d*', insight_text))

    # Valid numbers that should appear
    valid_numbers = {
        str(round(entry.opening_balance, 1)),
        str(round(entry.closing_balance, 1)),
        str(round(entry.total_withdrawals, 1)),
        str(round(entry.total_deposits, 1)),
        str(round(entry.net_change, 1)),
        # Component costs...
    }

    # All numbers in insight should be derivable from entry data
    # (This is simplified - actual implementation would be more thorough)
    return True  # Placeholder for full validation
```

#### **Guardrail 4: Single Insight Maximum**

**Enforcement:**

```python
class InsightManager:
    """Ensures one insight per day maximum."""

    def __init__(self):
        self.generated_insights = {}  # date -> insight

    def get_or_generate_insight(self, date: str, entry: DailyLedgerEntry,
                                historical: List[DailyLedgerEntry]) -> Optional[str]:
        """Return existing insight if already generated, otherwise generate new."""

        if date in self.generated_insights:
            return self.generated_insights[date]

        insight = generate_daily_insight(entry, historical)

        if insight:
            # Validate before storing
            if validate_insight(insight) and check_prescriptive_language(insight):
                self.generated_insights[date] = insight
                return insight

        return None
```

#### **Guardrail 5: Confidence Thresholds**

**Rule:** Only generate insights when confidence ≥ 70%

```python
def should_generate_insight(entry: DailyLedgerEntry) -> bool:
    """Determine if data quality is sufficient for insight generation."""

    if entry.confidence < 70:
        return False  # Data quality too low

    # Require minimum history for comparative insights
    # (handled in specific rules)

    return True
```

---

### 10.5 Example Output Scenarios

#### **Scenario 1: Crisis Day (Tuesday from 7-day simulation)**

**Data:**

- Opening: 100 CU
- Withdrawals: 362 CU (contexts: 62, decisions: 229, passive: 18, attention: 54)
- Deposits: 21 CU
- Closing: -241 CU
- Context count: 14, Decision count: 22

**Generated Insight (Rule 1):**

```
Balance dropped 341 CU in one day due to decision overload (229 CU from
22 decisions) and high context switching (62 CU from 14 contexts). This
created a -241 CU deficit that will carry forward as -48 CU tomorrow.
```

**Why This Works:**

- Quantifies the drop (341 CU)
- Identifies two primary drivers with exact costs
- Explains carryover mechanism
- Zero motivational language
- Zero prescriptive advice
- Pure causality explanation

---

#### **Scenario 2: Carryover Day (Wednesday)**

**Data:**

- Opening: 51.7 CU (reduced from 100 due to carryover)
- Withdrawals: 185 CU
- Deposits: 55 CU
- Closing: -78.6 CU

**Generated Insight (Rule 2):**

```
Started at 51.7 CU (reduced from baseline 100 CU due to -48.3 CU carryover
debt). This reduced initial capacity by 48%, contributing to today's
-78.6 CU result.
```

**Why This Works:**

- Makes invisible mechanism visible
- Quantifies capacity reduction
- Explains how previous day affects today
- No blame, just mechanics

---

#### **Scenario 3: Recovery Day (Thursday)**

**Data:**

- Opening: 84.3 CU
- Withdrawals: 91 CU
- Deposits: 64 CU
- Closing: 57.3 CU
- Net change: -27 CU

**Generated Insight (Rule 10 - Stable State):**

```
Balance changed -27 CU (withdrawals 91 CU, deposits 64 CU) resulting in
relatively stable state at 57 CU.
```

**Why This Works:**

- Acknowledges stability without drama
- Simple accounting
- No over-interpretation
- Validates equilibrium

---

#### **Scenario 4: Weekend Recovery (Saturday)**

**Data:**

- Opening: 100 CU
- Withdrawals: 24 CU (contexts: 2, decisions: 16, passive: 2, attention: 5)
- Deposits: 72 CU
- Closing: 148 CU (capped at 120)
- Recovery quality: 9/10

**Generated Insight (Rule 10):**

```
Balance changed +48 CU (withdrawals 24 CU, deposits 72 CU) resulting in
relatively stable state at 120 CU.
```

**Note:** Even positive days get factual summary, not celebration.

---

### 10.6 Non-Insight Conditions

**When NO insight is generated:**

1. **Insufficient data quality** (confidence < 70%)

   - Missing required inputs
   - Extreme outliers suggesting data entry errors

2. **First day of tracking** (no historical context)

   - Cannot calculate trends
   - Cannot compare to baseline

3. **Edge cases outside all rules**
   - Extremely rare scenarios
   - Better to say nothing than speculate

**User Message:**

```
"Insufficient data for insight generation. Continue logging for pattern analysis."
```

---

### 10.7 Integration with Prototype

```python
# Add to pcll_prototype.py

class InsightGenerator:
    """Rule-based insight generation following strict guardrails."""

    PROHIBITED_TERMS = [
        "mental health", "depression", "anxiety", "burnout",
        "you should", "you need", "you must", "try to"
    ]

    def generate_insight(self, entry: DailyLedgerEntry,
                        historical: List[DailyLedgerEntry]) -> Optional[str]:
        """Generate single insight following priority rules."""

        if entry.confidence < 70:
            return None

        # Evaluate rules in order (implementation in 10.3)
        insight = self._evaluate_rules(entry, historical)

        # Validate guardrails
        if insight and self._validate_insight(insight):
            return insight

        return None

    def _validate_insight(self, insight: str) -> bool:
        """Check all guardrails."""
        lower = insight.lower()
        return not any(term in lower for term in self.PROHIBITED_TERMS)
```

---

## 11. Safety, Ethical, and Legal Guardrails

### 11.1 System Classification

**Official Classification:** PCLL is a **productivity tracking tool** that uses self-reported activity data to model cognitive resource allocation patterns. It is explicitly NOT:

- A medical device
- A diagnostic tool
- A mental health application
- A clinical assessment instrument
- A wellness or wellbeing application

**Regulatory Positioning:**

- Does not fall under FDA medical device regulations (no diagnostic claims)
- Does not constitute digital therapeutics (no therapeutic claims)
- Does not qualify as clinical decision support (no medical recommendations)
- Functions as personal productivity software (similar to time trackers, task managers)

---

### 11.2 Required User Disclaimers

#### **11.2.1 Primary Disclaimer (Shown at First Use)**

```
╔════════════════════════════════════════════════════════════════╗
║                   IMPORTANT DISCLAIMER                        ║
╠════════════════════════════════════════════════════════════════╣
║                                                               ║
║  The Personal Cognitive Load Ledger (PCLL) is a personal     ║
║  productivity tracking tool that helps you understand your    ║
║  work patterns through self-reported activity logging.        ║
║                                                               ║
║  THIS TOOL IS NOT:                                           ║
║  • A medical or diagnostic device                            ║
║  • A substitute for professional mental health care          ║
║  • A measure of mental health, wellbeing, or fitness         ║
║  • A clinical assessment or screening tool                   ║
║                                                               ║
║  WHAT THIS TOOL DOES:                                        ║
║  • Tracks self-reported work activities and breaks           ║
║  • Calculates estimates of cognitive resource usage          ║
║  • Shows patterns in your activity allocation over time      ║
║                                                               ║
║  WHAT THIS TOOL DOES NOT DO:                                 ║
║  • Diagnose any medical or psychological condition           ║
║  • Measure actual cognitive performance or brain function    ║
║  • Provide medical, psychological, or therapeutic advice     ║
║  • Replace consultation with healthcare professionals        ║
║                                                               ║
║  IF YOU ARE EXPERIENCING:                                    ║
║  • Persistent fatigue, stress, or difficulty concentrating   ║
║  • Mental health concerns or emotional distress              ║
║  • Physical symptoms or health problems                      ║
║                                                               ║
║  Please consult a qualified healthcare professional.         ║
║  This tool is not designed to detect or address these issues.║
║                                                               ║
║  By continuing, you acknowledge that you understand this     ║
║  tool's purpose and limitations.                             ║
║                                                               ║
║  [ ] I understand and agree to these terms                   ║
║                                                               ║
╚════════════════════════════════════════════════════════════════╝
```

**Required:** Must be accepted before any data entry. Cannot be dismissed or skipped.

---

#### **11.2.2 In-App Persistent Disclaimer**

Displayed in footer/settings at all times:

```
ℹ PCLL is a productivity tracking tool, not a medical or mental health
  application. Values represent self-reported activity patterns, not
  health status. See full disclaimer.
```

---

#### **11.2.3 Data Export Disclaimer**

When exporting data (CSV, JSON, reports):

```
⚠ DISCLAIMER: This data represents self-reported activity logging and
  computational estimates. It does not constitute medical data, health
  records, or clinical assessments. Values are relative to personal
  baseline and not comparable across individuals.
```

---

#### **11.2.4 Deficit State Warning**

When closing balance < -50 CU for 3+ consecutive days:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PATTERN NOTICE

Your ledger shows multiple days with high estimated cognitive demand
relative to recovery activities. This pattern reflects your logged
work activities.

This is not a health alert or diagnostic indicator.

If you are experiencing persistent fatigue, difficulty concentrating,
or other concerning symptoms, please consult a healthcare professional.

PCLL tracks activity patterns only and cannot assess your actual
health or cognitive state.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Dismiss]  [Learn More]
```

**Important:** Notice focuses on pattern, not health. Emphasizes limitations.

---

### 11.3 Feature Limitations (By Design)

#### **11.3.1 No Biometric Integration**

**Prohibited:**

- Heart rate monitoring
- Sleep stage detection
- Stress hormone measurement
- EEG or brain activity tracking
- Galvanic skin response
- Any physiological sensor data

**Rationale:** Biometric data implies health monitoring, triggering medical device regulations and clinical expectations.

**Implementation:**

```python
class DataInput:
    """Enforce input type restrictions."""

    PROHIBITED_DATA_TYPES = [
        "heart_rate", "hrv", "sleep_stages", "cortisol",
        "blood_pressure", "body_temperature", "eeg", "gsr"
    ]

    def validate_input(self, data_type: str) -> bool:
        """Reject prohibited biometric data types."""
        if data_type in self.PROHIBITED_DATA_TYPES:
            raise ValueError(
                f"PCLL does not accept {data_type} data. "
                f"This tool uses self-reported activity data only."
            )
        return True
```

---

#### **11.3.2 No Emotional State Tracking**

**Prohibited Labels:**

- Mood ratings (happy/sad scales)
- Emotional state categorization
- Affect measurement
- Stress levels
- Anxiety ratings
- Mental health symptoms

**Allowed (Carefully Worded):**

- "Subjective depletion" (how drained you feel, 1-10)
- "Recovery quality" (how restorative breaks were, 1-10)

**Rationale:** Emotional tracking positions tool as mental health app.

**Language Guidance:**

```
❌ AVOID: "How stressed are you?" "Rate your anxiety"
✅ USE: "How mentally drained do you feel?" "Rate recovery quality"

❌ AVOID: "Mood", "emotional state", "mental health"
✅ USE: "Subjective depletion", "self-reported fatigue proxy"
```

---

#### **11.3.3 No Predictive Health Claims**

**Prohibited Statements:**

- "You will burn out if..."
- "Risk of depression is..."
- "Your mental health trajectory..."
- "Predicted exhaustion in X days..."
- "Likelihood of cognitive decline..."

**Allowed Statements:**

- "Current trend shows declining balance"
- "Pattern indicates recovery ratio below X%"
- "Deficit has persisted for X days"

**Implementation:**

```python
PROHIBITED_PREDICTION_LANGUAGE = [
    r'\bwill (develop|experience|suffer)\b',
    r'\brisk of (burnout|depression|anxiety)\b',
    r'\bmental health (decline|deterioration|trajectory)\b',
    r'\bpredict(ed)? (exhaustion|breakdown|crisis)\b',
    r'\blikelihood of (illness|disorder|impairment)\b'
]

def validate_output_text(text: str) -> bool:
    """Ensure no health predictions in any output."""
    import re
    for pattern in PROHIBITED_PREDICTION_LANGUAGE:
        if re.search(pattern, text, re.IGNORECASE):
            raise ValueError(f"Prohibited health prediction language detected")
    return True
```

---

#### **11.3.4 No Comparative Benchmarking**

**Prohibited:**

- "Your score is X percentile"
- "Typical person has Y balance"
- "You are above/below average"
- Leaderboards or rankings
- Population normative data

**Rationale:** Comparisons imply objective health metrics and create competitive dynamics harmful to autonomy.

**Implementation:**

```python
class LedgerOutput:
    """Prevent comparative statements."""

    def format_balance(self, balance: float) -> str:
        # ❌ BAD: "Your 45 CU is below the 60 CU average"
        # ✅ GOOD: "Current balance: 45 CU"
        return f"Current balance: {balance:.0f} CU"

    def format_trend(self, trend: str) -> str:
        # ❌ BAD: "Your trend is worse than 70% of users"
        # ✅ GOOD: "Trend direction: DECLINING"
        return f"Trend direction: {trend}"
```

---

#### **11.3.5 No Mandated Actions**

**Prohibited:**

- Forced break reminders
- Locked features until rest taken
- Mandatory recovery activities
- Blocked work sessions
- Enforced limits on activity logging

**Allowed:**

- Optional insights (dismissible)
- Pattern notifications (informational only)
- Trend summaries (descriptive)

**Rationale:** User autonomy is paramount. Tool provides information, user decides action.

**Implementation:**

```python
class Notification:
    """All notifications are optional and dismissible."""

    def __init__(self, message: str, dismissible: bool = True):
        if not dismissible:
            raise ValueError("All PCLL notifications must be dismissible")
        self.message = message
        self.dismissible = True  # Enforced

    def show(self):
        print(f"{self.message}\n[Dismiss] [Learn More]")
```

---

### 11.4 Language to Avoid (Comprehensive Blacklist)

#### **11.4.1 Clinical/Medical Terms**

```python
CLINICAL_BLACKLIST = [
    # Mental health conditions
    "depression", "depressive", "anxiety", "anxious", "panic",
    "burnout", "burned out", "ptsd", "trauma", "bipolar",
    "adhd", "add", "ocd", "autism", "disorder", "syndrome",

    # Clinical assessment
    "diagnosis", "diagnose", "diagnostic", "screen", "screening",
    "assess mental health", "psychological evaluation", "clinical",

    # Treatment/therapy
    "treatment", "therapy", "therapeutic", "intervention",
    "medication", "prescription", "clinical trial", "counseling",

    # Pathology
    "pathology", "dysfunction", "impairment", "abnormal",
    "symptoms", "illness", "disease", "condition", "affliction",

    # Medical authority
    "medical advice", "doctor recommends", "clinical guidance",
    "healthcare recommendation", "prescribed", "diagnosed"
]
```

---

#### **11.4.2 Wellness/Health Optimization**

```python
WELLNESS_BLACKLIST = [
    # Wellness terminology (blurs into health claims)
    "mental wellness", "psychological wellness", "mental fitness",
    "brain health", "cognitive health", "neurological health",

    # Performance optimization (implies medical enhancement)
    "optimize brain function", "enhance cognitive performance",
    "boost mental capacity", "improve brain chemistry",

    # Health status
    "healthy mind", "unhealthy patterns", "mental hygiene",
    "psychological fitness", "brain fitness", "mental state"
]
```

---

#### **11.4.3 Emotional/Affective Language**

```python
EMOTIONAL_BLACKLIST = [
    # Mood/affect
    "mood", "emotional state", "feelings", "emotions",
    "happy", "sad", "upset", "distressed", "overwhelmed",

    # Stress (borderline acceptable, use carefully)
    "stress levels", "stressed out", "stress disorder",
    # Note: "stressor" (neutral event) is acceptable

    # Sentiment
    "mental well-being", "emotional well-being", "psychological state"
]
```

---

#### **11.4.4 Prescriptive/Directive Language**

```python
PRESCRIPTIVE_BLACKLIST = [
    # Commands
    "you must", "you should", "you need to", "you have to",
    "it is important that you", "make sure you", "be sure to",

    # Advice
    "we recommend", "our advice", "you ought to", "consider doing",
    "try to", "attempt to", "it would be best if",

    # Requirements
    "required", "mandatory", "necessary", "essential that you",
    "critical that you", "imperative"
]
```

---

### 11.5 Risk Mitigation Strategies

#### **11.5.1 Misinterpretation as Health Tool**

**Risk:** Users perceive PCLL as mental health monitoring despite disclaimers.

**Mitigation:**

1. **Visual Design Differentiation**

   - Avoid medical UI patterns (blue/white clinical aesthetic)
   - Use productivity tool aesthetics (task manager style)
   - No health icons (hearts, brain symbols, medical crosses)

2. **Terminology Consistency**

   - Always: "cognitive load tracking" not "cognitive health"
   - Always: "activity patterns" not "mental state"
   - Always: "productivity tool" not "wellness app"

3. **Contextual Reminders**
   - Footer disclaimer on every screen
   - "What is PCLL?" link prominent in navigation
   - Periodic re-confirmation of understanding (quarterly)

```python
class UIGuidelines:
    """Enforce visual differentiation from health apps."""

    APPROVED_COLOR_SCHEMES = [
        "productivity_blue",  # Similar to project management tools
        "neutral_gray",       # Business software aesthetic
        "workspace_green"     # Work-focused palette
    ]

    PROHIBITED_COLOR_SCHEMES = [
        "medical_blue",       # Clinical software look
        "health_red",         # Medical alert palette
        "wellness_purple"     # Self-care app aesthetic
    ]

    PROHIBITED_ICONS = [
        "heart", "brain", "medical_cross", "pulse", "wellness_leaf"
    ]

    APPROVED_ICONS = [
        "calendar", "chart", "list", "clock", "document"
    ]
```

---

#### **11.5.2 Over-Reliance on Tool**

**Risk:** Users make significant life decisions based solely on PCLL data.

**Mitigation:**

1. **Decision Support Disclaimer**

   ```
   PCLL provides information about your self-reported activity patterns.
   It is one input among many for personal decision-making. Consult
   relevant professionals (managers, mentors, healthcare providers)
   for significant work or health decisions.
   ```

2. **Confidence Scoring**

   - Always show confidence level (e.g., "Confidence: 75%")
   - Explain limitations when confidence < 70%
   - Never present estimates as absolute truth

3. **Trend Caveats**
   ```python
   def format_trend_output(trend: str) -> str:
       base = f"Trend direction: {trend}"
       caveat = (
           "\n\nNote: Trend is based on self-reported data and "
           "computational estimates. Many factors beyond logged "
           "activities influence actual cognitive state."
       )
       return base + caveat
   ```

---

#### **11.5.3 Data Misuse by Third Parties**

**Risk:** Employers, insurers, or others misuse PCLL data for adverse decisions.

**Mitigation:**

1. **Data Ownership**

   - User owns all data
   - No automatic sharing with any party
   - No "organization" or "manager" view modes
   - No API endpoints for third-party data access

2. **Export Warnings**

   ```
   ⚠ DATA EXPORT WARNING

   You are about to export your PCLL data. Please be aware:

   • This data is personal and reflects your self-reported activities
   • It is not designed for use by employers, insurers, or other parties
   • Sharing this data may lead to misinterpretation
   • PCLL data should not be used for performance evaluations or
     employment decisions

   We recommend keeping this data private.

   [Cancel] [Acknowledge and Export]
   ```

3. **No Corporate Features**
   - No "team dashboards"
   - No "manager reports"
   - No "department averages"
   - No "productivity leaderboards"

**Code Enforcement:**

```python
class DataSharing:
    """Restrict all multi-user features."""

    def __init__(self):
        self.sharing_enabled = False  # Hardcoded

    def share_data(self, recipient: str):
        raise NotImplementedError(
            "Data sharing is not supported. PCLL is a personal tool only."
        )

    def create_team_view(self):
        raise NotImplementedError(
            "Team/organizational views are not supported to protect privacy."
        )
```

---

#### **11.5.4 Stigmatization of Deficit States**

**Risk:** Users develop negative self-perception from seeing "deficit" states.

**Mitigation:**

1. **Neutral Terminology**

   - ✅ "Deficit" (accounting term, neutral)
   - ❌ "Failure", "breakdown", "collapse", "exhaustion"

2. **Explanatory Context**

   ```
   STATE: DEFICIT

   What this means: Your ledger shows more logged withdrawals than
   deposits. This is a mathematical state in the ledger system, similar
   to a bank account balance going negative temporarily.

   What this does NOT mean: This is not a judgment, diagnosis, or
   indication of personal failure. Many factors influence daily patterns.
   ```

3. **Reframing Prompts**
   ```python
   def format_state(state: str, balance: float) -> str:
       state_labels = {
           "SEVERE_DEFICIT": "High demand relative to logged recovery",
           "DEFICIT": "Elevated demand relative to logged recovery",
           "DEPLETED": "Moderate demand relative to logged recovery",
           "MODERATE": "Balanced demand and recovery pattern",
           "WELL_RESTED": "Recovery exceeds logged demand"
       }

       description = state_labels.get(state, state)
       return f"{description} (Balance: {balance:.0f} CU)"
   ```

---

#### **11.5.5 Liability for User Actions**

**Risk:** Users claim tool advised harmful actions or failed to prevent harm.

**Mitigation:**

1. **Liability Limitation (Terms of Service)**

   ```
   LIMITATION OF LIABILITY

   PCLL is a productivity tracking tool that processes self-reported
   data you provide. It does not monitor your actual health, cognitive
   state, or wellbeing.

   You acknowledge that:
   • PCLL makes no guarantees about accuracy of estimates
   • Decisions based on PCLL data are your sole responsibility
   • PCLL is not liable for decisions made using the tool
   • PCLL does not replace professional advice of any kind

   To the maximum extent permitted by law, the developers of PCLL
   disclaim all liability for any damages arising from use or misuse
   of this tool.
   ```

2. **Emergency Resource Information**

   - Prominent "Resources" section with crisis hotlines
   - Links to mental health professional directories
   - Clear distinction: "If you need help, these resources provide
     professional support. PCLL cannot."

3. **Audit Trail**
   - Log all disclaimers shown to user
   - Record acknowledgments and acceptance timestamps
   - Document that user was informed of limitations

---

### 11.6 Patent-Safe Language

#### **11.6.1 Avoiding Existing Patents**

**Strategy:** Use generic productivity terminology, not patented health/wellness concepts.

**Safe Terminology:**

- "Ledger" (accounting metaphor, widely used)
- "Transaction" (generic financial term)
- "Withdrawal" and "Deposit" (common accounting)
- "Balance" (universal financial concept)
- "Cognitive Load" (academic term in public domain since 1988)

**Avoid Patented Concepts:**

- Specific "burnout detection" algorithms (may be patented)
- Proprietary "stress indices" or "wellness scores"
- Branded "mental fitness" methodologies
- Licensed cognitive assessment frameworks

**Implementation:**

```python
class SystemDescription:
    """Patent-safe system description language."""

    SAFE_DESCRIPTION = (
        "A personal tracking system that applies accounting ledger "
        "principles to self-reported work activities. Users log "
        "activities and breaks; the system calculates estimated "
        "resource allocation using rule-based arithmetic. "
        "No proprietary algorithms, biometric sensing, or clinical "
        "methodologies are employed."
    )

    def get_description(self) -> str:
        return self.SAFE_DESCRIPTION
```

---

#### **11.6.2 Prior Art Documentation**

**Public Domain Foundations:**

- Cognitive Load Theory (Sweller, 1988) - academic public domain
- Double-entry bookkeeping (Pacioli, 1494) - ancient public domain
- Self-reporting methodologies - standard research practice
- Time tracking concepts - widely used since 1970s

**Novelty Claims:**

- Specific combination of ledger metaphor + cognitive load quantification
- Rule-based estimation formulas (document in public domain)
- Carryover debt mechanics (publish openly)

**Strategy:**

- Publish full system specification openly (this document)
- Make prototype open source
- Establish public prior art before any patent applications

---

### 11.7 Compliance Checklist

#### **Before Launch:**

```
[ ] Primary disclaimer implemented and tested
[ ] In-app persistent disclaimer visible on all screens
[ ] All prohibited terms removed from UI and outputs
[ ] Biometric integration blocked at code level
[ ] Emotional state tracking removed
[ ] Health prediction language validated against blacklist
[ ] Comparative benchmarking disabled
[ ] Mandated actions removed (all notifications dismissible)
[ ] Data sharing/team features disabled or removed
[ ] Export warnings implemented
[ ] Terms of Service includes liability limitations
[ ] Emergency resources prominently linked
[ ] Visual design differentiated from health apps
[ ] Confidence scores displayed on all estimates
[ ] User acknowledgment logging implemented
[ ] Marketing materials reviewed for compliance
[ ] No medical/clinical claims in any documentation
[ ] Patent search completed (no infringement)
[ ] System description uses patent-safe language
```

---

### 11.8 Enforcement Mechanisms

#### **11.8.1 Automated Validation**

```python
class ComplianceValidator:
    """Enforce guardrails at runtime."""

    def __init__(self):
        self.clinical_blacklist = CLINICAL_BLACKLIST
        self.prescriptive_blacklist = PRESCRIPTIVE_BLACKLIST

    def validate_output(self, text: str) -> Tuple[bool, List[str]]:
        """
        Check all output text against blacklists.
        Returns (is_compliant, violations_found).
        """
        violations = []
        lower_text = text.lower()

        # Check clinical terms
        for term in self.clinical_blacklist:
            if term in lower_text:
                violations.append(f"Clinical term: '{term}'")

        # Check prescriptive language
        for term in self.prescriptive_blacklist:
            if term in lower_text:
                violations.append(f"Prescriptive language: '{term}'")

        is_compliant = len(violations) == 0
        return is_compliant, violations

    def enforce(self, text: str) -> str:
        """Raise exception if non-compliant."""
        is_compliant, violations = self.validate_output(text)
        if not is_compliant:
            raise ComplianceViolation(
                f"Output contains prohibited language: {violations}"
            )
        return text

class ComplianceViolation(Exception):
    """Raised when output violates safety guardrails."""
    pass
```

---

#### **11.8.2 Code Review Requirements**

**Mandatory Checks:**

1. Every user-facing text string reviewed for blacklist terms
2. All new features assessed for clinical/health implications
3. UI changes validated against design differentiation rules
4. Output generation validated against prescriptive language patterns

**Checklist Per Feature:**

```
Feature: ___________________

[ ] Contains no clinical/medical terminology
[ ] Contains no emotional/affective language
[ ] Contains no prescriptive/directive statements
[ ] Contains no health predictions or claims
[ ] Contains no comparative benchmarking
[ ] User autonomy fully preserved (all prompts dismissible)
[ ] Aligns with "productivity tool" classification
[ ] Includes appropriate disclaimers/caveats
[ ] Passed automated compliance validation
[ ] Reviewed by at least one other developer

Reviewer: ___________  Date: ________
```

---

#### **11.8.3 Monitoring and Auditing**

```python
class ComplianceAudit:
    """Log all compliance-relevant events."""

    def __init__(self):
        self.audit_log = []

    def log_disclaimer_shown(self, user_id: str, disclaimer_type: str):
        """Record that user was shown disclaimer."""
        self.audit_log.append({
            "timestamp": datetime.now(),
            "user_id": user_id,
            "event": "disclaimer_shown",
            "disclaimer_type": disclaimer_type
        })

    def log_disclaimer_accepted(self, user_id: str, disclaimer_type: str):
        """Record user acknowledgment."""
        self.audit_log.append({
            "timestamp": datetime.now(),
            "user_id": user_id,
            "event": "disclaimer_accepted",
            "disclaimer_type": disclaimer_type
        })

    def log_data_export(self, user_id: str):
        """Record data export with warning shown."""
        self.audit_log.append({
            "timestamp": datetime.now(),
            "user_id": user_id,
            "event": "data_exported",
            "warning_shown": True
        })

    def generate_audit_report(self) -> dict:
        """Produce compliance audit report."""
        return {
            "total_disclaimers_shown": len([e for e in self.audit_log
                                           if e["event"] == "disclaimer_shown"]),
            "total_acceptances": len([e for e in self.audit_log
                                     if e["event"] == "disclaimer_accepted"]),
            "total_exports": len([e for e in self.audit_log
                                 if e["event"] == "data_exported"])
        }
```

---

### 11.9 Crisis Resource Reference

**Required in App:**

```
═══════════════════════════════════════════════════════════
                     HELP RESOURCES
═══════════════════════════════════════════════════════════

PCLL is a productivity tracking tool and cannot provide help with
mental health concerns or crises.

If you are experiencing a mental health emergency or crisis:

  • National Suicide Prevention Lifeline: 988
    (24/7 support, free and confidential)

  • Crisis Text Line: Text HOME to 741741
    (24/7 text support)

  • SAMHSA National Helpline: 1-800-662-4357
    (Substance abuse and mental health services, 24/7)

For non-emergency mental health support:
  • Consult a licensed therapist or counselor
  • Contact your primary care physician
  • Visit your employee assistance program (if available)

PCLL cannot assess your mental health or provide therapeutic support.
Please reach out to qualified professionals if you need help.
═══════════════════════════════════════════════════════════
```

**Placement:**

- Prominent link in main navigation: "Crisis Resources"
- Footer on every page
- Auto-shown when pattern notice appears (Section 11.2.4)

---

### 11.10 Marketing and Communications Guidelines

#### **11.10.1 Approved Messaging**

✅ **Acceptable Claims:**

- "Track your work activities and break patterns"
- "Understand how you allocate cognitive resources"
- "See trends in your productivity patterns over time"
- "Apply accounting principles to work management"
- "Self-reported activity logging for knowledge workers"

✅ **Acceptable Positioning:**

- "Productivity tool for professionals"
- "Personal work tracking system"
- "Ledger-based activity management"
- "Time and attention allocation tracker"

---

#### **11.10.2 Prohibited Messaging**

❌ **Unacceptable Claims:**

- "Improve your mental health"
- "Prevent burnout before it happens"
- "Optimize your cognitive performance"
- "Monitor your brain health"
- "Detect early signs of exhaustion"
- "Enhance your psychological wellness"
- "Science-based cognitive assessment"

❌ **Unacceptable Positioning:**

- "Mental health tool"
- "Wellness application"
- "Cognitive health monitor"
- "Brain fitness tracker"
- "Digital therapeutic for burnout"

---

#### **11.10.3 Testimonial Guidelines**

**If using user testimonials:**

✅ **Acceptable:**

- "PCLL helped me understand my work patterns"
- "I can see when I'm overcommitting based on activity logs"
- "The ledger metaphor makes sense for tracking my projects"

❌ **Unacceptable:**

- "PCLL saved my mental health"
- "I avoided burnout thanks to PCLL"
- "My anxiety improved after using PCLL"
- "PCLL helped me recover from depression"

**Enforcement:**

```python
def validate_testimonial(text: str) -> bool:
    """Ensure testimonial makes no health claims."""
    prohibited_phrases = [
        "mental health", "burnout", "anxiety", "depression",
        "saved me", "cured", "healed", "prevented illness"
    ]
    lower_text = text.lower()
    return not any(phrase in lower_text for phrase in prohibited_phrases)
```

---

### 11.11 Summary of Guardrail Principles

1. **Explicit Classification**: Productivity tool, not health tool
2. **Comprehensive Disclaimers**: Primary, persistent, contextual
3. **Feature Limitations**: No biometrics, no emotions, no predictions, no mandates
4. **Language Discipline**: Strict blacklists, automated validation
5. **Risk Mitigation**: Visual differentiation, autonomy preservation, data protection
6. **Patent Safety**: Generic terminology, public domain foundations
7. **User Protection**: Crisis resources, liability limitations, informed consent
8. **Enforcement**: Automated checks, code review, compliance auditing

**Core Philosophy:**  
PCLL respects user autonomy, maintains clear boundaries, and never claims to assess, diagnose, or improve health. It is a tool for understanding work patterns, nothing more.

---

**Document Version:** 1.6  
**Date:** December 13, 2025  
**Classification:** System Definition - Non-Clinical Tool
