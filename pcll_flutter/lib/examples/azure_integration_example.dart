// EXAMPLE: Azure Insights Integration in Trends Screen

import 'package:flutter/material.dart';
import '../core/services/azure_insights_service.dart';
import '../core/models/azure_models.dart';
import '../core/models/models.dart';
import '../core/theme/app_theme.dart';

class TrendsScreenWithAzure extends StatefulWidget {
  const TrendsScreenWithAzure({Key? key}) : super(key: key);

  @override
  State<TrendsScreenWithAzure> createState() => _TrendsScreenWithAzureState();
}

class _TrendsScreenWithAzureState extends State<TrendsScreenWithAzure> {
  final _azureService = AzureInsightsService();

  AzureInsightResponse? _azureInsights;
  bool _isLoadingAzure = false;
  String? _azureError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TRENDS')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // EXISTING CONTENT (unchanged)
            _buildWeeklyChart(),
            _buildTrendIndicators(),
            _buildRuleBasedInsights(),

            // NEW: Optional Azure Insights Section
            if (_azureService.isAvailable) _buildAzureInsightsSection(),
          ],
        ),
      ),
    );
  }

  /// Optional Azure Insights Card
  Widget _buildAzureInsightsSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: const Icon(Icons.psychology_outlined),
            title: const Text('Natural Language Summary'),
            subtitle: const Text('AI-generated reflection (optional)'),
            trailing: _isLoadingAzure
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generateAzureInsights,
                    tooltip: 'Generate new summary',
                  ),
          ),

          const Divider(),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAzureContent(),
          ),

          // Disclaimer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Generated from aggregate trend data. Not a diagnosis or advice.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzureContent() {
    // Error state
    if (_azureError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 20),
              const SizedBox(width: PCLLSpacing.sm),
              Expanded(
                child: Text(
                  'Unable to generate summary: $_azureError',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.sm),
          TextButton.icon(
            onPressed: _generateAzureInsights,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    // No insights yet
    if (_azureInsights == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get an AI-generated natural language summary of your weekly patterns.',
          ),
          const SizedBox(height: PCLLSpacing.smd),
          ElevatedButton.icon(
            onPressed: _isLoadingAzure ? null : _generateAzureInsights,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Generate Summary'),
          ),
        ],
      );
    }

    // Display insights
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cache indicator
        if (_azureInsights!.fromCache)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: PCLLSpacing.xs),
                Text(
                  'Cached from ${_formatTimestamp(_azureInsights!.timestamp)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),

        // Observations
        ...(_azureInsights!.observations.asMap().entries.map((entry) {
          final index = entry.key;
          final observation = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}.',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: PCLLSpacing.sm),
                Expanded(
                  child: Text(
                    observation,
                    style: const TextStyle(height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList()),
      ],
    );
  }

  /// Generate Azure insights from current trends
  Future<void> _generateAzureInsights() async {
    if (!_azureService.isAvailable) return;

    setState(() {
      _isLoadingAzure = true;
      _azureError = null;
    });

    try {
      // Get current entries (from existing state)
      final entries = _getCurrentWeekEntries(); // Your existing method

      if (entries.isEmpty) {
        setState(() {
          _azureError = 'No data available';
          _isLoadingAzure = false;
        });
        return;
      }

      // Calculate trends from entries
      // TODO: Replace with your actual trends calculation logic
      final avgOpening =
          entries.map((e) => e.openingBalance).reduce((a, b) => a + b) /
              entries.length.toDouble();
      final avgClosing =
          entries.map((e) => e.closingBalance).reduce((a, b) => a + b) /
              entries.length.toDouble();
      final avgWithdrawals =
          entries.map((e) => e.totalWithdrawals).reduce((a, b) => a + b) /
              entries.length.toDouble();
      final avgDeposits =
          entries.map((e) => e.totalDeposits).reduce((a, b) => a + b) /
              entries.length.toDouble();
      final deficitDays = entries.where((e) => e.closingBalance < 0).length;
      final totalDeposits =
          entries.map((e) => e.totalDeposits).reduce((a, b) => a + b);
      final totalWithdrawals =
          entries.map((e) => e.totalWithdrawals).reduce((a, b) => a + b);
      final recoveryRatio = totalDeposits > 0
          ? (totalWithdrawals / totalDeposits).toDouble()
          : 0.0;

      final trends = WeeklyTrends(
        avgOpeningBalance: avgOpening,
        avgClosingBalance: avgClosing,
        avgWithdrawals: avgWithdrawals,
        avgDeposits: avgDeposits,
        deficitDays: deficitDays,
        recoveryRatio: recoveryRatio,
        trendDirection: avgClosing > avgOpening
            ? TrendDirection.improving
            : TrendDirection.declining,
        balanceSlope: (avgClosing - avgOpening) / entries.length.toDouble(),
        daysAnalyzed: entries.length,
        startDate: entries.first.date,
        endDate: entries.last.date,
      );

      // Build summary (this is the ONLY data sent to Azure)
      final summary = AzureInsightsService.buildSummaryFromTrends(
        entries: entries,
        trends: trends,
      );

      // Call Azure OpenAI
      final insights = await _azureService.getReflection(summary);

      setState(() {
        _azureInsights = insights;
        _isLoadingAzure = false;
      });
    } catch (e) {
      setState(() {
        _azureError = e.toString();
        _isLoadingAzure = false;
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Placeholder methods - replace with your actual implementation
  List<LedgerEntry> _getCurrentWeekEntries() => [];

  // Stub method - implement based on your TrendsScreen structure
  Widget _buildWeeklyChart() => Container();
  Widget _buildTrendIndicators() => Container();
  Widget _buildRuleBasedInsights() => Container();
}

// USAGE NOTES:
