/*
 * User Profile Model
 * ==================
 * 
 * Personal information that affects cognitive load calculations.
 * These factors influence baseline capacity and recovery rates.
 */

enum Gender { male, female, other, preferNotToSay }

enum RelationshipStatus {
  single,
  inRelationship,
  married,
  marriedWithKids,
  divorced,
  widowed,
}

enum LivingSituation {
  alone,
  withRoommates,
  withParents,
  withWife,
  withWifeAndKids,
  withWifeKidsAndParents,
}

enum WorkType {
  unemployed,
  student,
  partTime,
  fullTime,
  selfEmployed,
  freelancer,
  retired,
}

enum WorkEnvironment {
  office,
  remote,
  hybrid,
  fieldWork,
  shifts,
}

class UserProfile {
  final int? age;
  final Gender? gender;
  final RelationshipStatus? relationshipStatus;
  final int numberOfKids;
  final LivingSituation? livingSituation;
  final bool hasPets;
  final int numberOfPets;
  final String? petTypes; // e.g., "dog, cat"
  final WorkType? workType;
  final WorkEnvironment? workEnvironment;
  final String? jobTitle;
  final double commuteDistanceKm;
  final int workDaysPerWeek;
  final double averageWorkHours;
  final bool hasChronicHealth;
  final bool caregivingResponsibilities;

  const UserProfile({
    this.age,
    this.gender,
    this.relationshipStatus,
    this.numberOfKids = 0,
    this.livingSituation,
    this.hasPets = false,
    this.numberOfPets = 0,
    this.petTypes,
    this.workType,
    this.workEnvironment,
    this.jobTitle,
    this.commuteDistanceKm = 0,
    this.workDaysPerWeek = 5,
    this.averageWorkHours = 8,
    this.hasChronicHealth = false,
    this.caregivingResponsibilities = false,
  });

  UserProfile copyWith({
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
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      numberOfKids: numberOfKids ?? this.numberOfKids,
      livingSituation: livingSituation ?? this.livingSituation,
      hasPets: hasPets ?? this.hasPets,
      numberOfPets: numberOfPets ?? this.numberOfPets,
      petTypes: petTypes ?? this.petTypes,
      workType: workType ?? this.workType,
      workEnvironment: workEnvironment ?? this.workEnvironment,
      jobTitle: jobTitle ?? this.jobTitle,
      commuteDistanceKm: commuteDistanceKm ?? this.commuteDistanceKm,
      workDaysPerWeek: workDaysPerWeek ?? this.workDaysPerWeek,
      averageWorkHours: averageWorkHours ?? this.averageWorkHours,
      hasChronicHealth: hasChronicHealth ?? this.hasChronicHealth,
      caregivingResponsibilities:
          caregivingResponsibilities ?? this.caregivingResponsibilities,
    );
  }

  /// Calculate baseline cognitive load modifier based on profile
  /// Returns a multiplier (1.0 = normal, >1.0 = higher load, <1.0 = lower load)
  double get baselineLoadModifier {
    double modifier = 1.0;

    // Kids add significant cognitive load
    if (numberOfKids > 0) {
      modifier += 0.05 * numberOfKids; // +5% per child
    }

    // Living situation affects daily cognitive overhead
    switch (livingSituation) {
      case LivingSituation.alone:
        modifier += 0.0; // Baseline
      case LivingSituation.withRoommates:
        modifier += 0.05; // Social coordination
      case LivingSituation.withParents:
        modifier += 0.04; // Some coordination, but support
      case LivingSituation.withWife:
        modifier += 0.02; // Slight increase but support benefit
      case LivingSituation.withWifeAndKids:
        modifier += 0.08; // Family coordination needed
      case LivingSituation.withWifeKidsAndParents:
        modifier += 0.12; // Multi-generational considerations
      case null:
        break;
    }

    // Pets add some cognitive load (but also recovery benefit)
    if (hasPets && numberOfPets > 0) {
      modifier += 0.02 * numberOfPets;
    }

    // Commute affects cognitive drain
    if (commuteDistanceKm > 0) {
      // Every 10km adds ~2% cognitive load
      modifier += (commuteDistanceKm / 10) * 0.02;
    }

    // Work hours beyond 8 add strain
    if (averageWorkHours > 8) {
      modifier += (averageWorkHours - 8) * 0.03;
    }

    // Work environment factors
    switch (workEnvironment) {
      case WorkEnvironment.office:
        modifier += 0.03; // Commute + social overhead
      case WorkEnvironment.remote:
        modifier += 0.0; // Baseline
      case WorkEnvironment.hybrid:
        modifier += 0.02; // Context switching
      case WorkEnvironment.fieldWork:
        modifier += 0.08; // Physical + travel
      case WorkEnvironment.shifts:
        modifier += 0.10; // Irregular schedule impact
      case null:
        break;
    }

    // Health and caregiving
    if (hasChronicHealth) {
      modifier += 0.10;
    }
    if (caregivingResponsibilities) {
      modifier += 0.15;
    }

    return modifier;
  }

  /// Calculate recovery modifier based on profile
  /// Returns a multiplier (1.0 = normal, >1.0 = better recovery, <1.0 = harder recovery)
  double get recoveryModifier {
    double modifier = 1.0;

    // Pets can improve recovery (companionship)
    if (hasPets) {
      modifier += 0.05;
    }

    // Partner support
    if (relationshipStatus == RelationshipStatus.married ||
        relationshipStatus == RelationshipStatus.inRelationship) {
      modifier += 0.05;
    }

    // Kids reduce recovery time/quality
    if (numberOfKids > 0) {
      modifier -= 0.03 * numberOfKids;
    }

    // Remote work allows better recovery
    if (workEnvironment == WorkEnvironment.remote) {
      modifier += 0.05;
    }

    // Fewer work days = more recovery time
    if (workDaysPerWeek < 5) {
      modifier += (5 - workDaysPerWeek) * 0.03;
    }

    return modifier.clamp(0.5, 1.5);
  }

  /// Get a summary string for display
  String get summaryText {
    final parts = <String>[];

    if (age != null) parts.add('$age years old');
    if (relationshipStatus != null) {
      parts.add(_relationshipLabel(relationshipStatus!));
    }
    if (workType != null && workType != WorkType.unemployed) {
      parts.add(_workTypeLabel(workType!));
    }

    return parts.isEmpty ? 'Profile not set up' : parts.join(' • ');
  }

  String _relationshipLabel(RelationshipStatus status) {
    switch (status) {
      case RelationshipStatus.single:
        return 'Single';
      case RelationshipStatus.inRelationship:
        return 'In a relationship';
      case RelationshipStatus.married:
        return 'Married';
      case RelationshipStatus.marriedWithKids:
        return 'Married with $numberOfKids kid${numberOfKids > 1 ? 's' : ''}';
      case RelationshipStatus.divorced:
        return 'Divorced';
      case RelationshipStatus.widowed:
        return 'Widowed';
    }
  }

  String _workTypeLabel(WorkType type) {
    switch (type) {
      case WorkType.unemployed:
        return 'Unemployed';
      case WorkType.student:
        return 'Student';
      case WorkType.partTime:
        return 'Part-time';
      case WorkType.fullTime:
        return 'Full-time';
      case WorkType.selfEmployed:
        return 'Self-employed';
      case WorkType.freelancer:
        return 'Freelancer';
      case WorkType.retired:
        return 'Retired';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender?.index,
      'relationshipStatus': relationshipStatus?.index,
      'numberOfKids': numberOfKids,
      'livingSituation': livingSituation?.index,
      'hasPets': hasPets,
      'numberOfPets': numberOfPets,
      'petTypes': petTypes,
      'workType': workType?.index,
      'workEnvironment': workEnvironment?.index,
      'jobTitle': jobTitle,
      'commuteDistanceKm': commuteDistanceKm,
      'workDaysPerWeek': workDaysPerWeek,
      'averageWorkHours': averageWorkHours,
      'hasChronicHealth': hasChronicHealth,
      'caregivingResponsibilities': caregivingResponsibilities,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'],
      gender: json['gender'] != null ? Gender.values[json['gender']] : null,
      relationshipStatus: json['relationshipStatus'] != null
          ? RelationshipStatus.values[json['relationshipStatus']]
          : null,
      numberOfKids: json['numberOfKids'] ?? 0,
      livingSituation: json['livingSituation'] != null
          ? LivingSituation.values[json['livingSituation']]
          : null,
      hasPets: json['hasPets'] ?? false,
      numberOfPets: json['numberOfPets'] ?? 0,
      petTypes: json['petTypes'],
      workType:
          json['workType'] != null ? WorkType.values[json['workType']] : null,
      workEnvironment: json['workEnvironment'] != null
          ? WorkEnvironment.values[json['workEnvironment']]
          : null,
      jobTitle: json['jobTitle'],
      commuteDistanceKm: (json['commuteDistanceKm'] ?? 0).toDouble(),
      workDaysPerWeek: json['workDaysPerWeek'] ?? 5,
      averageWorkHours: (json['averageWorkHours'] ?? 8).toDouble(),
      hasChronicHealth: json['hasChronicHealth'] ?? false,
      caregivingResponsibilities: json['caregivingResponsibilities'] ?? false,
    );
  }
}
