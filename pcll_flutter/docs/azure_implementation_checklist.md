# Azure OpenAI Integration - Implementation Checklist

## Pre-Implementation

- [ ] Review and approve architecture design
- [ ] Confirm Azure OpenAI resource is provisioned
- [ ] Obtain deployment name and endpoint URL
- [ ] Review cost implications (~$2/user/year at 4 reflections/week)
- [ ] Establish testing plan with output validation

---

## Phase 1: Core Service Implementation

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  # Add for secure API key storage
  flutter_secure_storage: ^9.0.0

  # Already have these:
  shared_preferences: ^2.2.2
  # HTTP client built-in (using dart:io HttpClient)
```

- [ ] Add `flutter_secure_storage` dependency
- [ ] Run `flutter pub get`

### Data Models

- [ ] Create `lib/core/models/azure_models.dart`
  - [ ] `TrendSummaryForReflection` class
  - [ ] `AzureInsightResponse` class
  - [ ] `AzureConfig` class
  - [ ] `AzurePrompts` class with system prompt

### Service Implementation

- [ ] Create `lib/core/services/azure_insights_service.dart`
  - [ ] Singleton pattern
  - [ ] Initialize() method
  - [ ] configure() method for setup
  - [ ] testConnection() for validation
  - [ ] getReflection() main API call
  - [ ] Caching logic (24hr expiry)
  - [ ] Error handling with graceful fallback
  - [ ] buildSummaryFromTrends() static builder

### Unit Tests

- [ ] Test TrendSummaryForReflection serialization
- [ ] Test prompt string generation
- [ ] Test response parsing (mock Azure responses)
- [ ] Test cache key generation
- [ ] Test cache expiry logic
- [ ] Test error handling (timeout, 401, 500, etc.)
- [ ] Validate no raw data in serialized summary

---

## Phase 2: Settings Screen

### Settings UI

- [ ] Create Azure Insights settings section in existing settings screen
- [ ] Add enable/disable toggle (default: OFF)
- [ ] Add endpoint input field (validated URL)
- [ ] Add deployment name input field
- [ ] Add API key input field (obscured, secure storage)
- [ ] Add "Test Connection" button
- [ ] Add "Clear Configuration" button
- [ ] Show current status (enabled/disabled, configured/not)

### Disclaimer Text

- [ ] Add clear explanation of what data is sent
- [ ] Emphasize opt-in nature
- [ ] Link to full privacy disclosure
- [ ] Note that core system works without Azure

Example copy:

```
Azure Insights (Optional)

Generate natural language summaries of your weekly patterns
using Azure OpenAI.

What's Sent: Pre-computed trend summaries (averages, percentages)
What's NOT Sent: Individual entries, raw data, personal notes

Status: Disabled (tap to configure)

[Configure Azure Insights →]
```

---

## Phase 3: Integration into Trends Screen

### UI Changes (Minimal, Additive Only)

- [ ] Add optional "Natural Language Summary" card at bottom of trends
- [ ] Only show if Azure is enabled and configured
- [ ] Add "Generate Summary" button
- [ ] Show loading state during API call
- [ ] Display observations in numbered list
- [ ] Show cache timestamp
- [ ] Add refresh button
- [ ] Show error state with retry option
- [ ] Add small disclaimer text

### Integration Points

- [ ] Initialize AzureInsightsService in main()
- [ ] Check `isAvailable` before showing UI
- [ ] Call `buildSummaryFromTrends()` with existing entries/trends
- [ ] Handle null response gracefully (no UI crash)
- [ ] Don't block existing insights if Azure fails

---

## Phase 4: Security & Privacy

### API Key Security

- [ ] Never hardcode keys in source code
- [ ] Use `flutter_secure_storage` for key storage
- [ ] Keys encrypted at rest on device
- [ ] Provide "Delete All Azure Data" option
- [ ] Clear keys on app uninstall (automatic)

### Network Security

- [ ] Enforce HTTPS only (validate in URL input)
- [ ] Set 10s timeout on API requests
- [ ] No automatic retries (user-initiated only)
- [ ] Validate certificate (default in Dart HttpClient)

### Data Minimization Validation

- [ ] Audit `TrendSummaryForReflection.toJson()`
- [ ] Confirm no `LedgerEntry` objects serialized
- [ ] Confirm no dates with specific events
- [ ] Confirm only aggregate percentages sent
- [ ] Add assertion to prevent raw data leakage

Example assertion:

```dart
assert(
  !json.containsKey('entries'),
  'SECURITY: Raw entries must never be serialized',
);
```

---

## Phase 5: Testing

### Functional Testing

- [ ] Test with valid Azure endpoint → success
- [ ] Test with invalid API key → proper error message
- [ ] Test with network offline → graceful fallback
- [ ] Test with malformed response → error handling
- [ ] Test cache hit (2nd call same data) → returns cached
- [ ] Test cache miss (24+ hours old) → new API call
- [ ] Test timeout (>10s) → proper timeout message
- [ ] Test disable while loading → cancels properly

### Output Validation (Critical)

- [ ] Generate 50 test outputs with diverse inputs
- [ ] Manually review each for compliance
- [ ] Check for forbidden phrases (grep for "you should", "consider", etc.)
- [ ] Verify neutral tone in all cases
- [ ] Test with severe deficit data (no alarm language)
- [ ] Test with improvement data (no praise)
- [ ] Log any non-compliant outputs for prompt tuning

### Integration Testing

- [ ] Enable Azure → trends screen shows new section
- [ ] Disable Azure → trends screen hides section
- [ ] Generate summary → displays correctly
- [ ] Clear config → all settings removed
- [ ] Uninstall/reinstall → keys properly cleared

---

## Phase 6: Documentation

### User Documentation

- [ ] Add FAQ: "What is Azure Insights?"
- [ ] Add FAQ: "What data is sent to Azure?"
- [ ] Add FAQ: "Can I use PCLL without Azure?"
- [ ] Add setup guide with screenshots
- [ ] Document how to get Azure OpenAI endpoint

### Developer Documentation

- [ ] Comment architecture decisions in code
- [ ] Document data contract in `azure_models.dart`
- [ ] Add examples of compliant/non-compliant outputs
- [ ] Document testing procedures
- [ ] Add troubleshooting guide

---

## Phase 7: Deployment

### Pre-Launch Checklist

- [ ] All tests passing
- [ ] Output validation complete (0 non-compliant in 50 samples)
- [ ] Settings UI reviewed and approved
- [ ] Disclaimers clear and accurate
- [ ] Feature flag defaults to OFF
- [ ] Error handling tested in all scenarios
- [ ] Performance acceptable (<10s for API call)

### Launch Strategy

- [ ] Deploy with feature disabled by default
- [ ] Provide opt-in instructions
- [ ] Monitor error rates
- [ ] Monitor API usage/costs
- [ ] Collect user feedback on output quality
- [ ] Watch for any guardrail violations in wild

### Rollback Plan

- [ ] Can disable via remote config (if implemented)
- [ ] Users can disable in settings
- [ ] Core system unaffected if Azure removed entirely
- [ ] Instructions to clear Azure config if needed

---

## Phase 8: Monitoring & Iteration

### Week 1-2: Close Monitoring

- [ ] Check error logs daily
- [ ] Review sample outputs for compliance
- [ ] Monitor API costs vs. estimates
- [ ] Collect user feedback
- [ ] Document any issues

### Month 1: Evaluation

- [ ] Analyze adoption rate (% of users who enable)
- [ ] Review output quality (any violations?)
- [ ] Assess cost per user vs. estimates
- [ ] Survey users: "Is this feature valuable?"
- [ ] Decide: continue, iterate, or sunset

### Prompt Tuning (If Needed)

- [ ] If non-compliant outputs appear, update system prompt
- [ ] Add more examples to few-shot learning
- [ ] Adjust temperature if outputs too variable
- [ ] Test new prompt with validation suite
- [ ] Deploy prompt update (no code change needed)

---

## Success Criteria

### Must Have (Launch Blockers)

- ✅ Zero instances of advice/diagnosis in validation testing
- ✅ Core system works 100% when Azure fails
- ✅ API keys stored securely
- ✅ No raw data sent to Azure (validated)
- ✅ Feature defaults to disabled

### Should Have (Quality Targets)

- ✅ <10s response time or timeout
- ✅ <5% error rate in production
- ✅ Clear, understandable outputs
- ✅ Users understand it's optional

### Nice to Have (Future Enhancements)

- ⚪ Multiple language support
- ⚪ Customizable prompt templates
- ⚪ Export reflections as PDF
- ⚪ Voice narration of insights

---

## Risk Mitigation

| Risk                                | Mitigation                                               |
| ----------------------------------- | -------------------------------------------------------- |
| Azure produces non-compliant output | Extensive validation testing; prompt tuning; kill switch |
| API costs exceed budget             | Monitor usage; add rate limiting; warn users of quota    |
| Users misinterpret as diagnosis     | Clear disclaimers; neutral language; education           |
| API keys leaked                     | Secure storage; never in code; rotation capability       |
| Network errors frustrate users      | Graceful fallback; clear error messages; offline mode    |
| Slow response times                 | 10s timeout; caching; loading indicators                 |

---

## Post-Launch: Future Considerations

### Potential Enhancements (Not in v1)

- [ ] Support for other LLM providers (OpenAI, Anthropic, local models)
- [ ] User-customizable prompts (advanced users only)
- [ ] Batch generation (monthly summaries)
- [ ] Comparison mode ("This week vs. last month")
- [ ] Export summaries to journal apps

### Deprecation Plan (If Needed)

If feature is not valuable or too costly:

1. Announce deprecation 60 days in advance
2. Disable new configurations
3. Existing users can use until sunset date
4. Remove code in next major version
5. Core PCLL continues unchanged

---

## Final Pre-Launch Verification

**Before enabling for any users, verify:**

- [ ] I have tested 50+ outputs and found 0 instances of advice/diagnosis
- [ ] I have tested offline mode and confirmed graceful degradation
- [ ] I have verified no raw data in network logs (Wireshark/Charles)
- [ ] I have confirmed API keys are stored encrypted
- [ ] I have tested that core system works identically with Azure disabled
- [ ] I have clear disclaimers visible to users
- [ ] I have documented rollback procedure
- [ ] I have cost monitoring in place

**Signature:** ******\_\_\_\_****** **Date:** **\_\_\_\_**

---

## Notes

- This is an OPTIONAL enhancement to PCLL
- Core deterministic system must NEVER be affected
- When in doubt, fail gracefully and preserve offline functionality
- Azure is explanation layer only, not analysis or decision-making
- User privacy and data sovereignty are non-negotiable
