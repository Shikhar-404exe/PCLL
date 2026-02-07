// AI Recommendations Widget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/services/recommendations_service.dart';

class AIRecommendationsCard extends StatefulWidget {
  const AIRecommendationsCard({super.key});

  @override
  State<AIRecommendationsCard> createState() => _AIRecommendationsCardState();
}

class _AIRecommendationsCardState extends State<AIRecommendationsCard> {
  final RecommendationsService _recommendationsService =
      RecommendationsService();
  List<String>? _recommendations;
  bool _isLoading = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    await _recommendationsService.initialize();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    final ledger = context.read<LedgerProvider>();
    final currentCU = ledger.currentBalance;
    final state = ledger.currentState;
    final recentEntries = ledger.entries;

    try {
      final recommendations = await _recommendationsService.getRecommendations(
        currentCU: currentCU,
        state: state,
        recentEntries: recentEntries,
      );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_recommendationsService.isAvailable && _recommendations == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: isDark ? PCLLColors.surfaceDark : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? PCLLColors.borderDark : PCLLColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: isDark ? PCLLColors.accentDarkMode : PCLLColors.wood,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Recommendations',
                          style: TextStyle(
                            color: isDark
                                ? PCLLColors.textPrimaryDark
                                : PCLLColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Personalized suggestions for your current state',
                          style: TextStyle(
                            color: isDark
                                ? PCLLColors.textSecondaryDark
                                : PCLLColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: isDark
                          ? PCLLColors.textSecondaryDark
                          : PCLLColors.textSecondary,
                    ),
                    onPressed: _isLoading ? null : _loadRecommendations,
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildRecommendationsList(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? PCLLColors.accentDarkMode : PCLLColors.wood,
            ),
          ),
        ),
      );
    }

    if (_recommendations == null || _recommendations!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No recommendations available at the moment.',
          style: TextStyle(
            color: isDark
                ? PCLLColors.textSecondaryDark
                : PCLLColors.textSecondary,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        ..._recommendations!.asMap().entries.map((entry) {
          final index = entry.key;
          final recommendation = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        (isDark ? PCLLColors.accentDarkMode : PCLLColors.wood)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isDark
                            ? PCLLColors.accentDarkMode
                            : PCLLColors.wood,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      color: isDark
                          ? PCLLColors.textPrimaryDark
                          : PCLLColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (_recommendationsService.isAvailable)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Powered by AI',
                  style: TextStyle(
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
