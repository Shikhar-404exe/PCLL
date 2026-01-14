/*
 * Profile Provider
 * ================
 * 
 * Manages user profile state and persistence with SharedPreferences.
 */

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  static const String _profileKey = 'user_profile';

  UserProfile _profile = const UserProfile();
  bool _isLoading = false;
  bool _isInitialized = false;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isProfileComplete =>
      _profile.age != null && _profile.workType != null;

  /// Get the baseline load modifier from profile
  double get baselineLoadModifier => _profile.baselineLoadModifier;

  /// Get the recovery modifier from profile
  double get recoveryModifier => _profile.recoveryModifier;

  /// Update the profile
  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
    _saveProfile();
  }

  /// Update a single field
  void updateField({
    int? age,
    Gender? gender,
    RelationshipStatus? relationshipStatus,
    int? numberOfKids,
    LivingSituation? livingSituation,
    bool? hasPets,
    int? numberOfPets,
    String? petTypes,
    WorkType? workType,
    WorkEnvironment? workEnvironment,
    String? jobTitle,
    double? commuteDistanceKm,
    int? workDaysPerWeek,
    double? averageWorkHours,
    bool? hasChronicHealth,
    bool? caregivingResponsibilities,
  }) {
    _profile = _profile.copyWith(
      age: age,
      gender: gender,
      relationshipStatus: relationshipStatus,
      numberOfKids: numberOfKids,
      livingSituation: livingSituation,
      hasPets: hasPets,
      numberOfPets: numberOfPets,
      petTypes: petTypes,
      workType: workType,
      workEnvironment: workEnvironment,
      jobTitle: jobTitle,
      commuteDistanceKm: commuteDistanceKm,
      workDaysPerWeek: workDaysPerWeek,
      averageWorkHours: averageWorkHours,
      hasChronicHealth: hasChronicHealth,
      caregivingResponsibilities: caregivingResponsibilities,
    );
    notifyListeners();
    _saveProfile();
  }

  /// Load profile from SharedPreferences
  Future<void> loadProfile() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        _profile = UserProfile.fromJson(json);
        debugPrint('Profile loaded successfully');
      } else {
        debugPrint('No saved profile found, using defaults');
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Keep default profile on error
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Save profile to SharedPreferences
  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = _profile.toJson();
      final jsonString = jsonEncode(json);
      await prefs.setString(_profileKey, jsonString);
      debugPrint('Profile saved successfully');
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  /// Reset profile to defaults and clear storage
  Future<void> resetProfile() async {
    _profile = const UserProfile();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      debugPrint('Profile reset and cleared from storage');
    } catch (e) {
      debugPrint('Error clearing profile from storage: $e');
    }
  }
}
