// AI-Powered Recommendations Service
// DEMO MODE: Uses offline simulation instead of Azure API

import 'dart:math';
import '../models/models.dart';
import '../config/env_config.dart';

/// Service for generating personalized action recommendations based on current CU
/// Uses intelligent simulation for demo purposes
class RecommendationsService {
  static final RecommendationsService _instance =
      RecommendationsService._internal();
  factory RecommendationsService() => _instance;
  RecommendationsService._internal();

  final Random _random = Random();

  /// Initialize with Azure OpenAI configuration
  Future<void> initialize() async {
    // DEMO MODE: No actual initialization needed
  }

  /// Check if service is available (always true for demo simulation)
  bool get isAvailable => true; // DEMO: Always show as AI-powered

  /// Generate personalized recommendations based on current cognitive state
  Future<List<String>> getRecommendations({
    required double currentCU,
    required CognitiveState state,
    List<LedgerEntry>? recentEntries,
  }) async {
    // DEMO MODE: Simulate API delay for authenticity
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    return _getIntelligentSimulatedRecommendations(
      currentCU: currentCU,
      state: state,
      recentEntries: recentEntries,
    );
  }

  /// Analyze trend from recent entries
  String _analyzeTrend(List<LedgerEntry> entries) {
    if (entries.length < 2) return 'new';

    final first = entries.last.closingBalance;
    final last = entries.first.closingBalance;
    final diff = last - first;

    if (diff > 15) return 'rapidly_improving';
    if (diff > 5) return 'improving';
    if (diff < -15) return 'rapidly_declining';
    if (diff < -5) return 'declining';
    return 'stable';
  }

  /// Get average balance from recent entries
  double _getAvgBalance(List<LedgerEntry> entries) {
    if (entries.isEmpty) return 50.0;
    return entries.take(7).fold(0.0, (sum, e) => sum + e.closingBalance) /
        entries.take(7).length;
  }

  /// Count consecutive deficit days
  int _countDeficitDays(List<LedgerEntry> entries) {
    int count = 0;
    for (var entry in entries) {
      if (entry.closingBalance < 0) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  /// DEMO: Intelligent simulated recommendations that adapt to user data
  List<String> _getIntelligentSimulatedRecommendations({
    required double currentCU,
    required CognitiveState state,
    List<LedgerEntry>? recentEntries,
  }) {
    // Analyze context
    String trend = 'stable';
    double avgBalance = currentCU;
    int deficitDays = 0;
    bool hasRecentData = recentEntries != null && recentEntries.isNotEmpty;

    if (hasRecentData) {
      trend = _analyzeTrend(recentEntries);
      avgBalance = _getAvgBalance(recentEntries);
      deficitDays = _countDeficitDays(recentEntries);
    }

    // Select recommendations based on state and context
    List<String> pool = [];

    // Severe Deficit (<-50 CU or multiple deficit days)
    if (currentCU <= -50 || deficitDays >= 3) {
      pool = [
        'Your cognitive reserves are critically depleted. Take the rest of the day off if at all possible',
        'Schedule a full recovery day tomorrow - no work, just rest and activities you enjoy',
        'Consider a 20-30 minute power nap right now to help reset your system',
        'Reach out to someone you trust about redistributing your workload',
        'Go for a 15-minute walk outside without your phone or work thoughts',
        'Order or prepare a nourishing meal - proper nutrition is critical for recovery',
      ];
    }
    // Deficit (0 to -50 CU)
    else if (currentCU < 0) {
      if (trend == 'declining' || trend == 'rapidly_declining') {
        pool = [
          'The declining trend needs immediate attention - block out recovery time today',
          'Cancel or postpone non-critical commitments for the next 24 hours',
          'Take a proper 30-minute lunch break away from your workspace',
          'Set a hard stop time for work today and communicate it to your team',
          'Practice 5 minutes of box breathing (4-4-4-4 pattern) right now',
          'Identify one task you can delegate or defer until your CU improves',
        ];
      } else {
        pool = [
          'You\'re in deficit but stable - prioritize recovery activities this evening',
          'Switch to mindless routine tasks for the rest of the day',
          'Take frequent 5-minute movement breaks every 30 minutes',
          'Stay well hydrated - dehydration worsens cognitive fatigue',
          'Consider ending work an hour early if possible',
          'Prepare for tomorrow by planning light, structured tasks',
        ];
      }
    }
    // Depleted (1-39 CU)
    else if (currentCU < 40) {
      if (trend == 'improving') {
        pool = [
          'You\'re recovering! Keep up the current balance of work and rest',
          'Tackle one medium-priority task, then take a restorative break',
          'Your recovery is working - don\'t push too hard too fast',
          'Schedule recovery blocks into tomorrow to maintain this upward trend',
          'Do a 10-minute stretching routine to support your physical recovery',
        ];
      } else {
        pool = [
          'You\'re running low - save your energy for only essential tasks',
          'Break your next task into 3 smaller chunks with breaks between',
          'This is a good time for administrative work, not creative thinking',
          'Step outside for 10 minutes to get natural light and fresh air',
          'Avoid making any major decisions until your CU rises above 40',
          'Have a healthy snack and water - low energy often links to nutrition',
        ];
      }
    }
    // Moderate (40-69 CU)
    else if (currentCU < 70) {
      if (trend == 'declining') {
        pool = [
          'Your CU is dropping - take preemptive action to prevent deficit',
          'Review your schedule and remove one non-essential commitment',
          'Take a 15-minute walk before tackling your next task',
          'Set boundaries on context switching for the rest of the day',
          'Block out 30 minutes of uninterrupted focus time for your key task',
        ];
      } else if (avgBalance < 50) {
        pool = [
          'You\'re in a good zone but your weekly average is low - pace yourself',
          'Choose moderate-difficulty tasks that won\'t drain you completely',
          'Schedule your hardest task for tomorrow morning when you\'re fresh',
          'Take proactive 10-minute breaks every 90 minutes',
          'Plan something relaxing for this evening to maintain recovery',
        ];
      } else {
        pool = [
          'Solid capacity right now - this is great for collaborative work',
          'Tackle that medium-complexity task you\'ve been putting off',
          'Good time for meetings or brainstorming sessions',
          'Schedule your most challenging work for when you hit peak energy',
          'Take a quick 5-minute mindfulness break to maintain this level',
        ];
      }
    }
    // Well Rested (70+ CU)
    else {
      if (trend == 'improving' || trend == 'rapidly_improving') {
        pool = [
          'Excellent momentum! Channel this energy into your most important project',
          'Perfect time to tackle that complex problem you\'ve been avoiding',
          'Block out 2-3 hours for deep, focused work on high-value tasks',
          'Your cognitive capacity is peak - make strategic decisions now',
          'Use this high-energy period to build systems that reduce future load',
          'Consider mentoring or helping others while your capacity is high',
        ];
      } else {
        pool = [
          'Great energy levels! This is your window for your hardest challenges',
          'Block time for deep focus work on your most important goal',
          'Perfect state for creative problem-solving and strategic thinking',
          'Tackle decisions that require careful analysis and judgment',
          'Build in short breaks to sustain this high performance through the day',
          'Consider batch-processing similar tasks to maximize this productive state',
        ];
      }
    }

    // Add time-aware recommendations
    final hour = DateTime.now().hour;
    if (hour < 12 && currentCU > 40) {
      pool.add(
          'Morning is your peak time - use it for your most cognitively demanding work');
    } else if (hour >= 14 && hour < 17 && currentCU < 60) {
      pool.add(
          'Afternoon slump is normal - take a 10-minute walk or have a healthy snack');
    } else if (hour >= 17 && currentCU < 40) {
      pool.add(
          'Evening and low CU - wrap up work and focus on recovery for tomorrow');
    }

    // Add context-specific recommendations
    if (hasRecentData && deficitDays >= 2) {
      pool.add(
          '${deficitDays} consecutive deficit days detected - recovery must be your top priority');
    }

    if (trend == 'rapidly_declining') {
      pool.add(
          'Rapid decline in progress - identify and remove the biggest energy drain today');
    }

    // Shuffle and return 4-5 recommendations
    pool.shuffle(_random);
    return pool.take(4 + _random.nextInt(2)).toList();
  }
}
