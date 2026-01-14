/*
 * Ledger Card Widget
 * ==================
 * 
 * Day's ledger summary card.
 * Shows opening balance, transactions, closing balance.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';

/// Full ledger card showing day's transactions
class LedgerCard extends StatelessWidget {
  final LedgerEntry entry;
  final bool showDetails;
  final VoidCallback? onTap;

  const LedgerCard({
    super.key,
    required this.entry,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDeficit = entry.closingBalance < 0;
    final positiveColor =
        isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? PCLLColors.surfaceDark.withOpacity(0.9)
              : PCLLColors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          border: Border.all(
            color: isDark ? PCLLColors.borderDark : PCLLColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(PCLLSpacing.borderRadius - 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(entry.date),
                    style: PCLLTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? PCLLColors.textPrimaryDark
                          : PCLLColors.textPrimary,
                    ),
                  ),
                  _StateChip(state: entry.cognitiveState),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Opening balance
                  _TransactionRow(
                    label: 'Opening Balance',
                    value: entry.openingBalance,
                    style: TransactionStyle.neutral,
                  ),

                  const SizedBox(height: 12),

                  // Withdrawals section
                  if (showDetails) ...[
                    _TransactionRow(
                      label: 'Context Switching',
                      value: -entry.components.contextCost,
                      style: TransactionStyle.withdrawal,
                      indent: true,
                    ),
                    _TransactionRow(
                      label: 'Decision Making',
                      value: -entry.components.decisionCost,
                      style: TransactionStyle.withdrawal,
                      indent: true,
                    ),
                    _TransactionRow(
                      label: 'Passive Drain',
                      value: -entry.components.passiveDrain,
                      style: TransactionStyle.withdrawal,
                      indent: true,
                    ),
                  ] else
                    _TransactionRow(
                      label: 'Total Withdrawals',
                      value: -entry.totalWithdrawals,
                      style: TransactionStyle.withdrawal,
                    ),

                  const SizedBox(height: 8),

                  // Deposits
                  _TransactionRow(
                    label: showDetails ? 'Recovery Deposit' : 'Total Deposits',
                    value: entry.totalDeposits,
                    style: TransactionStyle.deposit,
                  ),

                  // Divider
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 1,
                    color: isDark ? PCLLColors.borderDark : PCLLColors.border,
                  ),

                  // Closing balance
                  _TransactionRow(
                    label: 'Closing Balance',
                    value: entry.closingBalance,
                    style: isDeficit
                        ? TransactionStyle.deficit
                        : TransactionStyle.surplus,
                    isTotal: true,
                  ),
                ],
              ),
            ),

            // Net change footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDeficit
                    ? PCLLColors.negative.withOpacity(0.05)
                    : positiveColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(PCLLSpacing.borderRadius - 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Net Change: ',
                    style: PCLLTypography.labelSmall.copyWith(
                      color: isDark
                          ? PCLLColors.textTertiaryDark
                          : PCLLColors.textTertiary,
                    ),
                  ),
                  Text(
                    '${entry.netChange >= 0 ? '+' : ''}${entry.netChange.toStringAsFixed(1)} CU',
                    style: PCLLTypography.dataMedium.copyWith(
                      color: entry.netChange >= 0
                          ? positiveColor
                          : PCLLColors.negative,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return DateFormat('EEEE, MMMM d').format(date);
  }
}

/// Compact ledger card (for lists)
class CompactLedgerCard extends StatelessWidget {
  final LedgerEntry entry;
  final VoidCallback? onTap;

  const CompactLedgerCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDeficit = entry.closingBalance < 0;
    final date = DateTime.parse(entry.date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PCLLColors.surface,
          borderRadius: BorderRadius.circular(PCLLSpacing.borderRadius),
          border: Border.all(color: PCLLColors.border),
        ),
        child: Row(
          children: [
            // Date column
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: PCLLTypography.dataLarge,
                  ),
                  Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: PCLLTypography.labelSmall.copyWith(
                      color: PCLLColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: PCLLColors.divider,
            ),

            // Transactions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.remove_circle_outline,
                        size: 14,
                        color: PCLLColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.totalWithdrawals.toStringAsFixed(0)} CU',
                        style: PCLLTypography.labelSmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.add_circle_outline,
                        size: 14,
                        color: PCLLColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.totalDeposits.toStringAsFixed(0)} CU',
                        style: PCLLTypography.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isDeficit ? '' : '+'}${entry.closingBalance.toStringAsFixed(0)}',
                  style: PCLLTypography.dataMedium.copyWith(
                    color:
                        isDeficit ? PCLLColors.negative : PCLLColors.positive,
                  ),
                ),
                Text(
                  'CU',
                  style: PCLLTypography.labelSmall.copyWith(
                    color: PCLLColors.textTertiary,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 20, color: PCLLColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// Transaction row styles
enum TransactionStyle { neutral, withdrawal, deposit, surplus, deficit }

// Transaction row component
class _TransactionRow extends StatelessWidget {
  final String label;
  final double value;
  final TransactionStyle style;
  final bool isTotal;
  final bool indent;

  const _TransactionRow({
    required this.label,
    required this.value,
    required this.style,
    this.isTotal = false,
    this.indent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final positiveColor =
        isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark;

    final (prefix, color) = switch (style) {
      TransactionStyle.neutral => (
          '',
          isDark ? PCLLColors.textPrimaryDark : PCLLColors.textPrimary
        ),
      TransactionStyle.withdrawal => (
          '',
          isDark ? PCLLColors.textSecondaryDark : PCLLColors.textSecondary
        ),
      TransactionStyle.deposit => ('+', positiveColor),
      TransactionStyle.surplus => ('+', positiveColor),
      TransactionStyle.deficit => ('', PCLLColors.negative),
    };

    return Padding(
      padding: EdgeInsets.only(left: indent ? 16 : 0, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? PCLLTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? PCLLColors.textPrimaryDark
                        : PCLLColors.textPrimary,
                  )
                : PCLLTypography.labelMedium.copyWith(
                    color: indent
                        ? (isDark
                            ? PCLLColors.textTertiaryDark
                            : PCLLColors.textTertiary)
                        : (isDark
                            ? PCLLColors.textSecondaryDark
                            : PCLLColors.textSecondary),
                  ),
          ),
          Text(
            '$prefix${value.toStringAsFixed(1)} CU',
            style: isTotal
                ? PCLLTypography.dataLarge.copyWith(color: color)
                : PCLLTypography.dataMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// State chip
class _StateChip extends StatelessWidget {
  final CognitiveState state;

  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      CognitiveState.wellRested => ('WELL RESTED', PCLLColors.zoneGreen),
      CognitiveState.moderate => ('MODERATE', PCLLColors.zoneYellow),
      CognitiveState.depleted => ('DEPLETED', PCLLColors.zoneOrange),
      CognitiveState.deficit => ('DEFICIT', PCLLColors.zoneRed),
      CognitiveState.severeDeficit => ('SEVERE DEFICIT', PCLLColors.zoneRed),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: PCLLTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
