/*
 * Settings Provider
 * =================
 * 
 * Manages app settings and user preferences.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _disclaimerAccepted = false;
  bool _isFirstLaunch = true;
  bool _showDecimals = true;
  bool _showOpeningBalance = true;
  ThemeMode _themeMode =
      ThemeMode.light; // Default to light theme on first boot

  bool get disclaimerAccepted => _disclaimerAccepted;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get showDecimals => _showDecimals;
  bool get showOpeningBalance => _showOpeningBalance;
  ThemeMode get themeMode => _themeMode;

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
}
