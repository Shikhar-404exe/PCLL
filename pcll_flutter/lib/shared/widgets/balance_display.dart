// Balance Display Widget

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';

/// Large balance display widget (for home screen hero section)
class BalanceDisplay extends StatelessWidget {
  final double balance;
  final CognitiveState state;
  final bool showLabel;
  final bool animate;

  const BalanceDisplay({
    super.key,
    required this.balance,
    required this.state,
    this.showLabel = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDeficit = balance < 0;

    // In light mode: brown for positive, terracotta for negative
    // In dark mode: mint for positive, terracotta for negative
    final positiveColor =
        isDark ? PCLLColors.accentDarkMode : PCLLColors.woodDark;
    final balanceColor = isDeficit ? PCLLColors.negative : positiveColor;

    // Semantic label for screen readers
    final stateDescription = state == CognitiveState.deficit
        ? 'Deficit'
        : state == CognitiveState.depleted
            ? 'Depleted'
            : state == CognitiveState.moderate
                ? 'Moderate'
                : 'Surplus';
    final balanceDescription =
        '${balance.toStringAsFixed(1)} Cognitive Units. Status: $stateDescription';

    return Semantics(
      label: 'Current balance',
      value: balanceDescription,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            if (showLabel)
              Text(
                'CURRENT BALANCE',
                style: PCLLTypography.labelMedium.copyWith(
                  letterSpacing: 1.5,
                  color: isDark
                      ? PCLLColors.textTertiaryDark
                      : PCLLColors.textTertiary,
                ),
              ),

            if (showLabel) const SizedBox(height: PCLLSpacing.smd),

            // Balance value - HERO ELEMENT (much larger)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isDeficit ? '' : '+',
                        style: TextStyle(
                          fontFamily: PCLLTypography.monoFamily,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2.0,
                          height: 1.0,
                          color: balanceColor,
                        ),
                      ),
                      animate
                          ? _AnimatedBalance(
                              value: balance, color: balanceColor, fontSize: 72)
                          : Text(
                              balance.toStringAsFixed(1),
                              style: TextStyle(
                                fontFamily: PCLLTypography.monoFamily,
                                fontSize: 72,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -2.0,
                                height: 1.0,
                                color: balanceColor,
                              ),
                            ),
                      const SizedBox(width: PCLLSpacing.smd),
                      Text(
                        'CU',
                        style: PCLLTypography.headlineMedium.copyWith(
                          color: isDark
                              ? PCLLColors.textTertiaryDark
                              : PCLLColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: PCLLSpacing.md),

            // State indicator
            _StateIndicator(state: state),
          ],
        ),
      ),
    );
  }
}

/// Compact balance display (for cards, lists)
class CompactBalanceDisplay extends StatelessWidget {
  final double balance;
  final String? label;

  const CompactBalanceDisplay({super.key, required this.balance, this.label});

  @override
  Widget build(BuildContext context) {
    final isDeficit = balance < 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: PCLLTypography.labelSmall.copyWith(
              color: PCLLColors.textTertiary,
            ),
          ),
          const SizedBox(width: PCLLSpacing.sm),
        ],
        Text(
          '${isDeficit ? '' : '+'}${balance.toStringAsFixed(1)}',
          style: PCLLTypography.dataMedium.copyWith(
            color: isDeficit ? PCLLColors.negative : PCLLColors.positive,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          'CU',
          style: PCLLTypography.labelSmall.copyWith(
            color: PCLLColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Inline balance (for table cells)
class InlineBalance extends StatelessWidget {
  final double value;
  final bool showSign;

  const InlineBalance({super.key, required this.value, this.showSign = true});

  @override
  Widget build(BuildContext context) {
    final isNegative = value < 0;
    String text = value.toStringAsFixed(1);
    if (showSign && !isNegative) text = '+$text';

    return Text(
      text,
      style: PCLLTypography.dataMedium.copyWith(
        color: isNegative ? PCLLColors.negative : PCLLColors.positive,
      ),
    );
  }
}

// State indicator pill
class _StateIndicator extends StatelessWidget {
  final CognitiveState state;

  const _StateIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    final (label, color, bgColor) = switch (state) {
      CognitiveState.wellRested => (
          'WELL RESTED',
          PCLLColors.zoneGreen,
          PCLLColors.zoneGreen.withOpacity(0.1),
        ),
      CognitiveState.moderate => (
          'MODERATE',
          PCLLColors.zoneYellow,
          PCLLColors.zoneYellow.withOpacity(0.1),
        ),
      CognitiveState.depleted => (
          'DEPLETED',
          PCLLColors.zoneOrange,
          PCLLColors.zoneOrange.withOpacity(0.1),
        ),
      CognitiveState.deficit => (
          'DEFICIT',
          PCLLColors.zoneRed,
          PCLLColors.zoneRed.withOpacity(0.1),
        ),
      CognitiveState.severeDeficit => (
          'SEVERE DEFICIT',
          PCLLColors.zoneRed,
          PCLLColors.zoneRed.withOpacity(0.1),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: PCLLTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// Animated balance counter
class _AnimatedBalance extends StatefulWidget {
  final double value;
  final Color color;
  final double fontSize;

  const _AnimatedBalance({
    required this.value,
    required this.color,
    this.fontSize = 48,
  });

  @override
  State<_AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<_AnimatedBalance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _setupAnimation();
    _controller.forward();
  }

  void _setupAnimation() {
    _animation = Tween<double>(
      begin: _previousValue,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(_AnimatedBalance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          _animation.value.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: PCLLTypography.monoFamily,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -2.0,
            height: 1.0,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Balance trend mini indicator
class BalanceTrendIndicator extends StatelessWidget {
  final TrendDirection trend;
  final double? changePercent;

  const BalanceTrendIndicator({
    super.key,
    required this.trend,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      TrendDirection.rapidlyImproving => (
          Icons.trending_up,
          PCLLColors.positive
        ),
      TrendDirection.improving => (Icons.trending_up, PCLLColors.positive),
      TrendDirection.declining => (Icons.trending_down, PCLLColors.negative),
      TrendDirection.deteriorating => (
          Icons.trending_down,
          PCLLColors.negative
        ),
      TrendDirection.stable => (Icons.trending_flat, PCLLColors.textTertiary),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        if (changePercent != null) ...[
          const SizedBox(width: PCLLSpacing.xs),
          Text(
            '${changePercent! > 0 ? '+' : ''}${changePercent!.toStringAsFixed(0)}%',
            style: PCLLTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ],
    );
  }
}
