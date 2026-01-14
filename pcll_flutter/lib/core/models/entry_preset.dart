// Entry Preset Models

/// Preset for quick-logging common day patterns
class EntryPreset {
  final String id;
  final String name;
  final String description;
  final int contextSwitches;
  final int decisions;
  final double focusHours;
  final int unresolvedItems;
  final int avoidedDecisions;
  final int recoveryQuality;
  final bool isCustom;

  const EntryPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.contextSwitches,
    required this.decisions,
    required this.focusHours,
    required this.unresolvedItems,
    required this.avoidedDecisions,
    required this.recoveryQuality,
    this.isCustom = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'contextSwitches': contextSwitches,
        'decisions': decisions,
        'focusHours': focusHours,
        'unresolvedItems': unresolvedItems,
        'avoidedDecisions': avoidedDecisions,
        'recoveryQuality': recoveryQuality,
        'isCustom': isCustom,
      };

  /// Create from JSON
  factory EntryPreset.fromJson(Map<String, dynamic> json) => EntryPreset(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        contextSwitches: json['contextSwitches'] as int,
        decisions: json['decisions'] as int,
        focusHours: (json['focusHours'] as num).toDouble(),
        unresolvedItems: json['unresolvedItems'] as int,
        avoidedDecisions: json['avoidedDecisions'] as int,
        recoveryQuality: json['recoveryQuality'] as int,
        isCustom: json['isCustom'] as bool? ?? false,
      );

  /// Copy with modifications
  EntryPreset copyWith({
    String? id,
    String? name,
    String? description,
    int? contextSwitches,
    int? decisions,
    double? focusHours,
    int? unresolvedItems,
    int? avoidedDecisions,
    int? recoveryQuality,
    bool? isCustom,
  }) =>
      EntryPreset(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        contextSwitches: contextSwitches ?? this.contextSwitches,
        decisions: decisions ?? this.decisions,
        focusHours: focusHours ?? this.focusHours,
        unresolvedItems: unresolvedItems ?? this.unresolvedItems,
        avoidedDecisions: avoidedDecisions ?? this.avoidedDecisions,
        recoveryQuality: recoveryQuality ?? this.recoveryQuality,
        isCustom: isCustom ?? this.isCustom,
      );
}

/// Default presets (user can modify or create their own)
class DefaultPresets {
  static const List<EntryPreset> all = [
    EntryPreset(
      id: 'deep_focus',
      name: 'Deep Focus Day',
      description: 'Long stretches of concentrated work, minimal interruptions',
      contextSwitches: 2,
      decisions: 5,
      focusHours: 6,
      unresolvedItems: 2,
      avoidedDecisions: 1,
      recoveryQuality: 6,
    ),
    EntryPreset(
      id: 'meeting_heavy',
      name: 'Meeting-Heavy Day',
      description: 'Many meetings, frequent context switching, decision-making',
      contextSwitches: 8,
      decisions: 12,
      focusHours: 5,
      unresolvedItems: 4,
      avoidedDecisions: 2,
      recoveryQuality: 4,
    ),
    EntryPreset(
      id: 'scattered',
      name: 'Scattered Day',
      description:
          'Fragmented attention, many interruptions, little focus time',
      contextSwitches: 12,
      decisions: 15,
      focusHours: 3,
      unresolvedItems: 6,
      avoidedDecisions: 4,
      recoveryQuality: 3,
    ),
    EntryPreset(
      id: 'light_day',
      name: 'Light Day',
      description: 'Minimal cognitive load, good recovery',
      contextSwitches: 3,
      decisions: 6,
      focusHours: 2,
      unresolvedItems: 1,
      avoidedDecisions: 0,
      recoveryQuality: 8,
    ),
    EntryPreset(
      id: 'recovery_focus',
      name: 'Recovery-Focused',
      description: 'Prioritizing rest, minimal work, high recovery',
      contextSwitches: 1,
      decisions: 3,
      focusHours: 1,
      unresolvedItems: 1,
      avoidedDecisions: 0,
      recoveryQuality: 9,
    ),
    EntryPreset(
      id: 'crisis_mode',
      name: 'Crisis Mode',
      description: 'High intensity, long hours, many decisions, low recovery',
      contextSwitches: 15,
      decisions: 20,
      focusHours: 8,
      unresolvedItems: 8,
      avoidedDecisions: 5,
      recoveryQuality: 2,
    ),
  ];
}
