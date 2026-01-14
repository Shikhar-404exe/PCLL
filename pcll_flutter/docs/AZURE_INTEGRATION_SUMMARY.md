# Azure OpenAI Integration Summary

## Overview

This design adds an **optional, opt-in explanation layer** to PCLL using Azure OpenAI. It generates natural language reflections from pre-computed trend summaries without analyzing raw data or modifying any core calculations.

---

## What Was Created

### 1. Documentation (`docs/`)

- **`azure_openai_integration.md`** - Complete architecture design, data contract, prompt structure, security model
- **`azure_output_examples.md`** - 50+ examples of compliant vs. non-compliant outputs with testing criteria
- **`azure_implementation_checklist.md`** - Phase-by-phase implementation guide with verification steps

### 2. Data Models (`lib/core/models/azure_models.dart`)

- **`TrendSummaryForReflection`** - Aggregate-only data structure (NO raw entries)
- **`AzureInsightResponse`** - Parsed AI-generated observations
- **`AzureConfig`** - Endpoint and deployment configuration
- **`AzurePrompts`** - System prompt with strict guardrails

### 3. Service Layer (`lib/core/services/azure_insights_service.dart`)

- **`AzureInsightsService`** - Main service class
  - Opt-in feature flag (disabled by default)
  - Secure API key storage
  - 24-hour caching
  - Graceful error handling
  - 10-second timeout
  - Static builder: `buildSummaryFromTrends()` (ONLY bridge to core system)

### 4. Integration Example (`lib/examples/azure_integration_example.dart`)

- Reference implementation for Trends Screen
- Shows how to add Azure Insights card
- Demonstrates fallback behavior
- Loading/error states

---

## Key Architectural Decisions

### ✅ What Azure OpenAI DOES

- Receives pre-computed aggregate summaries (averages, percentages, trends)
- Converts technical summaries into human-readable reflections
- Acts as pure translation layer

### ❌ What Azure OpenAI DOES NOT DO

- Analyze raw user data
- Make calculations or predictions
- Modify daily balances or trends
- Give advice or diagnoses
- Access individual entries or personal notes

---

## Data Contract

### What Gets Sent (Aggregate Only)

```
Period: 2025-12-11 to 2025-12-18
Days Analyzed: 7
Average Balance: 42.3 CU
Trend Direction: DECLINING
Dominant State: MODERATE

Category Percentages:
- Context Switching: 35%
- Decision Making: 28%
- Focus Work: 22%
- Persistent Load: 15%

Recovery Ratio: 0.42
Pattern Flags: [has consecutive deficits, reduced capacity, etc.]
```

### What NEVER Gets Sent

❌ Individual daily entries  
❌ Raw question answers  
❌ Specific dates with balances  
❌ Personal notes  
❌ User profile data

---

## Security & Privacy

### API Key Management

- Stored encrypted using `flutter_secure_storage`
- Never hardcoded
- User-deletable
- Cleared on uninstall

### Network Security

- HTTPS only
- 10-second timeout
- No automatic retries
- Certificate validation

### Data Minimization

- Only aggregate summaries sent
- No PII in payload
- Assertions prevent raw data leakage

---

## Implementation Phases

### Phase 1: Core Service (Week 1)

- Implement data models
- Build Azure API client
- Add caching and error handling
- Unit tests

### Phase 2: Settings UI (Week 1-2)

- Enable/disable toggle
- API key configuration
- Test connection button
- Clear disclaimers

### Phase 3: Trends Integration (Week 2)

- Optional insights card
- Loading/error states
- Refresh capability
- Graceful fallback

### Phase 4: Testing & Validation (Week 2-3)

- Generate 50+ test outputs
- Validate compliance (zero advice/diagnosis)
- Test all error scenarios
- Performance testing

### Phase 5: Launch (Week 3-4)

- Deploy with feature disabled
- Provide opt-in instructions
- Monitor closely
- Iterate on prompt if needed

---

## Example Output (Compliant)

**Input:** Declining balance (28.5 CU avg), high context switching (48%), low recovery (0.31)

**Azure Output:**

```
Over the past 7 days, your ledger showed an average balance of 28.5 CU
with a declining trend. Your entries logged multiple days ending in deficit
during this period.

Context switching made up 48% of your logged withdrawals this week—the
largest single category. Decision-making and focus work contributed 22%
and 18% respectively.

Your recovery ratio averaged 0.31, meaning logged recovery activities were
31% of withdrawal activities. This recovery rate remained stable across
the week.
```

**Why compliant:**

- Neutral, factual language
- No advice or recommendations
- No interpretation beyond data
- No alarm despite severity

---

## Testing Requirements

### Pre-Launch Validation

- [ ] 50+ outputs reviewed for compliance
- [ ] Zero instances of advice/diagnosis
- [ ] All error scenarios tested
- [ ] Core system works 100% when Azure disabled
- [ ] No raw data in network logs (verified)
- [ ] API keys stored securely (verified)
- [ ] Clear disclaimers present

### Output Compliance Criteria

✅ States facts from summary only  
✅ Uses neutral language  
✅ No advice ("you should", "consider")  
✅ No diagnosis ("indicates burnout")  
✅ No predictions ("will experience")  
✅ No urgency or alarm  
✅ Past tense, factual descriptions

---

## Cost Estimation

- **API Usage:** ~300 tokens per reflection
- **GPT-4 Pricing:** ~$0.01 per reflection
- **Typical Usage:** 4 reflections/week
- **Annual Cost:** ~$2 per active user

**Optimization:**

- 24-hour cache reduces repeat calls
- User-initiated only (not automatic)
- Can use GPT-3.5-Turbo for 70% cost reduction

---

## Success Metrics

### Must Have (Launch Blockers)

✅ Zero advice/diagnosis in validation  
✅ 100% core system uptime when Azure fails  
✅ Secure API key storage  
✅ No raw data sent (validated)  
✅ Feature defaults to disabled

### Should Have (Quality Targets)

✅ <10s response time  
✅ <5% error rate  
✅ Users understand it's optional  
✅ Outputs match tone of existing insights

---

## Risk Mitigation

| Risk                 | Mitigation                                        |
| -------------------- | ------------------------------------------------- |
| Non-compliant output | Extensive testing; prompt guardrails; kill switch |
| Cost overruns        | Usage monitoring; rate limiting; user quotas      |
| Misinterpretation    | Clear disclaimers; neutral language               |
| Security breach      | Encrypted storage; no hardcoded keys              |
| Network issues       | Graceful fallback; clear errors; offline mode     |

---

## Rollout Strategy

1. **Internal Testing (Week 1-2)**

   - Team members enable and test
   - Validate output quality
   - Tune prompt if needed

2. **Beta Testing (Week 3-4)**

   - Invite opt-in users
   - Monitor error rates
   - Collect feedback

3. **Production Launch (Week 5+)**

   - Feature available but disabled by default
   - Documentation and setup guide
   - Close monitoring for issues

4. **Evaluation (Month 1)**
   - Adoption rate
   - Output quality
   - Cost per user
   - User value assessment

---

## Next Steps

1. **Review & Approve** - Stakeholder sign-off on design
2. **Provision Azure** - Set up OpenAI resource and deployment
3. **Add Dependencies** - `flutter_secure_storage` to pubspec.yaml
4. **Implement Phase 1** - Core service and data models
5. **Unit Testing** - Validate all logic before UI work
6. **Settings UI** - Build configuration screen
7. **Integration** - Add to Trends screen
8. **Validation** - Generate and review 50+ test outputs
9. **Launch** - Deploy with feature disabled by default

---

## Files Reference

```
pcll_flutter/
├── docs/
│   ├── azure_openai_integration.md      # Architecture & design
│   ├── azure_output_examples.md         # Compliance examples
│   └── azure_implementation_checklist.md # Implementation guide
├── lib/
│   ├── core/
│   │   ├── models/
│   │   │   └── azure_models.dart        # Data structures
│   │   └── services/
│   │       └── azure_insights_service.dart # Main service
│   └── examples/
│       └── azure_integration_example.dart # UI integration example
```

---

## Important Reminders

🔒 **Security:** API keys encrypted, never in code  
🎯 **Scope:** Explanation layer only, not analysis  
🚫 **Boundaries:** No advice, diagnosis, or predictions  
⚡ **Performance:** <10s response or timeout  
🔌 **Offline:** Core system must work without Azure  
📊 **Privacy:** Only aggregate data sent  
🎛️ **Control:** Opt-in, user-controlled, deletable

---

## Contact & Support

If issues arise during implementation:

1. Review design documents in `docs/`
2. Check example implementation in `lib/examples/`
3. Verify against compliance criteria in output examples
4. Test with mock data before live Azure calls

**Remember:** When in doubt, preserve offline functionality and user control. Azure Insights is enhancement, not requirement.
