// Azure Insights Service
// DEMO MODE: Uses offline simulation instead of Azure API

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azure_models.dart';
import '../models/models.dart';
import '../config/env_config.dart';

/// Service for optional Azure OpenAI integration
/// DEMO MODE: Provides simulated responses for demonstrations
class AzureInsightsService {
  // Singleton pattern
  static final AzureInsightsService _instance =
      AzureInsightsService._internal();
  factory AzureInsightsService() => _instance;
  AzureInsightsService._internal();

  final Random _random = Random();

  // DEMO MODE: Always available
  bool _isEnabled = true;

  /// Initialize with configuration
  Future<void> initialize() async {
    // DEMO MODE: Always enabled for demonstration
    _isEnabled = true;
  }

  /// Check if service is available (always true for demo)
  bool get isAvailable => true; // DEMO: Always available

  /// Enable/disable the service (always enabled in demo mode)
  Future<void> setEnabled(bool enabled) async {
    // DEMO MODE: Always enabled
    _isEnabled = true;
  }

  /// Configure Azure connection (not needed in demo mode)
  Future<void> configure({
    required String endpoint,
    required String deploymentName,
    required String apiKey,
  }) async {
    // DEMO MODE: Configuration not needed
  }

  /// Test connection (always succeeds in demo mode)
  Future<bool> testConnection() async {
    // DEMO MODE: Simulate connection test with delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
    return true;
  }

  /// Generate natural language reflection from trend summary
  /// DEMO MODE: Returns simulated responses
  Future<AzureInsightResponse?> getReflection(
    TrendSummaryForReflection summary, {
    bool forceRefresh = false,
  }) async {
    // DEMO MODE: Simulate API delay
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    final observations = _generateSimulatedInsights(summary);

    return AzureInsightResponse(
      observations: observations,
      timestamp: DateTime.now(),
      fromCache: false,
    );
  }

  /// DEMO MODE: Generate simulated AI insights based on trend data
  List<String> _generateSimulatedInsights(TrendSummaryForReflection summary) {
    List<String> insights = [];

    // Opening based on average balance
    if (summary.avgBalance >= 70) {
      insights.add(
          'Your cognitive capacity has been excellent this week, averaging ${summary.avgBalance.toStringAsFixed(0)} CU. You\'re operating in an optimal zone for complex work and decision-making.');
    } else if (summary.avgBalance >= 40) {
      insights.add(
          'You\'ve maintained a moderate cognitive balance this week at ${summary.avgBalance.toStringAsFixed(0)} CU average. You\'re managing your workload reasonably well, though there\'s room to optimize.');
    } else if (summary.avgBalance >= 0) {
      insights.add(
          'Your average balance of ${summary.avgBalance.toStringAsFixed(0)} CU indicates you\'re running on lower reserves. You\'re in a depleted state that requires attention and recovery.');
    } else {
      insights.add(
          'Your cognitive account has been in deficit this week, averaging ${summary.avgBalance.toStringAsFixed(0)} CU. This is a clear signal that recovery needs to become your top priority.');
    }

    // Trend analysis
    if (summary.trendDirection.contains('IMPROVING')) {
      insights.add(
          'The positive trend is encouraging - you\'re moving in the right direction. Whatever changes you\'ve made recently are working. Keep up these recovery-focused habits.');
    } else if (summary.trendDirection.contains('DECLINING') ||
        summary.trendDirection.contains('DETERIORATING')) {
      insights.add(
          'I\'m concerned about the declining trend in your cognitive balance. This pattern suggests your current approach isn\'t sustainable. It\'s time to reassess your commitments and recovery strategies.');
    } else {
      insights.add(
          'Your balance has remained relatively stable. While consistency is valuable, consider whether you could push for gradual improvement or if you need to guard against slow decline.');
    }

    // Load category analysis
    final highestCategory = _getHighestLoadCategory(summary);
    switch (highestCategory) {
      case 'context':
        insights.add(
            'Context switching accounts for ${summary.contextSwitchingPct.toStringAsFixed(0)}% of your cognitive load - that\'s significant. Each context switch fragments your attention. Try batching similar tasks and protecting focus blocks.');
        break;
      case 'decisions':
        insights.add(
            'Decision-making is consuming ${summary.decisionMakingPct.toStringAsFixed(0)}% of your cognitive budget. Consider which decisions could be deferred, delegated, or automated with clear criteria.');
        break;
      case 'focus':
        insights.add(
            'Deep focus work represents ${summary.focusWorkPct.toStringAsFixed(0)}% of your load. While valuable, extended focus drains CU quickly. Make sure you\'re scheduling adequate recovery between intense sessions.');
        break;
      case 'persistent':
        insights.add(
            'Persistent unresolved items are taking ${summary.persistentLoadPct.toStringAsFixed(0)}% of your cognitive capacity. These background drains compound daily. Prioritize either completing or consciously releasing these items.');
        break;
    }

    // Recovery analysis
    if (summary.avgRecoveryRatio < 0.3) {
      insights.add(
          'Your recovery ratio of ${(summary.avgRecoveryRatio * 100).toStringAsFixed(0)}% is critically low. You\'re not getting adequate rest relative to your load. This isn\'t sustainable - you need to prioritize sleep, breaks, and genuine downtime.');
    } else if (summary.avgRecoveryRatio < 0.5) {
      insights.add(
          'Your recovery ratio of ${(summary.avgRecoveryRatio * 100).toStringAsFixed(0)}% suggests you\'re under-recovering. The quality or quantity of your rest periods needs improvement to match your cognitive demands.');
    } else if (summary.avgRecoveryRatio >= 0.7 && summary.avgBalance < 50) {
      insights.add(
          'Your recovery ratio is good at ${(summary.avgRecoveryRatio * 100).toStringAsFixed(0)}%, yet your balance remains low. This suggests your baseline load might be too high. Consider reducing commitments or improving recovery quality.');
    }

    // Pattern-specific insights
    if (summary.hasConsecutiveDeficits) {
      insights.add(
          'You\'ve experienced consecutive days in deficit - this is a red flag. Deficit accumulation has compounding effects on performance and wellbeing. Break this cycle with intentional recovery days.');
    }

    if (summary.hasReducedCapacity) {
      insights.add(
          'Starting days with reduced capacity (below 100 CU) means you\'re carrying cognitive debt forward. This makes you more vulnerable to deficit and reduces your buffer for unexpected demands.');
    }

    if (summary.recoveryTrend == 'IMPROVING' &&
        summary.trendDirection.contains('IMPROVING')) {
      insights.add(
          'Both your balance and recovery are trending upward - excellent! You\'ve found a sustainable rhythm. Document what\'s working so you can maintain or return to these practices.');
    } else if (summary.recoveryTrend == 'DECLINING') {
      insights.add(
          'Your recovery quality appears to be declining. Are you getting less sleep? More stress? Less effective breaks? Identify what\'s changed and address it before balance deteriorates further.');
    }

    // Add a closing recommendation
    if (summary.avgBalance < 0) {
      insights.add(
          'Action needed: Schedule at least one full recovery day this week. Clear your calendar, minimize decisions, and prioritize activities that genuinely restore you. Your system needs a reset.');
    } else if (summary.avgBalance < 40) {
      insights.add(
          'Next steps: Focus on incremental improvements. Add one 10-minute recovery break to each work block. Say no to one non-essential commitment. Small changes compound.');
    } else if (summary.avgBalance < 70) {
      insights.add(
          'You\'re in a solid position to optimize. Experiment with one process improvement - maybe time-boxing decisions, or front-loading your hardest work when CU is highest.');
    } else {
      insights.add(
          'You\'re operating at peak capacity. This is your opportunity to tackle challenging projects, mentor others, or build systems that will support you when CU is lower.');
    }

    return insights;
  }

  String _getHighestLoadCategory(TrendSummaryForReflection summary) {
    final categories = {
      'context': summary.contextSwitchingPct,
      'decisions': summary.decisionMakingPct,
      'focus': summary.focusWorkPct,
      'persistent': summary.persistentLoadPct,
    };

    return categories.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /* COMMENTED OUT: Azure API Call
  /// Internal: Call Azure OpenAI API
  Future<AzureInsightResponse> _callAzureAPI(
    TrendSummaryForReflection summary, {
    bool bypassCache = false,
  }) async {
    if (_config == null || _apiKey == null) {
      throw Exception('Azure not configured');
    }

    // Construct request URL
    final url = Uri.parse(
      '${_config!.endpoint}openai/deployments/${_config!.deploymentName}/chat/completions?api-version=${_config!.apiVersion}',
    );

    // Construct request body
    final body = {
      'messages': [
        {
          'role': 'system',
          'content': AzurePrompts.systemPrompt,
        },
        {
          'role': 'user',
          'content': summary.toPromptString(),
        },
      ],
      'temperature': _config!.temperature,
      'max_tokens': _config!.maxTokens,
      'top_p': 0.9,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    };

    // Make HTTP request
    final client = HttpClient();
    try {
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('api-key', _apiKey!);

      // Set timeout
      request.headers.set('Connection', 'close');

      request.add(utf8.encode(json.encode(body)));
      final response = await request.close().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        throw Exception('Azure API error: ${response.statusCode} - $errorBody');
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final responseJson = json.decode(responseBody);

      return AzureInsightResponse.fromJson(responseJson);
    } finally {
      client.close();
    }
  }

  /// Generate cache key from summary
  String _getCacheKey(TrendSummaryForReflection summary) {
    return '${summary.periodStart}_${summary.periodEnd}_${summary.avgBalance.toStringAsFixed(1)}';
  }

  /// Clear all cached insights
  void clearCache() {
    _cache.clear();
  }

  /// Clear configuration (for logout/reset)
  Future<void> clearConfiguration() async {
    _config = null;
    _apiKey = null;
    _isEnabled = false;
    _cache.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('azure_insights_enabled');
    await prefs.remove('azure_endpoint');
    await prefs.remove('azure_deployment');
    await prefs.remove('azure_api_key');
  }
  */ // END COMMENTED OUT SECTION

  /// Build TrendSummaryForReflection from existing PCLL data structures
  /// This is the ONLY bridge between core system and Azure
  static TrendSummaryForReflection buildSummaryFromTrends({
    required List<LedgerEntry> entries,
    required WeeklyTrends trends,
  }) {
    if (entries.isEmpty) {
      throw ArgumentError('Cannot build summary from empty entries');
    }

    // Time period
    final periodStart = entries.first.date;
    final periodEnd = entries.last.date;

    // Calculate category proportions
    double totalWithdrawals = 0;
    double totalContext = 0;
    double totalDecisions = 0;
    double totalFocus = 0;
    double totalPersistent = 0;

    for (final entry in entries) {
      totalWithdrawals += entry.totalWithdrawals;
      totalContext += entry.components.contextCost;
      totalDecisions += entry.components.decisionCost;
      totalFocus += entry.components.focusWorkCost;
      totalPersistent += entry.persistentDebt;
    }

    // Pattern flags
    final consecutiveDeficits =
        entries.where((e) => e.closingBalance < 0).length >= 3;
    final hasReducedCapacity = entries.any((e) => e.openingBalance < 100);
    final recoveryImprovement = trends.recoveryRatio > 0.4 &&
        entries.last.totalDeposits > entries.first.totalDeposits;

    return TrendSummaryForReflection(
      periodStart: periodStart,
      periodEnd: periodEnd,
      daysAnalyzed: entries.length,
      avgBalance: trends.avgClosingBalance,
      trendDirection: trends.trendDirection.name.toUpperCase(),
      dominantState: _getDominantState(entries),
      contextSwitchingPct:
          totalWithdrawals > 0 ? (totalContext / totalWithdrawals * 100) : 0,
      decisionMakingPct:
          totalWithdrawals > 0 ? (totalDecisions / totalWithdrawals * 100) : 0,
      focusWorkPct:
          totalWithdrawals > 0 ? (totalFocus / totalWithdrawals * 100) : 0,
      persistentLoadPct:
          totalWithdrawals > 0 ? (totalPersistent / totalWithdrawals * 100) : 0,
      avgRecoveryRatio: trends.recoveryRatio,
      recoveryTrend:
          _getRecoveryTrend(entries), // Simple heuristic based on trend
      hasConsecutiveDeficits: consecutiveDeficits,
      hasReducedCapacity: hasReducedCapacity,
      showsRecoveryImprovement: recoveryImprovement,
    );
  }

  /// Helper: Determine dominant cognitive state
  static String _getDominantState(List<LedgerEntry> entries) {
    final stateCounts = <CognitiveState, int>{};

    for (final entry in entries) {
      final state = entry.cognitiveState;
      stateCounts[state] = (stateCounts[state] ?? 0) + 1;
    }

    // Find most common state
    var maxCount = 0;
    CognitiveState? dominant;

    stateCounts.forEach((state, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = state;
      }
    });

    return dominant?.name.toUpperCase() ?? 'MODERATE';
  }

  /// Helper: Determine recovery trend (simple heuristic)
  static String _getRecoveryTrend(List<LedgerEntry> entries) {
    if (entries.length < 3) return 'STABLE';

    final firstHalf = entries.sublist(0, entries.length ~/ 2);
    final secondHalf = entries.sublist(entries.length ~/ 2);

    final firstAvg =
        firstHalf.map((e) => e.totalDeposits).reduce((a, b) => a + b) /
            firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.totalDeposits).reduce((a, b) => a + b) /
            secondHalf.length;

    if (secondAvg > firstAvg * 1.15) return 'IMPROVING';
    if (secondAvg < firstAvg * 0.85) return 'DECLINING';
    return 'STABLE';
  }
}
