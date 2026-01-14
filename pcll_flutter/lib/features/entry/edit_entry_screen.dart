// Edit Entry Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/ledger_provider.dart';
import '../../shared/widgets/radial_slider.dart';
import '../../shared/widgets/background_patterns.dart';

class EditEntryScreen extends StatefulWidget {
  final LedgerEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Current values (editable)
  late int _contextCount;
  late int _decisionCount;
  late int _focusHours;
  late int _unresolvedCount;
  late int _avoidedCount;
  late int _recoveryQuality;

  // Original values (for reference)
  late int _originalContextCount;
  late int _originalDecisionCount;
  late int _originalFocusHours;
  late int _originalUnresolvedCount;
  late int _originalAvoidedCount;
  late int _originalRecoveryQuality;

  List<_QuestionData> get _questions => [
        _QuestionData(
          question: 'How many different contexts did you work in?',
          description: 'Projects, meetings, task types, or areas of focus',
          minValue: 0,
          maxValue: 20,
          unit: 'contexts',
          category: 'Context',
        ),
        _QuestionData(
          question: 'How many decisions did you make?',
          description: 'Both significant and minor choices',
          minValue: 0,
          maxValue: 50,
          unit: 'decisions',
          category: 'Decisions',
        ),
        _QuestionData(
          question: 'Hours spent in focused work?',
          description: 'Deep, uninterrupted work time',
          minValue: 0,
          maxValue: 16,
          unit: 'hours',
          category: 'Focus',
        ),
        _QuestionData(
          question: 'How many items remain unresolved?',
          description: 'Open tasks, pending decisions, loose ends',
          minValue: 0,
          maxValue: 30,
          unit: 'items',
          category: 'Unresolved',
        ),
        _QuestionData(
          question: 'How many decisions did you avoid?',
          description: 'Deliberately postponed or delayed',
          minValue: 0,
          maxValue: 20,
          unit: 'decisions',
          category: 'Avoided',
        ),
        _QuestionData(
          question: 'Rate your recovery quality',
          description: 'Rest, breaks, and restorative activities',
          minValue: 1,
          maxValue: 10,
          unit: '/10',
          isRating: true,
          inverseColors: true,
          category: 'Recovery',
        ),
      ];

  @override
  void initState() {
    super.initState();
    // Set defaults first (will be replaced if DB load succeeds)
    _contextCount = 5;
    _decisionCount = 8;
    _focusHours = 4;
    _unresolvedCount = 3;
    _avoidedCount = 1;
    _recoveryQuality = 5;

    // Set default originals (same as current)
    _originalContextCount = _contextCount;
    _originalDecisionCount = _decisionCount;
    _originalFocusHours = _focusHours;
    _originalUnresolvedCount = _unresolvedCount;
    _originalAvoidedCount = _avoidedCount;
    _originalRecoveryQuality = _recoveryQuality;

    // Load actual values from database
    _loadOriginalValues();
  }

  Future<void> _loadOriginalValues() async {
    // Get the daily input from the ledger provider
    final dailyInput = await context
        .read<LedgerProvider>()
        .getDailyInputByDate(widget.entry.date);

    if (dailyInput != null) {
      setState(() {
        _contextCount = dailyInput.contextCount;
        _decisionCount = dailyInput.decisionCount;
        _focusHours = dailyInput.focusHours;
        _unresolvedCount = dailyInput.unresolvedCount;
        _avoidedCount = dailyInput.avoidedCount;
        _recoveryQuality = dailyInput.recoveryQuality;

        // Store originals for reference
        _originalContextCount = _contextCount;
        _originalDecisionCount = _decisionCount;
        _originalFocusHours = _focusHours;
        _originalUnresolvedCount = _unresolvedCount;
        _originalAvoidedCount = _avoidedCount;
        _originalRecoveryQuality = _recoveryQuality;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _currentValue {
    switch (_currentPage) {
      case 0:
        return _contextCount;
      case 1:
        return _decisionCount;
      case 2:
        return _focusHours;
      case 3:
        return _unresolvedCount;
      case 4:
        return _avoidedCount;
      case 5:
        return _recoveryQuality;
      default:
        return 0;
    }
  }

  int get _originalValue {
    switch (_currentPage) {
      case 0:
        return _originalContextCount;
      case 1:
        return _originalDecisionCount;
      case 2:
        return _originalFocusHours;
      case 3:
        return _originalUnresolvedCount;
      case 4:
        return _originalAvoidedCount;
      case 5:
        return _originalRecoveryQuality;
      default:
        return 0;
    }
  }

  void _setValue(int value) {
    setState(() {
      switch (_currentPage) {
        case 0:
          _contextCount = value;
        case 1:
          _decisionCount = value;
        case 2:
          _focusHours = value;
        case 3:
          _unresolvedCount = value;
        case 4:
          _avoidedCount = value;
        case 5:
          _recoveryQuality = value;
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _confirmSave();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _confirmSave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Entry?'),
        content: const Text(
          'This will update the historical entry and recalculate all subsequent balances.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _saveEntry();
    }
  }

  Future<void> _saveEntry() async {
    final updatedInput = DailyInput(
      date: widget.entry.date,
      contextCount: _contextCount,
      decisionCount: _decisionCount,
      focusHours: _focusHours,
      unresolvedCount: _unresolvedCount,
      avoidedCount: _avoidedCount,
      recoveryQuality: _recoveryQuality,
    );

    if (!mounted) return;

    // Update entry in ledger provider
    await context.read<LedgerProvider>().updateEntry(
          widget.entry.date,
          updatedInput,
        );

    if (!mounted) return;

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry updated successfully'),
        duration: Duration(seconds: 2),
      ),
    );

    // Return to history
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.parse(widget.entry.date);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ThemedPatternBackground(
        child: Column(
          children: [
            // App bar
            AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Entry'),
                  Text(
                    DateFormat('MMM d, yyyy').format(date),
                    style: PCLLTypography.labelSmall.copyWith(
                      color: isDark
                          ? PCLLColors.textSecondaryDark
                          : PCLLColors.textSecondary,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color:
                      isDark ? PCLLColors.textPrimaryDark : PCLLColors.woodDark,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Progress indicator
            _ProgressBar(
              current: _currentPage + 1,
              total: _questions.length,
            ),

            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _QuestionPage(
                    data: _questions[index],
                    value: _currentValue,
                    originalValue: _originalValue,
                    onChanged: _setValue,
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: PCLLSpacing.screenPadding,
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: PCLLSpacing.smd),
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage < _questions.length - 1
                            ? 'Next'
                            : 'Update Entry',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PCLLSpacing.md),
          ],
        ),
      ),
    );
  }
}

// Question data model
class _QuestionData {
  final String question;
  final String description;
  final int minValue;
  final int maxValue;
  final String unit;
  final bool isRating;
  final bool inverseColors;
  final String category;

  _QuestionData({
    required this.question,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    this.isRating = false,
    this.inverseColors = false,
    required this.category,
  });
}

// Question page widget
class _QuestionPage extends StatelessWidget {
  final _QuestionData data;
  final int value;
  final int originalValue;
  final ValueChanged<int> onChanged;

  const _QuestionPage({
    required this.data,
    required this.value,
    required this.originalValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasChanged = value != originalValue;
    final clampedValue = value.clamp(data.minValue, data.maxValue);

    return SingleChildScrollView(
      padding: PCLLSpacing.screenPadding,
      child: Column(
        children: [
          const SizedBox(height: PCLLSpacing.md),

          // Question
          Text(
            data.question,
            style: PCLLTypography.headlineMedium.copyWith(
              color:
                  isDark ? PCLLColors.textPrimaryDark : PCLLColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PCLLSpacing.xs),

          // Description
          Text(
            data.description,
            style: PCLLTypography.bodyMedium.copyWith(
              color: isDark
                  ? PCLLColors.textSecondaryDark
                  : PCLLColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: PCLLSpacing.lg),

          // Original value indicator
          if (hasChanged)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark
                          ? PCLLColors.accentLightDarkMode
                          : PCLLColors.accentLight)
                      .withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
                  ),
                ),
                child: Text(
                  'Original: $originalValue ${data.unit}',
                  style: PCLLTypography.labelSmall.copyWith(
                    color:
                        isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
                  ),
                ),
              ),
            ),

          // Slider with value in center
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                RadialSlider(
                  value: clampedValue.toDouble(),
                  min: data.minValue.toDouble(),
                  max: data.maxValue.toDouble(),
                  divisions: data.maxValue - data.minValue,
                  inverse: data.inverseColors,
                  size: 220,
                  onChanged: (v) => onChanged(v.round()),
                ),
                // Value display in center
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$clampedValue',
                      style: PCLLTypography.displayLarge.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? PCLLColors.textPrimaryDark
                            : PCLLColors.textPrimary,
                      ),
                    ),
                    Text(
                      data.unit,
                      style: PCLLTypography.labelMedium.copyWith(
                        color: isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: PCLLSpacing.smd),

          // Min/Max labels
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RangeLabel(
                value: data.minValue,
                label: data.inverseColors ? 'Low' : 'Min',
                isGood: data.inverseColors ? false : true,
              ),
              const SizedBox(width: PCLLSpacing.xxl),
              _RangeLabel(
                value: data.maxValue,
                label: data.inverseColors ? 'High' : 'Max',
                isGood: data.inverseColors ? true : false,
              ),
            ],
          ),

          // Quick select buttons for ratings
          if (data.isRating) ...[
            const SizedBox(height: PCLLSpacing.smd),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 1; i <= 10; i++)
                  _RatingButton(
                    value: i,
                    isSelected: clampedValue == i,
                    onTap: () => onChanged(i),
                    inverseColors: data.inverseColors,
                  ),
              ],
            ),
          ],

          const SizedBox(height: PCLLSpacing.md),
        ],
      ),
    );
  }
}

// Progress bar
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = current / total;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: PCLLTypography.labelSmall.copyWith(
                  color: isDark
                      ? PCLLColors.textTertiaryDark
                      : PCLLColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor:
                  isDark ? PCLLColors.borderDark : PCLLColors.border,
              valueColor: AlwaysStoppedAnimation(
                isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Range label widget
class _RangeLabel extends StatelessWidget {
  final int value;
  final String label;
  final bool isGood;

  const _RangeLabel({
    required this.value,
    required this.label,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: PCLLTypography.dataSmall.copyWith(
            color: PCLLColors.textSecondary,
          ),
        ),
        Text(
          label,
          style: PCLLTypography.labelSmall.copyWith(
            color: PCLLColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback onTap;
  final bool inverseColors;

  // Gradient colors matching the radial slider
  static const List<Color> _normalGradient = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
  ];

  static const List<Color> _inverseGradient = [
    Color(0xFFF44336), // Red
    Color(0xFFFF9800), // Orange
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
  ];

  const _RatingButton({
    required this.value,
    required this.isSelected,
    required this.onTap,
    this.inverseColors = false,
  });

  Color _getColorForValue(int val) {
    final gradient = inverseColors ? _inverseGradient : _normalGradient;
    final progress = (val - 1) / 9; // 1-10 range
    final colorIndex = progress * (gradient.length - 1);
    final lowerIndex = colorIndex.floor();
    final upperIndex = colorIndex.ceil().clamp(0, gradient.length - 1);

    if (lowerIndex == upperIndex) {
      return gradient[lowerIndex];
    }

    final t = colorIndex - lowerIndex;
    return Color.lerp(gradient[lowerIndex], gradient[upperIndex], t)!;
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = _getColorForValue(value);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? buttonColor : buttonColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: buttonColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$value',
            style: PCLLTypography.labelSmall.copyWith(
              color: isSelected ? Colors.white : buttonColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
