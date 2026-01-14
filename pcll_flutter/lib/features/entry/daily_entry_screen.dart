// Daily Entry Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/models/entry_preset.dart';
import '../../core/services/preset_service.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/providers/tutorial_provider.dart';
import '../../shared/widgets/tutorial_overlay.dart';
import '../../shared/widgets/radial_slider.dart';
import '../../shared/widgets/background_patterns.dart';

class DailyEntryScreen extends StatefulWidget {
  const DailyEntryScreen({super.key});

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Tutorial target keys
  final _sliderKey = GlobalKey();
  final _nextButtonKey = GlobalKey();
  final _progressKey = GlobalKey();

  // Selected preset tracking
  EntryPreset? _selectedPreset;

  // Input values - IMMEDIATE LOAD
  int _contextCount = 5;
  int _decisionCount = 8;
  int _focusHours = 4;

  // Input values - PERSISTENT LOAD
  int _unresolvedCount = 3;
  int _avoidedCount = 1;

  // Input values - RECOVERY
  int _recoveryQuality = 5;

  // Question definitions with color mode
  List<_QuestionData> get _questions => [
        // === IMMEDIATE LOAD QUESTIONS ===
        _QuestionData(
          question: 'How many different contexts did you work in today?',
          description: 'Projects, meetings, task types, or areas of focus',
          minValue: 0,
          maxValue: 20,
          unit: 'contexts',
          inverseColors: false, // More = higher intensity = red
          category: 'Immediate Load',
        ),
        _QuestionData(
          question: 'How many significant decisions did you make?',
          description: 'Choices that required thought or evaluation',
          minValue: 0,
          maxValue: 30,
          unit: 'decisions',
          inverseColors: false, // More = higher intensity = red
          category: 'Immediate Load',
        ),
        _QuestionData(
          question: 'How many hours of deep focus work today?',
          description: 'Meetings, focused study, intensive concentration',
          minValue: 0,
          maxValue: 12,
          unit: 'hours',
          inverseColors: false, // More hours = more drain
          category: 'Immediate Load',
        ),
        // === PERSISTENT LOAD QUESTIONS ===
        _QuestionData(
          question: 'How many items remain unresolved?',
          description: 'Open loops, pending tasks that will carry to tomorrow',
          minValue: 0,
          maxValue: 15,
          unit: 'items',
          inverseColors: false, // More unresolved = bad = red
          category: 'Persistent Load',
        ),
        _QuestionData(
          question: 'How many decisions did you avoid or defer?',
          description: 'Choices you put off that keep cycling in your mind',
          minValue: 0,
          maxValue: 10,
          unit: 'decisions',
          inverseColors: false, // More avoided = worse
          category: 'Persistent Load',
        ),
        // === RECOVERY QUESTION ===
        _QuestionData(
          question: 'Rate your recovery quality',
          description: 'Rest, breaks, and restorative activities',
          minValue: 1,
          maxValue: 10,
          unit: '/10',
          isRating: true,
          inverseColors: true, // Higher recovery = good = blue
          category: 'Recovery',
        ),
      ];

  @override
  void initState() {
    super.initState();
    // Start tutorial after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TutorialProvider>()
          .startTutorialIfNeeded(TutorialType.entry);
    });
  }

  void _applyPreset(EntryPreset preset) {
    setState(() {
      _selectedPreset = preset;
      _contextCount = preset.contextSwitches;
      _decisionCount = preset.decisions;
      _focusHours = preset.focusHours.round();
      _unresolvedCount = preset.unresolvedItems;
      _avoidedCount = preset.avoidedDecisions;
      _recoveryQuality = preset.recoveryQuality;
    });
  }

  void _clearPreset() {
    setState(() {
      _selectedPreset = null;
      // Reset to defaults
      _contextCount = 5;
      _decisionCount = 8;
      _focusHours = 4;
      _unresolvedCount = 3;
      _avoidedCount = 1;
      _recoveryQuality = 5;
    });
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
      _submitEntry();
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

  Future<void> _submitEntry() async {
    final input = DailyInput(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      // Immediate Load
      contextCount: _contextCount,
      decisionCount: _decisionCount,
      focusHours: _focusHours,
      // Persistent Load
      unresolvedCount: _unresolvedCount,
      avoidedCount: _avoidedCount,
      // Recovery
      recoveryQuality: _recoveryQuality,
    );

    final entry = await context.read<LedgerProvider>().addDailyEntry(input);

    if (!mounted) return;

    // Show result and return
    await _showResult(entry);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _showResult(LedgerEntry entry) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultDialog(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TutorialOverlay(
      targetKeys: {
        'slider': _sliderKey,
        'next_button': _nextButtonKey,
        'progress': _progressKey,
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ThemedPatternBackground(
          child: Column(
            children: [
              // App bar
              AppBar(
                title: const Text('Daily Entry'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.woodDark,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Progress indicator - Tutorial target
              Container(
                key: _progressKey,
                child: _ProgressBar(
                    current: _currentPage + 1, total: _questions.length),
              ),

              // Preset selector (with reduced vertical padding)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _PresetSelector(
                  selectedPreset: _selectedPreset,
                  onPresetSelected: _applyPreset,
                  onClearPreset: _clearPreset,
                ),
              ),

              // Questions - Tutorial target for slider
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return _QuestionPage(
                      key: ValueKey('question_$index'),
                      data: _questions[index],
                      value: _currentValue,
                      onChanged: _setValue,
                      sliderKey: index == _currentPage ? _sliderKey : null,
                    );
                  },
                ),
              ),

              // Navigation buttons - Tutorial target
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
                      child: Container(
                        key: _nextButtonKey,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          child: Text(
                            _currentPage < _questions.length - 1
                                ? 'Next'
                                : 'Submit',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PCLLSpacing.sm),
            ],
          ),
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
  final bool
      inverseColors; // If true, high values = blue (good), low = red (bad)
  final String? category; // 'Immediate Load', 'Persistent Load', or 'Recovery'

  const _QuestionData({
    required this.question,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    this.isRating = false,
    this.inverseColors = false,
    this.category,
  });
}

// Progress bar
class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: PCLLTypography.labelMedium,
              ),
              Text(
                '${((current / total) * 100).toInt()}%',
                style: PCLLTypography.labelMedium.copyWith(
                  color: PCLLColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.sm),
          LinearProgressIndicator(
            value: current / total,
            backgroundColor: PCLLColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(PCLLColors.accent),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

// Question page
class _QuestionPage extends StatelessWidget {
  final _QuestionData data;
  final int value;
  final ValueChanged<int> onChanged;
  final GlobalKey? sliderKey;

  const _QuestionPage({
    super.key,
    required this.data,
    required this.value,
    required this.onChanged,
    this.sliderKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Clamp value to valid range
    final clampedValue = value.clamp(data.minValue, data.maxValue);

    return SingleChildScrollView(
      padding: PCLLSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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

          // Radial Slider with value display in center
          Container(
            key: sliderKey,
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

// Result dialog
class _ResultDialog extends StatelessWidget {
  final LedgerEntry entry;

  const _ResultDialog({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDeficit = entry.closingBalance < 0;
    final hasDebt = entry.carryForwardDebt > 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Entry Recorded'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Balance
          Text(
            '${entry.closingBalance >= 0 ? '+' : ''}${entry.closingBalance.toStringAsFixed(1)} CU',
            style: PCLLTypography.displayMedium.copyWith(
              color: isDeficit ? PCLLColors.negative : PCLLColors.positive,
            ),
          ),
          const SizedBox(height: PCLLSpacing.xs),
          Text(
            entry.cognitiveState.label,
            style: PCLLTypography.labelMedium.copyWith(
              color: PCLLColors.textSecondary,
            ),
          ),
          const SizedBox(height: PCLLSpacing.lg),

          // Breakdown - Load Types
          _BreakdownRow(
            label: 'Opening',
            value: '+${entry.openingBalance.toStringAsFixed(1)}',
          ),
          const SizedBox(height: PCLLSpacing.sm),

          // Immediate Load section
          Text(
            'Immediate Load (today only)',
            style: PCLLTypography.labelSmall.copyWith(
              color: PCLLColors.textSecondary,
            ),
          ),
          _BreakdownRow(
            label: '  Context + Decisions + Focus',
            value: '-${entry.immediateLoad.toStringAsFixed(1)}',
            isNegative: true,
          ),

          // Persistent Load section
          Text(
            'Persistent Load (carries forward)',
            style: PCLLTypography.labelSmall.copyWith(
              color: hasDebt ? PCLLColors.warning : PCLLColors.textSecondary,
            ),
          ),
          _BreakdownRow(
            label: '  Unresolved + Avoided',
            value: '-${entry.persistentDebt.toStringAsFixed(1)}',
            isNegative: true,
          ),

          const SizedBox(height: PCLLSpacing.sm),
          _BreakdownRow(
            label: 'Recovery',
            value: '+${entry.totalDeposits.toStringAsFixed(1)}',
          ),
          const Divider(height: 16),
          _BreakdownRow(
            label: 'Closing',
            value:
                '${entry.closingBalance >= 0 ? '+' : ''}${entry.closingBalance.toStringAsFixed(1)}',
            isBold: true,
          ),

          // Show carry-forward debt warning
          if (hasDebt) ...[
            const SizedBox(height: PCLLSpacing.smd),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PCLLColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: PCLLColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: PCLLSpacing.sm),
                  Expanded(
                    child: Text(
                      '${entry.carryForwardDebt.toStringAsFixed(1)} CU debt carries to tomorrow',
                      style: PCLLTypography.labelSmall.copyWith(
                        color: PCLLColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;
  final bool isBold;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.isNegative = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isBold ? PCLLTypography.labelLarge : PCLLTypography.bodyMedium,
          ),
          Text(
            value,
            style:
                (isBold ? PCLLTypography.dataMedium : PCLLTypography.dataSmall)
                    .copyWith(
              color: isNegative ? PCLLColors.textSecondary : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Preset Selector Widget
class _PresetSelector extends StatelessWidget {
  final EntryPreset? selectedPreset;
  final Function(EntryPreset) onPresetSelected;
  final VoidCallback onClearPreset;

  const _PresetSelector({
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onClearPreset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                size: 16,
                color: isDark
                    ? PCLLColors.textSecondaryDark
                    : PCLLColors.textSecondary,
              ),
              const SizedBox(width: PCLLSpacing.sm),
              Text(
                'Quick-log preset',
                style: PCLLTypography.labelSmall.copyWith(
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (selectedPreset != null)
                TextButton(
                  onPressed: onClearPreset,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear',
                    style: PCLLTypography.labelSmall.copyWith(
                      color: PCLLColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: PCLLSpacing.sm),
          if (selectedPreset != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PCLLColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: PCLLColors.accent.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPreset!.name,
                    style: PCLLTypography.labelMedium.copyWith(
                      color: PCLLColors.accent,
                    ),
                  ),
                  const SizedBox(height: PCLLSpacing.xs),
                  Text(
                    selectedPreset!.description,
                    style: PCLLTypography.labelSmall.copyWith(
                      color: isDark
                          ? PCLLColors.textSecondaryDark
                          : PCLLColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: () => _showPresetSelector(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Select a preset to quickly fill values',
                      style: PCLLTypography.bodySmall.copyWith(
                        color: isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDark
                          ? PCLLColors.textSecondaryDark
                          : PCLLColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPresetSelector(BuildContext context) async {
    final service = PresetService();
    await service.initialize();
    final presets = service.getAll();

    if (!context.mounted) return;

    final selected = await showModalBottomSheet<EntryPreset>(
      context: context,
      builder: (context) => _PresetPickerSheet(presets: presets),
    );

    if (selected != null) {
      onPresetSelected(selected);
    }
  }
}

// Preset Picker Bottom Sheet
class _PresetPickerSheet extends StatelessWidget {
  final List<EntryPreset> presets;

  const _PresetPickerSheet({required this.presets});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? PCLLColors.backgroundDark : PCLLColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Select preset',
                  style: PCLLTypography.labelLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Preset list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                return _PresetTile(
                  preset: preset,
                  onTap: () => Navigator.pop(context, preset),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Individual Preset Tile
class _PresetTile extends StatelessWidget {
  final EntryPreset preset;
  final VoidCallback onTap;

  const _PresetTile({
    required this.preset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    preset.name,
                    style: PCLLTypography.labelLarge,
                  ),
                ),
                if (preset.isCustom)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PCLLColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Custom',
                      style: PCLLTypography.labelSmall.copyWith(
                        color: PCLLColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: PCLLSpacing.sm),
            Text(
              preset.description,
              style: PCLLTypography.bodySmall.copyWith(
                color: isDark
                    ? PCLLColors.textSecondaryDark
                    : PCLLColors.textSecondary,
              ),
            ),
            const SizedBox(height: PCLLSpacing.smd),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _PresetValue(
                  label: 'Contexts',
                  value: preset.contextSwitches.toString(),
                ),
                _PresetValue(
                  label: 'Decisions',
                  value: preset.decisions.toString(),
                ),
                _PresetValue(
                  label: 'Focus hrs',
                  value: preset.focusHours.toStringAsFixed(1),
                ),
                _PresetValue(
                  label: 'Unresolved',
                  value: preset.unresolvedItems.toString(),
                ),
                _PresetValue(
                  label: 'Avoided',
                  value: preset.avoidedDecisions.toString(),
                ),
                _PresetValue(
                  label: 'Recovery',
                  value: '${preset.recoveryQuality}/10',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Small value display for preset tiles
class _PresetValue extends StatelessWidget {
  final String label;
  final String value;

  const _PresetValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: PCLLTypography.labelSmall.copyWith(
            color: isDark
                ? PCLLColors.textSecondaryDark
                : PCLLColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: PCLLTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
