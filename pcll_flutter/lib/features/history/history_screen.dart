// History Screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/providers/tutorial_provider.dart';
import '../../shared/widgets/ledger_card.dart';
import '../../shared/widgets/tutorial_overlay.dart';
import '../../shared/widgets/background_patterns.dart';
import '../entry/edit_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Tutorial target keys
  final _headerRowKey = GlobalKey();
  final _entryRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start tutorial after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TutorialProvider>()
          .startTutorialIfNeeded(TutorialType.history);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TutorialOverlay(
      targetKeys: {
        'header_row': _headerRowKey,
        'entry_row': _entryRowKey,
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ThemedPatternBackground(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  'Ledger History',
                  style: TextStyle(
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.woodDark,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color:
                      isDark ? PCLLColors.textPrimaryDark : PCLLColors.woodDark,
                ),
              ),
              Expanded(
                child: Consumer<LedgerProvider>(
                  builder: (context, ledger, _) {
                    final entries = ledger.entries.reversed.toList();

                    if (entries.isEmpty) {
                      return const _EmptyState();
                    }

                    return Column(
                      children: [
                        // Header row (spreadsheet style) - Tutorial target
                        Container(
                          key: _headerRowKey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? PCLLColors.surfaceAltDark.withOpacity(0.9)
                                : PCLLColors.surfaceAlt.withOpacity(0.9),
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? PCLLColors.borderDark
                                    : PCLLColors.border,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  'DATE',
                                  style: PCLLTypography.labelSmall.copyWith(
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'OPEN',
                                  style: PCLLTypography.labelSmall.copyWith(
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'W/D',
                                  style: PCLLTypography.labelSmall.copyWith(
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'DEP',
                                  style: PCLLTypography.labelSmall.copyWith(
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'CLOSE',
                                  style: PCLLTypography.labelSmall.copyWith(
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Entries list - first entry is tutorial target
                        Expanded(
                          child: ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              // Apply tutorial key to first row
                              if (index == 0) {
                                return Container(
                                  key: _entryRowKey,
                                  child: _LedgerRow(
                                    entry: entry,
                                    onTap: () => _showDetail(context, entry),
                                  ),
                                );
                              }
                              return _LedgerRow(
                                entry: entry,
                                onTap: () => _showDetail(context, entry),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, LedgerEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _EntryDetailSheet(entry: entry),
    );
  }
}

// Ledger row (spreadsheet style)
class _LedgerRow extends StatelessWidget {
  final LedgerEntry entry;
  final VoidCallback onTap;

  const _LedgerRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.parse(entry.date);
    final isDeficit = entry.closingBalance < 0;
    final positiveColor =
        isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: isDark ? PCLLColors.dividerDark : PCLLColors.divider,
          )),
        ),
        child: Row(
          children: [
            // Date
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d').format(date),
                    style: PCLLTypography.labelMedium.copyWith(
                      color: isDark
                          ? PCLLColors.textPrimaryDark
                          : PCLLColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('E').format(date),
                    style: PCLLTypography.labelSmall.copyWith(
                      color: isDark
                          ? PCLLColors.textTertiaryDark
                          : PCLLColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Opening
            Expanded(
              child: Text(
                entry.openingBalance.toStringAsFixed(0),
                style: PCLLTypography.dataSmall.copyWith(
                  color: isDark
                      ? PCLLColors.textPrimaryDark
                      : PCLLColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            // Withdrawals
            Expanded(
              child: Text(
                '-${entry.totalWithdrawals.toStringAsFixed(0)}',
                style: PCLLTypography.dataSmall.copyWith(
                  color: isDark
                      ? PCLLColors.textTertiaryDark
                      : PCLLColors.textTertiary,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            // Deposits
            Expanded(
              child: Text(
                '+${entry.totalDeposits.toStringAsFixed(0)}',
                style: PCLLTypography.dataSmall.copyWith(
                  color:
                      isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            // Closing
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${isDeficit ? '' : '+'}${entry.closingBalance.toStringAsFixed(0)}',
                    style: PCLLTypography.dataMedium.copyWith(
                      color: isDeficit ? PCLLColors.negative : positiveColor,
                    ),
                  ),
                  const SizedBox(width: PCLLSpacing.sm),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark
                        ? PCLLColors.textTertiaryDark
                        : PCLLColors.textTertiary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Entry detail sheet
class _EntryDetailSheet extends StatelessWidget {
  final LedgerEntry entry;

  const _EntryDetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(entry.date);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: PCLLSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: PCLLSpacing.sm),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PCLLColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: PCLLSpacing.lg),

                // Date header
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(date),
                  style: PCLLTypography.headlineMedium,
                ),
                const SizedBox(height: PCLLSpacing.lg),

                // Full ledger card
                LedgerCard(entry: entry, showDetails: true),

                const SizedBox(height: PCLLSpacing.lg),

                // Component breakdown
                Text(
                  'COMPONENT BREAKDOWN',
                  style: PCLLTypography.labelMedium.copyWith(
                    letterSpacing: 1,
                    color: PCLLColors.textTertiary,
                  ),
                ),
                const SizedBox(height: PCLLSpacing.smd),

                _ComponentRow(
                  label: 'Context Switching',
                  value: entry.components.contextCost,
                  isWithdrawal: true,
                ),
                _ComponentRow(
                  label: 'Decision Making',
                  value: entry.components.decisionCost,
                  isWithdrawal: true,
                ),
                _ComponentRow(
                  label: 'Passive Drain',
                  value: entry.components.passiveDrain,
                  isWithdrawal: true,
                ),
                const Divider(height: 24),
                _ComponentRow(
                  label: 'Recovery',
                  value: entry.components.recoveryDeposit,
                  isWithdrawal: false,
                ),

                const SizedBox(height: PCLLSpacing.xl),

                // Edit button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context); // Close detail sheet
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEntryScreen(entry: entry),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Entry'),
                  ),
                ),

                const SizedBox(height: PCLLSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ComponentRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isWithdrawal;

  const _ComponentRow({
    required this.label,
    required this.value,
    required this.isWithdrawal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: PCLLTypography.bodyMedium),
          Text(
            '${isWithdrawal ? '-' : '+'}${value.toStringAsFixed(1)} CU',
            style: PCLLTypography.dataMedium.copyWith(
              color:
                  isWithdrawal ? PCLLColors.textSecondary : PCLLColors.positive,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: PCLLColors.textTertiary),
          const SizedBox(height: PCLLSpacing.md),
          Text(
            'No entries yet',
            style: PCLLTypography.headlineSmall.copyWith(
              color: PCLLColors.textSecondary,
            ),
          ),
          const SizedBox(height: PCLLSpacing.sm),
          Text(
            'Your ledger history will appear here',
            style: PCLLTypography.bodyMedium.copyWith(
              color: PCLLColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
