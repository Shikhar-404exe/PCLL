/*
 * Tutorial Overlay Widget
 * =======================
 * 
 * Interactive tutorial overlay with:
 * - Spotlight highlight on target elements
 * - Step-by-step tooltips
 * - Progress indicator
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/tutorial_provider.dart';

class TutorialOverlay extends StatelessWidget {
  final Widget child;
  final Map<String, GlobalKey> targetKeys;

  const TutorialOverlay({
    super.key,
    required this.child,
    this.targetKeys = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TutorialProvider>(
      builder: (context, tutorial, _) {
        return Stack(
          children: [
            child,
            if (tutorial.isShowingTutorial)
              _TutorialOverlayContent(
                tutorial: tutorial,
                targetKeys: targetKeys,
              ),
          ],
        );
      },
    );
  }
}

class _TutorialOverlayContent extends StatefulWidget {
  final TutorialProvider tutorial;
  final Map<String, GlobalKey> targetKeys;

  const _TutorialOverlayContent({
    required this.tutorial,
    required this.targetKeys,
  });

  @override
  State<_TutorialOverlayContent> createState() =>
      _TutorialOverlayContentState();
}

class _TutorialOverlayContentState extends State<_TutorialOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Rect? _getTargetRect() {
    final step = widget.tutorial.currentTutorialStep;
    if (step?.targetKey == null) return null;

    final key = widget.targetKeys[step!.targetKey];
    if (key?.currentContext == null) return null;

    final RenderBox? box =
        key!.currentContext!.findRenderObject() as RenderBox?;
    if (box == null) return null;

    final position = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      box.size.width,
      box.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.tutorial.currentTutorialStep;
    if (step == null) return const SizedBox.shrink();

    final targetRect = _getTargetRect();
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay with spotlight cutout
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _SpotlightPainter(
                  targetRect: targetRect,
                  pulseScale: _pulseAnimation.value,
                ),
              );
            },
          ),

          // Tooltip
          _buildTooltip(context, step, targetRect, size),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: widget.tutorial.skipTutorial,
              child: Text(
                'Skip Tour',
                style: PCLLTypography.labelMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    TutorialStep step,
    Rect? targetRect,
    Size screenSize,
  ) {
    final safeAreaTop = MediaQuery.of(context).padding.top + 60;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom + 20;
    final maxTooltipHeight = 220.0;

    double? top;
    double? bottom;

    if (step.tooltipPosition == TooltipPosition.center || targetRect == null) {
      // Center position - ensure it's in safe area
      top = (screenSize.height - maxTooltipHeight) / 2;
      top = top.clamp(
          safeAreaTop, screenSize.height - safeAreaBottom - maxTooltipHeight);
    } else if (step.tooltipPosition == TooltipPosition.top) {
      // Position above target
      bottom = screenSize.height - (targetRect.top - 20);
      // Ensure tooltip doesn't go below screen
      if (bottom < safeAreaBottom + maxTooltipHeight) {
        bottom = safeAreaBottom + 20;
      }
      // If bottom positioning would push tooltip off screen, use top positioning instead
      if (bottom > screenSize.height - safeAreaTop - maxTooltipHeight) {
        bottom = null;
        top = safeAreaTop;
      }
    } else {
      // Position below target
      top = targetRect.bottom + 20;
      // Ensure tooltip doesn't go below screen
      if (top + maxTooltipHeight > screenSize.height - safeAreaBottom) {
        // Position above instead
        top = null;
        bottom = screenSize.height - targetRect.top + 20;
        bottom = bottom.clamp(
            safeAreaBottom, screenSize.height - safeAreaTop - maxTooltipHeight);
      }
    }

    return Positioned(
      left: 24,
      right: 24,
      top: top,
      bottom: bottom,
      child: SingleChildScrollView(
        child: _TooltipCard(
          step: step,
          currentStep: widget.tutorial.currentStep,
          totalSteps: widget.tutorial.totalSteps,
          onNext: widget.tutorial.nextStep,
          onPrevious: widget.tutorial.previousStep,
          onSkip: widget.tutorial.skipTutorial,
        ),
      ),
    );
  }
}

// Spotlight painter
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double pulseScale;

  _SpotlightPainter({
    this.targetRect,
    this.pulseScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.85);

    if (targetRect == null) {
      // Full overlay
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    } else {
      // Overlay with spotlight cutout
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

      // Calculate spotlight size with pulse
      final spotlightRect = Rect.fromCenter(
        center: targetRect!.center,
        width: (targetRect!.width + 24) * pulseScale,
        height: (targetRect!.height + 24) * pulseScale,
      );

      path.addRRect(
        RRect.fromRectAndRadius(spotlightRect, const Radius.circular(12)),
      );

      path.fillType = PathFillType.evenOdd;
      canvas.drawPath(path, paint);

      // Spotlight border glow
      final glowPaint = Paint()
        ..color = PCLLColors.accent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRRect(
        RRect.fromRectAndRadius(spotlightRect, const Radius.circular(12)),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseScale != pulseScale;
  }
}

// Tooltip card
class _TooltipCard extends StatelessWidget {
  final TutorialStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  const _TooltipCard({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep >= totalSteps - 1;
    final isFirstStep = currentStep == 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              ...List.generate(totalSteps, (index) {
                return Container(
                  width: index == currentStep ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? PCLLColors.accent
                        : PCLLColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
              const Spacer(),
              Text(
                '${currentStep + 1}/$totalSteps',
                style: PCLLTypography.labelSmall.copyWith(
                  color: PCLLColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            step.title,
            style: PCLLTypography.headlineSmall.copyWith(
              color: PCLLColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            step.description,
            style: PCLLTypography.bodyMedium.copyWith(
              color: PCLLColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Navigation buttons
          Row(
            children: [
              if (!isFirstStep)
                TextButton(
                  onPressed: onPrevious,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: PCLLColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: PCLLTypography.labelMedium.copyWith(
                          color: PCLLColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLastStep ? 'Got it!' : 'Next'),
                    if (!isLastStep) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper widget for wrapping screens with tutorial support
class TutorialTarget extends StatelessWidget {
  final String keyName;
  final GlobalKey tutorialKey;
  final Widget child;

  const TutorialTarget({
    super.key,
    required this.keyName,
    required this.tutorialKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: tutorialKey,
      child: child,
    );
  }
}
