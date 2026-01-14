// Tutorial Provider

import 'package:flutter/foundation.dart';

enum TutorialType {
  home,
  entry,
  history,
  trends,
}

class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String? targetKey; // GlobalKey name to highlight
  final PointerPosition pointerPosition;
  final TooltipPosition tooltipPosition;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.targetKey,
    this.pointerPosition = PointerPosition.top,
    this.tooltipPosition = TooltipPosition.bottom,
  });
}

enum PointerPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
  none,
}

enum TooltipPosition {
  top,
  bottom,
  center,
}

class TutorialProvider extends ChangeNotifier {
  final Set<TutorialType> _completedTutorials = {};
  TutorialType? _activeTutorial;
  int _currentStep = 0;
  bool _tutorialsEnabled = true;

  // Getters
  bool get tutorialsEnabled => _tutorialsEnabled;
  TutorialType? get activeTutorial => _activeTutorial;
  int get currentStep => _currentStep;
  bool get isShowingTutorial => _activeTutorial != null;

  bool isTutorialCompleted(TutorialType type) =>
      _completedTutorials.contains(type);

  // Tutorial definitions
  static const Map<TutorialType, List<TutorialStep>> tutorials = {
    TutorialType.home: [
      TutorialStep(
        id: 'home_welcome',
        title: 'Welcome to PCLL',
        description:
            'Your Personal Cognitive Load Ledger tracks mental energy like a bank account. Let\'s take a quick tour.',
        pointerPosition: PointerPosition.none,
        tooltipPosition: TooltipPosition.center,
      ),
      TutorialStep(
        id: 'home_balance',
        title: 'Your Balance',
        description:
            'This shows your current cognitive balance in CU (Cognitive Units). Positive means you have reserves, negative means you\'re in deficit.',
        targetKey: 'balance_display',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.bottom,
      ),
      TutorialStep(
        id: 'home_state',
        title: 'Cognitive State',
        description:
            'Your state indicates how depleted or well-rested you are based on your balance.',
        targetKey: 'state_indicator',
        pointerPosition: PointerPosition.bottom,
        tooltipPosition: TooltipPosition.bottom,
      ),
      TutorialStep(
        id: 'home_ledger',
        title: 'Today\'s Ledger',
        description:
            'See today\'s transactions: withdrawals (mental costs) and deposits (recovery).',
        targetKey: 'today_ledger',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.bottom,
      ),
      TutorialStep(
        id: 'home_new_entry',
        title: 'Log Your Day',
        description:
            'Tap here to record your daily cognitive activity. Do this each evening for best tracking.',
        targetKey: 'new_entry_button',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.top,
      ),
    ],
    TutorialType.entry: [
      TutorialStep(
        id: 'entry_intro',
        title: 'Daily Entry',
        description:
            'Answer 4 quick questions about your day. This takes about 30 seconds.',
        pointerPosition: PointerPosition.none,
        tooltipPosition: TooltipPosition.center,
      ),
      TutorialStep(
        id: 'entry_slider',
        title: 'Use the Slider',
        description:
            'Drag the slider to indicate your answer. The number updates as you move it.',
        targetKey: 'entry_slider',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.bottom,
      ),
      TutorialStep(
        id: 'entry_navigation',
        title: 'Navigate Questions',
        description:
            'Use Next to proceed, or Back to review previous answers. Submit when done.',
        targetKey: 'entry_navigation',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.top,
      ),
    ],
    TutorialType.history: [
      TutorialStep(
        id: 'history_intro',
        title: 'Ledger History',
        description:
            'This is your cognitive ledger - a record of all past entries like a bank statement.',
        pointerPosition: PointerPosition.none,
        tooltipPosition: TooltipPosition.center,
      ),
      TutorialStep(
        id: 'history_row',
        title: 'Reading Entries',
        description:
            'Each row shows: Date, Opening balance, Withdrawals, Deposits, and Closing balance.',
        targetKey: 'history_header',
        pointerPosition: PointerPosition.bottom,
        tooltipPosition: TooltipPosition.bottom,
      ),
      TutorialStep(
        id: 'history_tap',
        title: 'View Details',
        description:
            'Tap any row to see the full breakdown of that day\'s cognitive transactions.',
        targetKey: 'history_list',
        pointerPosition: PointerPosition.center,
        tooltipPosition: TooltipPosition.bottom,
      ),
    ],
    TutorialType.trends: [
      TutorialStep(
        id: 'trends_intro',
        title: 'Trends & Insights',
        description: 'See patterns in your cognitive balance over time.',
        pointerPosition: PointerPosition.none,
        tooltipPosition: TooltipPosition.center,
      ),
      TutorialStep(
        id: 'trends_chart',
        title: 'Balance Chart',
        description:
            'This chart shows how your balance changes day by day. The dashed line at 0 marks break-even.',
        targetKey: 'trends_chart',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.bottom,
      ),
      TutorialStep(
        id: 'trends_components',
        title: 'Component Breakdown',
        description:
            'See which activities drain your cognitive resources the most.',
        targetKey: 'trends_components',
        pointerPosition: PointerPosition.top,
        tooltipPosition: TooltipPosition.bottom,
      ),
    ],
  };

  List<TutorialStep> get currentSteps {
    if (_activeTutorial == null) return [];
    return tutorials[_activeTutorial] ?? [];
  }

  TutorialStep? get currentTutorialStep {
    final steps = currentSteps;
    if (_currentStep >= steps.length) return null;
    return steps[_currentStep];
  }

  int get totalSteps => currentSteps.length;

  // Start a tutorial if not completed
  void startTutorialIfNeeded(TutorialType type) {
    if (!_tutorialsEnabled) return;
    if (_completedTutorials.contains(type)) return;
    if (_activeTutorial != null) return;

    _activeTutorial = type;
    _currentStep = 0;
    notifyListeners();
  }

  // Force start a tutorial (for replay)
  void startTutorial(TutorialType type) {
    _activeTutorial = type;
    _currentStep = 0;
    notifyListeners();
  }

  // Next step
  void nextStep() {
    if (_activeTutorial == null) return;

    final steps = currentSteps;
    if (_currentStep < steps.length - 1) {
      _currentStep++;
      notifyListeners();
    } else {
      completeTutorial();
    }
  }

  // Previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Complete current tutorial
  void completeTutorial() {
    if (_activeTutorial != null) {
      _completedTutorials.add(_activeTutorial!);
      _activeTutorial = null;
      _currentStep = 0;
      notifyListeners();
    }
  }

  // Skip tutorial
  void skipTutorial() {
    if (_activeTutorial != null) {
      _completedTutorials.add(_activeTutorial!);
      _activeTutorial = null;
      _currentStep = 0;
      notifyListeners();
    }
  }

  // Reset all tutorials
  void resetAllTutorials() {
    _completedTutorials.clear();
    notifyListeners();
  }

  // Toggle tutorials on/off
  void setTutorialsEnabled(bool enabled) {
    _tutorialsEnabled = enabled;
    notifyListeners();
  }
}
