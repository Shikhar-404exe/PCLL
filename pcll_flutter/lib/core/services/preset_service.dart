// Preset Service

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry_preset.dart';

class PresetService {
  static const String _presetsKey = 'entry_presets';

  // Singleton
  static final PresetService _instance = PresetService._internal();
  factory PresetService() => _instance;
  PresetService._internal();

  List<EntryPreset> _presets = [];
  bool _initialized = false;

  /// Initialize and load presets
  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final presetsJson = prefs.getString(_presetsKey);

    if (presetsJson == null) {
      // First time - use defaults
      _presets = List.from(DefaultPresets.all);
    } else {
      // Load saved presets
      final List<dynamic> decoded = json.decode(presetsJson);
      _presets = decoded.map((j) => EntryPreset.fromJson(j)).toList();
    }

    _initialized = true;
  }

  /// Get all presets (default + custom)
  List<EntryPreset> getAll() {
    if (!_initialized) throw StateError('PresetService not initialized');
    return List.unmodifiable(_presets);
  }

  /// Add custom preset
  Future<void> addPreset(EntryPreset preset) async {
    if (!_initialized) throw StateError('PresetService not initialized');

    _presets.add(preset.copyWith(isCustom: true));
    await _save();
  }

  /// Update existing preset
  Future<void> updatePreset(String id, EntryPreset updated) async {
    if (!_initialized) throw StateError('PresetService not initialized');

    final index = _presets.indexWhere((p) => p.id == id);
    if (index == -1) throw ArgumentError('Preset not found: $id');

    // Can't modify default presets
    if (!_presets[index].isCustom) {
      throw ArgumentError('Cannot modify default presets');
    }

    _presets[index] = updated;
    await _save();
  }

  /// Delete custom preset
  Future<void> deletePreset(String id) async {
    if (!_initialized) throw StateError('PresetService not initialized');

    final preset = _presets.firstWhere((p) => p.id == id);
    if (!preset.isCustom) {
      throw ArgumentError('Cannot delete default presets');
    }

    _presets.removeWhere((p) => p.id == id);
    await _save();
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    if (!_initialized) throw StateError('PresetService not initialized');

    _presets = List.from(DefaultPresets.all);
    await _save();
  }

  /// Save to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_presets.map((p) => p.toJson()).toList());
    await prefs.setString(_presetsKey, encoded);
  }
}
