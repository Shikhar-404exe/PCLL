// Settings Provider

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _disclaimerAccepted = false;
  bool _isFirstLaunch = true;
  bool _showDecimals = true;
  bool _showOpeningBalance = true;
  ThemeMode _themeMode =
      ThemeMode.light; // Default to light theme on first boot

  // Accessibility settings
  bool _highContrastMode = false;
  double _textScaleFactor = 1.0; // 1.0 = 100%, 2.0 = 200%
  bool _largerTouchTargets = false;

  bool get disclaimerAccepted => _disclaimerAccepted;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get showDecimals => _showDecimals;
  bool get showOpeningBalance => _showOpeningBalance;
  ThemeMode get themeMode => _themeMode;

  // Accessibility getters
  bool get highContrastMode => _highContrastMode;
  double get textScaleFactor => _textScaleFactor;
  bool get largerTouchTargets => _largerTouchTargets;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  void acceptDisclaimer() {
    _disclaimerAccepted = true;
    _isFirstLaunch = false;
    notifyListeners();
  }

  void setFirstLaunch(bool value) {
    _isFirstLaunch = value;
    notifyListeners();
  }

  void setShowDecimals(bool value) {
    _showDecimals = value;
    notifyListeners();
  }

  void setShowOpeningBalance(bool value) {
    _showOpeningBalance = value;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleDarkMode() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  // Accessibility setters
  void setHighContrastMode(bool value) {
    _highContrastMode = value;
    notifyListeners();
  }

  void setTextScaleFactor(double value) {
    _textScaleFactor = value.clamp(1.0, 2.0);
    notifyListeners();
  }

  void setLargerTouchTargets(bool value) {
    _largerTouchTargets = value;
    notifyListeners();
  }
}
