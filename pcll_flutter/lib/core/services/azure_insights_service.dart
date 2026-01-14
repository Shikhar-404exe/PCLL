// Azure Insights Service

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/azure_models.dart';
import '../models/models.dart';
import '../config/env_config.dart';

/// Service for optional Azure OpenAI integration
class AzureInsightsService {
  // Singleton pattern
  static final AzureInsightsService _instance =
      AzureInsightsService._internal();
  factory AzureInsightsService() => _instance;
  AzureInsightsService._internal();

  // Configuration
  AzureConfig? _config;
  String? _apiKey;
  bool _isEnabled = false;

  // Cache to avoid redundant API calls
  final Map<String, AzureInsightResponse> _cache = {};
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Initialize with configuration
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if feature is enabled (check both env and prefs)
    final envEnabled = EnvConfig.azureEnabled;
    final prefsEnabled = prefs.getBool('azure_insights_enabled');

    // Use env value as default, but allow user override in prefs
    _isEnabled = prefsEnabled ?? envEnabled;

    if (!_isEnabled) return;

    // Try to load from .env first, then fallback to SharedPreferences
    String? endpoint = EnvConfig.azureEndpoint;
    String? deployment = EnvConfig.azureDeployment;
    String? apiKey = EnvConfig.azureApiKey;

    // If not in .env, try SharedPreferences
    if (endpoint.isEmpty || deployment.isEmpty || apiKey.isEmpty) {
      endpoint = prefs.getString('azure_endpoint');
      deployment = prefs.getString('azure_deployment');
      apiKey = prefs.getString('azure_api_key');
    }

    if (endpoint != null &&
        endpoint.isNotEmpty &&
        deployment != null &&
        deployment.isNotEmpty &&
        apiKey != null &&
        apiKey.isNotEmpty) {
      _config = AzureConfig(
        endpoint: endpoint,
        deploymentName: deployment,
      );
      _apiKey = apiKey;
    }
  }

  /// Check if service is available
  bool get isAvailable => _isEnabled && _config != null && _apiKey != null;

  /// Enable/disable the service
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('azure_insights_enabled', enabled);
  }

  /// Configure Azure connection
  Future<void> configure({
    required String endpoint,
    required String deploymentName,
    required String apiKey,
  }) async {
    _config = AzureConfig(
      endpoint: endpoint,
      deploymentName: deploymentName,
    );
    _apiKey = apiKey;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('azure_endpoint', endpoint);
    await prefs.setString('azure_deployment', deploymentName);
    await prefs.setString('azure_api_key', apiKey);
  }

  /// Test connection
  Future<bool> testConnection() async {
    if (!isAvailable) return false;

    try {
      // Create minimal test summary
      final testSummary = TrendSummaryForReflection(
        periodStart: '2025-12-11',
        periodEnd: '2025-12-18',
        daysAnalyzed: 7,
        avgBalance: 50.0,
        trendDirection: 'STABLE',
        dominantState: 'MODERATE',
        contextSwitchingPct: 30,
        decisionMakingPct: 25,
        focusWorkPct: 25,
        persistentLoadPct: 20,
        avgRecoveryRatio: 0.4,
        recoveryTrend: 'STABLE',
        hasConsecutiveDeficits: false,
        hasReducedCapacity: false,
        showsRecoveryImprovement: false,
      );

      await _callAzureAPI(testSummary, bypassCache: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate natural language reflection from trend summary
  /// Returns cached result if available and fresh
  Future<AzureInsightResponse?> getReflection(
    TrendSummaryForReflection summary, {
    bool forceRefresh = false,
  }) async {
    // Check if service is available
    if (!isAvailable) {
      return null;
    }

    // Check cache
    final cacheKey = _getCacheKey(summary);
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      final age = DateTime.now().difference(cached.timestamp);
      if (age < _cacheExpiry) {
        return AzureInsightResponse(
          observations: cached.observations,
          timestamp: cached.timestamp,
          fromCache: true,
        );
      }
    }

    // Call Azure OpenAI
    try {
      final response = await _callAzureAPI(summary);
      _cache[cacheKey] = response; // Cache result
      return response;
    } catch (e) {
      // Fail gracefully - return null, caller handles fallback
      return null;
    }
  }

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
