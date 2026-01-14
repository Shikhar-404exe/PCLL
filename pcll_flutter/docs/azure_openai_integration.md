# Azure OpenAI Integration Design

## PCLL Enhancement: Natural Language Reflection Layer

---

## Core Principles

**MUST PRESERVE:**

- All local calculations remain unchanged
- Deterministic ledger engine stays rule-based
- No AI in the critical path (daily balance, trends)
- Full offline functionality
- User data sovereignty

**AZURE OPENAI ROLE:**

- Explanation layer ONLY
- Receives pre-computed summaries
- Generates human-readable reflections
- No analysis, no predictions, no advice

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    USER INTERFACE                        │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│              EXISTING PCLL CORE (Unchanged)              │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │ Ledger Service   │  │ Insight Service  │            │
│  │ (Deterministic)  │  │ (Rule-based)     │            │
│  └──────────────────┘  └──────────────────┘            │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │ Trend Analysis   │  │ Pattern Observer │            │
│  │ (Math only)      │  │ (Local stats)    │            │
│  └──────────────────┘  └──────────────────┘            │
└─────────────────────────────────────────────────────────┘
                           │
                           │ Pre-computed summaries only
                           ▼
┌─────────────────────────────────────────────────────────┐
│         NEW: Azure Insights Service (Opt-in)             │
│  ┌────────────────────────────────────────────┐         │
│  │  - Receives aggregate stats                │         │
│  │  - Calls Azure OpenAI API                  │         │
│  │  - Returns natural language text           │         │
│  │  - Fails gracefully if offline/disabled    │         │
│  └────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼ (Optional, can be disabled)
                    Azure OpenAI API
```

---

## Data Contract: What Gets Sent to Azure

### Summary Object Structure

```dart
class TrendSummaryForReflection {
  // Time period
  final String periodStart;  // "2025-12-11"
  final String periodEnd;    // "2025-12-18"
  final int daysAnalyzed;    // 7

  // Aggregate metrics (NO raw entries)
  final double avgBalance;           // 42.3 CU
  final String trendDirection;       // "DECLINING", "STABLE", "IMPROVING"
  final String dominantState;        // "MODERATE" (most common state)

  // Category proportions (percentages only)
  final double contextSwitchingPct;  // 35% of total withdrawals
  final double decisionMakingPct;    // 28%
  final double focusWorkPct;         // 22%
  final double persistentLoadPct;    // 15%

  // Recovery pattern (aggregate only)
  final double avgRecoveryRatio;     // 0.42 (42% recovery rate)
  final String recoveryTrend;        // "IMPROVING", "DECLINING", "STABLE"

  // Pattern flags (boolean observations)
  final bool hasConsecutiveDeficits;
  final bool hasReducedCapacity;
  final bool showsRecoveryImprovement;
}
```

### What Is NEVER Sent

❌ Individual daily entries  
❌ Raw question answers (e.g., "8 decisions")  
❌ Specific dates with balances  
❌ Personal notes or comments  
❌ User profile information  
❌ Timestamps or usage patterns

---

## Prompt Structure with Guardrails

### System Prompt

```
You are a neutral reflection assistant for the Personal Cognitive Load Ledger (PCLL).

YOUR ROLE:
- Convert pre-computed trend summaries into brief, human-readable reflections
- Mirror the user's patterns back to them in natural language
- Act as a translation layer, not an analyst

STRICT BOUNDARIES:
- You receive ONLY aggregate summaries, never raw data
- You do NOT analyze, diagnose, or interpret beyond what's in the summary
- You do NOT give advice, suggestions, or recommendations
- You do NOT make predictions about future states
- You do NOT reference medical, clinical, or psychological concepts
- You do NOT create urgency or alarm

OUTPUT REQUIREMENTS:
- Generate 1-3 short observations (2-3 sentences each)
- Use neutral, factual language
- Reflect patterns, do not prescribe solutions
- If a metric is missing, do not invent or assume it

FORBIDDEN PHRASES:
- "You should..."
- "Consider doing..."
- "This indicates burnout..."
- "You might be experiencing..."
- "Try to..."
- Any diagnostic language

ALLOWED PATTERNS:
- "Over the past 7 days, your balance averaged X CU..."
- "Context switching made up Y% of your withdrawals this week..."
- "Your trend direction is currently [direction]..."
- "Recovery activities were Z% of withdrawal activities..."
```

### User Prompt Template

```
Generate 1-3 brief, neutral observations from this 7-day trend summary:

Period: {periodStart} to {periodEnd}
Days Analyzed: {daysAnalyzed}

Average Balance: {avgBalance} CU
Trend Direction: {trendDirection}
Dominant State: {dominantState}

Withdrawal Breakdown:
- Context Switching: {contextSwitchingPct}%
- Decision Making: {decisionMakingPct}%
- Focus Work: {focusWorkPct}%
- Persistent Load: {persistentLoadPct}%

Recovery:
- Average Recovery Ratio: {avgRecoveryRatio}
- Recovery Trend: {recoveryTrend}

Pattern Flags:
- Consecutive Deficits: {hasConsecutiveDeficits}
- Reduced Capacity: {hasReducedCapacity}
- Recovery Improvement: {showsRecoveryImprovement}

Provide 1-3 observations in plain language. Do not give advice.
```

### API Configuration

```dart
// Azure OpenAI API settings
const azureConfig = {
  'endpoint': 'https://[YOUR-RESOURCE].openai.azure.com/',
  'deployment': 'gpt-4',  // or gpt-35-turbo
  'apiVersion': '2024-08-01-preview',
  'temperature': 0.3,  // Low for consistency
  'maxTokens': 300,    // ~2-3 short paragraphs
  'topP': 0.9,
  'frequencyPenalty': 0.0,
  'presencePenalty': 0.0,
};
```

---

## Example Outputs

### Input Summary

```
Period: 2025-12-11 to 2025-12-18
Days: 7
Avg Balance: 38.2 CU
Trend: DECLINING
Dominant State: MODERATE

Withdrawals:
- Context Switching: 42%
- Decisions: 25%
- Focus Work: 20%
- Persistent: 13%

Recovery Ratio: 0.35
Recovery Trend: STABLE
Consecutive Deficits: true
```

### Compliant Output ✅

```
Over the past 7 days, your ledger showed an average balance of 38.2 CU
with a declining trend. Your entries indicate you ended multiple days
in deficit during this period.

Context switching made up 42% of your logged withdrawals this week—the
largest category. Decision-making and focus work comprised the remaining
portions at 25% and 20% respectively.

Your recovery ratio averaged 0.35, meaning logged recovery activities were
35% of withdrawal activities. This recovery rate remained stable across
the week.
```

### Non-Compliant Output ❌

```
❌ "You're experiencing burnout symptoms. Consider reducing your workload."
   (Diagnostic language + advice)

❌ "This pattern suggests you should take a break soon to avoid exhaustion."
   (Prediction + prescription)

❌ "Your high context switching indicates poor time management."
   (Interpretation beyond the data)
```

---

## Implementation Plan

### Phase 1: Service Layer

```
lib/core/services/azure_insights_service.dart
  - AzureInsightsService class
  - API client with error handling
  - Prompt construction
  - Response parsing
  - Rate limiting / caching
```

### Phase 2: Data Models

```
lib/core/models/azure_models.dart
  - TrendSummaryForReflection class
  - AzureInsightResponse class
  - Configuration models
```

### Phase 3: Configuration

```
lib/core/config/azure_config.dart
  - API key management (never hardcoded)
  - Endpoint configuration
  - Feature flag: azureInsightsEnabled
```

### Phase 4: Settings UI

```
lib/features/settings/azure_settings_screen.dart
  - Enable/disable toggle (default: OFF)
  - API key input (secure)
  - Test connection button
  - Clear disclaimers
```

### Phase 5: Integration Points

```
lib/features/trends/trends_screen.dart
  - Optional "Natural Language Summary" button
  - Shows loading state
  - Falls back gracefully on error
  - Caches results (don't call API repeatedly)
```

---

## Security & Privacy

### API Key Storage

- Use `flutter_secure_storage` package
- Never commit keys to repository
- Keys stored encrypted on device
- Option to clear/delete keys

### Network Security

- HTTPS only
- Certificate pinning (optional)
- Timeout handling (10s max)
- No retry on failure (user-initiated only)

### Data Minimization

- Only send aggregate summaries
- No personally identifiable information
- No raw entries or dates with specific events
- Summaries expire/don't persist in API logs

### User Consent

```
Settings Screen Warning:
"Azure Insights is an optional feature that sends pre-computed
trend summaries (averages, percentages) to Azure OpenAI to
generate natural language reflections.

Your individual entries, balances, and personal data are NEVER
sent. The core PCLL system remains fully local and deterministic.

You can disable this feature at any time."
```

---

## Error Handling

### Graceful Degradation

```dart
try {
  final insights = await azureInsightsService.getReflection(summary);
  // Show insights in UI
} catch (e) {
  // Log error (optional telemetry)
  // Show fallback: "Natural language summary unavailable"
  // Core trends still visible - nothing breaks
}
```

### Failure Scenarios

- No internet connection → Show cached insight or none
- API key invalid → Prompt user to check settings
- Rate limit hit → Show message, suggest retry later
- Azure outage → Fall back to local insights only
- Timeout → Cancel request, show local data

---

## Testing Strategy

### Unit Tests

- Summary serialization
- Prompt construction
- Response parsing
- Error handling

### Integration Tests

- Mock Azure API responses
- Test with various trend patterns
- Validate output compliance with guardrails

### Manual Review

- Sample 50+ outputs with diverse inputs
- Check for forbidden phrases
- Verify no advice/diagnosis
- Confirm neutral tone

---

## Rollout Strategy

1. **Internal Testing** (Week 1-2)

   - Implement core service
   - Test with mock data
   - Validate guardrails

2. **Beta Testing** (Week 3-4)

   - Enable for opt-in users
   - Collect feedback on output quality
   - Monitor API usage/costs

3. **Production Release** (Week 5)
   - Feature flag: disabled by default
   - Opt-in via Settings
   - Clear documentation
   - Monitor for guardrail violations

---

## Cost Estimation

### Azure OpenAI Pricing (GPT-4)

- ~300 tokens per request (input + output)
- At current rates: ~$0.01 per reflection
- If user generates 4 reflections/week: ~$2/year per user

### Optimization

- Cache reflections for 24 hours
- Only generate on user request (not automatic)
- Use GPT-3.5-Turbo for lower cost (~70% cheaper)

---

## Success Metrics

### Functional

✅ Zero instances of advice/diagnosis in outputs  
✅ 100% uptime of core system when Azure fails  
✅ <10s response time or timeout  
✅ API key stored securely

### User Experience

✅ <5% of users report outputs as "prescriptive"  
✅ Insights match existing rule-based insights in tone  
✅ Clear understanding that it's optional

### Technical

✅ No raw data in API logs  
✅ Graceful degradation on all failure modes  
✅ Core calculations unchanged
