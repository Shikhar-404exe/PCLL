// Azure OpenAI Models

/// Summary data that can be safely sent to Azure OpenAI
/// Contains ONLY aggregate statistics, no raw entries
class TrendSummaryForReflection {
  // Time period
  final String periodStart; // e.g., "2025-12-11"
  final String periodEnd; // e.g., "2025-12-18"
  final int daysAnalyzed;

  // Aggregate metrics (NO raw entries)
  final double avgBalance; // Average daily balance in CU
  final String trendDirection; // DECLINING, STABLE, IMPROVING
  final String dominantState; // Most common CognitiveState

  // Category proportions (percentages only, no raw counts)
  final double contextSwitchingPct; // % of total withdrawals
  final double decisionMakingPct;
  final double focusWorkPct;
  final double persistentLoadPct;

  // Recovery pattern (aggregate only)
  final double avgRecoveryRatio; // deposits/withdrawals
  final String recoveryTrend; // IMPROVING, DECLINING, STABLE

  // Pattern flags (boolean observations from existing rules)
  final bool hasConsecutiveDeficits;
  final bool hasReducedCapacity;
  final bool showsRecoveryImprovement;

  const TrendSummaryForReflection({
    required this.periodStart,
    required this.periodEnd,
    required this.daysAnalyzed,
    required this.avgBalance,
    required this.trendDirection,
    required this.dominantState,
    required this.contextSwitchingPct,
    required this.decisionMakingPct,
    required this.focusWorkPct,
    required this.persistentLoadPct,
    required this.avgRecoveryRatio,
    required this.recoveryTrend,
    required this.hasConsecutiveDeficits,
    required this.hasReducedCapacity,
    required this.showsRecoveryImprovement,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() => {
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'daysAnalyzed': daysAnalyzed,
        'avgBalance': avgBalance,
        'trendDirection': trendDirection,
        'dominantState': dominantState,
        'contextSwitchingPct': contextSwitchingPct,
        'decisionMakingPct': decisionMakingPct,
        'focusWorkPct': focusWorkPct,
        'persistentLoadPct': persistentLoadPct,
        'avgRecoveryRatio': avgRecoveryRatio,
        'recoveryTrend': recoveryTrend,
        'hasConsecutiveDeficits': hasConsecutiveDeficits,
        'hasReducedCapacity': hasReducedCapacity,
        'showsRecoveryImprovement': showsRecoveryImprovement,
      };

  /// Format as prompt-friendly text
  String toPromptString() {
    return '''
Generate 1-3 brief, neutral observations from this 7-day trend summary:

Period: $periodStart to $periodEnd
Days Analyzed: $daysAnalyzed

Average Balance: ${avgBalance.toStringAsFixed(1)} CU
Trend Direction: $trendDirection
Dominant State: $dominantState

Withdrawal Breakdown:
- Context Switching: ${contextSwitchingPct.toStringAsFixed(0)}%
- Decision Making: ${decisionMakingPct.toStringAsFixed(0)}%
- Focus Work: ${focusWorkPct.toStringAsFixed(0)}%
- Persistent Load: ${persistentLoadPct.toStringAsFixed(0)}%

Recovery:
- Average Recovery Ratio: ${avgRecoveryRatio.toStringAsFixed(2)}
- Recovery Trend: $recoveryTrend

Pattern Flags:
- Consecutive Deficits: $hasConsecutiveDeficits
- Reduced Capacity: $hasReducedCapacity
- Recovery Improvement: $showsRecoveryImprovement

Provide 1-3 observations in plain language. Do not give advice.
''';
  }
}

/// Response from Azure OpenAI
class AzureInsightResponse {
  final List<String> observations;
  final DateTime timestamp;
  final bool fromCache;

  const AzureInsightResponse({
    required this.observations,
    required this.timestamp,
    this.fromCache = false,
  });

  factory AzureInsightResponse.fromJson(Map<String, dynamic> json) {
    // Parse Azure OpenAI response format
    final choices = json['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      return AzureInsightResponse(
        observations: ['No insights available'],
        timestamp: DateTime.now(),
      );
    }

    final message = choices[0]['message'];
    final content = message['content'] as String? ?? '';

    // Split content into observations (by paragraph or numbered list)
    final observations = content
        .split(RegExp(r'\n\n+|\n\d+\.\s+'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();

    return AzureInsightResponse(
      observations: observations,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'observations': observations,
        'timestamp': timestamp.toIso8601String(),
        'fromCache': fromCache,
      };

  factory AzureInsightResponse.fromCacheJson(Map<String, dynamic> json) {
    return AzureInsightResponse(
      observations: List<String>.from(json['observations']),
      timestamp: DateTime.parse(json['timestamp']),
      fromCache: true,
    );
  }
}

/// Azure OpenAI configuration
class AzureConfig {
  final String endpoint;
  final String deploymentName;
  final String apiVersion;
  final double temperature;
  final int maxTokens;

  const AzureConfig({
    required this.endpoint,
    required this.deploymentName,
    this.apiVersion = '2024-08-01-preview',
    this.temperature = 0.3,
    this.maxTokens = 300,
  });

  /// Validate configuration
  bool isValid() {
    return endpoint.isNotEmpty &&
        deploymentName.isNotEmpty &&
        endpoint.startsWith('https://');
  }
}

/// System prompt with strict guardrails
class AzurePrompts {
  static const String systemPrompt = '''
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
''';
}
