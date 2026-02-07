// Settings Provider

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  SettingsProvider() {
    _loadSettings();
  }

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
    _saveSettings();
    notifyListeners();
  }

  void setFirstLaunch(bool value) {
    _isFirstLaunch = value;
    _saveSettings();
    notifyListeners();
  }

  void setShowDecimals(bool value) {
    _showDecimals = value;
    _saveSettings();
    notifyListeners();
  }

  void setShowOpeningBalance(bool value) {
    _showOpeningBalance = value;
    _saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    _saveSettings();
    notifyListeners();
  }

  // Accessibility setters
  void setHighContrastMode(bool value) {
    _highContrastMode = value;
    _saveSettings();
    notifyListeners();
  }

  void setTextScaleFactor(double value) {
    _textScaleFactor = value.clamp(1.0, 2.0);
    _saveSettings();
    notifyListeners();
  }

  void setLargerTouchTargets(bool value) {
    _largerTouchTargets = value;
    _saveSettings();
    notifyListeners();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _disclaimerAccepted = prefs.getBool('disclaimer_accepted') ?? false;
      _isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      _showDecimals = prefs.getBool('show_decimals') ?? true;
      _showOpeningBalance = prefs.getBool('show_opening_balance') ?? true;
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
      _highContrastMode = prefs.getBool('high_contrast_mode') ?? false;
      _textScaleFactor = prefs.getDouble('text_scale_factor') ?? 1.0;
      _largerTouchTargets = prefs.getBool('larger_touch_targets') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('disclaimer_accepted', _disclaimerAccepted);
      await prefs.setBool('is_first_launch', _isFirstLaunch);
      await prefs.setBool('show_decimals', _showDecimals);
      await prefs.setBool('show_opening_balance', _showOpeningBalance);
      await prefs.setInt('theme_mode', _themeMode.index);
      await prefs.setBool('high_contrast_mode', _highContrastMode);
      await prefs.setDouble('text_scale_factor', _textScaleFactor);
      await prefs.setBool('larger_touch_targets', _largerTouchTargets);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}
