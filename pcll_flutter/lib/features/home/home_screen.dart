// Home Screen - Main Dashboard

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/ledger_provider.dart';
import '../../core/providers/tutorial_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/azure_insights_service.dart';
import '../entry/daily_entry_screen.dart';
import '../history/history_screen.dart';
import '../trends/trends_screen.dart';
import '../patterns/pattern_report_screen.dart';
import '../auth/login_screen.dart';
import '../profile/profile_edit_screen.dart';
import '../info/how_this_works_screen.dart';
import '../../shared/widgets/balance_display.dart';
import '../../shared/widgets/ledger_card.dart';
import '../../shared/widgets/calm_balance_chart.dart';
import '../../shared/widgets/tutorial_overlay.dart';
import '../../shared/widgets/background_patterns.dart';
import '../../shared/widgets/ai_recommendations_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Tutorial target keys
  final _balanceKey = GlobalKey();
  final _stateKey = GlobalKey();
  final _todayLedgerKey = GlobalKey();
  final _newEntryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Start tutorial after first frame and after preferences are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tutorialProvider = context.read<TutorialProvider>();
      // Wait a bit for SharedPreferences to load
      await Future.delayed(const Duration(milliseconds: 500));
      tutorialProvider.startTutorialIfNeeded(TutorialType.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TutorialOverlay(
      targetKeys: {
        'balance_display': _balanceKey,
        'state_indicator': _stateKey,
        'today_ledger': _todayLedgerKey,
        'new_entry_button': _newEntryKey,
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ThemedPatternBackground(
          child: SafeArea(
            child: Consumer<LedgerProvider>(
              builder: (context, ledger, _) {
                if (ledger.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? PCLLColors.accentDarkMode : PCLLColors.wood,
                      ),
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.transparent,
                      leading: _ProfileButton(),
                      title: Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          final displayName = auth.isAuthenticated &&
                                  auth.user?.displayName != null
                              ? auth.user!.displayName!
                              : 'Guest';
                          return Text(
                            displayName,
                            style: TextStyle(
                              color: isDark
                                  ? PCLLColors.textPrimaryDark
                                  : PCLLColors.woodDark,
                            ),
                          );
                        },
                      ),
                      actions: [
                        _InsightsToggle(),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            size: 22,
                            color: isDark
                                ? PCLLColors.textSecondaryDark
                                : PCLLColors.wood,
                          ),
                          onPressed: () => _showInfo(context),
                        ),
                      ],
                    ),

                    // Content
                    SliverPadding(
                      padding: PCLLSpacing.screenPadding,
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Date header
                          Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: PCLLTypography.bodyMedium.copyWith(
                              color: PCLLColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: PCLLSpacing.lg),

                          // Balance Display (Hero element) - Tutorial target
                          Container(
                            key: _balanceKey,
                            child: BalanceDisplay(
                              balance: ledger.currentBalance,
                              state: ledger.currentState,
                            ),
                          ),
                          const SizedBox(height: PCLLSpacing.xl),

                          // Today's Ledger Card - Tutorial target
                          if (ledger.todayEntry != null) ...[
                            _SectionHeader(title: 'TODAY\'S LEDGER'),
                            const SizedBox(height: PCLLSpacing.smd),
                            Container(
                              key: _todayLedgerKey,
                              child: LedgerCard(entry: ledger.todayEntry!),
                            ),
                            const SizedBox(height: PCLLSpacing.lg),
                          ],

                          // Today's Insight Card
                          if (ledger.todayInsight != null) ...[
                            _SectionHeader(title: 'INSIGHT'),
                            const SizedBox(height: PCLLSpacing.smd),
                            _InsightCard(insight: ledger.todayInsight!),
                            const SizedBox(height: PCLLSpacing.lg),
                          ],

                          // AI Recommendations
                          _SectionHeader(title: 'RECOMMENDATIONS'),
                          const SizedBox(height: PCLLSpacing.smd),
                          const AIRecommendationsCard(),
                          const SizedBox(height: PCLLSpacing.lg),

                          // Weekly Summary
                          if (ledger.weeklyTrends != null) ...[
                            _SectionHeader(title: '7-DAY SUMMARY'),
                            const SizedBox(height: PCLLSpacing.smd),
                            _WeeklySummaryCard(trends: ledger.weeklyTrends!),
                            const SizedBox(height: PCLLSpacing.md),
                            // Calm 7-day balance chart
                            if (ledger.entries.length >= 3)
                              CalmBalanceChart(entries: ledger.entries),
                            const SizedBox(height: PCLLSpacing.lg),
                          ],

                          // Quick Actions - Tutorial target
                          _SectionHeader(title: 'ACTIONS'),
                          const SizedBox(height: PCLLSpacing.smd),
                          Container(
                            key: _newEntryKey,
                            child: _QuickActions(
                              onNewEntry: () => _navigateToEntry(context),
                              onViewHistory: () => _navigateToHistory(context),
                              onViewTrends: () => _navigateToTrends(context),
                              onViewPatterns: () =>
                                  _navigateToPatterns(context),
                            ),
                          ),
                          const SizedBox(height: PCLLSpacing.xl),

                          // Disclaimer footer
                          Text(
                            'This tool tracks self-reported workload patterns. '
                            'Values are estimates using an arbitrary unit system. '
                            'Not a health assessment.',
                            style: PCLLTypography.bodySmall.copyWith(
                              color: PCLLColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: PCLLSpacing.md),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // FAB for new entry
        floatingActionButton: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return FloatingActionButton(
              onPressed: () => _navigateToEntry(context),
              backgroundColor:
                  isDark ? PCLLColors.accentDarkMode : PCLLColors.wood,
              child: Icon(Icons.add,
                  color: isDark ? PCLLColors.backgroundDark : Colors.white),
            );
          },
        ),
      ),
    );
  }

  void _navigateToEntry(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyEntryScreen()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void _navigateToTrends(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TrendsScreen()),
    );
  }

  void _navigateToPatterns(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PatternReportScreen()),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _InfoSheet(),
    );
  }
}

// Profile Button
class _ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final isGuest = auth.isGuest;

        return GestureDetector(
          onTap: () => _showProfileMenu(context, auth),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor:
                  isGuest ? PCLLColors.surfaceAlt : PCLLColors.accent,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Icon(
                      isGuest ? Icons.person_outline : Icons.person,
                      size: 20,
                      color: isGuest ? PCLLColors.textSecondary : Colors.white,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  void _showProfileMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ProfileSheet(auth: auth),
    );
  }
}

// Profile Sheet
class _ProfileSheet extends StatelessWidget {
  final AuthProvider auth;

  const _ProfileSheet({required this.auth});

  @override
  Widget build(BuildContext context) {
    final user = auth.user;
    final isGuest = auth.isGuest;
    final profileProvider = context.watch<ProfileProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final profile = profileProvider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [PCLLColors.surfaceDark, PCLLColors.backgroundDark]
              : [PCLLColors.surface, PCLLColors.accentLight],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: PCLLSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: PCLLSpacing.sm),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? PCLLColors.borderDark : PCLLColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: PCLLSpacing.lg),

            // Profile avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: isGuest
                  ? (isDark ? PCLLColors.surfaceAltDark : PCLLColors.surfaceAlt)
                  : PCLLColors.wood,
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Icon(
                      isGuest ? Icons.person_outline : Icons.person,
                      size: 40,
                      color: isGuest
                          ? (isDark
                              ? PCLLColors.textSecondaryDark
                              : PCLLColors.textSecondary)
                          : Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: PCLLSpacing.md),

            // Name
            Text(
              user?.displayName ?? 'Guest User',
              style: PCLLTypography.headlineSmall.copyWith(
                color: isDark
                    ? PCLLColors.textPrimaryDark
                    : PCLLColors.textPrimary,
              ),
            ),
            if (user?.email != null) ...[
              const SizedBox(height: PCLLSpacing.xs),
              Text(
                user!.email!,
                style: PCLLTypography.bodySmall.copyWith(
                  color: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                ),
              ),
            ],

            // Profile load factors summary
            const SizedBox(height: PCLLSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? PCLLColors.surfaceAltDark : PCLLColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? PCLLColors.borderDark : PCLLColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _LoadFactorChip(
                    label: 'Load',
                    value: profile.baselineLoadModifier,
                    isHighBad: true,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: isDark ? PCLLColors.borderDark : PCLLColors.border,
                  ),
                  _LoadFactorChip(
                    label: 'Recovery',
                    value: profile.recoveryModifier,
                    isHighBad: false,
                  ),
                ],
              ),
            ),

            // Dark mode toggle
            const SizedBox(height: PCLLSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? PCLLColors.surfaceAltDark : PCLLColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? PCLLColors.borderDark : PCLLColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? PCLLColors.woodDarkMode : PCLLColors.wood,
                    size: 22,
                  ),
                  const SizedBox(width: PCLLSpacing.smd),
                  Expanded(
                    child: Text(
                      'Dark Mode',
                      style: PCLLTypography.labelMedium.copyWith(
                        color: isDark
                            ? PCLLColors.textPrimaryDark
                            : PCLLColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: settingsProvider.themeMode == ThemeMode.dark,
                    onChanged: (_) => settingsProvider.toggleDarkMode(),
                    activeColor: PCLLColors.wood,
                    activeTrackColor: PCLLColors.woodLight,
                  ),
                ],
              ),
            ),

            // Edit Profile button
            const SizedBox(height: PCLLSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileEditScreen()),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? PCLLColors.woodDarkMode : PCLLColors.wood,
                  foregroundColor:
                      isDark ? PCLLColors.backgroundDark : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Guest mode banner
            if (isGuest) ...[
              const SizedBox(height: PCLLSpacing.md),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (isDark ? PCLLColors.accentDarkMode : PCLLColors.accent)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (isDark ? PCLLColors.accentDarkMode : PCLLColors.accent)
                            .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isDark
                          ? PCLLColors.accentDarkMode
                          : PCLLColors.accent,
                    ),
                    const SizedBox(width: PCLLSpacing.smd),
                    Expanded(
                      child: Text(
                        'You\'re using PCLL as a guest. Sign in to sync your data.',
                        style: PCLLTypography.bodySmall.copyWith(
                          color: isDark
                              ? PCLLColors.textSecondaryDark
                              : PCLLColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PCLLSpacing.smd),

              // Sign in button for guests
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? PCLLColors.accentDarkMode : PCLLColors.accent,
                    foregroundColor:
                        isDark ? PCLLColors.backgroundDark : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: PCLLSpacing.smd),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: Icon(
                  isGuest ? Icons.exit_to_app : Icons.logout,
                  size: 20,
                ),
                label: Text(isGuest ? 'Exit Guest Mode' : 'Sign Out'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: isDark
                      ? PCLLColors.textSecondaryDark
                      : PCLLColors.textSecondary,
                  side: BorderSide(
                    color: isDark ? PCLLColors.borderDark : PCLLColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: PCLLSpacing.md),
          ],
        ),
      ),
    );
  }
}

// Load Factor Chip for profile summary
class _LoadFactorChip extends StatelessWidget {
  final String label;
  final double value;
  final bool isHighBad;

  const _LoadFactorChip({
    required this.label,
    required this.value,
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
    return Column(
      children: [
        Text(
          label,
          style: PCLLTypography.labelSmall.copyWith(
            color: PCLLColors.textTertiary,
          ),
        ),
        const SizedBox(height: PCLLSpacing.xs),
        Text(
          '${(value * 100).round()}%',
          style: PCLLTypography.dataSmall.copyWith(
            color: _valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

// Weekly Summary Card
class _WeeklySummaryCard extends StatelessWidget {
  final WeeklyTrends trends;

  const _WeeklySummaryCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: PCLLSpacing.cardPadding,
      decoration: BoxDecoration(
        color: PCLLColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PCLLColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Avg. Balance',
                  value: '${trends.avgClosingBalance.toStringAsFixed(0)} CU',
                ),
              ),
              Container(width: 1, height: 40, color: PCLLColors.divider),
              Expanded(
                child: _StatItem(
                  label: 'Trend',
                  value: trends.trendDirection.symbol,
                ),
              ),
              Container(width: 1, height: 40, color: PCLLColors.divider),
              Expanded(
                child: _StatItem(
                  label: 'Deficit Days',
                  value: '${trends.deficitDays}',
                  isNegative: trends.deficitDays > 0,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Avg. Withdrawals',
                  value: '-${trends.avgWithdrawals.toStringAsFixed(0)}',
                ),
              ),
              Container(width: 1, height: 40, color: PCLLColors.divider),
              Expanded(
                child: _StatItem(
                  label: 'Avg. Deposits',
                  value: '+${trends.avgDeposits.toStringAsFixed(0)}',
                ),
              ),
              Container(width: 1, height: 40, color: PCLLColors.divider),
              Expanded(
                child: _StatItem(
                  label: 'Recovery Ratio',
                  value: '${(trends.recoveryRatio * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isNegative;

  const _StatItem({
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: PCLLTypography.dataMedium.copyWith(
            color: isNegative ? PCLLColors.negative : PCLLColors.textPrimary,
          ),
        ),
        const SizedBox(height: PCLLSpacing.xs),
        Text(
          label,
          style: PCLLTypography.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Insight Card - Displays AI-generated insight
class _InsightCard extends StatelessWidget {
  final Insight insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine card styling based on insight type
    final isPositive = insight.isPositive;
    final isWarning = insight.isWarning;

    Color backgroundColor;
    Color borderColor;
    Color iconColor;

    if (isPositive) {
      backgroundColor = isDark
          ? PCLLColors.positive.withValues(alpha: 0.1)
          : PCLLColors.positive.withValues(alpha: 0.08);
      borderColor = PCLLColors.positive.withValues(alpha: 0.3);
      iconColor = PCLLColors.positive;
    } else if (isWarning) {
      backgroundColor = isDark
          ? Colors.orange.withValues(alpha: 0.1)
          : Colors.orange.withValues(alpha: 0.08);
      borderColor = Colors.orange.withValues(alpha: 0.3);
      iconColor = Colors.orange;
    } else {
      backgroundColor = isDark
          ? PCLLColors.accentDarkMode.withValues(alpha: 0.1)
          : PCLLColors.accent.withValues(alpha: 0.08);
      borderColor = isDark
          ? PCLLColors.accentDarkMode.withValues(alpha: 0.3)
          : PCLLColors.accent.withValues(alpha: 0.3);
      iconColor = isDark ? PCLLColors.accentDarkMode : PCLLColors.accent;
    }

    return Container(
      padding: PCLLSpacing.cardPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              insight.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: PCLLSpacing.smd),
          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category label
                Text(
                  insight.category.label.toUpperCase(),
                  style: PCLLTypography.labelSmall.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: PCLLSpacing.xs),
                // Simple explanation (if available)
                if (insight.simpleExplanation != null) ...[
                  Text(
                    insight.simpleExplanation!,
                    style: PCLLTypography.bodyLarge.copyWith(
                      color: isDark
                          ? PCLLColors.textPrimaryDark
                          : PCLLColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: PCLLSpacing.xs),
                ],
                // Detailed message
                Text(
                  insight.message,
                  style: PCLLTypography.bodyMedium.copyWith(
                    color: isDark
                        ? PCLLColors.textSecondaryDark
                        : PCLLColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: PCLLSpacing.sm),
                // Confidence indicator
                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 14,
                      color: isDark
                          ? PCLLColors.textTertiaryDark
                          : PCLLColors.textTertiary,
                    ),
                    const SizedBox(width: PCLLSpacing.xs),
                    Text(
                      'Confidence: ${insight.confidence}%',
                      style: PCLLTypography.labelSmall.copyWith(
                        color: isDark
                            ? PCLLColors.textTertiaryDark
                            : PCLLColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Actions
class _QuickActions extends StatelessWidget {
  final VoidCallback onNewEntry;
  final VoidCallback onViewHistory;
  final VoidCallback onViewTrends;
  final VoidCallback onViewPatterns;

  const _QuickActions({
    required this.onNewEntry,
    required this.onViewHistory,
    required this.onViewTrends,
    required this.onViewPatterns,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.edit_note,
                label: 'New Entry',
                onTap: onNewEntry,
              ),
            ),
            const SizedBox(width: PCLLSpacing.smd),
            Expanded(
              child: _ActionButton(
                icon: Icons.history,
                label: 'History',
                onTap: onViewHistory,
              ),
            ),
          ],
        ),
        const SizedBox(height: PCLLSpacing.smd),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.trending_up,
                label: 'Trends',
                onTap: onViewTrends,
              ),
            ),
            const SizedBox(width: PCLLSpacing.smd),
            Expanded(
              child: _ActionButton(
                icon: Icons.analytics_outlined,
                label: 'Patterns',
                onTap: onViewPatterns,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: PCLLColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PCLLColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: PCLLColors.textSecondary, size: 24),
            const SizedBox(height: PCLLSpacing.sm),
            Text(label, style: PCLLTypography.labelMedium),
          ],
        ),
      ),
    );
  }
}

// Info Sheet
class _InfoSheet extends StatelessWidget {
  const _InfoSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: PCLLSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text('About PCLL', style: PCLLTypography.headlineMedium),
            const SizedBox(height: PCLLSpacing.md),
            Text(
              '100 CU = Full daily cognitive capacity\n\n'
              'Withdrawals: Tasks, decisions, and open items consume CU\n\n'
              'Deposits: Recovery activities restore CU\n\n'
              'Deficits carry over at 20% rate to the next day',
              style: PCLLTypography.bodyMedium,
            ),
            const SizedBox(height: PCLLSpacing.lg),

            // How This Works button
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowThisWorksScreen()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: PCLLColors.accent.withOpacity(0.1),
                  border: Border.all(color: PCLLColors.accent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: PCLLColors.accent,
                    ),
                    const SizedBox(width: PCLLSpacing.sm),
                    Text(
                      'How This Works (Full Explanation)',
                      style: PCLLTypography.labelMedium.copyWith(
                        color: PCLLColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PCLLSpacing.smd),

            // Tutorial replay button
            InkWell(
              onTap: () {
                Navigator.pop(context);
                context.read<TutorialProvider>().resetAllTutorials();
                context
                    .read<TutorialProvider>()
                    .startTutorial(TutorialType.home);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: PCLLColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.replay,
                      size: 20,
                      color: PCLLColors.textSecondary,
                    ),
                    const SizedBox(width: PCLLSpacing.sm),
                    Text(
                      'Replay Tutorial',
                      style: PCLLTypography.labelMedium.copyWith(
                        color: PCLLColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PCLLSpacing.md),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PCLLColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'This is a productivity tracking tool, not a health assessment.',
                style: PCLLTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// INSIGHTS TOGGLE WIDGET
// ============================================================================

/// Toggle between Local and AI insights (like Zomato's veg/non-veg toggle)
class _InsightsToggle extends StatefulWidget {
  const _InsightsToggle();

  @override
  State<_InsightsToggle> createState() => _InsightsToggleState();
}

class _InsightsToggleState extends State<_InsightsToggle> {
  final _azureService = AzureInsightsService();
  bool _isEnabled = false;
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    await _azureService.initialize();
    setState(() {
      _isEnabled = _azureService.isAvailable;
      _isConfigured = _azureService.isAvailable;
    });
  }

  Future<void> _toggleMode() async {
    if (!_isConfigured) {
      // Show setup dialog if not configured
      _showSetupDialog();
      return;
    }

    setState(() => _isEnabled = !_isEnabled);
    await _azureService.setEnabled(_isEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _isEnabled ? Icons.psychology : Icons.psychology_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: PCLLSpacing.sm),
              Text(
                _isEnabled ? 'AI Insights Enabled' : 'Local Insights Only',
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Azure AI Insights'),
        content: const Text(
          'Azure AI Insights is not configured.\n\n'
          'This optional feature generates natural language summaries '
          'from your trend data. Go to Settings to configure.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('GO TO SETTINGS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: _toggleMode,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isEnabled
                ? (isDark ? PCLLColors.accentDarkMode : PCLLColors.wood)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isEnabled
                  ? (isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isEnabled ? Icons.psychology : Icons.psychology_outlined,
                size: 16,
                color: _isEnabled
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
              Text(
                _isEnabled ? 'AI' : 'Local',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isEnabled
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
