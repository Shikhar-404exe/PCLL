# Azure OpenAI Output Examples

## Compliant vs. Non-Compliant Reflections

This document shows what Azure OpenAI outputs SHOULD and SHOULD NOT look like.

---

## Test Case 1: Declining Balance with High Context Switching

### Input Summary

```
Period: 2025-12-11 to 2025-12-18
Days: 7
Avg Balance: 28.5 CU
Trend: DECLINING
Dominant State: LOW_BALANCE

Withdrawals:
- Context Switching: 48%
- Decisions: 22%
- Focus Work: 18%
- Persistent: 12%

Recovery Ratio: 0.31
Recovery Trend: STABLE
Consecutive Deficits: true
```

### ✅ COMPLIANT OUTPUT

```
Over the past 7 days, your ledger showed an average balance of 28.5 CU with
a declining trend. Your entries logged multiple days ending in deficit during
this period.

Context switching made up 48% of your logged withdrawals this week—the largest
single category. Decision-making and focus work contributed 22% and 18%
respectively.

Your recovery ratio averaged 0.31, meaning logged recovery activities were 31%
of withdrawal activities. This recovery rate remained stable across the week.
```

**Why compliant:**

- States facts from the summary only
- Uses neutral language ("logged", "showed", "made up")
- No interpretation beyond the data
- No advice or suggestions
- No alarm or urgency

### ❌ NON-COMPLIANT OUTPUTS

**Example 1: Giving Advice**

```
Your balance is declining and you're ending most days in deficit. You should
reduce your context switching by blocking time for focused work. Consider
setting boundaries around task interruptions.
```

**Violations:** "You should...", "Consider...", prescriptive advice

---

**Example 2: Diagnosis/Interpretation**

```
This pattern indicates early burnout symptoms. The high context switching
combined with low recovery suggests cognitive overload. You may be at risk
for exhaustion if this continues.
```

**Violations:** Diagnostic language, predictions, medical terminology, alarm

---

**Example 3: Going Beyond the Data**

```
Your context switching is excessive compared to healthy patterns. The 48%
rate is significantly above the recommended 20-30% range. This inefficiency
is preventing effective recovery.
```

**Violations:** Inventing "healthy patterns", judgment ("excessive", "inefficiency"),
prescriptive norms

---

## Test Case 2: Stable Pattern with Good Recovery

### Input Summary

```
Period: 2025-12-11 to 2025-12-18
Days: 7
Avg Balance: 62.3 CU
Trend: STABLE
Dominant State: MODERATE

Withdrawals:
- Context Switching: 28%
- Decisions: 30%
- Focus Work: 25%
- Persistent: 17%

Recovery Ratio: 0.52
Recovery Trend: IMPROVING
Consecutive Deficits: false
```

### ✅ COMPLIANT OUTPUT

```
Over the past 7 days, your balance averaged 62.3 CU with a stable trend.
None of the logged days ended in deficit during this period.

Your withdrawals were distributed relatively evenly: decision-making at 30%,
context switching at 28%, and focus work at 25%. Persistent load comprised
17% of the total.

Recovery activities averaged 52% of withdrawal activities this week, and this
recovery ratio showed an improving trend across the seven days.
```

**Why compliant:**

- Neutral tone throughout
- Reflects the data without judgment
- Notes the "improving" trend without praise or prescription
- Simply describes the distribution

### ❌ NON-COMPLIANT OUTPUTS

**Example 1: Praise/Encouragement**

```
Great job! Your balance is stable and healthy at 62.3 CU. Keep doing what
you're doing—your recovery ratio is excellent and improving. You're managing
your cognitive load well!
```

**Violations:** Judgment ("great", "excellent", "healthy"), encouragement,
implicit advice ("keep doing...")

---

**Example 2: Future Predictions**

```
Your stable pattern suggests you've found a sustainable pace. If you maintain
this recovery ratio, you should avoid deficit states in the coming weeks.
This is a good baseline to return to when things get busier.
```

**Violations:** Predictions ("should avoid", "in the coming weeks"),
advice ("baseline to return to")

---

## Test Case 3: Severe Deficit with Low Recovery

### Input Summary

```
Period: 2025-12-11 to 2025-12-18
Days: 7
Avg Balance: -12.8 CU
Trend: DECLINING
Dominant State: DEFICIT

Withdrawals:
- Context Switching: 35%
- Decisions: 38%
- Focus Work: 20%
- Persistent: 7%

Recovery Ratio: 0.18
Recovery Trend: DECLINING
Consecutive Deficits: true
Reduced Capacity: true
```

### ✅ COMPLIANT OUTPUT

```
Over the past 7 days, your average balance was -12.8 CU with a declining trend.
All logged days in this period ended in deficit, and several days began with
reduced starting capacity.

Decision-making was the largest withdrawal category at 38%, followed by context
switching at 35% and focus work at 20%. Persistent load represented 7% of total
withdrawals.

Recovery activities averaged 18% of withdrawal activities, and this ratio showed
a declining trend across the week. Your logged recovery has decreased relative
to logged withdrawals.
```

**Why compliant (even with severe data):**

- States the negative balance factually, no alarm
- Uses past tense and neutral language
- Describes what was logged, not what it "means"
- No urgency despite severity
- Lets the data speak for itself

### ❌ NON-COMPLIANT OUTPUTS

**Example 1: Creating Alarm**

```
ALERT: Your balance has been negative all week at -12.8 CU. This is a serious
deficit pattern that needs immediate attention. You're in a critical state and
must prioritize rest before it gets worse.
```

**Violations:** Alarm language ("ALERT", "serious", "critical"), urgency
("immediate attention", "must"), predictions ("before it gets worse")

---

**Example 2: Diagnosis**

```
This severe deficit pattern indicates burnout. Your 18% recovery ratio is
insufficient to prevent cognitive depletion. You're showing signs of exhaustion
and may need professional support to recover.
```

**Violations:** Diagnostic ("indicates burnout", "exhaustion"), medical advice
("may need professional support"), interpretation beyond data

---

**Example 3: Prescriptive Solutions**

```
Your recovery is critically low at 18%. You need to immediately reduce
decision-making activities (currently 38%) and double your recovery time.
Consider taking a day off or delegating tasks to reduce your cognitive load.
```

**Violations:** Prescriptions ("need to", "consider"), specific advice ("take
a day off", "delegate"), urgency

---

## Test Case 4: Recovery Improvement Pattern

### Input Summary

```
Period: 2025-12-11 to 2025-12-18
Days: 7
Avg Balance: 45.2 CU
Trend: IMPROVING
Dominant State: MODERATE

Withdrawals:
- Context Switching: 30%
- Decisions: 28%
- Focus Work: 22%
- Persistent: 20%

Recovery Ratio: 0.48
Recovery Trend: IMPROVING
Recovery Improvement: true
```

### ✅ COMPLIANT OUTPUT

```
Over the past 7 days, your balance averaged 45.2 CU with an improving trend.
The logged pattern shows recovery activities increased during this period.

Your withdrawal categories were distributed relatively evenly: context switching
at 30%, decision-making at 28%, focus work at 22%, and persistent load at 20%.

Recovery activities averaged 48% of withdrawal activities, with an improving
trend across the week. Your logged recovery increased relative to logged
withdrawals during this period.
```

**Why compliant:**

- Notes improvement without praise
- Describes the change neutrally
- No encouragement or reinforcement
- Simply reflects the data

### ❌ NON-COMPLIANT OUTPUTS

**Example 1: Reinforcement**

```
Excellent progress! Your balance is improving and you've successfully increased
your recovery ratio to 48%. This shows you're learning to manage your energy
better. Keep up the good work!
```

**Violations:** Praise ("excellent", "successfully"), interpretation ("learning
to manage"), encouragement ("keep up")

---

## Key Patterns Summary

### ✅ COMPLIANT LANGUAGE PATTERNS

- "Your balance averaged X CU..."
- "Logged entries showed..."
- "Made up X% of withdrawals..."
- "Recovery activities were X% of..."
- "The pattern showed..." / "The trend indicated..."
- "During this period..."
- Past tense, factual descriptions

### ❌ FORBIDDEN LANGUAGE PATTERNS

- "You should..." / "You need to..."
- "Consider..." / "Try to..."
- "This indicates [diagnosis]..."
- "You're experiencing..."
- "Great job!" / "Keep it up!"
- "This is concerning..." / "Alert..."
- "If you continue..."
- "To improve, you should..."
- Any medical/clinical terms
- Any future predictions
- Any emotional coloring (good/bad, healthy/unhealthy)

---

## Edge Cases

### What if the data is incomplete?

**Compliant:** "During the 3 days logged this week, your balance averaged..."
**Non-compliant:** "You only logged 3 days—try to track more consistently."

### What if metrics conflict?

**Compliant:** "Balance was stable at 50 CU despite recovery ratio declining from 0.5 to 0.3."
**Non-compliant:** "Your recovery decline is concerning even though balance looks stable."

### What if there's no clear pattern?

**Compliant:** "Over 7 days, your balance ranged from 20 to 75 CU without a consistent trend direction."
**Non-compliant:** "Your inconsistent pattern makes it hard to identify problems. Try to be more consistent."

---

## Testing Checklist

Before deploying, validate 50+ outputs against these criteria:

- [ ] No instances of "you should" or "consider"
- [ ] No medical/diagnostic language
- [ ] No predictions about future states
- [ ] No advice or recommendations
- [ ] No emotional language (good/bad/healthy/unhealthy)
- [ ] No urgency or alarm
- [ ] All statements traceable to input data
- [ ] Neutral tone maintained even with severe data
- [ ] No invented "norms" or "recommended ranges"
- [ ] Falls back gracefully if data is missing
