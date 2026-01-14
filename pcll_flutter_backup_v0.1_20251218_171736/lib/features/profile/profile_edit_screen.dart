/*
 * Profile Edit Screen
 * ===================
 * 
 * Allows users to fill in their personal information
 * which affects cognitive load calculations.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/user_profile.dart';
import '../../core/providers/profile_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late UserProfile _editingProfile;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editingProfile = context.read<ProfileProvider>().profile;
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileProvider>().updateProfile(_editingProfile);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PCLLColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: PCLLSpacing.screenPadding,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PCLLColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: PCLLColors.accent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your profile helps personalize cognitive load calculations based on your life circumstances.',
                      style: PCLLTypography.bodySmall.copyWith(
                        color: PCLLColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Info Section
            _SectionHeader(title: 'PERSONAL INFO'),
            const SizedBox(height: 12),
            _buildCard([
              _AgeField(
                value: _editingProfile.age,
                onChanged: (v) => setState(() {
                  _editingProfile = _editingProfile.copyWith(age: v);
                }),
              ),
              const Divider(height: 1),
              _GenderField(
                value: _editingProfile.gender,
                onChanged: (v) => setState(() {
                  _editingProfile = _editingProfile.copyWith(gender: v);
                }),
              ),
            ]),
            const SizedBox(height: 24),

            // Relationship Section
            _SectionHeader(title: 'RELATIONSHIP & FAMILY'),
            const SizedBox(height: 12),
            _buildCard([
              _RelationshipField(
                value: _editingProfile.relationshipStatus,
                onChanged: (v) => setState(() {
                  _editingProfile =
                      _editingProfile.copyWith(relationshipStatus: v);
                }),
              ),
              if (_editingProfile.relationshipStatus ==
                  RelationshipStatus.marriedWithKids) ...[
                const Divider(height: 1),
                _NumberField(
                  label: 'Number of children',
                  value: _editingProfile.numberOfKids,
                  min: 1,
                  max: 10,
                  onChanged: (v) => setState(() {
                    _editingProfile = _editingProfile.copyWith(numberOfKids: v);
                  }),
                ),
              ],
              const Divider(height: 1),
              _LivingSituationField(
                value: _editingProfile.livingSituation,
                onChanged: (v) => setState(() {
                  _editingProfile =
                      _editingProfile.copyWith(livingSituation: v);
                }),
              ),
            ]),
            const SizedBox(height: 24),

            // Pets Section
            _SectionHeader(title: 'PETS'),
            const SizedBox(height: 12),
            _buildCard([
              _SwitchField(
                label: 'Do you have pets?',
                value: _editingProfile.hasPets,
                onChanged: (v) => setState(() {
                  _editingProfile = _editingProfile.copyWith(
                    hasPets: v,
                    numberOfPets: v ? 1 : 0,
                  );
                }),
              ),
              if (_editingProfile.hasPets) ...[
                const Divider(height: 1),
                _NumberField(
                  label: 'Number of pets',
                  value: _editingProfile.numberOfPets,
                  min: 1,
                  max: 10,
                  onChanged: (v) => setState(() {
                    _editingProfile = _editingProfile.copyWith(numberOfPets: v);
                  }),
                ),
                const Divider(height: 1),
                _TextField(
                  label: 'Pet types',
                  hint: 'e.g., dog, cat, fish',
                  value: _editingProfile.petTypes,
                  onChanged: (v) => setState(() {
                    _editingProfile = _editingProfile.copyWith(petTypes: v);
                  }),
                ),
              ],
            ]),
            const SizedBox(height: 24),

            // Work Section
            _SectionHeader(title: 'WORK'),
            const SizedBox(height: 12),
            _buildCard([
              _WorkTypeField(
                value: _editingProfile.workType,
                onChanged: (v) => setState(() {
                  _editingProfile = _editingProfile.copyWith(workType: v);
                }),
              ),
              if (_editingProfile.workType != null &&
                  _editingProfile.workType != WorkType.unemployed &&
                  _editingProfile.workType != WorkType.retired) ...[
                const Divider(height: 1),
                _TextField(
                  label: 'Job title / Field',
                  hint: 'e.g., Software Engineer',
                  value: _editingProfile.jobTitle,
                  onChanged: (v) => setState(() {
                    _editingProfile = _editingProfile.copyWith(jobTitle: v);
                  }),
                ),
                const Divider(height: 1),
                _WorkEnvironmentField(
                  value: _editingProfile.workEnvironment,
                  onChanged: (v) => setState(() {
                    _editingProfile =
                        _editingProfile.copyWith(workEnvironment: v);
                  }),
                ),
                const Divider(height: 1),
                _SliderField(
                  label: 'Work days per week',
                  value: _editingProfile.workDaysPerWeek.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  suffix: 'days',
                  onChanged: (v) => setState(() {
                    _editingProfile =
                        _editingProfile.copyWith(workDaysPerWeek: v.round());
                  }),
                ),
                const Divider(height: 1),
                _SliderField(
                  label: 'Average work hours per day',
                  value: _editingProfile.averageWorkHours,
                  min: 1,
                  max: 16,
                  divisions: 15,
                  suffix: 'hours',
                  onChanged: (v) => setState(() {
                    _editingProfile =
                        _editingProfile.copyWith(averageWorkHours: v);
                  }),
                ),
                const Divider(height: 1),
                _SliderField(
                  label: 'Daily commute (one way)',
                  value: _editingProfile.commuteDistanceKm,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  suffix: 'km',
                  onChanged: (v) => setState(() {
                    _editingProfile =
                        _editingProfile.copyWith(commuteDistanceKm: v);
                  }),
                ),
              ],
            ]),
            const SizedBox(height: 24),

            // Health Section
            _SectionHeader(title: 'ADDITIONAL FACTORS'),
            const SizedBox(height: 12),
            _buildCard([
              _SwitchField(
                label: 'Chronic health condition',
                subtitle: 'Ongoing health issue that affects daily energy',
                value: _editingProfile.hasChronicHealth,
                onChanged: (v) => setState(() {
                  _editingProfile =
                      _editingProfile.copyWith(hasChronicHealth: v);
                }),
              ),
              const Divider(height: 1),
              _SwitchField(
                label: 'Caregiving responsibilities',
                subtitle:
                    'Regularly caring for elderly or disabled family member',
                value: _editingProfile.caregivingResponsibilities,
                onChanged: (v) => setState(() {
                  _editingProfile =
                      _editingProfile.copyWith(caregivingResponsibilities: v);
                }),
              ),
            ]),
            const SizedBox(height: 24),

            // Load Factor Display
            _SectionHeader(title: 'YOUR LOAD FACTORS'),
            const SizedBox(height: 12),
            _buildCard([
              _FactorDisplay(
                label: 'Baseline Load Modifier',
                value: _editingProfile.baselineLoadModifier,
                description:
                    'Multiplier applied to daily cognitive withdrawals',
                isHighBad: true,
              ),
              const Divider(height: 1),
              _FactorDisplay(
                label: 'Recovery Modifier',
                value: _editingProfile.recoveryModifier,
                description:
                    'Multiplier applied to recovery/deposit activities',
                isHighBad: false,
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: PCLLColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PCLLColors.border),
      ),
      child: Column(children: children),
    );
  }
}

// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: PCLLTypography.labelMedium.copyWith(
        letterSpacing: 1,
        color: PCLLColors.textTertiary,
      ),
    );
  }
}

// Age Field
class _AgeField extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _AgeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Age'),
      trailing: SizedBox(
        width: 80,
        child: TextFormField(
          initialValue: value?.toString() ?? '',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.end,
          decoration: const InputDecoration(
            hintText: '—',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => onChanged(int.tryParse(v)),
        ),
      ),
    );
  }
}

// Gender Field
class _GenderField extends StatelessWidget {
  final Gender? value;
  final ValueChanged<Gender?> onChanged;

  const _GenderField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Gender'),
      trailing: DropdownButton<Gender>(
        value: value,
        hint: const Text('Select'),
        underline: const SizedBox(),
        items: Gender.values.map((g) {
          return DropdownMenuItem(
            value: g,
            child: Text(_genderLabel(g)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _genderLabel(Gender g) {
    switch (g) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
      case Gender.preferNotToSay:
        return 'Prefer not to say';
    }
  }
}

// Relationship Field
class _RelationshipField extends StatelessWidget {
  final RelationshipStatus? value;
  final ValueChanged<RelationshipStatus?> onChanged;

  const _RelationshipField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Relationship status'),
      trailing: DropdownButton<RelationshipStatus>(
        value: value,
        hint: const Text('Select'),
        underline: const SizedBox(),
        items: RelationshipStatus.values.map((r) {
          return DropdownMenuItem(
            value: r,
            child: Text(_label(r)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _label(RelationshipStatus r) {
    switch (r) {
      case RelationshipStatus.single:
        return 'Single';
      case RelationshipStatus.inRelationship:
        return 'In a relationship';
      case RelationshipStatus.married:
        return 'Married';
      case RelationshipStatus.marriedWithKids:
        return 'Married with kids';
      case RelationshipStatus.divorced:
        return 'Divorced';
      case RelationshipStatus.widowed:
        return 'Widowed';
    }
  }
}

// Living Situation Field
class _LivingSituationField extends StatelessWidget {
  final LivingSituation? value;
  final ValueChanged<LivingSituation?> onChanged;

  const _LivingSituationField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Living situation'),
      trailing: DropdownButton<LivingSituation>(
        value: value,
        hint: const Text('Select'),
        underline: const SizedBox(),
        items: LivingSituation.values.map((l) {
          return DropdownMenuItem(
            value: l,
            child: Text(_label(l)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _label(LivingSituation l) {
    switch (l) {
      case LivingSituation.alone:
        return 'Alone';
      case LivingSituation.withRoommates:
        return 'With roommates';
      case LivingSituation.withParents:
        return 'With parents';
      case LivingSituation.withWife:
        return 'With wife/partner';
      case LivingSituation.withWifeAndKids:
        return 'Wife + kids';
      case LivingSituation.withWifeKidsAndParents:
        return 'Wife + kids + parents';
    }
  }
}

// Work Type Field
class _WorkTypeField extends StatelessWidget {
  final WorkType? value;
  final ValueChanged<WorkType?> onChanged;

  const _WorkTypeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Employment status'),
      trailing: DropdownButton<WorkType>(
        value: value,
        hint: const Text('Select'),
        underline: const SizedBox(),
        items: WorkType.values.map((w) {
          return DropdownMenuItem(
            value: w,
            child: Text(_label(w)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _label(WorkType w) {
    switch (w) {
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
}

// Work Environment Field
class _WorkEnvironmentField extends StatelessWidget {
  final WorkEnvironment? value;
  final ValueChanged<WorkEnvironment?> onChanged;

  const _WorkEnvironmentField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Work environment'),
      trailing: DropdownButton<WorkEnvironment>(
        value: value,
        hint: const Text('Select'),
        underline: const SizedBox(),
        items: WorkEnvironment.values.map((w) {
          return DropdownMenuItem(
            value: w,
            child: Text(_label(w)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  String _label(WorkEnvironment w) {
    switch (w) {
      case WorkEnvironment.office:
        return 'Office';
      case WorkEnvironment.remote:
        return 'Remote';
      case WorkEnvironment.hybrid:
        return 'Hybrid';
      case WorkEnvironment.fieldWork:
        return 'Field work';
      case WorkEnvironment.shifts:
        return 'Shift work';
    }
  }
}

// Number Field
class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text(
            '$value',
            style: PCLLTypography.dataSmall,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

// Switch Field
class _SwitchField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchField({
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: PCLLTypography.bodySmall.copyWith(
                color: PCLLColors.textTertiary,
              ),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

// Text Field
class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 150,
        child: TextFormField(
          initialValue: value ?? '',
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Slider Field
class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text(
                '${value.round()} $suffix',
                style: PCLLTypography.dataSmall.copyWith(
                  color: PCLLColors.accent,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// Factor Display
class _FactorDisplay extends StatelessWidget {
  final String label;
  final double value;
  final String description;
  final bool isHighBad;

  const _FactorDisplay({
    required this.label,
    required this.value,
    required this.description,
    required this.isHighBad,
  });

  Color get _valueColor {
    if (isHighBad) {
      if (value > 1.2) return Colors.red;
      if (value > 1.1) return Colors.orange;
      return Colors.green;
    } else {
      if (value < 0.8) return Colors.red;
      if (value < 0.9) return Colors.orange;
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        description,
        style: PCLLTypography.bodySmall.copyWith(
          color: PCLLColors.textTertiary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _valueColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${(value * 100).round()}%',
          style: PCLLTypography.dataSmall.copyWith(
            color: _valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
