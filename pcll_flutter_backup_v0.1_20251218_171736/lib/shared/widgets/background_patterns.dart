/*
 * Background Pattern Widgets
 * ==========================
 * 
 * Minimalist nature-inspired background patterns:
 * - Leaf patterns for light mode
 * - Wood grain patterns for dark mode
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';

/// Leaf pattern background for light mode
class LeafPatternBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const LeafPatternBackground({
    super.key,
    required this.child,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          PCLLColors.accentLight,
          PCLLColors.background,
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: CustomPaint(
        painter: _LeafPatternPainter(),
        child: child,
      ),
    );
  }
}

class _LeafPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PCLLColors.accent.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..color = PCLLColors.accent.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    // Draw scattered leaf shapes
    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final rotation = random.nextDouble() * math.pi * 2;
      final scale = 0.5 + random.nextDouble() * 0.8;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.scale(scale);

      _drawMinimalistLeaf(canvas, paint, fillPaint);

      canvas.restore();
    }
  }

  void _drawMinimalistLeaf(Canvas canvas, Paint strokePaint, Paint fillPaint) {
    final path = Path();

    // Simple leaf shape
    path.moveTo(0, -30);
    path.quadraticBezierTo(20, -15, 15, 10);
    path.quadraticBezierTo(5, 25, 0, 30);
    path.quadraticBezierTo(-5, 25, -15, 10);
    path.quadraticBezierTo(-20, -15, 0, -30);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Center vein
    canvas.drawLine(
      const Offset(0, -25),
      const Offset(0, 25),
      strokePaint,
    );

    // Side veins
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final y = i * 8.0;
      final x = (i.abs() == 1) ? 8.0 : 6.0;
      canvas.drawLine(
        Offset(0, y),
        Offset(i > 0 ? x : -x, y - 5),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wood grain pattern background for dark mode
class WoodPatternBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const WoodPatternBackground({
    super.key,
    required this.child,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        [
          PCLLColors.woodDarkMode,
          PCLLColors.backgroundDark,
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: CustomPaint(
        painter: _WoodPatternPainter(),
        child: child,
      ),
    );
  }
}

class _WoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PCLLColors.woodDarkMode.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final random = math.Random(123);

    // Draw horizontal wood grain lines
    for (int i = 0; i < 30; i++) {
      final y = random.nextDouble() * size.height;
      final startX = random.nextDouble() * size.width * 0.3;
      final endX = startX + random.nextDouble() * size.width * 0.7;

      final path = Path();
      path.moveTo(startX, y);

      // Create wavy line for wood grain
      double currentX = startX;
      while (currentX < endX) {
        final nextX = currentX + 20 + random.nextDouble() * 30;
        final ctrlY = y + (random.nextDouble() - 0.5) * 8;
        path.quadraticBezierTo(
          (currentX + nextX) / 2,
          ctrlY,
          math.min(nextX, endX),
          y + (random.nextDouble() - 0.5) * 2,
        );
        currentX = nextX;
      }

      canvas.drawPath(path, paint);
    }

    // Draw subtle knot patterns
    final knotPaint = Paint()
      ..color = PCLLColors.woodDarkMode.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (int i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Concentric ellipses for wood knot
      for (int j = 1; j <= 3; j++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: j * 12.0,
            height: j * 8.0,
          ),
          knotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Themed background that automatically chooses pattern based on brightness
class ThemedPatternBackground extends StatelessWidget {
  final Widget child;

  const ThemedPatternBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return WoodPatternBackground(
        gradientColors: [
          const Color(0xFF3D3228), // Wood brown
          PCLLColors.backgroundDark, // Dark brown
        ],
        child: child,
      );
    } else {
      return LeafPatternBackground(
        gradientColors: [
          PCLLColors.accentLight, // Light mint green
          PCLLColors.accentLight, // Same color for uniform background
        ],
        child: child,
      );
    }
  }
}
